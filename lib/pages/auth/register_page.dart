import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/app_strings.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/core/services/app_feedback_service.dart';
import 'package:peoplesync/features/auth/auth_viewmodel.dart';
import 'package:peoplesync/shared/widgets/auth/auth_footer_links.dart';
import 'package:peoplesync/shared/widgets/auth/auth_logo.dart';
import 'package:peoplesync/shared/widgets/auth/auth_main_action_button.dart';
import 'package:peoplesync/shared/widgets/auth/auth_text_welcome.dart';
import 'package:peoplesync/shared/widgets/design/inputs/app_password_field.dart';
import 'package:peoplesync/shared/widgets/design/inputs/app_text_field.dart';
import 'package:peoplesync/shared/widgets/design/layout/app_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AuthViewModel>();
    await viewModel.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (viewModel.errorMessage == null) {
      AppFeedbackService.showInfo('Cuenta creada correctamente.');
      context.go(Routes.home);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese su nombre';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese su email';
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value.trim())) {
      return 'Email invalido';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contrasena';
    }
    if (value.length < 6) {
      return 'La contrasena debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme su contrasena';
    }
    if (value != _passwordController.text) {
      return 'Las contrasenas no coinciden';
    }
    return null;
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
                      const SizedBox(height: 24),
                      const AuthTextWelcome(
                        title: 'Crea tu cuenta',
                        description:
                            'Completa tus datos para empezar con el rol usuario',
                      ),
                      const SizedBox(height: 32),
                      if (viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 24,
                            left: 24,
                            right: 24,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: theme.colorScheme.error.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ),
                            child: Text(
                              viewModel.errorMessage!,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.74,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 28,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              AppTextField(
                                controller: _nameController,
                                label: AppStrings.name,
                                validator: _validateName,
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                              const SizedBox(height: 18),
                              AppTextField(
                                controller: _emailController,
                                label: AppStrings.email,
                                hintText: AppStrings.emailExample,
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateEmail,
                                prefixIcon: const Icon(
                                  Icons.alternate_email_rounded,
                                ),
                              ),
                              const SizedBox(height: 18),
                              AppPasswordField(
                                controller: _passwordController,
                                label: AppStrings.password,
                                validator: _validatePassword,
                                customPrefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),
                              ),
                              const SizedBox(height: 18),
                              AppPasswordField(
                                controller: _confirmPasswordController,
                                label: 'Confirmar contrasena',
                                validator: _validateConfirmPassword,
                                customPrefixIcon: const Icon(
                                  Icons.verified_user_outlined,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AuthMainActionButton(
                        isLoading: viewModel.isLoading,
                        label: AppStrings.signUp,
                        onPressed: _register,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.go(Routes.login),
                        child: const Text('Ya tengo una cuenta'),
                      ),
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
