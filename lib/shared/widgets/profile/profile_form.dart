import 'package:flutter/material.dart';
import 'package:peoplesync/core/constants/app_strings.dart';
import 'package:peoplesync/features/profile/models/user_profile.dart';

class ProfileForm extends StatefulWidget {
  final UserProfile? profile;
  final void Function(String name) onSave;

  const ProfileForm({super.key, required this.profile, required this.onSave});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profile?.full_name ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant ProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _nameController.text = widget.profile?.full_name ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display Name
        TextField(
          decoration: const InputDecoration(labelText: AppStrings.name),
          controller: _nameController,
        ),
        const SizedBox(height: 24),

        // Save button
        ElevatedButton(
          onPressed: () {
            widget.onSave(_nameController.text.trim());
          },
          child: const Text(AppStrings.saveChanges),
        ),
      ],
    );
  }
}
