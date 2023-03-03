# Home Connect Futter

The Home Connect Flutter package contains utilities for oauth and
storage management that can be used in your Flutter app.

## Usage

```dart
import 'package:homeconnect_flutter/homeconnect_flutter.dart';

Future<void> main() async {

  final prefs = await SharedPreferences.getInstance();
  final api =
      HomeConnectApi(Uri.parse(env["HOMECONNECT_URL"]!),
          credentials: HomeConnectClientCredentials(
            clientId: env["HOMECONNECT_CLIENT_ID"]!,
            redirectUri: env["HOMECONNECT_REDIRECT_URL"]!, // redirectUrl,
          ),
          authenticator: null,
          // pass storage to handle refresh tokens
          storage: SharedPreferencesHomeConnectAuthStorage(
            prefs,
          ),
      );
}

    // ... in you widget run the authorize function to start the oauth webview flow
    TextButton(
        onPressed: () async {
            await homeconnectApi.authenticate();
        },
    )
```
