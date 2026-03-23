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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppTextField(
            controller: emailController,
            label: AppStrings.email,
            hintText: AppStrings.emailExample,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          AppPasswordField(
            controller: passwordController,
            label: AppStrings.password,
          ),
        ],
      ),
    );
  }
}
