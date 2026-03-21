import 'package:flutter/material.dart';
import '../../base/inputs/base_password_field.dart';

class AppPasswordField extends BasePasswordField {
  AppPasswordField({
    super.key,
    required super.controller,
    required super.label,
    super.validator,
    Widget? customPrefixIcon, // Opción 1: Extra por parámetro
  }) : super(
         // Opción 2: Sobrescribimos la decoración para este widget específico
         decoration: InputDecoration(
           labelText: label,
           prefixIcon: customPrefixIcon ?? const Icon(Icons.lock_outline),
           // Podríamos añadir más estilos específicos aquí si quisiéramos
         ),
       );
}
