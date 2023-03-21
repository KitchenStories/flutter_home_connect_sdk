class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

class RefreshTokenException extends AuthException {
  RefreshTokenException(super.message);
}

class OauthCodeException extends AuthException {
  OauthCodeException(super.message);
}

class OauthScopeException extends AuthException {
  OauthScopeException(super.message);
}

class InvalidTokenException extends AuthException {
  InvalidTokenException(super.message);
}
