# travel_diary_network

Production-ready networking package for Flutter apps.

## Features
- Dio-based HTTP client
- Auth token injection and refresh flow
- Connectivity checks
- Structured logging with `logger`
- Consistent error mapping
- Reusable base service layer

## Usage

```dart
import 'package:travel_diary_network/network.dart';
```

## Quick start

```dart
final networkClient = NetworkClient(
  config: NetworkConfig(
    baseUrl: 'https://api.example.com',
    tokenRefresher: ({required dio, required refreshToken}) async {
      if (refreshToken == null) return null;
      final response = await dio.post(
        '/auth/refresh-token',
        options: Options(headers: {'Cookie': 'refreshToken=$refreshToken'}),
      );

      return TokenPair.fromJson(response.data as Map<String, dynamic>);
    },
  ),
  tokenProvider: yourTokenProvider,
);
```

See `lib/network.dart` for the public API.
