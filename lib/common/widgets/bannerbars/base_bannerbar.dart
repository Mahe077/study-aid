import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class CustomToast {
  final BuildContext context;

  CustomToast({required this.context});

  void _showToast({
    required String title,
    required String description,
    required ToastificationType type,
    Color? primaryColor,
    IconData? icon,
  }) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flat,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description:
          Text(description, style: TextStyle(fontWeight: FontWeight.w500)),
      autoCloseDuration: const Duration(seconds: 5),
      animationDuration: const Duration(milliseconds: 300),
      alignment: Alignment.topRight,
      icon: Icon(
        icon,
        color: primaryColor,
      ),
      primaryColor: primaryColor,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 16,
          offset: Offset(0, 16),
        ),
      ],
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      dragToClose: true,
      pauseOnHover: true,
      callbacks: ToastificationCallbacks(
        onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
        onDismissed: (toastItem) => print('Toast ${toastItem.id} dismissed'),
      ),
    );
  }

  void showSuccess({String? title, required String description}) {
    _showToast(
      title: title ?? 'Success',
      description: description,
      type: ToastificationType.success,
      primaryColor: Colors.green,
      icon: Icons.check_circle_outline,
    );
  }

  void showFailure({String? title, required String description}) {
    _showToast(
      title: title ?? 'Error',
      description: description,
      type: ToastificationType.error,
      primaryColor: Colors.red,
      icon: Icons.error_outline,
    );
  }

  void showInfo({String? title, required String description}) {
    _showToast(
      title: title ?? 'Info',
      description: description,
      type: ToastificationType.info,
      primaryColor: Colors.blue,
      icon: Icons.info_outline,
    );
  }

  void showWarning({String? title, required String description}) {
    _showToast(
      title: title ?? 'Warning',
      description: description,
      type: ToastificationType.warning,
      primaryColor: Colors.orange,
      icon: Icons.warning_amber_outlined,
    );
  }
}
