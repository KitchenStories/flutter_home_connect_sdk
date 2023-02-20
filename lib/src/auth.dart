import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class HomeConnectAuthCredentials {
  final String accessToken;
  final String refreshToken;

  HomeConnectAuthCredentials({
    required this.accessToken,
    required this.refreshToken,
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
  Future<HomeConnectAuthCredentials> authorize(HomeConnectClientCredentials credentials);
  Future<HomeConnectAuthCredentials> refresh(String refreshToken);
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
