import 'package:flutter/material.dart';
import 'package:peoplesync/core/constants/app_strings.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo.png',
            height: isWide ? 68 : 54,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          AppStrings.appName,
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(letterSpacing: -1.2),
        ),
        const SizedBox(height: 8),
        Text(
          'Conecta personas con naturalidad',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
