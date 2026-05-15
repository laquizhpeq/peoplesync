import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:peoplesync/features/qr_code/widgets/scanner_dialog.dart';
import 'package:peoplesync/shared/widgets/contacts/contact_avatar_placeholder.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectionsViewModel>(
      builder: (context, connectionsViewModel, _) {
        final reconnectContacts = _buildReconnectContacts(
          connectionsViewModel.contacts,
        );
        final careContacts = _buildCareContacts(connectionsViewModel.contacts);
        final spotlightContact = reconnectContacts.isNotEmpty
            ? reconnectContacts.first
            : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: _QuickActionsMenu(),
              ),
              const SizedBox(height: 16),
              _ReconnectSection(contacts: reconnectContacts),
              const SizedBox(height: 18),
              _CareSection(contacts: careContacts),
              const SizedBox(height: 18),
              _SpotlightSection(contact: spotlightContact),
            ],
          ),
        );
      },
    );
  }
}

enum _QuickAction { connections, addContact, scan, importContacts }

class _QuickActionsMenu extends StatelessWidget {
  const _QuickActionsMenu();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<_QuickAction>(
      tooltip: 'Accesos rapidos',
      onSelected: (action) => _handleAction(context, action),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: theme.colorScheme.surface,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _QuickAction.connections,
          child: _QuickActionMenuItem(
            icon: Icons.groups_rounded,
            label: 'Conexiones',
          ),
        ),
        PopupMenuItem(
          value: _QuickAction.addContact,
          child: _QuickActionMenuItem(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Anadir contacto',
          ),
        ),
        PopupMenuItem(
          value: _QuickAction.scan,
          child: _QuickActionMenuItem(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Escanear QR',
          ),
        ),
        PopupMenuItem(
          value: _QuickAction.importContacts,
          child: _QuickActionMenuItem(
            icon: Icons.cloud_download_rounded,
            label: 'Importar contactos',
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flash_on_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Acceso rapido',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, _QuickAction action) {
    switch (action) {
      case _QuickAction.connections:
        context.go(Routes.connections);
        break;
      case _QuickAction.addContact:
        context.go(Routes.contactNew);
        break;
      case _QuickAction.scan:
        ScannerDialog.show(context);
        break;
      case _QuickAction.importContacts:
        context.go(Routes.contactSync);
        break;
    }
  }
}

class _QuickActionMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickActionMenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: colors.primary, size: 20),
        const SizedBox(width: 12),
        Text(label),
      ],
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
              _Avatar(
                photoUrl: contact.identity.photoUrl,
                seed: contact.id,
                displayName: name,
                compact: true,
              ),
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
                _Avatar(
                  photoUrl: contact!.identity.photoUrl,
                  seed: contact!.id,
                  displayName: _displayName(contact!),
                ),
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

class _CareSection extends StatelessWidget {
  final List<ContactRecord> contacts;

  const _CareSection({required this.contacts});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Relaciones a cuidar',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Contactos que has marcado manualmente para reforzar la relacion.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (contacts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Cuando marques contactos para cuidar, apareceran aqui.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Column(
              children: contacts
                  .take(3)
                  .map(
                    (contact) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CareItem(contact: contact),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _CareItem extends StatelessWidget {
  final ContactRecord contact;

  const _CareItem({required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go('${Routes.connections}/contact/${contact.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Avatar(
                photoUrl: contact.identity.photoUrl,
                seed: contact.id,
                displayName: _displayName(contact),
                compact: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName(contact),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _careSubtitle(contact),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
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
  final String seed;
  final String displayName;
  final bool compact;

  const _Avatar({
    required this.photoUrl,
    required this.seed,
    required this.displayName,
    this.compact = false,
  });

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
                return _AvatarFallback(seed: seed, displayName: displayName);
              },
            )
          : _AvatarFallback(seed: seed, displayName: displayName),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String seed;
  final String displayName;

  const _AvatarFallback({required this.seed, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return ContactAvatarPlaceholder(
      seed: seed,
      displayName: displayName,
      fontSize: 16,
    );
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

List<ContactRecord> _buildCareContacts(List<ContactRecord> contacts) {
  final filtered = contacts
      .where((contact) => contact.relationship.wantsToStrengthenRelationship)
      .toList();
  filtered.sort((a, b) {
    final aDate = _stalenessDate(a);
    final bDate = _stalenessDate(b);
    return aDate.compareTo(bDate);
  });
  return filtered;
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

String _careSubtitle(ContactRecord contact) {
  final pieces = <String>[];
  final context = contact.relationship.contextNote?.trim();
  final note = contact.relationship.lastInteractionNote?.trim();
  final role = contact.identity.jobTitle?.trim();

  if (context != null && context.isNotEmpty) {
    pieces.add(context);
  } else if (role != null && role.isNotEmpty) {
    pieces.add(role);
  }

  if (note != null && note.isNotEmpty) {
    pieces.add(note);
  }

  if (pieces.isEmpty) {
    return 'Marcado manualmente para no dejar enfriar esta relacion.';
  }

  return pieces.take(2).join(' - ');
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
