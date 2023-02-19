# Home Connect SDK
This library is a work in progress sdk for [Homme Connect](https://www.home-connect.com/us/en) api.


## Setup
- Get your account and access token from [here](https://api-docs.home-connect.com/quickstart?).
- Import the package in your flutter app.


## General overview
```mermaid
classDiagram
    class HomeDevice {
        - HomeConnectApi api
        - DeviceInfo info
        - DeviceProgram selectedProgram
        - List<DeviceOptions> options
        - List<DeviceStatus> status
        - List<DeviceProgram> programs
        + get deviceName(): String
        + get deviceHaId(): String
        + updateStatusFromEvent(event: Event): void
        + selectProgram(programKey: String): Future<void>
        + getPrograms(): Future<List<DeviceProgram>>
        + startProgram(programKey: String, options: Map<String, int>): void
        + turnOn(): void
        + turnOff(): void
    }
    class HomeConnectApi {
        - http.Client client
        - String baseUrl
        - String accessToken
        - List<HomeDevice> devices
        - StreamSubscription<Event> subscription
        - HomeConnectClientCredentials credentials
        - HomeConnectAuth? authenticator
        + authenticate(): Future<void>
        + put(resource: String, headers: Map<String, String>, body: String): Future<http.Response>
        + get(resource: String): Future<http.Response>
        + getDevices(): Future<List<HomeDevice>>
        + getDevice(device: HomeDevice): Future<HomeDevice>
        + putPowerState(haId: String, settingKey: String, payload: Map<String, dynamic>): Future<void>
        + startProgram(haId: String, programKey: String, payload: Map<String, dynamic>): Future<void>
        + stopProgram(haId: String, programKey: String): Future<void>
    }
```

## Show all devices
- Get a list of all devices and their info, run `api.getDevices()`, this will return a list of HomdeDevices

## Select a specific device
- To select a device and its options you should run `api.getDevice(<device instance>)`, this will return a device of proper type. For example if the selected device was an oven, it will return an OvenDevice instance.

##  To get a device programs
- run `myDevice.getPrograms()` will return a list of programs.

## To select a progam
- run `myDevice.selectProgram(<program key>)` this will select the specified program and update the programs constrains and options.

## To start a program
- run `myDevice.startProgram(<haid>, <programKey>, <options map>)`
