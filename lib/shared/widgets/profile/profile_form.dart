import 'package:flutter/material.dart';
import 'package:peoplesync/features/profile/models/user_profile.dart';
import 'package:peoplesync/shared/widgets/design/buttons/app_primary_button.dart';
import 'package:peoplesync/shared/widgets/design/inputs/app_text_field.dart';

class ProfileForm extends StatefulWidget {
  final UserProfile? profile;
  final Future<void> Function(String name) onSave;
  final bool isSaving;

  const ProfileForm({
    super.key,
    required this.profile,
    required this.onSave,
    this.isSaving = false,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _roleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profile?.fullName ?? '',
    );
    _emailController = TextEditingController(text: widget.profile?.email ?? '');
    _roleController = TextEditingController(text: widget.profile?.rolId ?? '');
  }

  @override
  void didUpdateWidget(covariant ProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _nameController.text = widget.profile?.fullName ?? '';
      _emailController.text = widget.profile?.email ?? '';
      _roleController.text = widget.profile?.rolId ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Introduce tu nombre';
    }
    if (value.trim().length < 2) {
      return 'El nombre es demasiado corto';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _nameController,
            label: 'Nombre visible',
            validator: _validateName,
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _roleController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Rol',
              prefixIcon: Icon(Icons.verified_user_outlined),
            ),
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            onPressed: widget.isSaving
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) return;
                    await widget.onSave(_nameController.text.trim());
                  },
            child: widget.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Guardar perfil'),
          ),
        ],
      ),
    );
  }
}
