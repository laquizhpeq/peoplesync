import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/design/buttons/app_primary_button.dart';
import '../../shared/widgets/design/inputs/app_password_field.dart';
import '../../shared/widgets/design/inputs/app_text_field.dart';
import '../../shared/widgets/design/layout/app_page.dart';
import 'auth_service.dart';

class AuthPage extends StatefulWidget {
  final AuthService? authService;
  const AuthPage({super.key, this.authService});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(AppStrings.loginSuccess)));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = AppStrings.unexpectedError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
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
                  const _AppLogo(),
                  const SizedBox(height: 24),
                  const _TextWelcome(),
                  const SizedBox(height: 32),

                  if (_errorMessage != null)
                    _ErrorBanner(message: _errorMessage!),

                  _LoginFormFields(
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),

                  const _PasswordResetLink(),
                  const SizedBox(height: 24),

                  _MainActionButton(isLoading: _isLoading, onPressed: _login),

                  const SizedBox(height: 24),
                  const _Separator(),
                  const SizedBox(height: 24),

                  const _GoogleSignInButton(),
                  const SizedBox(height: 24),

                  const _SignUpLink(),
                  const SizedBox(height: 40),

                  const _FooterLinks(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- COMPONENTES PRIVADOS ---

class _AppLogo extends StatelessWidget {
  const _AppLogo();
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

class _TextWelcome extends StatelessWidget {
  const _TextWelcome();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.welcome,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.welcomeDescription,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _LoginFormFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  const _LoginFormFields({
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

class _MainActionButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  const _MainActionButton({required this.isLoading, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppPrimaryButton(
        onPressed: onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(AppStrings.signIn),
      ),
    );
  }
}

class _PasswordResetLink extends StatelessWidget {
  const _PasswordResetLink();
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: TextButton(
          onPressed: () {},
          child: const Text(AppStrings.passwordReset),
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(AppStrings.or, style: TextStyle(color: Colors.grey[600])),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        icon: const Icon(
          Icons.g_mobiledata,
          size: 30,
        ), // Sustituir por icono de Google real
        label: const Text(AppStrings.signInWithGoogle),
        onPressed: () {},
      ),
    );
  }
}

class _SignUpLink extends StatelessWidget {
  const _SignUpLink();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(AppStrings.noAccount),
        TextButton(
          onPressed: () {},
          child: const Text(
            AppStrings.signUp,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks();
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
              onPressed: () {},
              child: Text(AppStrings.termsAndConditions, style: style),
            ),
            const Text("|", style: TextStyle(color: Colors.grey)),
            TextButton(
              onPressed: () {},
              child: Text(AppStrings.privacyPolicy, style: style),
            ),
          ],
        ),
        Text(AppStrings.copyRight, style: style),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
