import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/features/profile/profile_viewmodel.dart';
import 'package:peoplesync/core/constants/app_strings.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/shared/widgets/base/layout/base_page.dart';
import 'package:peoplesync/shared/widgets/design/bottom_nav/bottom_nav_bar.dart';
import 'package:peoplesync/shared/widgets/profile/profile_avatar.dart';
import 'package:peoplesync/shared/widgets/profile/profile_form.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ProfileViewModel>(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, _) => BasePage(
          title: AppStrings.profile,
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.errorMessage != null
              ? Center(child: Text(viewModel.errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ProfileAvatar(
                        photoUrl: viewModel.profile?.photoUrl,
                        onEditPhoto: () {
                          // TODO: Implement image picker
                        },
                      ),
                      const SizedBox(height: 20),
                      ProfileForm(
                        profile: viewModel.profile,
                        onSave: (name, phone, bio) {
                          viewModel.updateProfile(
                            displayName: name,
                            phoneNumber: phone,
                            bio: bio,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Perfil guardado con éxito'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
          footer: const BottomNavBar(),
        ),
      ),
    );
  }
}
