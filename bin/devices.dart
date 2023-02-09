import 'package:flutter_home_connect_sdk/src/client.dart';
import 'package:flutter_home_connect_sdk/src/resources/device.dart';

import '../lib/flutter_home_connect_sdk.dart';

const accessToken = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE5IiwieC1yZWciOiJTSU0iLCJ4LWVudiI6IlBSRCJ9.eyJzdWIiOiJkZXZwb3J0YWxVc2VySWQ6NDY0NTkiLCJleHAiOjE2NzU5OTY1MDIsInNjb3BlIjpbIklkZW50aWZ5QXBwbGlhbmNlIiwiQ29mZmVlTWFrZXIiXSwiYXpwIjoiMDM5NDNBM0FGOTEzN0U1NDg3MTQzOUQ2OTBBREMwNTkwN0Y0ODBERUMyMkU5Mzg1QzA4NTJDMUJEMUE2NTMzQyIsImF1ZCI6IjAzOTQzQTNBRjkxMzdFNTQ4NzE0MzlENjkwQURDMDU5MDdGNDgwREVDMjJFOTM4NUMwODUyQzFCRDFBNjUzM0MiLCJwcm0iOltdLCJpc3MiOiJldTpzaW06b2F1dGg6MSIsImp0aSI6Ijc1YTFiYzIyLTNhY2UtNDU4Zi05MzYzLTBlMTI0N2I0YzM1OSIsImlhdCI6MTY3NTkxMDEwMn0.czQuVf-YIEuwN9a7dsLjJWJ08U99PaqX9Y3pZLPqUhwaIdaYaNg6PAsb3q-NliaAfKftlLtKTIbeHCj6Nlpu1Q';

void main() async {
  print("Hello World");
  final api = HomeConnectApi('https://simulator.home-connect.com/api', accessToken: accessToken);
  final devices = await api.devices.getAll();
  print(devices.map((e) => e.toString()).toList());
  print("status first device");
  final status = await devices.firstWhere((element) => element.type == DeviceType.coffeMaker).status;
  print(status);

}
