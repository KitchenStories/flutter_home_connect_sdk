import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:eventsource/eventsource.dart';
import 'package:homeconnect/homeconnect.dart';
import 'package:homeconnect/src/models/event/event_controller.dart';
import 'package:homeconnect/src/utils/uri.dart';

import 'package:http/http.dart' as http;

class HomeConnectApi {
  late http.Client client;
  Uri baseUrl;
  String _accessToken = '';
  late StreamSubscription<Event> subscription;

  /// oauth client credentials
  HomeConnectClientCredentials credentials;
  HomeConnectAuth? authenticator;
  HomeConnectAuthStorage storage = MemoryHomeConnectAuthStorage();

  HomeConnectApi(this.baseUrl, {required this.credentials, HomeConnectAuthStorage? storage, this.authenticator}) {
    client = http.Client();

    // set default storage
    if (storage != null) {
      this.storage = storage;
    }
  }

  Future<void> authenticate() async {
    if (authenticator == null) {
      throw Exception('No authenticator provided');
    }
    final token = await authenticator!.authorize(baseUrl, credentials);
    _accessToken = token.accessToken;
    storage.setCredentials(token);
  }

  Future<bool> shouldRefreshToken() async {
    final userCredentials = await storage.getCredentials();
    if (userCredentials == null || userCredentials.isAccessTokenExpired()) {
      return true;
    }
    return false;
  }

  Future<void> refreshToken() async {
    if (authenticator == null) {
      throw Exception('No authenticator provided');
    }
    final userCredentials = await storage.getCredentials();
    if (userCredentials == null) {
      throw Exception('Failed to refresh token');
    }
    final tokens = await authenticator?.refresh(baseUrl, userCredentials.refreshToken);
    if (tokens == null) {
      throw Exception('Failed to refresh token');
    }
    _accessToken = tokens.accessToken;
    await storage.setCredentials(tokens);
  }

  Future<http.Response> put({required String resource, required String body}) async {
    await checkTokenIntegrity();
    final uri = baseUrl.join('/api/homeappliances/$resource');
    final response = await client.put(uri, headers: commonHeaders, body: body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw Exception(response.body);
    }
  }

  Future<http.Response> get(String resource) async {
    await checkTokenIntegrity();
    final uri = baseUrl.join('/api/homeappliances/$resource');
    final response = await client.get(
      uri,
      headers: commonHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw Exception(response.body);
    }
  }

  Future<http.Response> delete(String resource) async {
    await checkTokenIntegrity();
    final uri = baseUrl.join('/api/homeappliances/$resource');
    final response = await client.delete(
      uri,
      headers: commonHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw Exception(response.body);
    }
  }

  Map<String, String> get commonHeaders {
    final result = <String, String>{};
    result['Authorization'] = 'Bearer $_accessToken';
    result['Content-Type'] = 'application/vnd.bsh.sdk.v1+json';
    return result;
  }

  Future<List<HomeDevice>> getDevices() async {
    final response = await get('');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> devices = data['data']['homeappliances'];
      final result = <HomeDevice>[];
      for (final device in devices) {
        final deviceType = device['type'];
        switch (deviceType) {
          case 'Oven':
            DeviceInfo info = DeviceInfo.fromJson(device);
            result.add(DeviceOven.fromInfoPayload(this, info));
            break;
        }
      }
      return result;
    } else {
      throw Exception('Error getting devices: ${response.body}');
    }
  }

  Future<void> openEventListenerChannel({required HomeDevice source}) async {
    final uri = baseUrl.join("/api/homeappliances/${source.info.haId}/events");
    await checkTokenIntegrity();
    EventController eventController = EventController();

    try {
      EventSource eventSource = await EventSource.connect(
        uri,
        headers: commonHeaders,
      );
      subscription = eventSource.listen((Event event) {
        eventController.handleEvent(event, source);
      });
    } catch (e) {
      throw Exception("Event Source error: $e");
    }
  }

  Future<void> closeEventChannel() async {
    await subscription.cancel();
  }

  Future<HomeConnectAuthCredentials?> checkTokenIntegrity() async {
    if (await shouldRefreshToken()) {
      await refreshToken();
    }

    final userCredentials = await storage.getCredentials();
    return userCredentials;
  }

  Future<bool> isAuthenticated() async {
    final credentials = await storage.getCredentials();
    if (credentials == null) {
      return false;
    }

    return !credentials.isAccessTokenExpired() || !credentials.isRefreshTokenExpired();
  }

  Future<void> logout() async {
    _accessToken = '';
    await storage.clearCredentials();
  }
}
