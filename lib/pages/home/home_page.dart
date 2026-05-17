import 'dart:math';

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
        final careContacts = _buildCareContacts(connectionsViewModel.contacts);
        final relationshipMap = _buildRelationshipMap(
          connectionsViewModel.contacts,
        );
        final spotlightContact = _pickSpotlightContact(
          connectionsViewModel.contacts,
        );

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: _QuickActionsMenu(),
                  ),
                  const SizedBox(height: 16),
                  _RelationshipMapSection(
                    totalContacts: connectionsViewModel.contacts.length,
                    mapItems: relationshipMap,
                  ),
                  const SizedBox(height: 18),
                  _CareSection(contacts: careContacts),
                  const SizedBox(height: 18),
                  _SpotlightSection(contact: spotlightContact),
                ],
              ),
            ),
            const Positioned(
              right: 18,
              bottom: 108,
              child: _AssistantFloatingButton(),
            ),
          ],
        );
      },
    );
  }
}

class _AssistantFloatingButton extends StatelessWidget {
  const _AssistantFloatingButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () => context.push(Routes.assistant),
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF8A65), Color(0xFFE85D5D)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE85D5D).withValues(alpha: 0.30),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.82),
              width: 2,
            ),
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
        ),
      ),
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
      padding: EdgeInsets.zero,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Acciones',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
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

class _RelationshipMapSection extends StatelessWidget {
  final int totalContacts;
  final List<_RelationshipMapItem> mapItems;

  const _RelationshipMapSection({
    required this.totalContacts,
    required this.mapItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = mapItems.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mapa de relaciones',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasData
                ? 'Asi se reparte tu red segun el tipo de relacion que has definido.'
                : 'Todavia no has clasificado contactos por tipo de relacion.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 280,
            child: _RelationshipMapCanvas(
              totalContacts: totalContacts,
              items: mapItems,
            ),
          ),
          if (!hasData) ...[
            const SizedBox(height: 14),
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
                totalContacts == 0
                    ? 'Todavia no hay conexiones. Cuando empieces a guardar contactos, aqui veras el total de tu red.'
                    : 'Todavia no has clasificado contactos por tipo de relacion, pero aqui ya ves el total de conexiones.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (hasData) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: mapItems
                  .map((item) => _RelationshipMapLegendChip(item: item))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _RelationshipMapCanvas extends StatelessWidget {
  final int totalContacts;
  final List<_RelationshipMapItem> items;

  const _RelationshipMapCanvas({
    required this.totalContacts,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleItems = items.take(6).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final center = Offset(size.width / 2, size.height / 2);
        final orbitRadius = min(size.width, size.height) * 0.41;
        final coreRadius = min(size.width, size.height) * 0.23;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _RelationshipOrbitPainter(
                  items: visibleItems,
                  center: center,
                  orbitRadius: orbitRadius,
                  lineColor: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.12,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: coreRadius * 2.1,
                height: coreRadius * 2.1,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF8A65), Color(0xFFE85D5D)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE85D5D).withValues(alpha: 0.24),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$totalContacts',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalContacts == 1 ? 'conexion' : 'conexiones',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...List.generate(visibleItems.length, (index) {
              final item = visibleItems[index];
              final angle =
                  (-pi / 2) + ((2 * pi) / visibleItems.length) * index;
              final nodeCenter = Offset(
                center.dx + cos(angle) * orbitRadius,
                center.dy + sin(angle) * orbitRadius,
              );

              return Positioned(
                left: nodeCenter.dx - 46,
                top: nodeCenter.dy - 28,
                child: _RelationshipMapNode(item: item),
              );
            }),
          ],
        );
      },
    );
  }
}

class _RelationshipMapNode extends StatelessWidget {
  final _RelationshipMapItem item;

  const _RelationshipMapNode({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: item.color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            '${item.count}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationshipMapLegendChip extends StatelessWidget {
  final _RelationshipMapItem item;

  const _RelationshipMapLegendChip({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 16, color: item.color),
          const SizedBox(width: 8),
          Text(
            '${item.label} ${item.count}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: item.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationshipOrbitPainter extends CustomPainter {
  final List<_RelationshipMapItem> items;
  final Offset center;
  final double orbitRadius;
  final Color lineColor;

  const _RelationshipOrbitPainter({
    required this.items,
    required this.center,
    required this.orbitRadius,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final orbitPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, orbitRadius, orbitPaint);
    canvas.drawCircle(center, orbitRadius * 0.62, orbitPaint);

    for (var index = 0; index < items.length; index++) {
      final angle = (-pi / 2) + ((2 * pi) / items.length) * index;
      final nodeCenter = Offset(
        center.dx + cos(angle) * orbitRadius,
        center.dy + sin(angle) * orbitRadius,
      );

      final linkPaint = Paint()
        ..color = items[index].color.withValues(alpha: 0.2)
        ..strokeWidth = 2;

      canvas.drawLine(center, nodeCenter, linkPaint);
      canvas.drawCircle(
        nodeCenter,
        5,
        Paint()..color = items[index].color.withValues(alpha: 0.24),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RelationshipOrbitPainter oldDelegate) {
    return oldDelegate.items != items ||
        oldDelegate.center != center ||
        oldDelegate.orbitRadius != orbitRadius ||
        oldDelegate.lineColor != lineColor;
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

List<_RelationshipMapItem> _buildRelationshipMap(List<ContactRecord> contacts) {
  final counts = <String, int>{};

  for (final contact in contacts) {
    final type = _relationshipTypeKey(contact);
    if (type == null) continue;
    counts[type] = (counts[type] ?? 0) + 1;
  }

  final items = counts.entries
      .map((entry) => _relationshipMapItemFromKey(entry.key, entry.value))
      .whereType<_RelationshipMapItem>()
      .toList();

  items.sort((a, b) => b.count.compareTo(a.count));
  return items;
}

ContactRecord? _pickSpotlightContact(List<ContactRecord> contacts) {
  if (contacts.isEmpty) return null;

  final now = DateTime.now();
  final seed = now.year * 1000 + now.month * 100 + now.day;
  final index = Random(seed).nextInt(contacts.length);
  return contacts[index];
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

class _RelationshipMapItem {
  final String key;
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _RelationshipMapItem({
    required this.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });
}

String? _relationshipTypeKey(ContactRecord contact) {
  final value = contact.relationship.relationshipType?.trim().toLowerCase();
  if (value == null || value.isEmpty) return null;

  return switch (value) {
    'networking' => 'networking',
    'amistad' => 'amistad',
    'clientes' => 'clientes',
    'colaboradores' => 'colaboradores',
    'familia' => 'familia',
    'seguir cultivando' => 'seguir cultivando',
    _ => null,
  };
}

_RelationshipMapItem? _relationshipMapItemFromKey(String key, int count) {
  switch (key) {
    case 'networking':
      return _RelationshipMapItem(
        key: 'networking',
        label: 'Networking',
        count: count,
        icon: Icons.hub_outlined,
        color: const Color(0xFF4F6BED),
      );
    case 'amistad':
      return _RelationshipMapItem(
        key: 'amistad',
        label: 'Amistad',
        count: count,
        icon: Icons.favorite_outline_rounded,
        color: const Color(0xFFE85D75),
      );
    case 'clientes':
      return _RelationshipMapItem(
        key: 'clientes',
        label: 'Clientes',
        count: count,
        icon: Icons.business_center_outlined,
        color: const Color(0xFFF2994A),
      );
    case 'colaboradores':
      return _RelationshipMapItem(
        key: 'colaboradores',
        label: 'Colaboradores',
        count: count,
        icon: Icons.handshake_outlined,
        color: const Color(0xFF1FA37A),
      );
    case 'familia':
      return _RelationshipMapItem(
        key: 'familia',
        label: 'Familia',
        count: count,
        icon: Icons.home_outlined,
        color: const Color(0xFF9B51E0),
      );
    case 'seguir cultivando':
      return _RelationshipMapItem(
        key: 'seguir cultivando',
        label: 'Seguir cultivando',
        count: count,
        icon: Icons.eco_outlined,
        color: const Color(0xFF43A047),
      );
    default:
      return null;
  }
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
