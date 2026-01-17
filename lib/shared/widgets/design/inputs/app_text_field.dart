import '../../base/inputs/base_text_field.dart';

class AppTextField extends BaseTextField {
  const AppTextField({
    super.key,
    required super.controller,
    required super.label,
    super.keyboardType,
    super.validator,
  });
}
