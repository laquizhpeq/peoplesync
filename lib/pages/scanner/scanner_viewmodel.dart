import 'package:flutter/material.dart';
import 'package:peoplesync/features/auth/auth_service.dart';
import 'package:peoplesync/features/contacts/contact_service.dart';
import 'package:peoplesync/features/profile/profile_service.dart';
import 'package:peoplesync/features/qr_code/qr_service.dart';

class ScannerViewModel extends ChangeNotifier {
  final ContactService contactService;
  final ProfileService profileService;
  final AuthService authService;
  final QrService qrService;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  ScannerViewModel({
    required this.contactService,
    required this.profileService,
    required this.authService,
    required this.qrService,
  });

  Future<String?> processQrCode(String? barcode) async {
    if (barcode == null || _isProcessing) return null;

    final contactoUid = qrService.parseProfileQrData(barcode);
    if (contactoUid == null) return null;

    final miUid = authService.currentUser?.uid;
    if (miUid == null) return null;

    _isProcessing = true;
    notifyListeners();

    try {
      await contactService.saveScannedContact(
        miUid: miUid,
        contactoUid: contactoUid,
        notaContexto: 'Escaneado via QR',
      );

      final profile = await profileService.getUserProfile(contactoUid);
      return profile?.fullName;
    } catch (_) {
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
