import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper tipado sobre [SharedPreferences] dedicado ao armazenamento de
/// tokens de autenticação. Mantém `SharedPreferences` como detalhe de
/// implementação — o resto do app consome apenas esta interface.
class SharedPreferencesService {
  SharedPreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static const _accessTokenKey = 'auth.accessToken';
  static const _refreshTokenKey = 'auth.refreshToken';

  String? get accessToken => _prefs.getString(_accessTokenKey);

  String? get refreshToken => _prefs.getString(_refreshTokenKey);

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _prefs.setString(_accessTokenKey, accessToken);
    await _prefs.setString(_refreshTokenKey, refreshToken);
  }

  /// Remove apenas as chaves de auth — não apaga o storage inteiro para
  /// preservar eventuais outras preferências do usuário.
  Future<void> clear() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
  }
}
