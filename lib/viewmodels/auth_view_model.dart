import 'package:flutter/foundation.dart';

import '../models/auth_session.dart';
import '../services/auth_api.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._api);

  final AuthApi _api;
  AuthSession? _session;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _session != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthUser? get user => _session?.user;
  String? get token => _session?.token;

  Future<void> submit({
    required bool createAccount,
    required String name,
    required String email,
    required String password,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = createAccount
          ? await _api.register(name: name, email: email, password: password)
          : await _api.login(email: email, password: password);
    } on AuthApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  void signOut() {
    _session = null;
    _errorMessage = null;
    notifyListeners();
  }
}
