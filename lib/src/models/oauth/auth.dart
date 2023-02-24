import 'dart:convert';

import 'package:flutter_home_connect_sdk/src/models/oauth/oauth_token.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;

// load join extension
import '../../utils/uri.dart';

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
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }
    return payloadMap;
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
  Uri getCodeGrant(Uri baseUrl, HomeConnectClientCredentials credentials) {
    final grant = oauth2.AuthorizationCodeGrant(
      credentials.clientId,
      baseUrl.join('/security/oauth/authorize'),
      baseUrl.join('/security/oauth/token'),
      secret: credentials.clientSecret,
    );
    return grant.getAuthorizationUrl(Uri.parse(credentials.redirectUri));
  }

  Future<HomeConnectAuthCredentials> exchangeCode(
      Uri baseUrl, HomeConnectClientCredentials credentials, String code) async {
    final tokenResponse = await http.post(
      baseUrl.join('/security/oauth/token'),
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'client_id': credentials.clientId,
        'redirect_uri': credentials.redirectUri,
      },
    );

    final res = OauthTokenResponsePayload.fromJson(json.decode(tokenResponse.body));
    return HomeConnectAuthCredentials(
      accessToken: res.accessToken,
      refreshToken: res.refreshToken,
      expirationDate: DateTime.now().add(Duration(seconds: res.expiresIn)),
    );
  }

  Future<HomeConnectAuthCredentials> authorize(Uri baseUrl, HomeConnectClientCredentials credentials);
  Future<HomeConnectAuthCredentials> refresh(Uri baseUrl, String refreshToken) async {
    final res = await http.post(baseUrl.join("security/oauth/token"), body: {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    });
    if (res.statusCode != 200) {
      throw Exception('Failed to refresh token');
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
