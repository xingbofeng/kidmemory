import 'package:test/test.dart';
import 'package:kidmemory_protocol/kidmemory_protocol.dart';


/// tests for HealthApi
void main() {
  final instance = KidmemoryProtocol().getHealthApi();

  group(HealthApi, () {
    // Health check endpoint
    //
    //Future healthControllerGetHealth() async
    test('test healthControllerGetHealth', () async {
      // TODO
    });

    // Readiness check endpoint
    //
    //Future healthControllerGetReadiness() async
    test('test healthControllerGetReadiness', () async {
      // TODO
    });

  });
}
