import 'dart:convert';

import 'package:http/http.dart' as http;
import './resources/device.dart';

class HomeConnectApi {
  late http.Client client;
  String baseUrl;
  String accessToken;
  late final Devices devices;

  HomeConnectApi(this.baseUrl, { required this.accessToken }) {
    client = http.Client();
    devices = Devices(this);
  }

  Future<http.Response> get(String resource) async {
    var path = '$baseUrl/$resource';
    final uri = Uri.tryParse(path);
    if (uri == null) {
      throw Exception('Invalid URI: $path');
    }
    final response = await http.get(
      uri,
      headers: commonHeaders,
    );
    return response;
  }

  Map<String, String> get commonHeaders {
    final result = <String, String>{};
    result['Authorization'] = 'Bearer $accessToken';
    return result;
  }
}
