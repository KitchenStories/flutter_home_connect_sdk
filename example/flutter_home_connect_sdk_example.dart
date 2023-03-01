import 'dart:io';

import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';

const accessToken =
    "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE5IiwieC1yZWciOiJTSU0iLCJ4LWVudiI6IlBSRCJ9.eyJzdWIiOiJkZXZwb3J0YWxVc2VySWQ6NDYwMzIiLCJleHAiOjE2Nzc2ODg5MzYsInNjb3BlIjpbIkNsZWFuaW5nUm9ib3QiLCJDbGVhbmluZ1JvYm90LUNvbnRyb2wiLCJDbGVhbmluZ1JvYm90LU1vbml0b3IiLCJDbGVhbmluZ1JvYm90LVNldHRpbmdzIiwiQ29mZmVlTWFrZXIiLCJDb2ZmZWVNYWtlci1Db250cm9sIiwiQ29mZmVlTWFrZXItTW9uaXRvciIsIkNvZmZlZU1ha2VyLVNldHRpbmdzIiwiQ29udHJvbCIsIkNvb2tQcm9jZXNzb3IiLCJDb29rUHJvY2Vzc29yLUNvbnRyb2wiLCJDb29rUHJvY2Vzc29yLU1vbml0b3IiLCJDb29rUHJvY2Vzc29yLVNldHRpbmdzIiwiRGlzaHdhc2hlciIsIkRpc2h3YXNoZXItQ29udHJvbCIsIkRpc2h3YXNoZXItTW9uaXRvciIsIkRpc2h3YXNoZXItU2V0dGluZ3MiLCJEcnllciIsIkRyeWVyLUNvbnRyb2wiLCJEcnllci1Nb25pdG9yIiwiRHJ5ZXItU2V0dGluZ3MiLCJGcmVlemVyIiwiRnJlZXplci1Db250cm9sIiwiRnJlZXplci1Nb25pdG9yIiwiRnJlZXplci1TZXR0aW5ncyIsIkZyaWRnZUZyZWV6ZXItQ29udHJvbCIsIkZyaWRnZUZyZWV6ZXItTW9uaXRvciIsIkZyaWRnZUZyZWV6ZXItU2V0dGluZ3MiLCJIb2IiLCJIb2ItQ29udHJvbCIsIkhvYi1Nb25pdG9yIiwiSG9iLVNldHRpbmdzIiwiSG9vZCIsIkhvb2QtQ29udHJvbCIsIkhvb2QtTW9uaXRvciIsIkhvb2QtU2V0dGluZ3MiLCJJZGVudGlmeUFwcGxpYW5jZSIsIk1vbml0b3IiLCJPdmVuIiwiT3Zlbi1Db250cm9sIiwiT3Zlbi1Nb25pdG9yIiwiT3Zlbi1TZXR0aW5ncyIsIlJlZnJpZ2VyYXRvciIsIlJlZnJpZ2VyYXRvci1Db250cm9sIiwiUmVmcmlnZXJhdG9yLU1vbml0b3IiLCJSZWZyaWdlcmF0b3ItU2V0dGluZ3MiLCJTZXR0aW5ncyIsIldhc2hlciIsIldhc2hlci1Db250cm9sIiwiV2FzaGVyLU1vbml0b3IiLCJXYXNoZXItU2V0dGluZ3MiLCJXYXNoZXJEcnllciIsIldhc2hlckRyeWVyLUNvbnRyb2wiLCJXYXNoZXJEcnllci1Nb25pdG9yIiwiV2FzaGVyRHJ5ZXItU2V0dGluZ3MiLCJXaW5lQ29vbGVyIiwiV2luZUNvb2xlci1Db250cm9sIiwiV2luZUNvb2xlci1Nb25pdG9yIiwiV2luZUNvb2xlci1TZXR0aW5ncyJdLCJhenAiOiI1NzQxRTVBMENCQjlDQ0U0Q0RFNUFBNkJGREJEQjVFNjRBMzQzMjVBMzI5RTA5MUY2ODY5NzU0MTY4NjA1RUU0IiwiYXVkIjoiNTc0MUU1QTBDQkI5Q0NFNENERTVBQTZCRkRCREI1RTY0QTM0MzI1QTMyOUUwOTFGNjg2OTc1NDE2ODYwNUVFNCIsInBybSI6W10sImlzcyI6ImV1OnNpbTpvYXV0aDoxIiwianRpIjoiMGY0OWMxMjctMTFiOS00YTUzLThmMGQtZmFjMTFiMzE1MGY3IiwiaWF0IjoxNjc3NjAyNTM2fQ.beihWNR7umB38ov-hKDswBJvCLd9RlYylFS9R0bbv6fOjqDcrtTdmQCRT12W5NvSFh69WoZfr5uWZw5MjOSzjA";
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

  // List<EventCallback> callbacks = [
  //   (event, object) => {print("heloo")},
  //   (event, object) => {print("bye")}
  // ];

  // Listener? listener;
  ProcessSignal.sigint.watch().listen((signal) {
    print("Closing stream...");
    api.closeEventChannel();
    // listener!.cancel();
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

    api.eventEmitter.addListener((ev, context) {
      print(ev.eventName);
      print(ev.sender);
      print(ev.eventData);
    });
    // emitter experiments
    // for (var element in callbacks) {
    //   api.eventEmitter.on("update", null, element);
    // }

    // print(api.eventEmitter.getListenersCount("status"));
    // api.eventEmitter.removeAllByCallback(callbacks[0]);
    // print(api.eventEmitter.getListenersCount("update"));
    // listener = api.eventEmitter.on("update", null, (event, context) {
    //   print(event.eventName);
    //   print(event.sender);
    //   print(event.eventData);
    // });

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
