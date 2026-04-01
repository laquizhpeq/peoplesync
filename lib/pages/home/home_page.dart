import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/app_strings.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/auth/auth_viewmodel.dart';
import 'package:peoplesync/shared/widgets/design/actions/quick_actions.dart';
import 'package:peoplesync/shared/widgets/design/card/time_reconect.dart';
import 'package:peoplesync/shared/widgets/design/header/welcome.dart';
import 'package:peoplesync/shared/widgets/design/listtile/contact_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthViewModel>(
      create: (_) => getIt<AuthViewModel>(),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const WelcomeWidget(
                title: AppStrings.dashboard,
                greeting: AppStrings.welcomeBack,
                boldText: AppStrings.appName,
              ),
              TimeReconectCard(
                leadingIcon: Icons.replay,
                title: AppStrings.timeToConnect,
                description: AppStrings.youHaventSpoken,
                footerText: AppStrings.startConversations,
                secondaryActionLabel: AppStrings.message,
                // ignore: avoid_print
                onSecondaryAction: () => print("Ir a mensajes"),
                primaryActionLabel: AppStrings.dismiss,
                // ignore: avoid_print
                onPrimaryAction: () => print("Cerrar tarjeta"),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [Text(AppStrings.quickActions)],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QuickActionsCard(
                    icon: Icons.qr_code,
                    label: AppStrings.scanQR,
                    iconColor: Colors.white,
                    circleColor: Colors.blue,
                    // ignore: avoid_print
                    onTap: () => print(AppStrings.scanQR),
                  ),
                  QuickActionsCard(
                    icon: Icons.near_me,
                    label: AppStrings.nearMe,
                    iconColor: Colors.white,
                    circleColor: Colors.blue,
                    // ignore: avoid_print
                    onTap: () => print(AppStrings.nearMe),
                  ),
                  QuickActionsCard(
                    icon: Icons.person_add,
                    label: AppStrings.addManually,
                    iconColor: Colors.white,
                    circleColor: Colors.blue,
                    // ignore: avoid_print
                    onTap: () => print(AppStrings.addManually),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(AppStrings.recentContacts),
                  Text(
                    AppStrings.viewAll,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Column(
                children: [
                  ContactItem(
                    name: 'Luis Angel',
                    subtitle: 'Trabajo',
                    imageUrl: 'https://i.pravatar.cc/150?img=12',
                  ),
                  ContactItem(
                    name: 'Sergio Moreno',
                    subtitle: 'Trabajo',
                    imageUrl: 'https://i.pravatar.cc/150?img=13',
                  ),
                  ContactItem(
                    name: 'Juan Perez',
                    subtitle: 'Trabajo',
                    imageUrl: 'https://i.pravatar.cc/150?img=14',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Consumer<AuthViewModel>(
                builder: (context, viewModel, _) => TextButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          await viewModel.logout();
                          if (!context.mounted) return;
                          context.go(Routes.login);
                        },
                  child: const Text('Cerrar sesion (dev)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
