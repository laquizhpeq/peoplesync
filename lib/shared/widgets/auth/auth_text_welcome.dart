import 'package:flutter/material.dart';
import 'package:peoplesync/core/constants/app_strings.dart';

class AuthTextWelcome extends StatelessWidget {
  final String title;
  final String description;

  const AuthTextWelcome({
    super.key,
    this.title = AppStrings.welcome,
    this.description = AppStrings.welcomeDescription,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
