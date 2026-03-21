import 'package:flutter/material.dart';

abstract class BaseInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const BaseInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.validator,
  });
}
