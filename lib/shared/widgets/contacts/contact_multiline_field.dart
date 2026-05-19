import 'package:flutter/material.dart';

class ContactMultilineField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hintText;

  const ContactMultilineField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: 3,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: Icon(icon),
        ),
      ),
    );
  }
}
