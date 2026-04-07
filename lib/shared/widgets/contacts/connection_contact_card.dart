import 'package:flutter/material.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:provider/provider.dart';

class ConnectionContactCard extends StatelessWidget {
  final ContactRecord contact;

  const ConnectionContactCard({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = _buildSubtitle(contact);
    final displayName =
        contact.relationship.customDisplayName?.trim().isNotEmpty == true
        ? contact.relationship.customDisplayName!
        : contact.identity.displayName;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment
            .start, // Alineación al inicio para permitir crecimiento
        children: [
          _ContactPhoto(photoUrl: contact.identity.photoUrl, name: displayName),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min, // Importante para que no pida infinito
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if ((contact.identity.age ?? 0) > 0)
                        _MiniBadge(label: '${contact.identity.age} años'),
                      _ContactActionsMenu(contact: contact),
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_hasText(contact.identity.city))
                        _MiniBadge(label: contact.identity.city!),
                      if (_hasText(contact.identity.company))
                        _MiniBadge(label: contact.identity.company!),
                      if (contact.identity.socialProfiles.isNotEmpty)
                        _MiniBadge(
                          label:
                              '${contact.identity.socialProfiles.length} redes',
                        ),
                      if (contact.relationship.interests.isNotEmpty)
                        _MiniBadge(
                          label:
                              '${contact.relationship.interests.length} intereses',
                        ),
                    ],
                  ),
                  if (_hasText(contact.identity.bio)) ...[
                    const SizedBox(height: 14),
                    Text(
                      contact.identity.bio!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
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
    );
  }
}

class _ContactPhoto extends StatelessWidget {
  final String? photoUrl;
  final String name;

  const _ContactPhoto({required this.photoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return Container(
      width: 120,
      height: 164,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo con degradado por si la imagen falla o es transparente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF8A65), Color(0xFFE85D5D)],
              ),
            ),
          ),

          if (hasPhoto)
            Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                // Si falla por CORS o cualquier cosa, mostramos el fallback
                return const _PhotoFallback();
              },
            )
          else
            const _PhotoFallback(),
        ],
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sin foto',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;

  const _MiniBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
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
        Icons.more_vert_rounded,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (value) async {
        if (value == 'sync') {
          await viewModel.syncContact(contact.linkedUserUid!);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Identidad sincronizada')),
            );
          }
        } else if (value == 'notes') {
          _showEditNotesDialog(context, viewModel, contact);
        }
      },
      itemBuilder: (context) => [
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

  void _showEditNotesDialog(
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
            hintText: 'Añade contexto sobre esta persona...',
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
    return '${contact.identity.jobTitle} · ${contact.identity.company}';
  }
  if (_hasText(contact.identity.jobTitle)) return contact.identity.jobTitle;
  if (_hasText(contact.identity.company)) return contact.identity.company;
  if (_hasText(contact.relationship.contextNote)) {
    return contact.relationship.contextNote;
  }
  return null;
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
