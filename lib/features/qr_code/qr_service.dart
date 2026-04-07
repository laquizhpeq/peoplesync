class QrService {
  /// Generate the string to encode in the QR code for a given profile UID.
  String generateProfileQrData(String uid) {
    return 'peoplesync://profile/$uid';
  }

  /// Parses the scanned QR data.
  /// Returns the user's UID if the QR is a valid profile URL, else null.
  String? parseProfileQrData(String qrData) {
    const prefix = 'peoplesync://profile/';
    if (qrData.startsWith(prefix)) {
      final uid = qrData.substring(prefix.length);
      if (uid.isNotEmpty) return uid;
    }
    return null;
  }
}
