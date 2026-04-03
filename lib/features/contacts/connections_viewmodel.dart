import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:peoplesync/features/contacts/contact_service.dart';
import 'package:peoplesync/features/contacts/models/contact_record.dart';

class ConnectionsViewModel extends ChangeNotifier {
  final ContactService contactService;

  List<ContactRecord> _contacts = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<List<ContactRecord>>? _subscription;

  List<ContactRecord> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ConnectionsViewModel({required this.contactService}) {
    _subscribe();
  }

  void _subscribe() {
    _subscription = contactService.watchContacts().listen(
      (contacts) {
        _contacts = contacts;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = '$error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
