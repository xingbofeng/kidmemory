import 'package:test/test.dart';
import 'package:kidmemory_protocol/kidmemory_protocol.dart';


/// tests for DevicesApi
void main() {
  final instance = KidmemoryProtocol().getDevicesApi();

  group(DevicesApi, () {
    // Get device by ID
    //
    //Future<DeviceResponseDto> devicesControllerGetDevice() async
    test('test devicesControllerGetDevice', () async {
      // TODO
    });

    // Update device heartbeat
    //
    //Future<DeviceResponseDto> devicesControllerHeartbeat() async
    test('test devicesControllerHeartbeat', () async {
      // TODO
    });

    // Register a device (idempotent by machineId)
    //
    //Future<DeviceResponseDto> devicesControllerRegister() async
    test('test devicesControllerRegister', () async {
      // TODO
    });

  });
}
