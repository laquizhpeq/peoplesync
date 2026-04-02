import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/shared/widgets/common/empty_state.dart';
import 'package:peoplesync/shared/widgets/common/loading_widget.dart';
import 'package:peoplesync/shared/widgets/contacts/connection_contact_card.dart';

class ConnectionsPage extends StatelessWidget {
  const ConnectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ConnectionsViewModel>(
      create: (_) => getIt<ConnectionsViewModel>(),
      child: Consumer<ConnectionsViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const AppLoadingWidget();
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'No se pudieron cargar tus conexiones',
                  description: viewModel.errorMessage!,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ConnectionsHeader(
                  total: viewModel.contacts.length,
                  onAddManual: () => context.go(Routes.contactNew),
                ),
                const SizedBox(height: 20),
                if (viewModel.contacts.isEmpty)
                  AppEmptyState(
                    icon: Icons.groups_rounded,
                    title: 'Todavía no tienes conexiones guardadas',
                    description:
                        'Añade tu primer contacto manualmente y empezará a aparecer aquí como una ficha visual.',
                    action: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go(Routes.contactNew),
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('Crear primera conexión'),
                      ),
                    ),
                  )
                else
                  ...viewModel.contacts.map(
                    (contact) => ConnectionContactCard(contact: contact),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ConnectionsHeader extends StatelessWidget {
  final int total;
  final VoidCallback onAddManual;

  const _ConnectionsHeader({required this.total, required this.onAddManual});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu red personal',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            total == 1 ? '1 conexión guardada' : '$total conexiones guardadas',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
              ),
              onPressed: onAddManual,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Añadir conexión manual'),
            ),
          ),
        ],
      ),
    );
  }
}
