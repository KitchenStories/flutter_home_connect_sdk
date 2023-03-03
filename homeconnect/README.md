# Home Connect SDK

SDK for the [Home Connect](https://www.home-connect.com/us/en) API.

## Setup
- Get your account and access token [here](https://api-docs.home-connect.com/quickstart?).
- Import the package in your flutter app.

## Usage

After getting a client id from the home connect website, you can pass the
id and secret in order to use the SDK

```dart
import 'package:homeconnect/homeconnect.dart';

HomeConnectApi api = HomeConnectApi(
  Uri.parse('https://simulator.home-connect.com/'),
  credentials: HomeConnectClientCredentials(
    clientId: 'Your client id',
    clientSecret: 'Your client secret',
    redirectUri: 'https://example.com',
  ),
);

final devices = await api.getDevices();

final oven = res.firstWhere((element) => element.info.type == DeviceType.oven);
await oven.init();
oven.startListening();
```
