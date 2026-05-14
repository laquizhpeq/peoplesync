import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/features/contacts/contact_sync_viewmodel.dart';
import 'package:peoplesync/shared/widgets/design/layout/base_page.dart';

class ContactSyncPage extends StatelessWidget {
  const ContactSyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Importar del Movil',
      body: Consumer<ContactSyncViewModel>(
        builder: (context, viewModel, child) {
          final theme = Theme.of(context);

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sync_rounded,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Sincroniza tu agenda',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Importaremos todos tus contactos nativos y crearemos fichas editables independientes en un instante.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 48),
                    if (viewModel.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          viewModel.errorMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (viewModel.isLoading) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        viewModel.statusMessage ?? 'Cargando...',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Por favor, no cierres esta aplicacion hasta que termine.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ] else if (viewModel.isSuccess) ...[
                      const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        viewModel.statusMessage ?? 'Completado',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => context.pop(),
                          child: const Text('Volver al inicio'),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: viewModel.importContacts,
                          icon: const Icon(Icons.cloud_download_rounded),
                          label: const Text(
                            'Comenzar importacion',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Cancelar'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
