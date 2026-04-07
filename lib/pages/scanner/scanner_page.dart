import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/pages/scanner/scanner_viewmodel.dart';
import 'package:peoplesync/core/constants/routes.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡$resultName añadido a tu agenda!')),
        );
        context.go(Routes.home);
        return; // Stop after first successful read
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScannerViewModel>(
      create: (_) => getIt<ScannerViewModel>(),
      child: Builder(
        builder: (context) {
          final viewModel = context.watch<ScannerViewModel>();

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Escanear Contacto',
                style: TextStyle(color: Colors.white),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) => _onDetect(capture, viewModel),
                ),
                // Overlay for guiding the user
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
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
