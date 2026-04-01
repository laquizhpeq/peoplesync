import 'package:flutter/material.dart';

class WelcomeWidget extends StatelessWidget {
  final String title;
  final String greeting;
  final String boldText;
  final TextAlign textAlign;

  const WelcomeWidget({
    super.key,
    required this.title,
    required this.greeting,
    required this.boldText,
    this.textAlign = TextAlign.center, // Por defecto centrado
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título superior (ej: Dashboard)
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          // Texto combinado (ej: Welcome back, PeopleSync)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: greeting, style: const TextStyle(fontSize: 22)),
                const TextSpan(text: ' '), // Espacio manual
                TextSpan(
                  text: boldText,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            textAlign: textAlign,
          ),
        ],
      ),
    );
  }
}
