import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/auth/auth_viewmodel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthViewModel>(
      create: (_) => getIt<AuthViewModel>(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pagina de inicio - contenido de prueba'),
              const SizedBox(height: 16),
              Consumer<AuthViewModel>(
                builder: (context, viewModel, _) => TextButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          await viewModel.logout();
                          if (!context.mounted) return;
                          context.go(Routes.login);
                        },
                  child: const Text('Cerrar sesion (dev)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
