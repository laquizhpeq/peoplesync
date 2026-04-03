import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/features/profile/profile_editor_viewmodel.dart';
import 'package:peoplesync/shared/widgets/contacts/contact_form_section_card.dart';
import 'package:peoplesync/shared/widgets/contacts/contact_multiline_field.dart';
import 'package:peoplesync/shared/widgets/design/buttons/app_primary_button.dart';
import 'package:peoplesync/shared/widgets/design/inputs/app_text_field.dart';
import 'package:peoplesync/shared/widgets/profile/profile_social_profile_card.dart';

class ProfileForm extends StatelessWidget {
  final bool isOnboarding;
  final Future<void> Function() onSave;
  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryAction;

  const ProfileForm({
    super.key,
    required this.isOnboarding,
    required this.onSave,
    required this.primaryLabel,
    this.secondaryLabel,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileEditorViewModel>();
    final profile = viewModel.profile;

    return Form(
      key: viewModel.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContactFormSectionCard(
            title: 'Identidad basica',
            subtitle:
                'Esta informacion construye tu ficha principal dentro de PeopleSync.',
            child: Column(
              children: [
                AppTextField(
                  controller: viewModel.fullNameController,
                  label: 'Nombre visible',
                  validator: viewModel.validateRequiredName,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: viewModel.cityController,
                  label: 'Ciudad',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                const SizedBox(height: 16),
                ContactMultilineField(
                  controller: viewModel.bioController,
                  label: 'Bio breve',
                  icon: Icons.auto_awesome_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ContactFormSectionCard(
            title: 'Imagen y presencia',
            subtitle:
                'Puedes usar una URL de foto por ahora y anadir las redes que quieras mostrar.',
            child: Column(
              children: [
                AppTextField(
                  controller: viewModel.photoUrlController,
                  label: 'URL de la foto',
                  keyboardType: TextInputType.url,
                  prefixIcon: const Icon(Icons.image_outlined),
                ),
                const SizedBox(height: 16),
                if (profile?.email != null && profile!.email!.trim().isNotEmpty)
                  TextFormField(
                    initialValue: profile.email,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ContactFormSectionCard(
            title: 'Redes sociales',
            subtitle:
                'Comparte solo las redes que tengan sentido para tu perfil publico.',
            child: Column(
              children: [
                ...List.generate(viewModel.socialProfiles.length, (index) {
                  final draft = viewModel.socialProfiles[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == viewModel.socialProfiles.length - 1
                          ? 0
                          : 16,
                    ),
                    child: ProfileSocialProfileCard(
                      draft: draft,
                      onPlatformChanged: (platform) =>
                          viewModel.updateSocialPlatform(index, platform),
                      onRemove: () => viewModel.removeSocialProfile(index),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: viewModel.addSocialProfile,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Anadir red social'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            onPressed: viewModel.isSaving ? null : onSave,
            child: viewModel.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(primaryLabel),
          ),
          if (secondaryLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: viewModel.isSaving ? null : onSecondaryAction,
                child: Text(secondaryLabel!),
              ),
            ),
          ],
          if (isOnboarding) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Podras cambiar estos datos cuando quieras desde la pestana de perfil.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
