import 'package:test/test.dart';
import 'package:kidmemory_protocol/kidmemory_protocol.dart';


/// tests for ConfigApi
void main() {
  final instance = KidmemoryProtocol().getConfigApi();

  group(ConfigApi, () {
    // Get configuration status
    //
    //Future configControllerGetStatus() async
    test('test configControllerGetStatus', () async {
      // TODO
    });

  });
}
