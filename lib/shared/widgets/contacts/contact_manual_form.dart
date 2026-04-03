import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/features/contacts/contact_form_viewmodel.dart';
import 'package:peoplesync/shared/widgets/contacts/contact_form_header.dart';
import 'package:peoplesync/shared/widgets/contacts/contact_form_section_card.dart';
import 'package:peoplesync/shared/widgets/contacts/contact_multiline_field.dart';
import 'package:peoplesync/shared/widgets/contacts/contact_social_profile_card.dart';
import 'package:peoplesync/shared/widgets/design/buttons/app_primary_button.dart';
import 'package:peoplesync/shared/widgets/design/inputs/app_text_field.dart';

class ContactManualForm extends StatelessWidget {
  final VoidCallback onCancel;
  final Future<void> Function() onSubmit;

  const ContactManualForm({
    super.key,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ContactFormViewModel>();

    return Form(
      key: viewModel.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContactFormHeader(),
          const SizedBox(height: 20),
          ContactFormSectionCard(
            title: 'Identidad',
            subtitle:
                'Solo el nombre es obligatorio. El resto puede completarse despues o llegar desde una importacion.',
            child: Column(
              children: [
                AppTextField(
                  controller: viewModel.identityDisplayNameController,
                  label: 'Nombre visible',
                  validator: viewModel.validateRequiredName,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: viewModel.identityAgeController,
                        label: 'Edad',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.cake_outlined),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: viewModel.identityCityController,
                        label: 'Ciudad',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ContactMultilineField(
                  controller: viewModel.identityBioController,
                  label: 'Bio breve',
                  icon: Icons.auto_awesome_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ContactFormSectionCard(
            title: 'Identidad extendida',
            subtitle:
                'Datos base del contacto que puedes conocer, importar o editar sin tocar tu capa privada.',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: viewModel.identityCompanyController,
                        label: 'Empresa',
                        prefixIcon: const Icon(Icons.apartment_rounded),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: viewModel.identityJobTitleController,
                        label: 'Cargo',
                        prefixIcon: const Icon(Icons.work_outline_rounded),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ContactMultilineField(
                  controller: viewModel.identityAboutController,
                  label: 'Como es esta persona',
                  icon: Icons.favorite_border_rounded,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: viewModel.identityFavoriteSongController,
                  label: 'Cancion favorita',
                  prefixIcon: const Icon(Icons.music_note_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ContactFormSectionCard(
            title: 'Relacion privada',
            subtitle:
                'Todo lo que solo tu sabes o quieres recordar sobre esta conexion.',
            child: Column(
              children: [
                AppTextField(
                  controller: viewModel.relationshipInterestsController,
                  label: 'Intereses',
                  hintText: 'cine, viajes, cafe',
                  prefixIcon: const Icon(Icons.interests_outlined),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: viewModel.relationshipLookingForController,
                  label: 'Que representa esta relacion',
                  hintText: 'amistad, networking, colaboracion',
                  prefixIcon: const Icon(Icons.explore_outlined),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: viewModel.relationshipPersonalityTagsController,
                  label: 'Tags de personalidad',
                  hintText: 'cercana, creativa, curiosa',
                  prefixIcon: const Icon(Icons.sell_outlined),
                ),
                const SizedBox(height: 16),
                ContactMultilineField(
                  controller: viewModel.relationshipContextNoteController,
                  label: 'Como os conocisteis',
                  icon: Icons.handshake_outlined,
                ),
                const SizedBox(height: 16),
                ContactMultilineField(
                  controller:
                      viewModel.relationshipLastInteractionNoteController,
                  label: 'Ultima nota o recuerdo',
                  icon: Icons.history_edu_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ContactFormSectionCard(
            title: 'Contacto directo',
            subtitle:
                'Campos opcionales para enriquecer la identidad sin obligar a completar la ficha entera.',
            child: Column(
              children: [
                AppTextField(
                  controller: viewModel.identityEmailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: viewModel.identityPhoneController,
                  label: 'Telefono',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ContactFormSectionCard(
            title: 'Redes sociales',
            subtitle: 'Anade una a una las redes que conozcas de este contacto.',
            child: Column(
              children: [
                ...List.generate(viewModel.socialProfiles.length, (index) {
                  final profile = viewModel.socialProfiles[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == viewModel.socialProfiles.length - 1
                          ? 0
                          : 16,
                    ),
                    child: ContactSocialProfileCard(
                      draft: profile,
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
            onPressed: viewModel.isSaving ? null : onSubmit,
            child: viewModel.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Guardar contacto'),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: viewModel.isSaving ? null : onCancel,
              child: const Text('Cancelar'),
            ),
          ),
        ],
      ),
    );
  }
}
