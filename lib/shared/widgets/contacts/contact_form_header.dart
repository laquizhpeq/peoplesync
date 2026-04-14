import 'package:flutter/material.dart';

class ContactFormHeader extends StatelessWidget {
  final bool isEditMode;

  const ContactFormHeader({super.key, required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
            theme.colorScheme.tertiary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditMode ? 'Editar contacto' : 'Nuevo contacto',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isEditMode
                ? 'Ajusta la ficha completa sin salir de tu flujo. Si un dato sobra, vacialo y se actualizara.'
                : 'Crea una ficha flexible. El modelo admite datos parciales y esta preparado para futuras importaciones por QR.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}
