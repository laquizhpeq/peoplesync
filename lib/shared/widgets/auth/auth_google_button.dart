import 'package:flutter/material.dart';
import 'package:peoplesync/core/constants/app_strings.dart';

class AuthGoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AuthGoogleButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          side: BorderSide(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.18),
          ),
          backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.84),
        ),
        icon: Icon(
          Icons.g_mobiledata,
          size: 34,
          color: theme.colorScheme.primary,
        ),
        label: const Text(AppStrings.signInWithGoogle),
        onPressed: onPressed ?? () {},
      ),
    );
  }
}
