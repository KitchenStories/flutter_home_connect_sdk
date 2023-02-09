import 'dart:convert';
import '../client.dart' show HomeConnectApi;

enum DeviceType {
  oven,
  coffeMaker,
  fridgeFreezer,
  dishwasher,
  washer,
  dryer,
}

Map<String, DeviceType> deviceTypeMap = {
  'Oven': DeviceType.oven,
  'CoffeeMaker': DeviceType.coffeMaker,
  'FridgeFreezer': DeviceType.fridgeFreezer,
  'Dishwasher': DeviceType.dishwasher,
  'Washer': DeviceType.washer,
  'Dryer': DeviceType.dryer,
};

class Device {
  late HomeConnectApi api;

  String name;
  String brand;
  String vib;
  bool connected;
  DeviceType type;
  String enumber;
  String haId;

  Device(HomeConnectApi api, {
    required this.name,
    required this.brand,
    required this.vib,
    required this.connected,
    required this.type,
    required this.enumber,
    required this.haId,
  }) {
    this.api = api;
  }

  String toString() {
    return "Device: $name type: $type";
  }

  Future<Map<String, dynamic>> get status async {
    final response = await api.get('homeappliances/$haId/status');
    return jsonDecode(response.body);
  }

  factory Device.fromJson(Map<String, dynamic> json, HomeConnectApi api) {
    DeviceType deviceType = deviceTypeMap[json['type']]!;
    return Device(
      api,
      name: json['name'],
      brand: json['brand'],
      vib: json['vib'],
      connected: json['connected'],
      type: deviceType,
      enumber: json['enumber'],
      haId: json['haId'],
    );
  }
}

class Oven extends Device {
  Oven(HomeConnectApi api, {
    required super.name,
    required super.brand,
    required super.vib,
    required super.connected,
    required super.type,
    required super.enumber,
    required super.haId,
  }) : super(api);
}

class CoffeMaker extends Device {
  CoffeMaker(HomeConnectApi api, {
    required super.name,
    required super.brand,
    required super.vib,
    required super.connected,
    required super.type,
    required super.enumber,
    required super.haId,
  }) : super(api);
}

class Devices {
  final HomeConnectApi api;

  Devices(this.api);

  Future<List<Device>> getAll() async {
    // ...
    final res = await api.get('homeappliances');
    //print(res.body);
    final json = jsonDecode(res.body);
    final deviceMap = List.from(json['data']?['homeappliances']);
    final devices = deviceMap.map((device) {
      return Device.fromJson(device, api);
    }).toList();
    return devices;
  }
}
