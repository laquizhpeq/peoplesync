import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:peoplesync/shared/widgets/contacts/contact_avatar_placeholder.dart';
import 'package:provider/provider.dart';

class ConnectionContactCard extends StatelessWidget {
  final ContactRecord contact;

  const ConnectionContactCard({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName =
        contact.relationship.customDisplayName?.trim().isNotEmpty == true
        ? contact.relationship.customDisplayName!
        : contact.identity.displayName;
    final subtitle = _buildSubtitle(contact);
    final metaLine = _buildMetaLine(contact);
    final relationshipMode = _resolveRelationshipMode(contact);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push(
          '${Routes.connections}/contact/${contact.id}',
          extra: contact,
        ),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              _ContactPhoto(
                photoUrl: contact.identity.photoUrl,
                seed: contact.id,
                displayName: displayName,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (relationshipMode != null) ...[
                            _RelationshipModeBadge(mode: relationshipMode),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (contact.relationship.isFavorite)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.favorite_rounded,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          if (contact
                              .relationship
                              .wantsToStrengthenRelationship)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                size: 16,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          _ContactActionsMenu(contact: contact),
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (metaLine != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          metaLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelationshipModeBadge extends StatelessWidget {
  final _RelationshipMode mode;

  const _RelationshipModeBadge({required this.mode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: mode.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Icon(mode.icon, size: 14, color: mode.color),
    );
  }
}

class _ContactPhoto extends StatelessWidget {
  final String? photoUrl;
  final String seed;
  final String displayName;

  const _ContactPhoto({
    required this.photoUrl,
    required this.seed,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return Container(
      width: 64,
      height: 82,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF8A65), Color(0xFFE85D5D)],
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        child: hasPhoto
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _PhotoFallback(seed: seed, displayName: displayName);
                },
              )
            : _PhotoFallback(seed: seed, displayName: displayName),
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  final String seed;
  final String displayName;

  const _PhotoFallback({required this.seed, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return ContactAvatarPlaceholder(
      seed: seed,
      displayName: displayName,
      shape: BoxShape.rectangle,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        bottomLeft: Radius.circular(24),
      ),
      fontSize: 18,
    );
  }
}

class _ContactActionsMenu extends StatelessWidget {
  final ContactRecord contact;

  const _ContactActionsMenu({required this.contact});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ConnectionsViewModel>(context, listen: false);
    final theme = Theme.of(context);
    final isLinked = contact.linkedUserUid != null;

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz_rounded,
        size: 18,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      onSelected: (value) async {
        if (value == 'favorite') {
          await viewModel.toggleFavorite(
            contact.id,
            !contact.relationship.isFavorite,
          );
        } else if (value == 'care') {
          await viewModel.toggleStrengthenRelationship(
            contact.id,
            !contact.relationship.wantsToStrengthenRelationship,
          );
        } else if (value == 'sync') {
          await viewModel.syncContact(contact.linkedUserUid!);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Identidad sincronizada')),
            );
          }
        } else if (value == 'notes') {
          showEditNotesDialog(context, viewModel, contact);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'favorite',
          child: ListTile(
            leading: Icon(
              contact.relationship.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ),
            title: Text(
              contact.relationship.isFavorite
                  ? 'Quitar favorito'
                  : 'Marcar favorito',
            ),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        PopupMenuItem(
          value: 'care',
          child: ListTile(
            leading: Icon(
              contact.relationship.wantsToStrengthenRelationship
                  ? Icons.heart_broken_rounded
                  : Icons.auto_awesome_rounded,
            ),
            title: Text(
              contact.relationship.wantsToStrengthenRelationship
                  ? 'Quitar de relaciones a cuidar'
                  : 'Mejorar relacion',
            ),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        if (isLinked)
          const PopupMenuItem(
            value: 'sync',
            child: ListTile(
              leading: Icon(Icons.sync_rounded),
              title: Text('Sincronizar perfil'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
        const PopupMenuItem(
          value: 'notes',
          child: ListTile(
            leading: Icon(Icons.note_alt_rounded),
            title: Text('Notas privadas'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }

  static void showEditNotesDialog(
    BuildContext context,
    ConnectionsViewModel viewModel,
    ContactRecord contact,
  ) {
    final controller = TextEditingController(
      text: contact.relationship.privateNotes,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notas privadas'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Anade contexto sobre esta persona...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.updateNotes(contact.id, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

String? _buildSubtitle(ContactRecord contact) {
  if (_hasText(contact.identity.jobTitle) &&
      _hasText(contact.identity.company)) {
    return '${contact.identity.jobTitle} - ${contact.identity.company}';
  }
  if (_hasText(contact.identity.jobTitle)) return contact.identity.jobTitle;
  if (_hasText(contact.identity.company)) return contact.identity.company;
  return null;
}

String? _buildMetaLine(ContactRecord contact) {
  final parts = <String>[];
  final relationshipMode = _resolveRelationshipMode(contact);

  if (relationshipMode != null) {
    parts.add(relationshipMode.label);
  }

  if (contact.relationship.wantsToStrengthenRelationship) {
    parts.add('Relacion a cuidar');
  }
  if (_hasText(contact.identity.city)) {
    parts.add(contact.identity.city!);
  }
  if ((contact.identity.age ?? 0) > 0) {
    parts.add('${contact.identity.age} anos');
  }
  if (_hasText(contact.relationship.contextNote)) {
    parts.add(contact.relationship.contextNote!);
  }

  if (parts.isEmpty) return null;
  return parts.take(2).join(' | ');
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

class _RelationshipMode {
  final String label;
  final IconData icon;
  final Color color;

  const _RelationshipMode({
    required this.label,
    required this.icon,
    required this.color,
  });
}

_RelationshipMode? _resolveRelationshipMode(ContactRecord contact) {
  final candidates = <String>[
    contact.relationship.relationshipType ?? '',
    ...contact.relationship.lookingFor,
    ...contact.relationship.personalityTags,
  ];

  for (final candidate in candidates) {
    final mode = _relationshipModeFromText(candidate);
    if (mode != null) return mode;
  }

  return null;
}

_RelationshipMode? _relationshipModeFromText(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) return null;

  if (normalized.contains('network')) {
    return const _RelationshipMode(
      label: 'Networking',
      icon: Icons.hub_outlined,
      color: Color(0xFF3F51B5),
    );
  }
  if (normalized.contains('amist')) {
    return const _RelationshipMode(
      label: 'Amistad',
      icon: Icons.favorite_outline_rounded,
      color: Color(0xFFE85D75),
    );
  }
  if (normalized.contains('client')) {
    return const _RelationshipMode(
      label: 'Cliente',
      icon: Icons.business_center_outlined,
      color: Color(0xFFFB8C00),
    );
  }
  if (normalized.contains('colabor')) {
    return const _RelationshipMode(
      label: 'Colaboracion',
      icon: Icons.handshake_outlined,
      color: Color(0xFF00897B),
    );
  }
  if (normalized.contains('famil')) {
    return const _RelationshipMode(
      label: 'Familia',
      icon: Icons.home_outlined,
      color: Color(0xFF8E24AA),
    );
  }
  if (normalized.contains('cultiv') ||
      normalized.contains('seguir') ||
      normalized.contains('cuidar')) {
    return const _RelationshipMode(
      label: 'Seguir cultivando',
      icon: Icons.eco_outlined,
      color: Color(0xFF43A047),
    );
  }

  return null;
}
