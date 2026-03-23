import 'package:flutter/material.dart';
import 'package:peoplesync/core/constants/app_strings.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 600;
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: isWeb ? 180 : 100,
            fit: BoxFit.contain,
          ),
          Text(
            AppStrings.appName,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
