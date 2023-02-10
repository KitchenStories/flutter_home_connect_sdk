import 'package:flutter_home_connect_sdk/src/client_dart.dart';

const accessToken = "your token";
void main() {
  HomeConnectApi api = HomeConnectApi(
      'https://simulator.home-connect.com/api/homeappliances',
      accessToken: accessToken);
  api.devices.turnOn();
  api.startListening(api.devices.deviceHaId);
}
