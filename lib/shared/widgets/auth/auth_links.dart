import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peoplesync/core/constants/app_strings.dart';
import 'package:peoplesync/core/constants/routes.dart';

class AuthPasswordResetLink extends StatelessWidget {
  final VoidCallback? onPressed;

  const AuthPasswordResetLink({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: TextButton(
        onPressed: onPressed ?? () {},
        child: Text(
          AppStrings.passwordReset,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class AuthSignUpLink extends StatelessWidget {
  final VoidCallback? onPressed;

  const AuthSignUpLink({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppStrings.noAccount, style: theme.textTheme.bodyMedium),
        TextButton(
          onPressed: onPressed ?? () => context.go(Routes.register),
          child: Text(
            AppStrings.signUp,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class AuthSeparator extends StatelessWidget {
  const AuthSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.26),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.or,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.26),
          ),
        ),
      ],
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  final String message;

  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.error.withValues(alpha: 0.18),
          ),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
