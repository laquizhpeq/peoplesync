import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/contacts/connections_viewmodel.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetailPage extends StatelessWidget {
  final String? contactId;
  final ContactRecord? initialContact;

  const ContactDetailPage({super.key, this.contactId, this.initialContact});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ConnectionsViewModel>(
      create: (_) => getIt<ConnectionsViewModel>(),
      child: Consumer<ConnectionsViewModel>(
        builder: (context, viewModel, _) {
          final contact = _resolveContact(
            viewModel.contacts,
            contactId,
            initialContact,
          );

          if (contact == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_search_rounded, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      'No se encontro este contacto',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.go(Routes.connections),
                      child: const Text('Volver a conexiones'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _ContactDetailView(contact: contact);
        },
      ),
    );
  }

  ContactRecord? _resolveContact(
    List<ContactRecord> contacts,
    String? contactId,
    ContactRecord? initialContact,
  ) {
    for (final contact in contacts) {
      if (contact.id == contactId) return contact;
    }

    if (initialContact == null) return null;

    for (final contact in contacts) {
      if (contact.id == initialContact.id) return contact;
    }

    return initialContact;
  }
}

class _ContactDetailView extends StatelessWidget {
  final ContactRecord contact;

  const _ContactDetailView({required this.contact});

  @override
  Widget build(BuildContext context) {
    final essentialItems = _essentialItems(contact);
    final directItems = _directContactItems(contact);
    final interests = contact.relationship.interests;
    final lookingFor = contact.relationship.lookingFor;
    final personalityTags = contact.relationship.personalityTags;
    final socialProfiles = contact.identity.socialProfiles;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroCard(
            contact: contact,
            name: _displayName(contact),
            subtitle: _subtitle(contact),
          ),
          const SizedBox(height: 18),
          _ActionRow(contact: contact),
          if (directItems.isNotEmpty) ...[
            const SizedBox(height: 18),
            _DetailSection(
              title: 'Contacto directo',
              child: _InfoGrid(items: directItems),
            ),
          ],
          if (essentialItems.isNotEmpty) ...[
            const SizedBox(height: 18),
            _DetailSection(
              title: 'Lo esencial',
              child: _InfoGrid(items: essentialItems),
            ),
          ],
          if (_hasText(contact.relationship.contextNote) ||
              _hasText(contact.identity.bio) ||
              _hasText(contact.identity.about)) ...[
            const SizedBox(height: 18),
            _DetailSection(
              title: 'Contexto',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hasText(contact.relationship.contextNote))
                    _TextBlock(
                      label: 'Como os conocisteis',
                      value: contact.relationship.contextNote!,
                    ),
                  if (_hasText(contact.identity.bio)) ...[
                    if (_hasText(contact.relationship.contextNote))
                      const SizedBox(height: 14),
                    _TextBlock(
                      label: 'Bio breve',
                      value: contact.identity.bio!,
                    ),
                  ],
                  if (_hasText(contact.identity.about)) ...[
                    if (_hasText(contact.relationship.contextNote) ||
                        _hasText(contact.identity.bio))
                      const SizedBox(height: 14),
                    _TextBlock(
                      label: 'Como es esta persona',
                      value: contact.identity.about!,
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (interests.isNotEmpty ||
              lookingFor.isNotEmpty ||
              personalityTags.isNotEmpty ||
              _hasText(contact.identity.favoriteSong)) ...[
            const SizedBox(height: 18),
            _DetailSection(
              title: 'Afinidades',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hasText(contact.identity.favoriteSong))
                    _InfoStrip(
                      icon: Icons.music_note_rounded,
                      label: 'Cancion favorita',
                      value: contact.identity.favoriteSong!,
                    ),
                  if (_hasText(contact.identity.favoriteSong) &&
                      (interests.isNotEmpty ||
                          lookingFor.isNotEmpty ||
                          personalityTags.isNotEmpty))
                    const SizedBox(height: 14),
                  if (interests.isNotEmpty)
                    _ChipGroup(title: 'Intereses', values: interests),
                  if (interests.isNotEmpty &&
                      (lookingFor.isNotEmpty || personalityTags.isNotEmpty))
                    const SizedBox(height: 14),
                  if (lookingFor.isNotEmpty)
                    _ChipGroup(
                      title: 'Que representa esta relacion',
                      values: lookingFor,
                    ),
                  if (lookingFor.isNotEmpty && personalityTags.isNotEmpty)
                    const SizedBox(height: 14),
                  if (personalityTags.isNotEmpty)
                    _ChipGroup(
                      title: 'Tags de personalidad',
                      values: personalityTags,
                    ),
                ],
              ),
            ),
          ],
          if (socialProfiles.isNotEmpty) ...[
            const SizedBox(height: 18),
            _DetailSection(
              title: 'Redes',
              child: Column(
                children: socialProfiles
                    .map(
                      (profile) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SocialRow(
                          label: _platformLabel(profile.platform),
                          value: profile.label?.trim().isNotEmpty == true
                              ? profile.label!
                              : profile.value,
                          platform: profile.platform,
                          secondaryValue: profile.url,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          if (_hasText(contact.relationship.privateNotes) ||
              _hasText(contact.relationship.lastInteractionNote) ||
              contact.relationship.lastInteractionAt != null) ...[
            const SizedBox(height: 18),
            _DetailSection(
              title: 'Memoria privada',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hasText(contact.relationship.privateNotes))
                    _TextBlock(
                      label: 'Notas privadas',
                      value: contact.relationship.privateNotes!,
                    ),
                  if (_hasText(contact.relationship.privateNotes) &&
                      (_hasText(contact.relationship.lastInteractionNote) ||
                          contact.relationship.lastInteractionAt != null))
                    const SizedBox(height: 14),
                  if (_hasText(contact.relationship.lastInteractionNote))
                    _TextBlock(
                      label: 'Ultima nota',
                      value: contact.relationship.lastInteractionNote!,
                    ),
                  if (_hasText(contact.relationship.lastInteractionNote) &&
                      contact.relationship.lastInteractionAt != null)
                    const SizedBox(height: 14),
                  if (contact.relationship.lastInteractionAt != null)
                    _InfoStrip(
                      icon: Icons.schedule_rounded,
                      label: 'Ultima interaccion',
                      value: _formatDateTime(
                        contact.relationship.lastInteractionAt,
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          _DangerSection(contact: contact),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final ContactRecord contact;
  final String name;
  final String? subtitle;

  const _HeroCard({
    required this.contact,
    required this.name,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUrl = contact.identity.photoUrl;
    final hasPhoto = photoUrl != null && photoUrl.trim().isNotEmpty;

    return Container(
      height: 430,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF8A65), Color(0xFFE85D5D)],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasPhoto)
            Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const _HeroFallback();
              },
            )
          else
            const _HeroFallback(),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.12),
                  Colors.black.withValues(alpha: 0.02),
                  Colors.black.withValues(alpha: 0.72),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _HeroIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => context.pop(),
                    ),
                    const Spacer(),
                    _HeroIconButton(
                      icon: Icons.edit_rounded,
                      onTap: () => context.push(
                        Routes.contactEdit(contact.id),
                        extra: contact,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (contact.relationship.isFavorite)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Favorito',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.person_rounded,
        size: 120,
        color: Colors.white.withValues(alpha: 0.85),
      ),
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeroIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final ContactRecord contact;

  const _ActionRow({required this.contact});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ConnectionsViewModel>(context, listen: false);

    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () => _showNotesDialog(context, viewModel, contact),
            icon: const Icon(Icons.note_alt_rounded),
            label: const Text('Notas'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => viewModel.toggleFavorite(
              contact.id,
              !contact.relationship.isFavorite,
            ),
            icon: Icon(
              contact.relationship.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ),
            label: Text(
              contact.relationship.isFavorite ? 'Favorito' : 'Guardar',
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailSection({required this.title, required this.child});

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
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final List<_InfoItemData> items;

  const _InfoGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _gridColumns(constraints.maxWidth, items.length);
        const spacing = 10.0;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: _InfoCard(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final _InfoItemData item;

  const _InfoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap == null ? null : () => item.onTap!(context),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.42,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(item.icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.value,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final String label;
  final String value;

  const _TextBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _InfoStrip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoStrip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.42,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
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
          ),
        ],
      ),
    );
  }
}

class _ChipGroup extends StatelessWidget {
  final String title;
  final List<String> values;

  const _ChipGroup({required this.title, required this.values});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((value) => _TagChip(label: value)).toList(),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DangerSection extends StatelessWidget {
  final ContactRecord contact;

  const _DangerSection({required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestionar ficha',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Editar es reversible. Eliminar no. Si borras la ficha, pierdes contexto, notas y estructura guardada.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmDelete(context, contact),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Eliminar contacto'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialRow extends StatelessWidget {
  final String label;
  final String value;
  final SocialPlatform platform;
  final String? secondaryValue;

  const _SocialRow({
    required this.label,
    required this.value,
    required this.platform,
    this.secondaryValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openSocialProfile(
          context,
          platform: platform,
          value: value,
          url: secondaryValue,
        ),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                _socialPlatformIcon(platform),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              if (_hasText(secondaryValue)) ...[
                const SizedBox(height: 4),
                Text(
                  secondaryValue!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItemData {
  final IconData icon;
  final String label;
  final String value;
  final Future<void> Function(BuildContext context)? onTap;

  const _InfoItemData({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });
}

int _gridColumns(double maxWidth, int itemCount) {
  if (itemCount <= 1) return 1;
  if (maxWidth < 420) return itemCount == 2 ? 2 : 1;
  if (itemCount == 2) return 2;
  if (itemCount == 4) return 2;
  if (maxWidth >= 720 && itemCount >= 3) return 3;
  return 2;
}

IconData _socialPlatformIcon(SocialPlatform platform) {
  switch (platform) {
    case SocialPlatform.instagram:
      return Icons.camera_alt_rounded;
    case SocialPlatform.x:
      return Icons.alternate_email_rounded;
    case SocialPlatform.tiktok:
      return Icons.music_video_rounded;
    case SocialPlatform.linkedin:
      return Icons.business_center_rounded;
    case SocialPlatform.facebook:
      return Icons.thumb_up_alt_rounded;
    case SocialPlatform.telegram:
      return Icons.send_rounded;
    case SocialPlatform.whatsapp:
      return Icons.chat_rounded;
    case SocialPlatform.youtube:
      return Icons.play_circle_fill_rounded;
    case SocialPlatform.twitch:
      return Icons.videogame_asset_rounded;
    case SocialPlatform.snapchat:
      return Icons.flash_on_rounded;
    case SocialPlatform.website:
      return Icons.language_rounded;
    case SocialPlatform.other:
      return Icons.public_rounded;
  }
}

Future<void> _openExternalUri(BuildContext context, Uri uri) async {
  final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (success || !context.mounted) return;

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('No se pudo abrir el enlace')));
}

Future<void> _openSocialProfile(
  BuildContext context, {
  required SocialPlatform platform,
  required String value,
  String? url,
}) async {
  final preparedUrl = _buildSocialUrl(
    platform: platform,
    value: value,
    explicitUrl: url,
  );

  if (preparedUrl == null) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay un perfil valido para abrir')),
    );
    return;
  }

  await _openExternalUri(context, preparedUrl);
}

void _showNotesDialog(
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

Future<void> _confirmDelete(BuildContext context, ContactRecord contact) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Eliminar contacto'),
      content: Text(
        'Vas a eliminar a ${_displayName(contact)}. Se borraran sus notas y el contexto guardado.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final viewModel = Provider.of<ConnectionsViewModel>(context, listen: false);
  final error = await viewModel.deleteContact(contact.id);

  if (!context.mounted) return;

  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    return;
  }

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Contacto eliminado')));
  context.go(Routes.connections);
}

String _displayName(ContactRecord contact) {
  return contact.relationship.customDisplayName?.trim().isNotEmpty == true
      ? contact.relationship.customDisplayName!
      : contact.identity.displayName;
}

String? _subtitle(ContactRecord contact) {
  if (_hasText(contact.identity.jobTitle) &&
      _hasText(contact.identity.company)) {
    return '${contact.identity.jobTitle} - ${contact.identity.company}';
  }
  if (_hasText(contact.identity.jobTitle)) return contact.identity.jobTitle;
  if (_hasText(contact.identity.company)) return contact.identity.company;
  if (_hasText(contact.identity.city)) return contact.identity.city;
  return null;
}

List<_InfoItemData> _essentialItems(ContactRecord contact) {
  final items = <_InfoItemData>[];

  if (_hasText(contact.identity.city)) {
    items.add(
      _InfoItemData(
        icon: Icons.location_on_outlined,
        label: 'Ciudad',
        value: contact.identity.city!,
      ),
    );
  }
  if ((contact.identity.age ?? 0) > 0) {
    items.add(
      _InfoItemData(
        icon: Icons.cake_outlined,
        label: 'Edad',
        value: '${contact.identity.age} anos',
      ),
    );
  }
  if (contact.identity.birthday != null) {
    items.add(
      _InfoItemData(
        icon: Icons.event_outlined,
        label: 'Cumpleanos',
        value: _formatDate(contact.identity.birthday),
      ),
    );
  }
  if (_hasText(contact.identity.company)) {
    items.add(
      _InfoItemData(
        icon: Icons.apartment_rounded,
        label: 'Empresa',
        value: contact.identity.company!,
      ),
    );
  }
  if (_hasText(contact.identity.jobTitle)) {
    items.add(
      _InfoItemData(
        icon: Icons.work_outline_rounded,
        label: 'Cargo',
        value: contact.identity.jobTitle!,
      ),
    );
  }
  if (_hasText(contact.relationship.relationshipType)) {
    items.add(
      _InfoItemData(
        icon: Icons.people_alt_outlined,
        label: 'Relacion',
        value: contact.relationship.relationshipType!,
      ),
    );
  }

  return items;
}

List<_InfoItemData> _directContactItems(ContactRecord contact) {
  final items = <_InfoItemData>[];

  if (_hasText(contact.identity.email)) {
    items.add(
      _InfoItemData(
        icon: Icons.alternate_email_rounded,
        label: 'Email',
        value: contact.identity.email!,
        onTap: (context) => _openExternalUri(
          context,
          Uri(scheme: 'mailto', path: contact.identity.email!),
        ),
      ),
    );
  }
  if (_hasText(contact.identity.phone)) {
    final sanitizedPhone = contact.identity.phone!.replaceAll(
      RegExp(r'[^0-9+]'),
      '',
    );

    items.add(
      _InfoItemData(
        icon: Icons.phone_outlined,
        label: 'Telefono',
        value: contact.identity.phone!,
        onTap: (context) =>
            _openExternalUri(context, Uri(scheme: 'tel', path: sanitizedPhone)),
      ),
    );
  }

  return items;
}

String _platformLabel(SocialPlatform platform) {
  switch (platform) {
    case SocialPlatform.instagram:
      return 'Instagram';
    case SocialPlatform.x:
      return 'X';
    case SocialPlatform.tiktok:
      return 'TikTok';
    case SocialPlatform.linkedin:
      return 'LinkedIn';
    case SocialPlatform.facebook:
      return 'Facebook';
    case SocialPlatform.telegram:
      return 'Telegram';
    case SocialPlatform.whatsapp:
      return 'WhatsApp';
    case SocialPlatform.youtube:
      return 'YouTube';
    case SocialPlatform.twitch:
      return 'Twitch';
    case SocialPlatform.snapchat:
      return 'Snapchat';
    case SocialPlatform.website:
      return 'Web';
    case SocialPlatform.other:
      return 'Otra';
  }
}

Uri? _buildSocialUrl({
  required SocialPlatform platform,
  required String value,
  String? explicitUrl,
}) {
  final trimmedUrl = explicitUrl?.trim() ?? '';
  if (trimmedUrl.isNotEmpty) {
    final parsed = Uri.tryParse(trimmedUrl);
    if (parsed != null) {
      if (parsed.hasScheme) return parsed;
      return Uri.tryParse('https://$trimmedUrl');
    }
  }

  final rawValue = value.trim();
  if (rawValue.isEmpty) return null;
  final normalizedValue = rawValue.replaceAll('@', '').trim();

  switch (platform) {
    case SocialPlatform.instagram:
      return Uri.parse('https://www.instagram.com/$normalizedValue');
    case SocialPlatform.x:
      return Uri.parse('https://x.com/$normalizedValue');
    case SocialPlatform.tiktok:
      final handle = rawValue.startsWith('@') ? rawValue : '@$normalizedValue';
      return Uri.parse('https://www.tiktok.com/$handle');
    case SocialPlatform.linkedin:
      return Uri.parse('https://www.linkedin.com/in/$normalizedValue');
    case SocialPlatform.facebook:
      return Uri.parse('https://www.facebook.com/$normalizedValue');
    case SocialPlatform.telegram:
      return Uri.parse('https://t.me/$normalizedValue');
    case SocialPlatform.whatsapp:
      final digits = rawValue.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.isEmpty) return null;
      return Uri.parse('https://wa.me/$digits');
    case SocialPlatform.youtube:
      if (rawValue.startsWith('@')) {
        return Uri.parse('https://www.youtube.com/$rawValue');
      }
      return Uri.https('www.youtube.com', '/results', {
        'search_query': rawValue,
      });
    case SocialPlatform.twitch:
      return Uri.parse('https://www.twitch.tv/$normalizedValue');
    case SocialPlatform.snapchat:
      return Uri.parse('https://www.snapchat.com/add/$normalizedValue');
    case SocialPlatform.website:
      final parsed = Uri.tryParse(rawValue);
      if (parsed == null) return null;
      if (parsed.hasScheme) return parsed;
      return Uri.tryParse('https://$rawValue');
    case SocialPlatform.other:
      return Uri.https('www.google.com', '/search', {'q': rawValue});
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '-';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String _formatDateTime(DateTime? date) {
  if (date == null) return '-';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/${date.year} $hour:$minute';
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
