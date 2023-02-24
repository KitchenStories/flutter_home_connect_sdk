import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';
import 'package:flutter_home_connect_sdk/src/oauth/oauth_token.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockHomeConnectAuthCredentials extends Mock implements HomeConnectAuthCredentials {
  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final DateTime expirationDate;

  MockHomeConnectAuthCredentials({required this.accessToken, required this.refreshToken, required this.expirationDate});
  @override
  Map<String, dynamic> parseJwt(String token) {
    return noSuchMethod(Invocation.method(#parseJwt, [token]), returnValue: <String, dynamic>{'exp': 0});
  }

  @override
  bool isAccessTokenExpired() {
    final jwt = parseJwt(accessToken);
    final exp = jwt['exp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (exp < now) {
      return true;
    }
    return false;
  }
}

void main() {
  group('Auth', () {
    test('payload', () {
      final resPayload = OauthTokenResponsePayload.fromJson({
        "access_token": "access",
        "refresh_token": "refresh",
        "expires_in": 1000,
      });
      expect(resPayload.accessToken, "access");
    });
  });
  group('HomeAuthCredentials tests', () {
    test('test valid expiration token', () {
      var mock = MockHomeConnectAuthCredentials(
        accessToken: 'valid_token',
        refreshToken: 'fake_refresh_token',
        expirationDate: DateTime.fromMillisecondsSinceEpoch(1),
      );
      when(mock.parseJwt('valid_token')).thenReturn({
        "exp": DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch,
      });

      expect(mock.isAccessTokenExpired(), false);
    });

    test('test expired token', () {
      var mock = MockHomeConnectAuthCredentials(
        accessToken: 'invalid_token',
        refreshToken: 'fake_refresh_token',
        expirationDate: DateTime.fromMillisecondsSinceEpoch(1),
      );
      when(mock.parseJwt('invalid_token')).thenReturn({
        "exp": 0,
      });

      expect(mock.isAccessTokenExpired(), true);
    });

    test('test token is valid', () async {
      var authCredentials = HomeConnectAuthCredentials(
          accessToken: 'badToken', refreshToken: 'badToken', expirationDate: DateTime.fromMillisecondsSinceEpoch(1));

      expect(() => authCredentials.parseJwt('badToken'), throwsA(isA<Exception>()));
    });
  });
}
