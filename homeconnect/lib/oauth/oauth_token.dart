import 'package:json_annotation/json_annotation.dart';

part 'oauth_token.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OauthTokenResponsePayload {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  OauthTokenResponsePayload({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory OauthTokenResponsePayload.fromJson(Map<String, dynamic> json) =>
      _$OauthTokenResponsePayloadFromJson(json);

  Map<String, dynamic> toJson() => _$OauthTokenResponsePayloadToJson(this);
}
