import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:peoplesync/core/constants/routes.dart';
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
      context.go(Routes.home);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) => AppPage(
        title: AppStrings.blank,
        centerBody: true,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 460),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.surface.withValues(alpha: 0.82),
                    theme.colorScheme.surface.withValues(alpha: 0.58),
                  ],
                ),
                border: Border.all(
                  color: theme.colorScheme.surface.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    blurRadius: 40,
                    offset: const Offset(0, 24),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 28),
                      const AuthLogo(),
                      const SizedBox(height: 28),
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
                        label: AppStrings.signIn,
                        onPressed: _login,
                      ),
                      const SizedBox(height: 24),
                      const AuthSeparator(),
                      const SizedBox(height: 24),
                      const AuthGoogleButton(),
                      const SizedBox(height: 24),
                      const AuthSignUpLink(),
                      const SizedBox(height: 24),
                      const AuthFooterLinks(),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
