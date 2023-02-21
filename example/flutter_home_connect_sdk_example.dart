
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';

const accessToken = "Your dev token";
const refreshToken = "Your refresh token";

class SandboxAuthorizer extends HomeConnectAuth {
  String baseUrl;

  SandboxAuthorizer({
    this.baseUrl = 'https://simulator.home-connect.com/'
  });

  @override
  Future<HomeConnectAuthCredentials> authorize(HomeConnectClientCredentials credentials) {
    throw UnimplementedError();
  }

  @override
  Future<HomeConnectAuthCredentials> refresh(String refreshToken) async {
    final res = await http.post(
      Uri.parse("${baseUrl}security/oauth/token"),
      body: {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    });
    if (res.statusCode != 200) {
      print(res.body);
      print('failed refresh');
      throw Exception('Failed to refresh token');
    }
    final tokenRes = jsonDecode(utf8.decode(res.bodyBytes)) as Map;
    return HomeConnectAuthCredentials(
      accessToken: tokenRes['access_token'],
      refreshToken: tokenRes['refresh_token'],
    );
  }
}


void main() async {
  HomeConnectApi api = HomeConnectApi(
    'https://simulator.home-connect.com/api/homeappliances',
    credentials: HomeConnectClientCredentials(
      clientId: 'Your client id',
      clientSecret: 'Your client secret',
      redirectUri: 'https://example.com',
    ),
    authenticator: SandboxAuthorizer(),
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

  api.storage.setCredentials(HomeConnectAuthCredentials(
    accessToken: accessToken,
    refreshToken: refreshToken,
  ));
  print("init $api");
  final res = await api.getDevices();
  print("devices $res");
}
