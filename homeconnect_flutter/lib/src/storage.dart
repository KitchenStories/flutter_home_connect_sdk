import 'package:homeconnect/homeconnect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHomeConnectAuthStorage implements HomeConnectAuthStorage {
  final SharedPreferences _prefs;

  SharedPreferencesHomeConnectAuthStorage(this._prefs);

  @override
  Future<HomeConnectAuthCredentials?> getCredentials() async {
    final accessToken = _prefs.getString("accessToken");
    final refreshToken = _prefs.getString("refreshToken");
    final expirationDate = _prefs.getInt("expirationDate");
    if (accessToken == null || refreshToken == null || expirationDate == null) {
      return null;
    }
    return HomeConnectAuthCredentials(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expirationDate: DateTime.fromMillisecondsSinceEpoch(expirationDate),
    );
  }

  @override
  Future<void> clearCredentials() async {
    await _prefs.clear();
  }

  @override
  Future<void> setCredentials(HomeConnectAuthCredentials credentials) async {
    await _prefs.setString("accessToken", credentials.accessToken);
    await _prefs.setString("refreshToken", credentials.refreshToken);
    await _prefs.setInt("expirationDate", credentials.expirationDate.millisecondsSinceEpoch);
  }
}
