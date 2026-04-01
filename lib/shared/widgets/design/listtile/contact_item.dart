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
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 4.0,
      ), // Espacio entre tarjetas
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8), // Ese color gris azulado muy clarito
        borderRadius: BorderRadius.circular(40), // Bordes estilo cápsula
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.black26,
          size: 10,
        ),
        onTap: () {
          // Acción al tocar el contacto
        },
      ),
    );
  }
}
