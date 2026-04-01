import 'package:flutter/material.dart';
import 'package:peoplesync/shared/widgets/design/actions/quick_actions.dart';
import 'package:peoplesync/shared/widgets/design/card/time_reconect.dart';
import 'package:peoplesync/shared/widgets/design/header/welcome.dart';
import 'package:peoplesync/core/constants/app_strings.dart';
import 'package:peoplesync/shared/widgets/design/listtile/contact_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // 1. Usamos SingleChildScrollView para que toda la pantalla tenga scroll
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Ya no usamos Center para que el scroll funcione bien
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

            // Título Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(AppStrings.quickActions)],
            ),
            const SizedBox(height: 16),

            // Fila de Botones
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

            // Título Contactos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.recentContacts),
                Text(AppStrings.viewAll, style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 16),

            // 2. IMPORTANTE: En lugar de ListView, usamos una Column
            // porque el scroll ya lo maneja el SingleChildScrollView de arriba
            Column(
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
                  name: 'Juan Pérez',
                  subtitle: 'Trabajo',
                  imageUrl: 'https://i.pravatar.cc/150?img=14',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
