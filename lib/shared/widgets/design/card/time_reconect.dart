import 'package:flutter/material.dart';

class TimeReconectCard extends StatelessWidget {
  final IconData leadingIcon;
  final Color? iconColor;
  final String title;
  final String description;
  final String? footerText;

  // Botón Secundario (Texto)
  final String secondaryActionLabel;
  final VoidCallback onSecondaryAction;

  // Botón Principal (Relleno)
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;

  // Personalización de color opcional
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
    return Card(
      elevation: 0,
      color: backgroundColor ?? const Color(0xFFF0F4F8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado
            Row(
              children: [
                Icon(leadingIcon, color: iconColor ?? Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Cuerpo
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], height: 1.4),
            ),

            // Texto de pie de página (opcional)
            if (footerText != null) ...[
              const SizedBox(height: 12),
              Text(
                footerText!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],

            const SizedBox(height: 20),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: onSecondaryAction,
                  child: Text(secondaryActionLabel),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: onPrimaryAction,
                  child: Text(primaryActionLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
