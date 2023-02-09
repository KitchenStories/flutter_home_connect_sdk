import 'package:flutter_home_connect_sdk/src/client.dart';
import 'package:flutter_home_connect_sdk/src/resources/device.dart';

import '../lib/flutter_home_connect_sdk.dart';

const accessToken = '...youraccesstoken...';

void main() async {
  final api = HomeConnectApi('https://simulator.home-connect.com/api', accessToken: accessToken);
  final devices = await api.devices.getAll();
  print(devices.map((e) => e.toString()).toList());
  print("status first device");
  final status = await devices.firstWhere((element) => element.type == DeviceType.coffeMaker).status;
  print(status);

}
