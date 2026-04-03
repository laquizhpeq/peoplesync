import 'package:flutter/material.dart';
import 'package:peoplesync/features/contacts/contact_form_viewmodel.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';
import 'package:peoplesync/shared/widgets/design/inputs/app_text_field.dart';

class ContactSocialProfileCard extends StatelessWidget {
  final ContactSocialProfileDraft draft;
  final ValueChanged<SocialPlatform> onPlatformChanged;
  final VoidCallback onRemove;

  const ContactSocialProfileCard({
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
            hintText: '@usuario o teléfono',
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

String platformLabel(SocialPlatform platform) {
  switch (platform) {
    case SocialPlatform.instagram:
      return 'Instagram';
    case SocialPlatform.x:
      return 'X';
    case SocialPlatform.tiktok:
      return 'TikTok';
    case SocialPlatform.linkedin:
      return 'LinkedIn';
    case SocialPlatform.facebook:
      return 'Facebook';
    case SocialPlatform.telegram:
      return 'Telegram';
    case SocialPlatform.whatsapp:
      return 'WhatsApp';
    case SocialPlatform.youtube:
      return 'YouTube';
    case SocialPlatform.twitch:
      return 'Twitch';
    case SocialPlatform.snapchat:
      return 'Snapchat';
    case SocialPlatform.website:
      return 'Web personal';
    case SocialPlatform.other:
      return 'Otra';
  }
}
