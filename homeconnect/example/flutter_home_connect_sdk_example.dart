import 'package:homeconnect/src/auth.dart';
import 'package:homeconnect/src/client_dart.dart';
import 'package:homeconnect/src/home_device.dart';
import 'package:homeconnect/src/models/payloads/device_options.dart';

const accessToken = "Your dev token";
const refreshToken = "Your refresh token";

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

  // print("init $api");
  final res = await api.getDevices();
  var selectedDevice = res.firstWhere((element) => element.info.type == DeviceType.oven);
  selectedDevice = await api.getDevice(selectedDevice);
  await selectedDevice.getPrograms();

  print(selectedDevice.info.haId);
  selectedDevice.programs.toList().forEach((element) {
    print(element.key);
  });
  await selectedDevice.selectProgram(programKey: 'Cooking.Oven.Program.HeatingMode.TopBottomHeating');

  print(selectedDevice.selectedProgram.options);
  for (var element in selectedDevice.selectedProgram.options) {
    print(element.constraints!.toJson());
    print(element.unit);
  }

  final option1 = DeviceOptions.toCommandPayload(key: 'Cooking.Oven.Option.SetpointTemperature', value: 200);
  final option2 = DeviceOptions.toCommandPayload(key: 'BSH.Common.Option.Duration', value: 500);

  selectedDevice.startProgram(options: [option1, option2]);

  await Future.delayed(Duration(seconds: 5));
  selectedDevice.stopProgram();
}
