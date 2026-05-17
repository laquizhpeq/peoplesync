import 'package:flutter/foundation.dart';
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
        centerBody: !kIsWeb,
        body: kIsWeb
            ? _buildWebLayout(context, viewModel, theme)
            : _buildMobileLayout(context, viewModel, theme),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    AuthViewModel viewModel,
    ThemeData theme,
  ) {
    return Center(
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
          child: _buildAuthShell(
            context,
            viewModel,
            backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout(
    BuildContext context,
    AuthViewModel viewModel,
    ThemeData theme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;

        if (!wide) {
          return _buildMobileLayout(context, viewModel, theme);
        }

        return Row(
          children: [
            Expanded(
              flex: 11,
              child: Container(
                height: double.infinity,
                padding: const EdgeInsets.fromLTRB(56, 48, 56, 48),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF8A65), Color(0xFFE85D5D)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthLogo(),
                    const Spacer(),
                    Text(
                      'PeopleSync',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 0.95,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Text(
                        'Gestiona mejor tus relaciones, guarda contexto real y vuelve a cada persona con algo mas que un nombre en una lista.',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const [
                        _WebAuthPill(label: 'Relaciones'),
                        _WebAuthPill(label: 'Contexto'),
                        _WebAuthPill(label: 'Seguimiento'),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: Container(
                height: double.infinity,
                color: theme.colorScheme.surface.withValues(alpha: 0.94),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 32,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: _buildAuthShell(
                        context,
                        viewModel,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAuthShell(
    BuildContext context,
    AuthViewModel viewModel, {
    required Color backgroundColor,
    BorderRadius? borderRadius,
  }) {
    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 28),
            if (!kIsWeb) const AuthLogo(),
            if (!kIsWeb) const SizedBox(height: 28),
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
            const AuthSignUpLink(),
            const SizedBox(height: 24),
            const AuthFooterLinks(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _WebAuthPill extends StatelessWidget {
  final String label;

  const _WebAuthPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
