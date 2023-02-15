import 'package:flutter_home_connect_sdk/src/client_dart.dart';

const accessToken = "your token here";
void main() async {
  HomeConnectApi api = HomeConnectApi(
      'https://simulator.home-connect.com/api/homeappliances',
      accessToken: accessToken);

  // List<HomeDevice> devices = await api.getDevices();
  // HomeDevice oven = await api.getDevice(devices[0]);
  // api.getPrograms(oven.deviceHaId);
  // print(oven.programs[0].options[0].constraints);
}
