import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/features/profile/profile_viewmodel.dart';
import 'package:peoplesync/features/qr_code/qr_service.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:go_router/go_router.dart';

class QrDialog extends StatelessWidget {
  const QrDialog({super.key});

  static void show(BuildContext context) {
    showDialog(context: context, builder: (context) => const QrDialog());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qrService = getIt<QrService>();

    return ChangeNotifierProvider.value(
      value: getIt<ProfileViewModel>(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, _) {
          final profile = viewModel.profile;

          if (viewModel.isLoading) {
            return const AlertDialog(
              content: SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (profile == null) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('No se pudo cargar tu perfil'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          }

          final qrData = qrService.generateProfileQrData(profile.uid);

          return AlertDialog(
            title: Text(
              'Tu Código QR',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Muestra este código para compartir tu perfil fácilmente.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: PrettyQrView.data(
                      data: qrData,
                      decoration: PrettyQrDecoration(
                        shape: PrettyQrSmoothSymbol(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.fullName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (profile.email != null)
                  Text(
                    profile.email!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push(Routes.scanner);
                    },
                    icon: const Icon(Icons.document_scanner_rounded),
                    label: const Text('Escanear QR'),
                  ),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            actions: [
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
