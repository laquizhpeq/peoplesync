import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/admin/admin_users_viewmodel.dart';
import 'package:peoplesync/features/admin/models/admin_user_account.dart';
import 'package:peoplesync/shared/widgets/common/empty_state.dart';
import 'package:peoplesync/shared/widgets/common/loading_widget.dart';
import 'package:peoplesync/shared/widgets/contacts/contact_avatar_placeholder.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminUsersViewModel>(
      create: (_) => getIt<AdminUsersViewModel>(),
      child: const _AdminUsersView(),
    );
  }
}

class _AdminUsersView extends StatelessWidget {
  const _AdminUsersView();

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminUsersViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const AppLoadingWidget();
        }

        if (viewModel.errorMessage != null && viewModel.allUsers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppEmptyState(
                icon: Icons.admin_panel_settings_outlined,
                title: 'No se pudo abrir el panel admin',
                description:
                    '${viewModel.errorMessage!} Revisa permisos y reglas de Firestore.',
              ),
            ),
          );
        }

        final users = viewModel.users;
        final allUsers = viewModel.allUsers;
        final activeCount = allUsers.where((user) => user.isActive).length;
        final adminCount = allUsers
            .where((user) => user.rolId.toLowerCase() == 'admin')
            .length;
        final inactiveCount = allUsers.length - activeCount;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AdminHeader(totalUsers: allUsers.length),
              const SizedBox(height: 18),
              _AdminStatsRow(
                totalUsers: allUsers.length,
                activeCount: activeCount,
                inactiveCount: inactiveCount,
                adminCount: adminCount,
              ),
              const SizedBox(height: 18),
              _AdminInfoBanner(),
              const SizedBox(height: 18),
              _AdminToolbar(viewModel: viewModel),
              const SizedBox(height: 18),
              if (allUsers.isEmpty)
                const AppEmptyState(
                  icon: Icons.group_off_rounded,
                  title: 'No hay usuarios para administrar',
                  description:
                      'La coleccion users esta vacia o las reglas no permiten verla desde este panel.',
                )
              else if (users.isEmpty)
                const AppEmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No hay usuarios con esos filtros',
                  description:
                      'Ajusta la busqueda o cambia el filtro para ver resultados.',
                )
              else
                ...users.map((user) => _AdminUserCard(user: user)).toList(),
            ],
          ),
        );
      },
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final int totalUsers;

  const _AdminHeader({required this.totalUsers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          totalUsers == 1
              ? '1 usuario bajo control'
              : '$totalUsers usuarios bajo control',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AdminStatsRow extends StatelessWidget {
  final int totalUsers;
  final int activeCount;
  final int inactiveCount;
  final int adminCount;

  const _AdminStatsRow({
    required this.totalUsers,
    required this.activeCount,
    required this.inactiveCount,
    required this.adminCount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 680;
        final cards = [
          _AdminStatCard(
            label: 'Total',
            value: '$totalUsers',
            icon: Icons.groups_rounded,
            color: const Color(0xFF4F6BED),
          ),
          _AdminStatCard(
            label: 'Activos',
            value: '$activeCount',
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF1FA37A),
          ),
          _AdminStatCard(
            label: 'Inactivos',
            value: '$inactiveCount',
            icon: Icons.pause_circle_outline_rounded,
            color: const Color(0xFFE85D5D),
          ),
          _AdminStatCard(
            label: 'Admins',
            value: '$adminCount',
            icon: Icons.admin_panel_settings_outlined,
            color: const Color(0xFF9B51E0),
          ),
        ];

        if (!wide) {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: card,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: cards
              .map(
                (card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: card,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminInfoBanner extends StatelessWidget {
  const _AdminInfoBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        'Este panel gestiona perfiles de la app. Sin backend o Cloud Functions no existe alta/baja real en Firebase Auth: aqui puedes activar, desactivar, cambiar rol y editar datos del perfil.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          height: 1.35,
        ),
      ),
    );
  }
}

class _AdminToolbar extends StatelessWidget {
  final AdminUsersViewModel viewModel;

  const _AdminToolbar({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: viewModel.setQuery,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre, email, rol o ciudad',
            prefixIcon: const Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _AdminFilterChip(
                label: 'Todos',
                selected: viewModel.filter == AdminUsersFilter.all,
                onTap: () => viewModel.setFilter(AdminUsersFilter.all),
              ),
              const SizedBox(width: 8),
              _AdminFilterChip(
                label: 'Activos',
                selected: viewModel.filter == AdminUsersFilter.active,
                onTap: () => viewModel.setFilter(AdminUsersFilter.active),
              ),
              const SizedBox(width: 8),
              _AdminFilterChip(
                label: 'Inactivos',
                selected: viewModel.filter == AdminUsersFilter.inactive,
                onTap: () => viewModel.setFilter(AdminUsersFilter.inactive),
              ),
              const SizedBox(width: 8),
              _AdminFilterChip(
                label: 'Admins',
                selected: viewModel.filter == AdminUsersFilter.admins,
                onTap: () => viewModel.setFilter(AdminUsersFilter.admins),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AdminFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
    );
  }
}

class _AdminUserCard extends StatelessWidget {
  final AdminUserAccount user;

  const _AdminUserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.read<AdminUsersViewModel>();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: user.isActive
              ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08)
              : theme.colorScheme.error.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: ContactAvatarPlaceholder(
                  seed: user.uid,
                  displayName: user.fullName.isEmpty ? user.email : user.fullName,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName.isEmpty ? 'Sin nombre' : user.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email.isEmpty ? 'Sin email' : user.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusChip(
                          label: user.rolId,
                          color: user.rolId.toLowerCase() == 'admin'
                              ? const Color(0xFF9B51E0)
                              : theme.colorScheme.primary,
                        ),
                        _StatusChip(
                          label: user.isActive ? 'Activo' : 'Inactivo',
                          color: user.isActive
                              ? const Color(0xFF1FA37A)
                              : const Color(0xFFE85D5D),
                        ),
                        _StatusChip(
                          label: user.onboardingCompleted
                              ? 'Onboarding ok'
                              : 'Onboarding pendiente',
                          color: const Color(0xFFF2994A),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleAdminAction(context, viewModel, value, user),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar perfil'),
                  ),
                  PopupMenuItem(
                    value: user.isActive ? 'deactivate' : 'activate',
                    child: Text(
                      user.isActive ? 'Dar de baja' : 'Dar de alta',
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reset_onboarding',
                    child: Text('Reiniciar onboarding'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _AdminInfoLine(
                  label: 'Ciudad',
                  value: user.city?.trim().isNotEmpty == true
                      ? user.city!
                      : 'Sin ciudad',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AdminInfoLine(
                  label: 'Ultimo acceso',
                  value: _formatDate(user.lastLogin),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAdminAction(
    BuildContext context,
    AdminUsersViewModel viewModel,
    String action,
    AdminUserAccount user,
  ) async {
    switch (action) {
      case 'edit':
        await _showEditDialog(context, viewModel, user);
        break;
      case 'activate':
        await _showResult(
          context,
          viewModel.setUserActiveStatus(uid: user.uid, isActive: true),
          successMessage: 'Usuario reactivado',
        );
        break;
      case 'deactivate':
        await _showResult(
          context,
          viewModel.softDeleteUser(user.uid),
          successMessage: 'Usuario dado de baja',
        );
        break;
      case 'reset_onboarding':
        await _showResult(
          context,
          viewModel.resetOnboarding(user.uid),
          successMessage: 'Onboarding reiniciado',
        );
        break;
    }
  }

  Future<void> _showEditDialog(
    BuildContext context,
    AdminUsersViewModel viewModel,
    AdminUserAccount user,
  ) async {
    final fullNameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    final cityController = TextEditingController(text: user.city ?? '');
    final bioController = TextEditingController(text: user.bio ?? '');
    String selectedRole = user.rolId;
    bool onboardingCompleted = user.onboardingCompleted;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar usuario'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: fullNameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: viewModel.roles.contains(selectedRole)
                        ? selectedRole
                        : viewModel.roles.first,
                    decoration: const InputDecoration(labelText: 'Rol'),
                    items: viewModel.roles
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedRole = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'Ciudad'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Bio'),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    value: onboardingCompleted,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Onboarding completado'),
                    onChanged: (value) {
                      setState(() {
                        onboardingCompleted = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final error = await viewModel.updateUser(
                  uid: user.uid,
                  fullName: fullNameController.text,
                  email: emailController.text,
                  rolId: selectedRole,
                  city: cityController.text,
                  bio: bioController.text,
                  onboardingCompleted: onboardingCompleted,
                );
                if (!context.mounted) return;
                if (error != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error)));
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    fullNameController.dispose();
    emailController.dispose();
    cityController.dispose();
    bioController.dispose();

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuario actualizado')));
    }
  }

  Future<void> _showResult(
    BuildContext context,
    Future<String?> future, {
    required String successMessage,
  }) async {
    final error = await future;
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? successMessage)),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AdminInfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _AdminInfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Sin registro';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year;
  return '$day/$month/$year';
}
