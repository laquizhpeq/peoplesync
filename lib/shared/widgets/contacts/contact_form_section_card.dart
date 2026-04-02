import 'package:flutter/material.dart';

class ContactFormSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const ContactFormSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
