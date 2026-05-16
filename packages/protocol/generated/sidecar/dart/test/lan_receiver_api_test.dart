import 'package:test/test.dart';
import 'package:kidmemory_protocol/kidmemory_protocol.dart';


/// tests for LanReceiverApi
void main() {
  final instance = KidmemoryProtocol().getLanReceiverApi();

  group(LanReceiverApi, () {
    //Future lanReceiverControllerDiscover() async
    test('test lanReceiverControllerDiscover', () async {
      // TODO
    });

    //Future lanReceiverControllerDiscoverDevices() async
    test('test lanReceiverControllerDiscoverDevices', () async {
      // TODO
    });

    //Future lanReceiverControllerGetSessionStatus() async
    test('test lanReceiverControllerGetSessionStatus', () async {
      // TODO
    });

    //Future lanReceiverControllerPair() async
    test('test lanReceiverControllerPair', () async {
      // TODO
    });

    //Future lanReceiverControllerUpload() async
    test('test lanReceiverControllerUpload', () async {
      // TODO
    });

  });
}
