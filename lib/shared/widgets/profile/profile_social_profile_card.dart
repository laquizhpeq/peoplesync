import 'package:flutter/material.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:peoplesync/features/profile/profile_editor_viewmodel.dart';
import 'package:peoplesync/shared/widgets/contacts/contact_social_profile_card.dart';
import 'package:peoplesync/shared/widgets/design/inputs/app_text_field.dart';

class ProfileSocialProfileCard extends StatelessWidget {
  final ProfileSocialProfileDraft draft;
  final ValueChanged<SocialPlatform> onPlatformChanged;
  final VoidCallback onRemove;

  const ProfileSocialProfileCard({
    super.key,
    required this.draft,
    required this.onPlatformChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<SocialPlatform>(
                  initialValue: draft.platform,
                  decoration: const InputDecoration(
                    labelText: 'Red social',
                    prefixIcon: Icon(Icons.public_rounded),
                  ),
                  items: SocialPlatform.values
                      .map(
                        (platform) => DropdownMenuItem(
                          value: platform,
                          child: Text(platformLabel(platform)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) onPlatformChanged(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: draft.valueController,
            label: 'Usuario o identificador',
            hintText: '@usuario o telefono',
            prefixIcon: const Icon(Icons.alternate_email_rounded),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: draft.labelController,
            label: 'Etiqueta',
            hintText: 'Personal, trabajo, secundario...',
            prefixIcon: const Icon(Icons.label_outline_rounded),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: draft.urlController,
            label: 'URL',
            hintText: 'https://...',
            keyboardType: TextInputType.url,
            prefixIcon: const Icon(Icons.link_rounded),
          ),
        ],
      ),
    );
  }
}
