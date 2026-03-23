import 'package:flutter/material.dart';
import 'package:peoplesync/core/constants/app_strings.dart';
import 'package:peoplesync/features/profile/models/user_profile.dart';

class ProfileForm extends StatefulWidget {
  final UserProfile? profile;
  final void Function(String name, String phone, String bio) onSave;

  const ProfileForm({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profile?.displayName ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.profile?.phoneNumber ?? '',
    );
    _bioController = TextEditingController(text: widget.profile?.bio ?? '');
  }

  @override
  void didUpdateWidget(covariant ProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the profile data changes from the backend, update the controllers
    if (oldWidget.profile != widget.profile) {
      _nameController.text = widget.profile?.displayName ?? '';
      _phoneController.text = widget.profile?.phoneNumber ?? '';
      _bioController.text = widget.profile?.bio ?? '';
    }
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
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
        const SizedBox(height: 16),

        // Phone
        TextField(
          decoration: const InputDecoration(labelText: AppStrings.phone),
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        // Bio
        TextField(
          decoration: const InputDecoration(labelText: AppStrings.bio),
          maxLines: 3,
          controller: _bioController,
        ),
        const SizedBox(height: 24),

        // Save button
        ElevatedButton(
          onPressed: () {
            widget.onSave(
              _nameController.text.trim(),
              _phoneController.text.trim(),
              _bioController.text.trim(),
            );
          },
          child: const Text(AppStrings.saveChanges),
        ),
      ],
    );
  }
}
