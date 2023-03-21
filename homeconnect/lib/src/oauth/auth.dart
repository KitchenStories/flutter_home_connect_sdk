import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:uuid/uuid.dart';
import '../utils/uri.dart';
import './oauth_token.dart';
import './auth_exceptions.dart';
import './scopes.dart';

const defaultScopes = [
  OauthScope.identifyAppliance,
];

class HomeConnectAuthCredentials {
  final String accessToken;
  final String refreshToken;
  final DateTime expirationDate;

  HomeConnectAuthCredentials({
    required this.accessToken,
    required this.refreshToken,
    required this.expirationDate,
  });

  Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw InvalidTokenException('invalid token');
    }

    try {
      final payload = _decodeBase64(parts[1]);
      final payloadMap = json.decode(payload);
      if (payloadMap is! Map<String, dynamic>) {
        throw InvalidTokenException('invalid payload');
      }
      return payloadMap;
    } on Exception {
      // handle decode error
      throw InvalidTokenException('invalid token');
    }
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  bool isAccessTokenExpired() {
    final jwt = parseJwt(accessToken);
    final exp = jwt['exp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (exp < now) {
      return true;
    }
    return false;
  }

  bool isRefreshTokenExpired() {
    final jwt = parseJwt(accessToken);
    final exp = jwt['exp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (exp < now) {
      return true;
    }
    return false;
  }
}

class HomeConnectClientCredentials {
  final String clientId;
  final String? clientSecret;
  final String redirectUri;

  HomeConnectClientCredentials({
    required this.clientId,
    this.clientSecret,
    required this.redirectUri,
  });
}

abstract class HomeConnectAuth {
  List<OauthScope> scopes = defaultScopes;
  String? codeVerifier;

  /// Get the code grant url
  ///
  /// Given the [baseUrl] and client [credentials] return the url
  /// to which the user should be redirected to authorize the app.
  Uri getCodeGrant(Uri baseUrl, HomeConnectClientCredentials credentials) {
    codeVerifier = Uri.encodeFull(Uuid().v4());
    final grant = oauth2.AuthorizationCodeGrant(
      credentials.clientId,
      baseUrl.join('/security/oauth/authorize'),
      baseUrl.join('/security/oauth/token'),
      secret: credentials.clientSecret,
      codeVerifier: codeVerifier,
    );
    return grant.getAuthorizationUrl(
      Uri.parse(credentials.redirectUri),
      scopes: scopesToStringList(scopes),
    );
  }

  /// Exchange the [code] for an access token.
  /// throws [OauthCodeException] if the code request fails.
  Future<HomeConnectAuthCredentials> exchangeCode(
      Uri baseUrl, HomeConnectClientCredentials credentials, String code) async {
    late final http.Response tokenResponse;
    final tokenPayload = {
      'grant_type': 'authorization_code',
      'code': code,
      'client_id': credentials.clientId,
      'redirect_uri': credentials.redirectUri,
      'code_verifier': codeVerifier,
    };
    if (credentials.clientSecret != null) {
        tokenPayload['client_secret'] = credentials.clientSecret;
    }
    try {
      tokenResponse = await http.post(
        baseUrl.join('/security/oauth/token'),
        body: tokenPayload
      );
    } catch (e) {
      throw OauthCodeException('Failed to exchange token');
    }

    final res = OauthTokenResponsePayload.fromJson(json.decode(tokenResponse.body));
    return HomeConnectAuthCredentials(
      accessToken: res.accessToken,
      refreshToken: res.refreshToken,
      expirationDate: DateTime.now().add(Duration(seconds: res.expiresIn)),
    );
  }

  Future<HomeConnectAuthCredentials> authorize(Uri baseUrl, HomeConnectClientCredentials credentials);

  /// Refresh the access token with the provided [refreshToken].
  Future<HomeConnectAuthCredentials> refresh(Uri baseUrl, String refreshToken) async {
    final res = await http.post(baseUrl.join("security/oauth/token"), body: {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    });
    if (res.statusCode != 200) {
      throw RefreshTokenException('Failed to refresh token');
    }
    final tokenRes = OauthTokenResponsePayload.fromJson(json.decode(res.body));
    return HomeConnectAuthCredentials(
      accessToken: tokenRes.accessToken,
      refreshToken: tokenRes.refreshToken,
      expirationDate: DateTime.now().add(Duration(seconds: tokenRes.expiresIn)),
    );
  }
}

abstract class HomeConnectAuthStorage {
  Future<HomeConnectAuthCredentials?> getCredentials();
  Future<void> setCredentials(HomeConnectAuthCredentials credentials);
  Future<void> clearCredentials();
}

class MemoryHomeConnectAuthStorage implements HomeConnectAuthStorage {
  HomeConnectAuthCredentials? _credentials;

  @override
  Future<HomeConnectAuthCredentials?> getCredentials() async {
    return _credentials;
  }

  @override
  Future<void> setCredentials(HomeConnectAuthCredentials credentials) async {
    _credentials = credentials;
  }

  @override
  Future<void> clearCredentials() async {
    _credentials = null;
  }
}
