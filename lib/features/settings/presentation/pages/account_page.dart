import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/bannerbars/base_bannerbar.dart';
import 'package:study_aid/common/widgets/buttons/basic_app_button.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/core/utils/validators/validators.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:study_aid/features/authentication/domain/entities/user.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
import 'package:study_aid/features/settings/presentation/providers/account_provider.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isSocialLogin = false;

  final _accountSettingsKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeUserInfo();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _initializeUserInfo() async {
    final authUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      setState(() {
        _isSocialLogin = authUser.providerData.any((provider) => [
              'google.com',
              'facebook.com',
              'apple.com'
            ].contains(provider.providerId));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(accountNotifierProvider);
    final userAsyncValue = ref.watch(userProvider);

    return Scaffold(
      appBar: const BasicAppbar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeadings(
                text: 'Account Settings',
                alignment: TextAlign.left,
              ),
              const SizedBox(height: 20),
              userAsyncValue.when(
                data: (user) => _buildAccountForm(context, user, isSaving),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  Logger().e('Error loading user info',
                      error: error, stackTrace: stack);
                  return const Center(child: Text("Something went wrong!"));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountForm(
      BuildContext context, User? user, AsyncValue<void> isSaving) {
    if (user != null) {
      _usernameController.text = user.username;
    }

    return Form(
      key: _accountSettingsKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField(context,
              label: 'Username',
              controller: _usernameController,
              validator: isValidUsername,
              hintText: 'Username',
              suffixIcon: const Icon(Icons.person),
              triggerValidationOnChange: false),
          if (!_isSocialLogin) ...[
            const SizedBox(height: 20),
            _buildField(
              context,
              label: 'Password',
              controller: _passwordController,
              obscureText: !_passwordVisible,
              validator: (value) =>
                  value?.isNotEmpty ?? false ? validatePassword(value) : null,
              hintText: 'Password',
              suffixIcon: _buildPasswordVisibilityToggle(
                isVisible: _passwordVisible,
                onToggle: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
              ),
            ),
            const SizedBox(height: 20),
            _buildField(
              context,
              label: 'Confirm Password',
              controller: _confirmPasswordController,
              obscureText: !_confirmPasswordVisible,
              validator: (value) => value != _passwordController.text
                  ? "Passwords do not match"
                  : null,
              hintText: 'Confirm Password',
              suffixIcon: _buildPasswordVisibilityToggle(
                isVisible: _confirmPasswordVisible,
                onToggle: () => setState(
                    () => _confirmPasswordVisible = !_confirmPasswordVisible),
              ),
            ),
          ],
          const SizedBox(height: 20),
          BasicAppButton(
            onPressed: () {
              if (isSaving.isLoading) {
                // Log or handle the case where saving is already in progress
                Logger().d("Save in progress, button disabled.");
                return;
              }

              // Validate the form and call _saveChanges if valid
              if (_accountSettingsKey.currentState?.validate() ?? false) {
                Logger()
                    .d("Form validated successfully, calling _saveChanges...");
                _saveChanges(ref, user);
              } else {
                Logger().d("Form validation failed.");
              }
            },
            title: isSaving.isLoading ? "Saving..." : "Save Changes",
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    String? Function(String?)? validator,
    String? hintText,
    Widget? suffixIcon,
    bool triggerValidationOnChange = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field label
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        // Input field
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          onChanged: (_) {
            if (triggerValidationOnChange) {
              _accountSettingsKey.currentState?.validate();
            }
          },
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            hintText: hintText ?? label, // Default hint text to label
          ).applyDefaults(Theme.of(context).inputDecorationTheme),
        ),
      ],
    );
  }

  Widget _buildPasswordVisibilityToggle(
      {required bool isVisible, required VoidCallback onToggle}) {
    return IconButton(
      icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
      onPressed: onToggle,
    );
  }

  Future<void> _saveChanges(WidgetRef ref, User? user) async {
    final toast = CustomToast(context: context);

    if (user == null) {
      toast.showFailure(description: 'User not logged in');
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final usernameChanged = username.isNotEmpty && username != user.username;
    final passwordChanged = !_isSocialLogin && password.isNotEmpty;

    // Ensure at least one field has changed
    if (!usernameChanged && !passwordChanged) {
      toast.showInfo(description: 'No changes made');
      return;
    }

    try {
      final res = await ref.read(accountNotifierProvider.notifier).saveChanges(
            usernameChanged ? user.copyWith(username: username) : null,
            passwordChanged ? password : null,
          );

      // Update username field if changed
      if (usernameChanged) {
        _usernameController.text = username;
      }

      // Clear password fields only if a password update occurred
      if (passwordChanged) {
        _passwordController.clear();
        _confirmPasswordController.clear();
      }

      // Display success messages based on what was updated
      if (res != null) {
        toast.showFailure(description: res.message);
      } else if (usernameChanged && passwordChanged) {
        toast.showSuccess(
            description: 'Username and password updated successfully');
      } else if (usernameChanged) {
        toast.showSuccess(description: 'Username updated successfully');
      } else if (passwordChanged) {
        toast.showSuccess(description: 'Password updated successfully');
      }

      // Refresh user state
      ref.invalidate(userProvider);
    } catch (error, stack) {
      Logger().e('Error saving changes', error: error, stackTrace: stack);
      toast.showFailure(description: 'Failed to update account settings');
    }
  }
}
