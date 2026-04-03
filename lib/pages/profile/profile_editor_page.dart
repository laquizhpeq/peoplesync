import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/navigation/navigation_provider.dart';
import 'package:peoplesync/features/profile/profile_editor_viewmodel.dart';
import 'package:peoplesync/shared/widgets/profile/profile_form.dart';
import 'package:peoplesync/shared/widgets/profile/profile_section_card.dart';
import 'package:peoplesync/shared/widgets/design/layout/app_page.dart';

class ProfileEditorPage extends StatelessWidget {
  final bool isOnboarding;

  const ProfileEditorPage({super.key, this.isOnboarding = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ProfileEditorViewModel>(param1: isOnboarding),
      child: Consumer<ProfileEditorViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return isOnboarding
                ? const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  )
                : const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return isOnboarding
                ? Scaffold(body: Center(child: Text(viewModel.errorMessage!)))
                : Center(child: Text(viewModel.errorMessage!));
          }

          final content = SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ProfileSectionCard(
                  title: isOnboarding ? 'Completa tu perfil' : 'Editar perfil',
                  subtitle: isOnboarding
                      ? 'Antes de entrar en la app, deja lista tu identidad basica.'
                      : 'Actualiza tu informacion publica y tus redes cuando quieras.',
                  child: ProfileForm(
                    isOnboarding: isOnboarding,
                    primaryLabel: isOnboarding
                        ? 'Guardar y continuar'
                        : 'Guardar cambios',
                    secondaryLabel: isOnboarding ? null : 'Cancelar',
                    onSecondaryAction: isOnboarding
                        ? null
                        : () => context.pop(),
                    onSave: () async {
                      final success = await viewModel.save();
                      if (!context.mounted) return;

                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              viewModel.errorMessage ??
                                  'No se pudo guardar el perfil',
                            ),
                          ),
                        );
                        return;
                      }

                      if (isOnboarding) {
                        final uid = viewModel.profile?.uid;
                        if (uid != null) {
                          await getIt<NavigationProvider>().loadMenus(uid);
                        }
                        if (context.mounted) {
                          context.go(Routes.home);
                        }
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Perfil guardado con exito'),
                        ),
                      );
                      context.pop();
                    },
                  ),
                ),
              ),
            ),
          );

          if (isOnboarding) {
            return AppPage(title: '', centerBody: true, body: content);
          }

          return content;
        },
      ),
    );
  }
}
