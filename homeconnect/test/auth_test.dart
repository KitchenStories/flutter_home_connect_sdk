import 'package:test/test.dart';

import 'package:homeconnect/src/models/payloads/oauth_token.dart';

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
}
