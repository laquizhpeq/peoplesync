import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
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
              _ContactPhoto(photoUrl: contact.identity.photoUrl),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
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

class _ContactPhoto extends StatelessWidget {
  final String? photoUrl;

  const _ContactPhoto({required this.photoUrl});

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
                  return const _PhotoFallback();
                },
              )
            : const _PhotoFallback(),
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.person_rounded,
        color: Colors.white.withValues(alpha: 0.88),
        size: 24,
      ),
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
