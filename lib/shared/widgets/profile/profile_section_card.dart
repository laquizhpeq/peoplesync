import 'package:flutter/material.dart';

class ProfileSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colors.onSurfaceVariant.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: textTheme.bodyMedium),
          ],
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
