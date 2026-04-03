import 'package:flutter/material.dart';
import 'package:peoplesync/core/constants/app_strings.dart';

class AuthFooterLinks extends StatelessWidget {
  final VoidCallback? onTermsPressed;
  final VoidCallback? onPrivacyPressed;

  const AuthFooterLinks({
    super.key,
    this.onTermsPressed,
    this.onPrivacyPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: onTermsPressed ?? () {},
              child: Text(AppStrings.termsAndConditions, style: style),
            ),
            Text('|', style: style),
            TextButton(
              onPressed: onPrivacyPressed ?? () {},
              child: Text(AppStrings.privacyPolicy, style: style),
            ),
          ],
        ),
        Text(AppStrings.copyRight, style: style),
      ],
    );
  }
}
