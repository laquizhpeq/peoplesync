import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:peoplesync/features/auth/auth_viewmodel.dart';
import 'package:peoplesync/core/constants/app_strings.dart';
import 'package:peoplesync/shared/widgets/design/layout/app_page.dart';
import 'package:peoplesync/shared/widgets/auth/auth_logo.dart';
import 'package:peoplesync/shared/widgets/auth/auth_text_welcome.dart';
import 'package:peoplesync/shared/widgets/auth/auth_form_fields.dart';
import 'package:peoplesync/shared/widgets/auth/auth_main_action_button.dart';
import 'package:peoplesync/shared/widgets/auth/auth_google_button.dart';
import 'package:peoplesync/shared/widgets/auth/auth_footer_links.dart';
import 'package:peoplesync/shared/widgets/auth/auth_links.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final viewModel = context.read<AuthViewModel>();
    await viewModel.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    if (!mounted) return;

    if (viewModel.errorMessage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful')));
      context.go('/');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) => AppPage(
        title: AppStrings.blank,
        centerBody: true,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AuthLogo(),
                    const SizedBox(height: 24),
                    const AuthTextWelcome(),
                    const SizedBox(height: 32),

                    if (viewModel.errorMessage != null)
                      AuthErrorBanner(message: viewModel.errorMessage!),

                    AuthFormFields(
                      emailController: _emailController,
                      passwordController: _passwordController,
                    ),

                    const AuthPasswordResetLink(),
                    const SizedBox(height: 24),

                    AuthMainActionButton(
                      isLoading: viewModel.isLoading,
                      onPressed: _login,
                    ),

                    const SizedBox(height: 24),
                    const AuthSeparator(),
                    const SizedBox(height: 24),

                    const AuthGoogleButton(),
                    const SizedBox(height: 24),

                    const AuthSignUpLink(),
                    const SizedBox(height: 40),

                    const AuthFooterLinks(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
