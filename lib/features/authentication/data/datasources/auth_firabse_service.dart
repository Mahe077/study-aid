import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/app_logger.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/authentication/data/models/user.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

abstract class RemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(
      String email, String password, String username);
  Future<UserModel?> signInWithGoogle();
  Future<UserModel?> signInWithFacebook();
  Future<UserModel?> signInWithApple();
  Future<void> updateUser(UserModel user);
  Future<UserModel?> getUserById(String id);
  Future<Unit> signOut();
  Future<Unit> resetPassword(String newPassword);
  Future<Unit> sendPasswordResetEmail(String email);
  Future<Either<Failure, void>> updatePassword(String password);
  Future<Either<Failure, void>> updateColor(UserModel user);
  Future<Unit> reauthenticate(String? password);
  Future<Unit> deleteAccount();
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      if (!doc.exists) {
        throw Exception('User data not found. Please contact support.');
      }

      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage =
              'No user found with this email. Please check and try again.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage =
              'The email address is not valid. Please check and try again.';
          break;
        case 'user-disabled':
          errorMessage =
              'This user account has been disabled. Please contact support.';
          break;
        default:
          errorMessage = 'An unknown error occurred. Please try again later.';
      }

      AppLogger.e("Error signing in: ${e.message}"); // Log the detailed error
      throw Exception(errorMessage); // Return user-friendly error
    } catch (e) {
      // Handle unexpected errors
      AppLogger.e("Error signing in: $e");
      throw Exception('An error occurred while signing in. Please try again.');
    }
  }

  @override
  Future<UserModel> signUpWithEmail(
      String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      UserModel user = UserModel(
        id: userCredential.user!.uid,
        username: username,
        email: email,
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
        createdTopics: [],
        syncStatus: ConstantStrings.synced,
        recentItems: [],
        color: AppColors.defaultColor,
      );

      await updateUser(user);
      return user;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'This email is already in use. Please use a different email.';
          break;
        case 'invalid-email':
          errorMessage =
              'The email address is not valid. Please check and try again.';
          break;
        case 'weak-password':
          errorMessage =
              'The password is too weak. Please use a stronger password.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage = 'An unknown error occurred. Please try again later.';
      }

      AppLogger.e("Error signing up: ${e.message}"); // Log the detailed error
      throw Exception(errorMessage); // Return user-friendly error
    } catch (e) {
      // Handle any other unexpected errors
      AppLogger.e("Error signing up: $e");
      throw Exception('An error occurred while signing up. Please try again.');
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toFirestore());
    } on FirebaseException catch (e) {
      // Handle specific Firestore errors
      String errorMessage;

      switch (e.code) {
        case 'permission-denied':
          errorMessage =
              'You do not have permission to update this user. Please contact support.';
          break;
        case 'unavailable':
          errorMessage =
              'Firestore is currently unavailable. Please try again later.';
          break;
        case 'deadline-exceeded':
          errorMessage =
              'The operation timed out. Please check your connection and try again.';
          break;
        default:
          errorMessage =
              'An unknown error occurred while updating the user. Please try again.';
      }

      AppLogger.e("Error updating user: ${e.message}"); // Log the detailed error
      throw Exception(errorMessage); // Throw a user-friendly error
    } catch (e) {
      // Handle unexpected errors
      AppLogger.e("Unexpected error updating user: $e");
      throw Exception(
          'An unexpected error occurred while updating the user. Please try again.');
    }
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(id).get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'permission-denied':
          errorMessage = 'You do not have permission to access this user.';
          break;
        case 'not-found':
          errorMessage = 'User not found. Please check the ID and try again.';
          break;
        case 'unavailable':
          errorMessage =
              'Firestore is currently unavailable. Please try again later.';
          break;
        default:
          errorMessage = 'An unknown error occurred while retrieving the user.';
      }

      AppLogger.e(
          "Error retrieving user by ID: ${e.message}"); // Log the detailed error
      throw Exception(errorMessage); // Throw a user-friendly error message
    } catch (e) {
      // Handle unexpected errors
      AppLogger.e("Unexpected error retrieving user by ID: $e");
      throw Exception(
          'An unexpected error occurred while retrieving the user. Please try again.');
    }
  }

  @override
  Future<Unit> signOut() async {
    try {
      await _auth.signOut();
      return unit;
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'no-current-user':
          errorMessage = 'No user is currently signed in.';
          break;
        default:
          errorMessage =
              'An error occurred while signing out. Please try again.';
      }

      AppLogger.e(
          "Firebase error during sign out: ${e.message}"); // Log detailed error
      throw Exception(errorMessage); // Throw user-friendly error
    } catch (e) {
      // Handle unexpected errors
      AppLogger.e("Unexpected error during sign out: $e");
      throw Exception(
          'An unexpected error occurred while signing out. Please try again.');
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in flow
        AppLogger.i("Google Sign-In canceled by user");
        throw Exception("Google Sign-In canceled by user."); 
      }

      // Obtain authentication details from the Google Sign-In flow
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Retrieve the user's data from Firestore
      UserModel? user = await getUserById(userCredential.user!.uid);
      if (user == null) {
        // Create a new user in Firestore if not already present
        user = UserModel(
          id: userCredential.user!.uid,
          username: userCredential.user?.displayName ?? '',
          email: userCredential.user?.email ?? '',
          createdDate: DateTime.now(),
          updatedDate: DateTime.now(),
          createdTopics: [],
          syncStatus: ConstantStrings.synced,
          recentItems: [],
          color: AppColors.defaultColor,
        );
        await updateUser(user); // Save the new user to Firestore
        AppLogger.i("New user created with Google Sign-In: ${user.email}");
      } else {
        AppLogger.i("Existing user signed in with Google: ${user.email}");
      }

      return user; // Return the user model
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      AppLogger.e("Firebase error during Google Sign-In: ${e.message}");
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception(
              "An account already exists with a different credential.");
        case 'invalid-credential':
          throw Exception("The credential provided is invalid.");
        default:
          throw Exception(
              "An error occurred during Google Sign-In. Please try again.");
      }
    } catch (e) {
      // Handle unexpected errors
      AppLogger.e("Unexpected error during Google Sign-In: $e");
      throw Exception("An unexpected error occurred. Please try again.");
    }
  }

  @override
  Future<UserModel?> signInWithFacebook() async {
    try {
      // Trigger the Facebook login flow
      final LoginResult facebookUser = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      if (facebookUser.status != LoginStatus.success ||
          facebookUser.accessToken == null) {
        AppLogger
            .i("Facebook Sign-In canceled or failed: ${facebookUser.status}");
        return null; // User canceled or login failed
      }

      // Create a credential using the Facebook access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(
        facebookUser.accessToken!.tokenString,
      );

      // Sign in to Firebase with the Facebook credential
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      // Fetch the user from Firestore or create a new one if not found
      UserModel? user = await getUserById(userCredential.user!.uid);

      if (user == null) {
        // Create a new user
        user = UserModel(
          id: userCredential.user!.uid,
          username: userCredential.user?.displayName ?? '',
          email: userCredential.user?.email ?? '',
          createdDate: DateTime.now(),
          updatedDate: DateTime.now(),
          createdTopics: [],
          syncStatus: ConstantStrings.synced,
          recentItems: [],
          color: AppColors.defaultColor,
        );
        await updateUser(user); // Save the new user to Firestore
        AppLogger.i("New user created with Facebook Sign-In: ${user.email}");
      } else {
        AppLogger.i("Existing user signed in with Facebook: ${user.email}");
      }

      return user; // Return the user model
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      AppLogger.e("Firebase error during Facebook Sign-In: ${e.message}");
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception(
              "An account already exists with a different credential.");
        case 'invalid-credential':
          throw Exception("The credential provided is invalid.");
        default:
          throw Exception(
              "An error occurred during Facebook Sign-In. Please try again.");
      }
    } catch (e) {
      // Handle unexpected errors
      AppLogger.e("Unexpected error during Facebook Sign-In: $e");
      throw Exception("An unexpected error occurred. Please try again.");
    }
  }

  @override
  Future<UserModel?> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider();

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithProvider(appleProvider);

      // Retrieve the user's data from Firestore
      UserModel? user = await getUserById(userCredential.user!.uid);

      if (user == null) {
        // Create a new user in Firestore if not already present
        user = UserModel(
          id: userCredential.user!.uid,
          username: userCredential.user?.displayName ?? '',
          email: userCredential.user?.email ?? '',
          createdDate: DateTime.now(),
          updatedDate: DateTime.now(),
          createdTopics: [],
          syncStatus: ConstantStrings.synced,
          recentItems: [],
          color: AppColors.defaultColor,
        );
        await updateUser(user); // Save the new user to Firestore
        AppLogger.i("New user created with Apple Sign-In: ${user.email}");
      } else {
        AppLogger.e("Existing user signed in with Apple: ${user.email}");
      }

      return user; // Return the user model
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      AppLogger.e("Firebase error during Apple Sign-In: ${e.message}");
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception(
              "An account already exists with a different credential.");
        case 'invalid-credential':
          throw Exception("The credential provided is invalid.");
        default:
          AppLogger.e(e as String);
          throw Exception(
              "An error occurred during Apple Sign-In. Please try again.");
      }
    } catch (e) {
      // Handle unexpected errors
      AppLogger.e("Unexpected error during Aoogle Sign-In: $e");
      throw Exception("An unexpected error occurred. Please try again.");
    }
  }

  @override
  Future<Unit> resetPassword(String newPassword) async {
    try {
      var user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw Exception('Error reset password: user not logged in');
      }
      return unit;
    } catch (e) {
      throw Exception('Error reset password: $e');
    }
  }

  @override
  Future<Unit> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return unit;
    } catch (e) {
      throw Exception('Error password reset email: $e');
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword(String password) async {
    final user = _auth.currentUser;

    // Ensure the user is signed in
    if (user != null) {
      try {
        // Attempt to update the password
        await user.updatePassword(password);
        AppLogger.d("Successfully changed password");

        return const Right(null); // Success, no error message
      } on FirebaseAuthException catch (e) {
        AppLogger.e("Password update error: ${e.code}, ${e.message}");

        // Handle specific FirebaseAuthException cases
        switch (e.code) {
          case 'requires-recent-login':
            return Left(Failure(
                'Please log in again to update your password for security reasons.'));
          case 'weak-password':
            return Left(Failure('The password provided is too weak.'));
          case 'network-request-failed':
            return Left(NoInternetFailure());
          case 'email-already-exists':
            return Left(Failure('The email already exists.'));
          default:
            return Left(Failure('An unexpected error occurred: ${e.message}'));
        }
      } catch (e) {
        AppLogger.e("Unexpected error during password update: $e");
        // Generic error handling
        return Left(
            Failure('An unexpected error occurred. Please try again later.'));
      }
    } else {
      // If no user is signed in, return an appropriate failure message
      return Left(Failure('No user is currently signed in.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateColor(UserModel user) async {
    final userCredential = _auth.currentUser;

    // Ensure the user is signed in
    if (userCredential != null) {
      try {
        // Update user's color if already exists
        await updateUser(user.copyWith(updatedDate: DateTime.now()));

        return const Right(null);
      } catch (e) {
        AppLogger.e('Error updating user color', error: e);
        return Left(Failure('Failed to update user color.'));
      }
    }

    return Left(Failure('No user is currently signed in.'));
  }

  @override
  Future<Unit> reauthenticate(String? password) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      // Check if user signed in with email/password
      final isEmailProvider = user.providerData.any(
        (provider) => provider.providerId == 'password',
      );

      if (isEmailProvider) {
        // Reauthenticate with email and password
        if (password == null || password.isEmpty) {
          throw Exception('Password is required for reauthentication.');
        }

        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        await user.reauthenticateWithCredential(credential);
        AppLogger.i('Successfully reauthenticated with email/password');
      } else {
        // Reauthenticate with social provider
        final providerId = user.providerData.first.providerId;
        
        AuthCredential? credential;
        
        switch (providerId) {
          case 'google.com':
            final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
            if (googleUser == null) {
              throw Exception('Google Sign-In canceled by user.');
            }
            final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
            credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            break;
            
          case 'facebook.com':
            final LoginResult facebookUser = await _facebookAuth.login(
              permissions: ['email', 'public_profile'],
            );
            if (facebookUser.status != LoginStatus.success || facebookUser.accessToken == null) {
              throw Exception('Facebook Sign-In canceled or failed.');
            }
            credential = FacebookAuthProvider.credential(
              facebookUser.accessToken!.tokenString,
            );
            break;
            
          case 'apple.com':
            final appleProvider = AppleAuthProvider();
            await _auth.signInWithProvider(appleProvider);
            // For Apple, we need to use the credential from the new sign-in
            AppLogger.i('Successfully reauthenticated with Apple');
            return unit;
            
          default:
            throw Exception('Unsupported authentication provider: $providerId');
        }
        
        await user.reauthenticateWithCredential(credential);
        AppLogger.i('Successfully reauthenticated with $providerId');
      }

      return unit;
    } on FirebaseAuthException catch (e) {
      AppLogger.e('Error during reauthentication: ${e.message}');
      
      switch (e.code) {
        case 'wrong-password':
          throw Exception('Incorrect password. Please try again.');
        case 'user-mismatch':
          throw Exception('The credentials do not match the current user.');
        case 'user-not-found':
          throw Exception('No user found with these credentials.');
        case 'invalid-credential':
          throw Exception('The credential is invalid or expired.');
        case 'invalid-email':
          throw Exception('The email address is invalid.');
        default:
          throw Exception('Reauthentication failed. Please try again.');
      }
    } catch (e) {
      AppLogger.e('Unexpected error during reauthentication: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Unit> deleteAccount() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      final userId = user.uid;

      // Delete user document from Firestore
      try {
        await _firestore.collection('users').doc(userId).delete();
        AppLogger.i('Successfully deleted user document from Firestore: $userId');
      } on FirebaseException catch (e) {
        AppLogger.e('Error deleting user document from Firestore: ${e.message}');
        
        switch (e.code) {
          case 'permission-denied':
            throw Exception(
                'You do not have permission to delete this account. Please contact support.');
          case 'unavailable':
            throw Exception(
                'Firestore is currently unavailable. Please try again later.');
          default:
            throw Exception(
                'Failed to delete user data. Please try again.');
        }
      }

      // Delete Firebase Authentication user
      try {
        await user.delete();
        AppLogger.i('Successfully deleted Firebase Auth user: $userId');
      } on FirebaseAuthException catch (e) {
        AppLogger.e('Error deleting Firebase Auth user: ${e.message}');
        
        switch (e.code) {
          case 'requires-recent-login':
            throw Exception(
                'For security, please sign out and sign in again before deleting your account.');
          case 'no-current-user':
            throw Exception('No user is currently signed in.');
          default:
            throw Exception(
                'Failed to delete account. Please try again.');
        }
      }

      return unit;
    } catch (e) {
      AppLogger.e('Unexpected error during account deletion: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}

