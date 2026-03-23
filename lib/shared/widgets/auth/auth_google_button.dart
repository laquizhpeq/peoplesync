import 'package:flutter/material.dart';
import 'package:peoplesync/core/constants/app_strings.dart';

class AuthGoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  
  const AuthGoogleButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        icon: const Icon(
          Icons.g_mobiledata,
          size: 30,
        ),
        label: const Text(AppStrings.signInWithGoogle),
        onPressed: onPressed ?? () {},
      ),
    );
  }
}
