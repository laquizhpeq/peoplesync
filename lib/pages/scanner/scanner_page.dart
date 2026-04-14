import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:peoplesync/core/constants/routes.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/pages/scanner/scanner_viewmodel.dart';

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
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (viewModel.isProcessing) return;

      final resultName = await viewModel.processQrCode(barcode.rawValue);
      if (resultName != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$resultName anadido a tus conexiones')),
        );
        context.go(Routes.home);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScannerViewModel>(
      create: (_) => getIt<ScannerViewModel>(),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final viewModel = context.watch<ScannerViewModel>();

          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) => _onDetect(capture, viewModel),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _OverlayIconButton(
                              icon: Icons.arrow_back_rounded,
                              onTap: () => context.go(Routes.home),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Escanear QR',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IgnorePointer(
                          child: Center(
                            child: Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.18),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        _ScannerBottomSheet(
                          title: 'Un solo paso',
                          description:
                              'Centra el QR dentro del marco y espera. No necesitas mas botones ni mas texto.',
                        ),
                      ],
                    ),
                  ),
                ),
                if (viewModel.isProcessing)
                  Container(
                    color: Colors.black.withValues(alpha: 0.55),
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

class _OverlayIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _OverlayIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _ScannerBottomSheet extends StatelessWidget {
  final String title;
  final String description;

  const _ScannerBottomSheet({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
        ],
      ),
    );
  }
}
