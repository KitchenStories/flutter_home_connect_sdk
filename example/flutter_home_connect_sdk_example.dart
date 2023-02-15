
import 'package:flutter_home_connect_sdk/src/client_dart.dart';

const accessToken = "Your dev token";
void main() async {
  HomeConnectApi api = HomeConnectApi(
      'https://simulator.home-connect.com/api/homeappliances',
      accessToken: accessToken);

}
