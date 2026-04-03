import 'package:flutter/material.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';

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
      constraints: const BoxConstraints(minHeight: 164),
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
      child: IntrinsicHeight(
        child: Row(
          children: [
            _ContactPhoto(
              photoUrl: contact.identity.photoUrl,
              name: displayName,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            label: '${contact.identity.socialProfiles.length} redes',
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
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        bottomLeft: Radius.circular(30),
      ),
      child: Container(
        width: 132,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF8A65), Color(0xFFE85D5D)],
          ),
        ),
        alignment: Alignment.center,
        child: hasPhoto
            ? Image.network(
                photoUrl!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _PhotoFallback(),
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

String? _buildSubtitle(ContactRecord contact) {
  if (_hasText(contact.identity.jobTitle) && _hasText(contact.identity.company)) {
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
