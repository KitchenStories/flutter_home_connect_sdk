import 'dart:io';

import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';

const accessToken = "";
const refreshToken = "";

class SandboxAuthorizer extends HomeConnectAuth {
  @override
  Future<HomeConnectAuthCredentials> authorize(Uri baseUrl, HomeConnectClientCredentials credentials) {
    throw UnimplementedError();
  }
}

void main() async {
  HomeConnectApi api = HomeConnectApi(
    Uri.parse('https://simulator.home-connect.com/'),
    credentials: HomeConnectClientCredentials(
      clientId: 'Your client id',
      clientSecret: 'Your client secret',
      redirectUri: 'https://example.com',
    ),
    authenticator: SandboxAuthorizer(),
  );

  api.storage.setCredentials(HomeConnectAuthCredentials(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expirationDate: DateTime.now().add(Duration(days: 1)),
  ));

  ProcessSignal.sigint.watch().listen((signal) {
    print("Closing stream...");
    api.closeEventChannel();
    exit(0);
  });

  try {
    final res = await api.getDevices();
    var selectedDevice = res.firstWhere((element) => element.info.type == DeviceType.oven);
    await selectedDevice.init();
    await selectedDevice.getPrograms();
    for (var element in selectedDevice.programs) {
      print(element.key);
    }
    selectedDevice.startListening();
    await selectedDevice.selectProgram(programKey: 'Cooking.Oven.Program.HeatingMode.TopBottomHeating');

    final option1 = ProgramOptions.toCommandPayload(key: 'Cooking.Oven.Option.SetpointTemperature', value: 200);
    final option2 = ProgramOptions.toCommandPayload(key: 'BSH.Common.Option.Duration', value: 500);

    selectedDevice.startProgram(options: [option1, option2]);
    await Future.delayed(Duration(seconds: 5));
    selectedDevice.stopProgram();

    await Future.delayed(Duration(seconds: 5));
    selectedDevice.turnOff();
    await Future.delayed(Duration(seconds: 5));
    selectedDevice.turnOn();
  } catch (e) {
    api.closeEventChannel();
  }
}
