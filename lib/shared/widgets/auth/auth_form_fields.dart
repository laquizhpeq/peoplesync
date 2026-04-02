import 'package:flutter/material.dart';
import 'package:peoplesync/core/constants/app_strings.dart';
import 'package:peoplesync/shared/widgets/design/inputs/app_password_field.dart';
import 'package:peoplesync/shared/widgets/design/inputs/app_text_field.dart';

class AuthFormFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const AuthFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          children: [
            AppTextField(
              controller: emailController,
              label: AppStrings.email,
              hintText: AppStrings.emailExample,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.alternate_email_rounded),
            ),
            const SizedBox(height: 18),
            AppPasswordField(
              controller: passwordController,
              label: AppStrings.password,
              customPrefixIcon: const Icon(Icons.lock_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
