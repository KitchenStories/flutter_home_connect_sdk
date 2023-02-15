
import 'package:flutter_home_connect_sdk/src/client_dart.dart';
import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';


const accessToken = "Your dev token";

void main() async {
  HomeConnectApi api = HomeConnectApi(
    'https://simulator.home-connect.com/api/homeappliances',
    accessToken: accessToken,
    credentials: HomeConnectClientCredentials(
      clientId: 'Your client id',
      clientSecret: 'Your client secret',
      redirectUri: 'https://example.com',
    ),
  );
  print("init $api");
}
