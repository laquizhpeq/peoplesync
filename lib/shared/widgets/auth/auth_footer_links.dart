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
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Colors.grey);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: onTermsPressed ?? () {},
              child: Text(AppStrings.termsAndConditions, style: style),
            ),
            const Text("|", style: TextStyle(color: Colors.grey)),
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
