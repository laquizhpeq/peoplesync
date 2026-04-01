import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/features/profile/profile_viewmodel.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/shared/widgets/profile/profile_avatar.dart';
import 'package:peoplesync/shared/widgets/profile/profile_form.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ProfileViewModel>(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.errorMessage != null) {
            return Center(child: Text(viewModel.errorMessage!));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ProfileAvatar(
                  onEditPhoto: () {
                    // ignore: avoid_print
                    print("Editar foto");
                  },
                ),
                const SizedBox(height: 20),
                ProfileForm(
                  profile: viewModel.profile,
                  onSave: (name) {
                    viewModel.updateProfile(fullName: name);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Perfil guardado con éxito'),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
