import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/pages/scanner/scanner_viewmodel.dart';
import 'package:peoplesync/core/constants/routes.dart';

class ScannerDialog extends StatefulWidget {
  const ScannerDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ScannerDialog(),
    );
  }

  @override
  State<ScannerDialog> createState() => _ScannerDialogState();
}

class _ScannerDialogState extends State<ScannerDialog> {
  final MobileScannerController controller = MobileScannerController();

  Future<void> _onDetect(
    BarcodeCapture capture,
    ScannerViewModel viewModel,
  ) async {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (viewModel.isProcessing) return;

      final resultName = await viewModel.processQrCode(barcode.rawValue);
      if (resultName != null && mounted) {
        // Success! Provide feedback and close
        Navigator.of(context).pop(); // Close Dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('¡$resultName añadido a tu agenda!')),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // As per user request, go to Home (though we are already there, it forces a refresh if needed)
        context.go(Routes.home);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider<ScannerViewModel>(
      create: (_) => getIt<ScannerViewModel>(),
      child: Builder(
        builder: (context) {
          final viewModel = context.watch<ScannerViewModel>();

          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            backgroundColor: Colors.transparent,
            content: Container(
              width: 320,
              height: 400,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: controller,
                    onDetect: (capture) => _onDetect(capture, viewModel),
                  ),
                  // Scanner Overlay UI
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.5),
                          width: 40,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  // Header
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Escaneando QR...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Close button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                  if (viewModel.isProcessing)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
