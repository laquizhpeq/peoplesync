import 'package:flutter/material.dart';

class ContactItem extends StatelessWidget {
  final String name;
  final String subtitle;
  final String imageUrl;

  const ContactItem({
    super.key,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.primary,
          ),
        ),
        onTap: () {},
      ),
    );
  }
}
