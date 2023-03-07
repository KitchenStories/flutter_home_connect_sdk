import 'dart:io';

import 'package:homeconnect/homeconnect.dart';

const accessToken = "";
const refreshToken = "";

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

    try {
      // selectedDevice.addCallbackToListener(callback: (ev, obj) {
      //   print("from callback ${ev.eventData}");
      // });
    } catch (e) {
      print(e);
    }
    // for (var element in selectedDevice.programs) {
    //   print(element.key);
    // }
    // await selectedDevice.selectProgram(programKey: 'Cooking.Oven.Program.HeatingMode.TopBottomHeating');

    // final option1 = ProgramOptions.toCommandPayload(key: 'Cooking.Oven.Option.SetpointTemperature', value: 200);
    // final option2 = ProgramOptions.toCommandPayload(key: 'BSH.Common.Option.Duration', value: 500);

    // selectedDevice.startProgram(options: [option1, option2]);
    // await Future.delayed(Duration(seconds: 5));
    // selectedDevice.stopProgram();

    // await Future.delayed(Duration(seconds: 5));
    // selectedDevice.turnOff();
    // await Future.delayed(Duration(seconds: 5));
    // selectedDevice.turnOn();

  } catch (e) {
    // close the stream on error
    api.closeEventChannel();
  }
}
