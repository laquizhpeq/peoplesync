import 'package:flutter/material.dart';

class TimeReconectCard extends StatelessWidget {
  final IconData leadingIcon;
  final Color? iconColor;
  final String title;
  final String description;
  final String? footerText;
  final String secondaryActionLabel;
  final VoidCallback onSecondaryAction;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final Color? backgroundColor;

  const TimeReconectCard({
    super.key,
    required this.leadingIcon,
    this.iconColor,
    required this.title,
    required this.description,
    this.footerText,
    required this.secondaryActionLabel,
    required this.onSecondaryAction,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            theme.colorScheme.surface.withValues(alpha: 0.96),
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(leadingIcon, color: iconColor ?? Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(description, style: theme.textTheme.bodyMedium),
          if (footerText != null) ...[
            const SizedBox(height: 12),
            Text(
              footerText!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton(
                onPressed: onSecondaryAction,
                child: Text(secondaryActionLabel),
              ),
              ElevatedButton(
                onPressed: onPrimaryAction,
                child: Text(primaryActionLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
