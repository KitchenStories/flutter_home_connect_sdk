import 'dart:io';

import 'package:homeconnect/homeconnect.dart';

const accessToken = "";
const refreshToken = "";
const clientSecret = "";

class SandboxAuthorizer extends HomeConnectAuth {
  @override
  Future<HomeConnectAuthCredentials> authorize(Uri baseUrl, HomeConnectClientCredentials credentials) {
    throw UnimplementedError();
  }
}

void main() async {
  // set up the api
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

  // close stream on exit
  ProcessSignal.sigint.watch().listen((signal) {
    print("Closing stream...");
    api.closeEventChannel();
    exit(0);
  });

  try {
    // get all devices
    final res = await api.getDevices();
    // select the first oven
    final selectedDevice = res.firstWhere((element) => element.info.type == DeviceType.oven);

    // initialize the device, this fetches all available programs and status
    await selectedDevice.init();

    // devices listen to events, we need to open a stream to receive them
    selectedDevice.startListening();

    // print all available programs
    for (var element in selectedDevice.programs) {
      print(element.key);
    }

    // print devices status
    for (var element in selectedDevice.status) {
      print(element.key);
    }

    // we need to select a program to get its options and constraints
    await selectedDevice.selectProgram(programKey: 'Cooking.Oven.Program.HeatingMode.TopBottomHeating');

    // print all available options
    for (var option in selectedDevice.selectedProgram.options) {
      print(option.key);
      print(option.constraints!.toJson());
    }

    final option1 = ProgramOptions.toCommandPayload(key: 'Cooking.Oven.Option.SetpointTemperature', value: 200);
    final option2 = ProgramOptions.toCommandPayload(key: 'BSH.Common.Option.Duration', value: 500);

    // start the program with the selected options
    await selectedDevice.startProgram(options: [option1, option2]);
    await Future.delayed(Duration(seconds: 5));
    selectedDevice.stopProgram();

    await Future.delayed(Duration(seconds: 5));
    // turn off the oven
    selectedDevice.turnOff();
    await Future.delayed(Duration(seconds: 5));
    // turn on the oven
    selectedDevice.turnOn();
  } catch (e) {
    // close the stream on error
    api.closeEventChannel();
  }
}
