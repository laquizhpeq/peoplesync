import 'package:flutter/material.dart';

class BasePasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final InputDecoration? decoration; // <--- Para permitir Opción 2

  const BasePasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.decoration,
  });

  @override
  State<BasePasswordField> createState() => _BasePasswordFieldState();
}

class _BasePasswordFieldState extends State<BasePasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    // Combinamos la decoración base con el botón de visibilidad
    final effectiveDecoration =
        (widget.decoration ?? InputDecoration(labelText: widget.label))
            .copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
            );

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      decoration: effectiveDecoration,
    );
  }
}
