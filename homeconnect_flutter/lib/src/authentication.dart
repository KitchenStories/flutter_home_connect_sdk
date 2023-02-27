import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:homeconnect/homeconnect.dart';
import 'components/webview_login.dart' show showLogin;

class HomeConnectOauth extends HomeConnectAuth {
  final BuildContext context;

  HomeConnectOauth({
    required this.context,
  });

  @override
  Future<HomeConnectAuthCredentials> authorize(
      Uri baseUrl, HomeConnectClientCredentials credentials) async {
    final authorizationUrl = getCodeGrant(baseUrl, credentials);
    final response = await showLogin(
      context: context,
      clientId: credentials.clientId,
      redirectUrl: credentials.redirectUri,
      authorizationUrl: authorizationUrl.toString(),
    );

    if (response == null) {
      throw Exception("Login failed");
    }

    return exchangeCode(baseUrl, credentials, response["token"]);
  }
}
