# Home Connect SDK

A Dart package for interacting with the Home Connect API, which provides a unified interface for controlling a variety of smart home appliances.
Getting started
Prerequisites

    Dart 2.17 or higher

# Installation

Add the following dependency to your `pubspec.yaml` file:

yaml

    dependencies:
    homeconnect: ^0.0.2

Then, run `dart pub get` to install the package.

## Usage

First, import the package:

```dart
import 'package:homeconnect/homeconnect.dart';
```

To create an instance of the HomeConnectApi class, you need to provide the base URL of the Home Connect API, as well as the client credentials for authentication. Checkout out the [example](./homeconnect/example/flutter_home_connect_sdk_example.dart) file to get a better idea.

```dart
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
final api = HomeConnectApi(Uri.parse('https://api.home-connect.com'), credentials: HomeConnectClientCredentials(clientId: '...', clientSecret: '...'));
```

## Get all devices.

```dart
final devices = await api.getDevices();
```

## Select a device.

You can pick a device using any method, here we select the first oven from the device list.

```dart
final selectedDevice = devices.firstWhere((element) => element.info.type == DeviceType.oven);
```

## Fetch device programs and status.

Once you have the selected device, to fetch its data we need to run `selectedDevice.init()`

```dart
await selectedDevice.init();
```

After this we will have access to the devices programs and status.

```dart
// print all available programs
for (var program in selectedDevice.programs) {
    print(program.key);
}

// print device status
for (var stat in selectedDevice.status) {
    print(stat.key);
}
```

## Select a program

We need to select a program before getting its options and contraints.

```dart
await selectedDevice.selectProgram(programKey: 'Cooking.Oven.Program.HeatingMode.TopBottomHeating');
```

Selecting a program will allows to use `startProgram`, but first we need to set some valid values for the options.

In the example we will print the program options and their coinstraints to get the valid values.

```dart
for (var option in selectedDevice.selectedProgram.options) {
    print(option.key);
    print(option.constraints!.toJson());
}
```

The output will be something like this:

    Cooking.Oven.Option.SetpointTemperature
    {min: 30, max: 250, stepsize: 5}
    BSH.Common.Option.Duration
    {min: 1, max: 86340, stepsize: 1}

Now we can a start a program with valid options.

## Starting a program

First, lets generate the option payloads

We use `toCommandPayload` to parse the data for the request.

```dart
final tempOption = ProgramOptions.toCommandPayload(key: 'Cooking.Oven.Option.SetpointTemperature', value: 200);
final durationOption = ProgramOptions.toCommandPayload(key: 'BSH.Common.Option.Duration', value: 500);
```

To start the program just call the method like this:

```dart
await selectedDevice.startProgram(options: [tempOption, durationOption]);
```

## Other methods.

HomeDevice class also allows you to turn off and on your device.

```dart
selectedDevice.turnOff();
selectedDevice.turnOn();
```
