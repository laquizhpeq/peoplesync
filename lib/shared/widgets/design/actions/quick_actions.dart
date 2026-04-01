import 'package:flutter/material.dart';

class QuickActionsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color circleColor;
  final VoidCallback onTap;

  const QuickActionsCard({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.circleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Sombra suave
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          24,
        ), // Bordes muy redondeados como en la imagen
      ),
      child: InkWell(
        // Para que sea pulsable con efecto visual
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // El círculo con el icono
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: circleColor, // Color de fondo del círculo
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(
                height: 10,
              ), // Espacio vertical entre icono y texto
              // El texto descriptivo
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
