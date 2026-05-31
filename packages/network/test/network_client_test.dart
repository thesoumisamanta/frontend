import 'package:flutter_test/flutter_test.dart';
import 'package:travel_diary_network/network.dart';

void main() {
  test('NetworkClient configures dio with base url', () {
    final client = NetworkClient(
      config: const NetworkConfig(baseUrl: 'https://api.example.com'),
    );

    expect(client.dio.options.baseUrl, 'https://api.example.com');
    client.close(force: true);
  });

  test('NetworkConfig copies values correctly', () {
    const config = NetworkConfig(baseUrl: 'https://api.example.com');
    final updated = config.copyWith(enableLogging: false);

    expect(updated.baseUrl, 'https://api.example.com');
    expect(updated.enableLogging, isFalse);
  });
}
