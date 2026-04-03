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
    final theme = Theme.of(context);

    return ChangeNotifierProvider<AuthViewModel>(
      create: (_) => getIt<AuthViewModel>(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeWidget(
              title: AppStrings.dashboard,
              greeting: AppStrings.welcomeBack,
              boldText: AppStrings.appName,
            ),
            const SizedBox(height: 18),
            TimeReconectCard(
              leadingIcon: Icons.replay_rounded,
              title: AppStrings.timeToConnect,
              description:
                  'Revisa fichas que llevan tiempo sin actualizar y mantén tu red personal con más contexto y mejor memoria.',
              footerText: AppStrings.startConversations,
              secondaryActionLabel: AppStrings.dismiss,
              onSecondaryAction: () => debugPrint('Cerrar tarjeta'),
              primaryActionLabel: AppStrings.reviewContacts,
              onPrimaryAction: () => debugPrint('Revisar fichas'),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: AppStrings.quickActions, actionLabel: 'Hoy'),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 640;
                final items = [
                  QuickActionsCard(
                    icon: Icons.qr_code_scanner_rounded,
                    label: AppStrings.scanQR,
                    iconColor: Colors.white,
                    circleColor: theme.colorScheme.primary,
                    onTap: () => debugPrint(AppStrings.scanQR),
                  ),
                  QuickActionsCard(
                    icon: Icons.near_me_rounded,
                    label: AppStrings.nearMe,
                    iconColor: Colors.white,
                    circleColor: theme.colorScheme.secondary,
                    onTap: () => debugPrint(AppStrings.nearMe),
                  ),
                  QuickActionsCard(
                    icon: Icons.person_add_alt_1_rounded,
                    label: AppStrings.addManually,
                    iconColor: Colors.white,
                    circleColor: theme.colorScheme.tertiary,
                    onTap: () => context.go(Routes.contactNew),
                  ),
                ];

                if (isCompact) {
                  return SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return SizedBox(width: 150, child: items[index]);
                      },
                    ),
                  );
                }

                return Row(
                  children: List.generate(items.length, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == items.length - 1 ? 0 : 12,
                        ),
                        child: SizedBox(height: 150, child: items[index]),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: AppStrings.recentContacts,
              actionLabel: AppStrings.viewAll,
            ),
            const SizedBox(height: 14),
            const ContactItem(
              name: 'Luis Angel',
              subtitle: 'Trabajo',
              imageUrl: 'https://i.pravatar.cc/150?img=12',
            ),
            const ContactItem(
              name: 'Sergio Moreno',
              subtitle: 'Trabajo',
              imageUrl: 'https://i.pravatar.cc/150?img=13',
            ),
            const ContactItem(
              name: 'Juan Perez',
              subtitle: 'Trabajo',
              imageUrl: 'https://i.pravatar.cc/150?img=14',
            ),
            const SizedBox(height: 24),
            Consumer<AuthViewModel>(
              builder: (context, viewModel, _) => Center(
                child: TextButton(
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
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;

  const _SectionHeader({required this.title, required this.actionLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          actionLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
