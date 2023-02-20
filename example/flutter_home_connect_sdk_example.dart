import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';

const accessToken =
    'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE5IiwieC1yZWciOiJTSU0iLCJ4LWVudiI6IlBSRCJ9.eyJzdWIiOiJkZXZwb3J0YWxVc2VySWQ6NDYwMzIiLCJleHAiOjE2NzcwMDQwNDgsInNjb3BlIjpbIkNsZWFuaW5nUm9ib3QiLCJDbGVhbmluZ1JvYm90LUNvbnRyb2wiLCJDbGVhbmluZ1JvYm90LU1vbml0b3IiLCJDbGVhbmluZ1JvYm90LVNldHRpbmdzIiwiQ29mZmVlTWFrZXIiLCJDb2ZmZWVNYWtlci1Db250cm9sIiwiQ29mZmVlTWFrZXItTW9uaXRvciIsIkNvZmZlZU1ha2VyLVNldHRpbmdzIiwiQ29udHJvbCIsIkNvb2tQcm9jZXNzb3IiLCJDb29rUHJvY2Vzc29yLUNvbnRyb2wiLCJDb29rUHJvY2Vzc29yLU1vbml0b3IiLCJDb29rUHJvY2Vzc29yLVNldHRpbmdzIiwiRGlzaHdhc2hlciIsIkRpc2h3YXNoZXItQ29udHJvbCIsIkRpc2h3YXNoZXItTW9uaXRvciIsIkRpc2h3YXNoZXItU2V0dGluZ3MiLCJEcnllciIsIkRyeWVyLUNvbnRyb2wiLCJEcnllci1Nb25pdG9yIiwiRHJ5ZXItU2V0dGluZ3MiLCJGcmVlemVyIiwiRnJlZXplci1Db250cm9sIiwiRnJlZXplci1Nb25pdG9yIiwiRnJlZXplci1TZXR0aW5ncyIsIkZyaWRnZUZyZWV6ZXItQ29udHJvbCIsIkZyaWRnZUZyZWV6ZXItTW9uaXRvciIsIkZyaWRnZUZyZWV6ZXItU2V0dGluZ3MiLCJIb2IiLCJIb2ItQ29udHJvbCIsIkhvYi1Nb25pdG9yIiwiSG9iLVNldHRpbmdzIiwiSG9vZCIsIkhvb2QtQ29udHJvbCIsIkhvb2QtTW9uaXRvciIsIkhvb2QtU2V0dGluZ3MiLCJJZGVudGlmeUFwcGxpYW5jZSIsIk1vbml0b3IiLCJPdmVuIiwiT3Zlbi1Db250cm9sIiwiT3Zlbi1Nb25pdG9yIiwiT3Zlbi1TZXR0aW5ncyIsIlJlZnJpZ2VyYXRvciIsIlJlZnJpZ2VyYXRvci1Db250cm9sIiwiUmVmcmlnZXJhdG9yLU1vbml0b3IiLCJSZWZyaWdlcmF0b3ItU2V0dGluZ3MiLCJTZXR0aW5ncyIsIldhc2hlciIsIldhc2hlci1Db250cm9sIiwiV2FzaGVyLU1vbml0b3IiLCJXYXNoZXItU2V0dGluZ3MiLCJXYXNoZXJEcnllciIsIldhc2hlckRyeWVyLUNvbnRyb2wiLCJXYXNoZXJEcnllci1Nb25pdG9yIiwiV2FzaGVyRHJ5ZXItU2V0dGluZ3MiLCJXaW5lQ29vbGVyIiwiV2luZUNvb2xlci1Db250cm9sIiwiV2luZUNvb2xlci1Nb25pdG9yIiwiV2luZUNvb2xlci1TZXR0aW5ncyJdLCJhenAiOiI1NzQxRTVBMENCQjlDQ0U0Q0RFNUFBNkJGREJEQjVFNjRBMzQzMjVBMzI5RTA5MUY2ODY5NzU0MTY4NjA1RUU0IiwiYXVkIjoiNTc0MUU1QTBDQkI5Q0NFNENERTVBQTZCRkRCREI1RTY0QTM0MzI1QTMyOUUwOTFGNjg2OTc1NDE2ODYwNUVFNCIsInBybSI6W10sImlzcyI6ImV1OnNpbTpvYXV0aDoxIiwianRpIjoiNTIyYzJiNGYtYWM4YS00ZjM2LWE2MzUtN2EyZDdhOTQyZjIyIiwiaWF0IjoxNjc2OTE3NjQ4fQ.elWx0Vrp6g0SCjdJ-at7jOsrz9qQSlCOC0jCOmH6y-PydA0oyPtH5jgegtt1KFyf_AHrVc106dj8g77WlY_o5A';

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
