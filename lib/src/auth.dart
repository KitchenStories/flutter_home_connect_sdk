class HomeConnectAuthCredentials {
  final String accessToken;
  final String refreshToken;

  HomeConnectAuthCredentials({
    required this.accessToken,
    required this.refreshToken,
  });
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
}
