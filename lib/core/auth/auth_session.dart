import 'package:flutter/foundation.dart';

import '../network/token_storage.dart';

class AuthSession extends ChangeNotifier {
  AuthSession(this._tokens);

  final TokenStorage _tokens;
  bool _ready = false;
  bool _authenticated = false;

  bool get ready => _ready;
  bool get isAuthenticated => _authenticated;

  Future<void> bootstrap() async {
    final access = await _tokens.readAccessToken();
    _authenticated = access != null && access.isNotEmpty;
    _ready = true;
    notifyListeners();
  }

  Future<void> markAuthenticated() async {
    _authenticated = true;
    notifyListeners();
  }

  Future<void> clear() async {
    await _tokens.clear();
    _authenticated = false;
    notifyListeners();
  }
}
