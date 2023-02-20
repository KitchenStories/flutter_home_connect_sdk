import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';

const accessToken = 'dev token';

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
  // print("init $api");
  final res = await api.getDevices();
  var selectedDevice =
      res.firstWhere((element) => element.info.type == DeviceType.oven);
  selectedDevice = await api.getDevice(selectedDevice);
  await selectedDevice.getPrograms();

  print(selectedDevice.info.haId);
  selectedDevice.programs.toList().forEach((element) {
    print(element.key);
  });
  await selectedDevice.selectProgram(
      programKey: 'Cooking.Oven.Program.HeatingMode.TopBottomHeating');

  print(selectedDevice.selectedProgram.options);
  for (var element in selectedDevice.selectedProgram.options) {
    print(element.constraints!.toJson());
    print(element.unit);
  }

  final option1 = DeviceOptions.toCommandPayload(
      key: 'Cooking.Oven.Option.SetpointTemperature', value: 200);
  final option2 = DeviceOptions.toCommandPayload(
      key: 'BSH.Common.Option.Duration', value: 500);

  selectedDevice.startProgram(options: [option1, option2]);

  await Future.delayed(Duration(seconds: 5));
  selectedDevice.stopProgram();
}
