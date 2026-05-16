import 'package:test/test.dart';
import 'package:kidmemory_protocol/kidmemory_protocol.dart';


/// tests for SecurityMonitorApi
void main() {
  final instance = KidmemoryProtocol().getSecurityMonitorApi();

  group(SecurityMonitorApi, () {
    //Future securityMonitorControllerGetSecurityHealth() async
    test('test securityMonitorControllerGetSecurityHealth', () async {
      // TODO
    });

    //Future securityMonitorControllerGetSecurityStats() async
    test('test securityMonitorControllerGetSecurityStats', () async {
      // TODO
    });

  });
}
