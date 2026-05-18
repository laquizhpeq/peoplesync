import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/core/services/app_feedback_service.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:peoplesync/features/contacts/models/relationship_type_preset.dart';
import 'package:peoplesync/shared/widgets/contacts/contact_avatar_placeholder.dart';

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
    final relationshipMode = resolveRelationshipPreset(contact);
    final focusLine = _buildFocusLine(contact, relationshipMode);
    final footerLine = _buildFooterLine(contact);

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
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: (relationshipMode?.color ?? theme.colorScheme.primary)
                    .withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              _ContactPhoto(
                photoUrl: contact.identity.photoUrl,
                seed: contact.id,
                displayName: displayName,
                relationshipMode: relationshipMode,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
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
                          if (contact.relationship.wantsToStrengthenRelationship)
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
                      const SizedBox(height: 6),
                      Text(
                        focusLine,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              relationshipMode?.color ?? theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      if (footerLine != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          footerLine,
                          maxLines: 1,
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
        ),
      ),
    );
  }
}

class _ContactPhoto extends StatelessWidget {
  final String? photoUrl;
  final String seed;
  final String displayName;
  final RelationshipTypePreset? relationshipMode;

  const _ContactPhoto({
    required this.photoUrl,
    required this.seed,
    required this.displayName,
    required this.relationshipMode,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;
    final gradient = relationshipMode?.gradient ??
        const [Color(0xFFFF8A65), Color(0xFFE85D5D)];

    return Container(
      width: 94,
      height: 118,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradient,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            hasPhoto
                ? Image.network(
                    photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _PhotoFallback(
                        seed: seed,
                        displayName: displayName,
                      );
                    },
                  )
                : _PhotoFallback(seed: seed, displayName: displayName),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.42),
                  ],
                ),
              ),
            ),
            if (relationshipMode != null)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        relationshipMode!.icon,
                        size: 13,
                        color: relationshipMode!.color,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        relationshipMode!.label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: relationshipMode!.color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
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
          AppFeedbackService.showInfo('Identidad sincronizada.');
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

String _buildFocusLine(
  ContactRecord contact,
  RelationshipTypePreset? relationshipMode,
) {
  if (_hasText(contact.relationship.contextNote)) {
    return contact.relationship.contextNote!;
  }
  if (_hasText(contact.relationship.lastInteractionNote)) {
    return contact.relationship.lastInteractionNote!;
  }
  if (_hasText(contact.identity.about)) {
    return contact.identity.about!;
  }
  if (_hasText(contact.identity.bio)) {
    return contact.identity.bio!;
  }
  if (relationshipMode != null) {
    return 'Relacion enfocada en ${relationshipMode.label.toLowerCase()}.';
  }
  if (_hasText(contact.identity.jobTitle) && _hasText(contact.identity.company)) {
    return '${contact.identity.jobTitle} en ${contact.identity.company}';
  }
  if (_hasText(contact.identity.jobTitle)) {
    return contact.identity.jobTitle!;
  }
  return 'Todavia falta contexto fuerte en esta ficha.';
}

String? _buildFooterLine(ContactRecord contact) {
  final parts = <String>[];

  if (_hasText(contact.identity.city)) {
    parts.add(contact.identity.city!);
  }
  if (_hasText(contact.identity.jobTitle)) {
    parts.add(contact.identity.jobTitle!);
  }
  if (contact.relationship.wantsToStrengthenRelationship) {
    parts.add('A cuidar');
  }
  if (contact.relationship.isFavorite) {
    parts.add('Favorito');
  }

  if (parts.isEmpty) return null;
  return parts.take(2).join(' · ');
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
