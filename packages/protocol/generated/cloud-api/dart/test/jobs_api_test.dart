import 'package:test/test.dart';
import 'package:kidmemory_protocol/kidmemory_protocol.dart';


/// tests for JobsApi
void main() {
  final instance = KidmemoryProtocol().getJobsApi();

  group(JobsApi, () {
    // Get pending jobs for device
    //
    //Future<List<JobResponseDto>> jobsControllerGetPendingJobs({ num limit, Object deviceId }) async
    test('test jobsControllerGetPendingJobs', () async {
      // TODO
    });

    // Update job status
    //
    //Future<JobResponseDto> jobsControllerUpdateStatus() async
    test('test jobsControllerUpdateStatus', () async {
      // TODO
    });

  });
}
