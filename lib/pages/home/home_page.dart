import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/auth/auth_viewmodel.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:peoplesync/features/qr_code/widgets/scanner_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => getIt<AuthViewModel>(),
        ),
        ChangeNotifierProvider<ConnectionsViewModel>(
          create: (_) => getIt<ConnectionsViewModel>(),
        ),
      ],
      child: Consumer<ConnectionsViewModel>(
        builder: (context, connectionsViewModel, _) {
          final reconnectContacts = _buildReconnectContacts(
            connectionsViewModel.contacts,
          );
          final spotlightContact = reconnectContacts.isNotEmpty
              ? reconnectContacts.first
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReconnectSection(contacts: reconnectContacts),
                const SizedBox(height: 18),
                _SpotlightSection(contact: spotlightContact),
                const SizedBox(height: 28),
                const _QuickActionsCluster(),
                const SizedBox(height: 24),
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, _) => Center(
                    child: TextButton(
                      onPressed: authViewModel.isLoading
                          ? null
                          : () async {
                              await authViewModel.logout();
                              if (!context.mounted) return;
                              context.go(Routes.login);
                            },
                      child: const Text('Cerrar sesion (dev)'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReconnectSection extends StatelessWidget {
  final List<ContactRecord> contacts;

  const _ReconnectSection({required this.contacts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vuelve a conectar',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Personas de tu red que llevan tiempo sin una actualizacion.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 16),
          if (contacts.isEmpty)
            _ReconnectEmpty()
          else
            Column(
              children: contacts
                  .take(3)
                  .map(
                    (contact) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ReconnectItem(contact: contact),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ReconnectEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Todavia no hay contactos suficientes para sugerir a quien revisar.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReconnectItem extends StatelessWidget {
  final ContactRecord contact;

  const _ReconnectItem({required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = _displayName(contact);
    final subtitle = _reconnectSubtitle(contact);

    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go(Routes.connections),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Avatar(photoUrl: contact.identity.photoUrl, compact: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotlightSection extends StatelessWidget {
  final ContactRecord? contact;

  const _SpotlightSection({required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
        ),
      ),
      child: contact == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recuerda a esta persona',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cuando empieces a guardar conexiones, aqui te recordaremos a quien conviene revisar.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(photoUrl: contact!.identity.photoUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recuerda a esta persona',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _displayName(contact!),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _spotlightText(contact!),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        onPressed: () => context.go(Routes.connections),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('Ver ficha'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _QuickActionsCluster extends StatelessWidget {
  const _QuickActionsCluster();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: _QuickActionPill(
            icon: Icons.groups_rounded,
            label: 'Conexiones',
            size: _QuickActionSize.large,
            onTap: () => context.go(Routes.connections),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _QuickActionPill(
                  icon: Icons.person_add_alt_1_rounded,
                  label: 'Anadir',
                  size: _QuickActionSize.medium,
                  onTap: () => context.go(Routes.contactNew),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _QuickActionPill(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Escanear',
                  size: _QuickActionSize.medium,
                  onTap: () => ScannerDialog.show(context),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: _QuickActionPill(
            icon: Icons.cloud_download_rounded,
            label: 'Importar contactos',
            size: _QuickActionSize.large, // Match the style of connections button
            onTap: () => context.go(Routes.contactSync),
          ),
        ),
      ],
    );
  }
}

enum _QuickActionSize { large, medium }

class _QuickActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final _QuickActionSize size;
  final VoidCallback onTap;

  const _QuickActionPill({
    required this.icon,
    required this.label,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLarge = size == _QuickActionSize.large;

    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.97),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? 22 : 18,
            vertical: isLarge ? 16 : 14,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isLarge ? 44 : 40,
                height: isLarge ? 44 : 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: isLarge ? 22 : 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style:
                    (isLarge
                            ? theme.textTheme.titleMedium
                            : theme.textTheme.titleSmall)
                        ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final bool compact;

  const _Avatar({required this.photoUrl, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 42.0 : 54.0;
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF8A65), Color(0xFFE85D5D)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasPhoto
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const _AvatarFallback();
              },
            )
          : const _AvatarFallback(),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.person_rounded, color: Colors.white, size: 24);
  }
}

List<ContactRecord> _buildReconnectContacts(List<ContactRecord> contacts) {
  final sorted = [...contacts];
  sorted.sort((a, b) {
    final aScore = _stalenessDate(a);
    final bScore = _stalenessDate(b);
    return aScore.compareTo(bScore);
  });
  return sorted.take(3).toList();
}

DateTime _stalenessDate(ContactRecord contact) {
  return contact.relationship.lastInteractionAt ??
      contact.updatedAt ??
      contact.createdAt ??
      DateTime.now();
}

String _displayName(ContactRecord contact) {
  return contact.relationship.customDisplayName?.trim().isNotEmpty == true
      ? contact.relationship.customDisplayName!
      : contact.identity.displayName;
}

String _reconnectSubtitle(ContactRecord contact) {
  final days = DateTime.now().difference(_stalenessDate(contact)).inDays;
  final context = contact.relationship.contextNote?.trim();
  final role = contact.identity.jobTitle?.trim();

  if (context != null && context.isNotEmpty) {
    return context;
  }
  if (role != null && role.isNotEmpty) {
    return '$role · hace $days dias';
  }
  return days <= 0
      ? 'Sin actualizacion reciente'
      : 'Hace $days dias sin revisar';
}

String _spotlightText(ContactRecord contact) {
  final pieces = <String>[];
  final context = contact.relationship.contextNote?.trim();
  final note = contact.relationship.lastInteractionNote?.trim();
  final city = contact.identity.city?.trim();

  if (context != null && context.isNotEmpty) {
    pieces.add(context);
  }
  if (note != null && note.isNotEmpty) {
    pieces.add(note);
  }
  if (city != null && city.isNotEmpty) {
    pieces.add('En $city');
  }

  if (pieces.isEmpty) {
    return 'Hace tiempo que esta persona no recibe contexto nuevo. Revisa su ficha antes de que se enfrie la relacion.';
  }

  return pieces.take(2).join(' · ');
}
