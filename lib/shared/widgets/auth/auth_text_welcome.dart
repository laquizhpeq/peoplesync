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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
