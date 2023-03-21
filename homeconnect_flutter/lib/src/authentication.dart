import 'package:flutter/material.dart';
import 'package:homeconnect/homeconnect.dart';
import 'components/webview_login.dart' show showLogin;

class HomeConnectOauth extends HomeConnectAuth {
  final BuildContext context;

  HomeConnectOauth({
    required this.context,
    scopes = defaultScopes,
  }) {
    this.scopes = scopes;
  }

  @override
  Future<HomeConnectAuthCredentials> authorize(Uri baseUrl, HomeConnectClientCredentials credentials) async {
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

    if (response["error"] != null) {
      if (response["error"] == "invalid_scope") {
        throw OauthScopeException("Invalid scope");
      }
      throw Exception(response["error"]);
    }

    return exchangeCode(baseUrl, credentials, response["token"]);
  }
}
