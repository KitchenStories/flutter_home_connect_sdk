import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';

const accessToken = "Your dev token";
const refreshToken = "Your refresh token";

class SandboxAuthorizer extends HomeConnectAuth {
  String baseUrl;

  SandboxAuthorizer({
    this.baseUrl = 'https://simulator.home-connect.com/'
  });

  @override
  Future<HomeConnectAuthCredentials> authorize(HomeConnectClientCredentials credentials) {
    throw UnimplementedError();
  }

  @override
  Future<HomeConnectAuthCredentials> refresh(String refreshToken) async {
    final res = await http.post(
      Uri.parse("${baseUrl}security/oauth/token"),
      body: {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    });
    if (res.statusCode != 200) {
      print(res.body);
      print('failed refresh');
      throw Exception('Failed to refresh token');
    }
    final tokenRes = jsonDecode(utf8.decode(res.bodyBytes)) as Map;
    return HomeConnectAuthCredentials(
      accessToken: tokenRes['access_token'],
      refreshToken: tokenRes['refresh_token'],
    );
  }
}

void main() async {
  HomeConnectApi api = HomeConnectApi(
    'https://simulator.home-connect.com/api/homeappliances',
    credentials: HomeConnectClientCredentials(
      clientId: 'Your client id',
      clientSecret: 'Your client secret',
      redirectUri: 'https://example.com',
    ),
    authenticator: SandboxAuthorizer(),
  );
  api.storage.setCredentials(HomeConnectAuthCredentials(
    accessToken: accessToken,
    refreshToken: refreshToken,
  ));
  print("init $api");
  final res = await api.getDevices();
  print("devices $res");
}
