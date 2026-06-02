part of 'app_test.dart';

String _taskIdFromTaskRoute(String path) {
  final parts = path.split('/');
  final index = parts.indexOf('tasks');
  if (index >= 0 && index + 1 < parts.length) {
    return Uri.decodeComponent(parts[index + 1]);
  }
  return '';
}

class _FakeSidecarApi extends SidecarApi {
  Map<String, dynamic>? lastExportBody;
  String? lastTaskId;
  Map<String, dynamic>? lastGenerateBody;
  Map<String, dynamic>? lastTaskBody;
  Map<String, dynamic>? lastPathBody;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/ui') {
      return {
        'generate': {
          'templates': ['温暖童趣'],
          'pageSizes': ['A4 竖版  210 × 297 mm'],
          'styles': ['温暖童趣  亲切温暖，适合儿童阅读'],
          'exportTargets': ['PDF 文件  高质量 PDF（打印级别）', '长图 JPG 体积更小'],
          'defaults': {
            'template': '温暖童趣',
            'pageSize': 'A4 竖版  210 × 297 mm',
            'style': '温暖童趣  亲切温暖，适合儿童阅读',
            'exportTarget': '长图 JPG 体积更小',
          },
        },
      };
    }
    if (path == '/config/status') {
      return {
        'ok': true,
        'paths': {'exportDir': '/tmp/kidmemory-exports'},
      };
    }
    if (path == '/api/config/agent-configs/default') {
      return {
        'id': 'agent-config-default',
        'name': 'Default Agent',
        'provider': 'custom',
        'model': 'mimo-v2-pro',
        'baseUrl': 'https://api.xiaomimimo.com/v1',
        'apiKeyConfigured': true,
        'temperature': 0.7,
        'maxTokens': 4096,
        'toolsEnabled': <String>[],
        'workspaceConfig': <String, dynamic>{},
        'isDefault': true,
        'isActive': true,
        'createdAt': '2026-05-20T00:00:00.000Z',
        'updatedAt': '2026-05-20T00:00:00.000Z',
      };
    }
    if (path == '/children') {
      return {
        'children': [
          {'id': 'child-1', 'name': '澄澄'},
        ],
      };
    }
    if (path.startsWith('/assets')) {
      return {
        'assets': [
          {
            'id': 'asset-dino-world',
            'title': '恐龙世界',
            'type': 'artwork',
            'description': '描述',
            'tags': ['恐龙'],
            'capturedAt': '2026-05-12',
          },
        ],
      };
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/api/config/agent-configs/agent-config-default/test') {
      return {'success': true, 'responseTime': 42, 'modelUsed': 'mimo-v2-pro'};
    }
    if (path.startsWith('/config/check/')) {
      return {'ok': true};
    }
    if (path == '/config/paths') {
      lastPathBody = body;
      return {'ok': true, 'paths': body};
    }
    if (path == '/creation/tasks') {
      lastTaskBody = body;
      return {
        'taskId': 'task_123456',
        'creationType': body['creationType'] ?? 'storybook',
        'summary': 'Create a PDF from selected assets',
        'skillName': 'KidMemory storybook',
        'steps': _testPlanSteps,
        'requirements': _testStructuredPlanRequirements,
        'requirementItems': _testPlanRequirements,
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      final taskId = _taskIdFromTaskRoute(path);
      lastTaskId = taskId.isEmpty ? 'task_123456' : taskId;
      lastGenerateBody = {...body, 'taskId': lastTaskId};
      return {
        'taskId': lastTaskId,
        'creationType': 'storybook',
        'status': 'succeeded',
        'currentStepId': 'publish',
        'steps': const <Map<String, dynamic>>[],
        'artifacts': const <Map<String, dynamic>>[],
        'error': null,
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/export')) {
      lastExportBody = body;
      return {
        'artifactId': 'artifact-task-pdf',
        'kind': body['target'] ?? 'pdf',
        'taskId': lastTaskId,
        'localPath': body['targetPath'],
      };
    }
    return {'ok': true};
  }
}

class _SlowCreationSidecarApi extends _FakeSidecarApi {
  final planCompleter = Completer<Map<String, dynamic>>();
  final jobCompleter = Completer<Map<String, dynamic>>();

  void completePlan() {
    if (!planCompleter.isCompleted) {
      planCompleter.complete({
        'taskId': 'task_slow',
        'creationType': 'storybook',
        'summary': 'Slow creation plan is ready',
        'skillName': 'KidMemory storybook',
        'steps': _testPlanSteps,
        'requirements': _testPlanRequirements,
      });
    }
  }

  void completeJob() {
    if (!jobCompleter.isCompleted) {
      lastTaskId = 'task_slow';
      jobCompleter.complete({
        'taskId': lastTaskId,
        'creationType': 'storybook',
        'status': 'succeeded',
        'currentStepId': 'publish',
        'steps': const <Map<String, dynamic>>[],
        'artifacts': const <Map<String, dynamic>>[],
        'error': null,
      });
    }
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/creation/tasks') {
      lastTaskBody = body;
      return planCompleter.future;
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      final taskId = _taskIdFromTaskRoute(path);
      lastTaskId = taskId;
      lastGenerateBody = {...body, 'taskId': taskId};
      return jobCompleter.future;
    }
    return super.post(path, body);
  }
}

class _PlanFailureSidecarApi extends _FakeSidecarApi {
  int taskAttempts = 0;

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/creation/tasks') {
      taskAttempts += 1;
      lastTaskBody = body;
      throw const SidecarApiException('计划失败：规划服务暂时不可用');
    }
    return super.post(path, body);
  }
}

class _FailedCreationJobSidecarApi extends _FakeSidecarApi {
  int taskAttempts = 0;
  int generateAttempts = 0;

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/creation/tasks') {
      taskAttempts += 1;
      lastTaskBody = body;
      return {
        'taskId': 'task_failed_$taskAttempts',
        'creationType': body['creationType'] ?? 'storybook',
        'summary': 'Create a PDF from selected assets',
        'skillName': 'KidMemory storybook',
        'steps': _testPlanSteps,
        'requirements': _testPlanRequirements,
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      generateAttempts += 1;
      final taskId = _taskIdFromTaskRoute(path);
      lastTaskId = taskId.isEmpty ? 'task_failed_$generateAttempts' : taskId;
      lastGenerateBody = {...body, 'taskId': lastTaskId};
      return {
        'taskId': lastTaskId,
        'creationType': 'storybook',
        'status': 'failed',
        'currentStepId': 'generate',
        'steps': const <Map<String, dynamic>>[
          {
            'stepId': 'compose',
            'label': 'Compose selected assets',
            'status': 'succeeded',
          },
          {
            'stepId': 'plan',
            'label': 'Confirm persisted agent plan',
            'status': 'succeeded',
          },
          {
            'stepId': 'generate',
            'label': 'Generate PDF draft',
            'status': 'failed',
            'detail': 'Skill runtime crashed',
          },
        ],
        'artifacts': const <Map<String, dynamic>>[],
        'error': const {
          'category': 'skill',
          'message': 'Skill runtime crashed',
          'stepId': 'generate',
          'code': 'E_SKILL_RUNTIME',
        },
      };
    }
    return super.post(path, body);
  }
}

class _FailedMemoirVideoCreationJobSidecarApi extends _FakeSidecarApi {
  int taskAttempts = 0;
  int generateAttempts = 0;

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/creation/tasks') {
      taskAttempts += 1;
      lastTaskBody = body;
      return {
        'taskId': 'task_video_failed_$taskAttempts',
        'creationType': body['creationType'] ?? 'memoir_video',
        'summary': 'Create a memory video from selected assets',
        'skillName': 'KidMemory Hyperframes memoir video',
        'steps': const <Map<String, dynamic>>[
          {'stepId': 'compose', 'label': '准备视频素材', 'status': 'pending'},
          {'stepId': 'generate', 'label': '生成 MP4 视频', 'status': 'pending'},
        ],
        'requirements': const [
          {'label': 'Hyperframes runtime', 'required': true},
          {'label': 'FFmpeg available or auto-repaired', 'required': true},
        ],
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      generateAttempts += 1;
      final taskId = _taskIdFromTaskRoute(path);
      lastTaskId = taskId.isEmpty
          ? 'task_video_failed_$generateAttempts'
          : taskId;
      lastGenerateBody = {...body, 'taskId': lastTaskId};
      return {
        'taskId': lastTaskId,
        'creationType': 'memoir_video',
        'status': 'failed',
        'currentStepId': 'generate',
        'steps': const <Map<String, dynamic>>[
          {'stepId': 'compose', 'label': '准备视频素材', 'status': 'succeeded'},
          {
            'stepId': 'generate',
            'label': '生成 MP4 视频',
            'status': 'failed',
            'detail': 'Hyperframes render exited before writing MP4',
          },
        ],
        'artifacts': const <Map<String, dynamic>>[],
        'error': const {
          'category': 'hyperframes',
          'message': 'Hyperframes 未能成功生成 MP4。',
          'stepId': 'generate',
          'code': 'E_HYPERFRAMES_RENDER',
        },
      };
    }
    return super.post(path, body);
  }
}

class _SuccessfulMemoirVideoCreationJobSidecarApi extends _FakeSidecarApi {
  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/creation/tasks') {
      lastTaskBody = body;
      return {
        'taskId': 'task_video_success',
        'creationType': body['creationType'] ?? 'memoir_video',
        'summary': 'Create a memory video from selected assets',
        'skillName': 'KidMemory Hyperframes memoir video',
        'steps': const <Map<String, dynamic>>[
          {'stepId': 'compose', 'label': '准备视频素材', 'status': 'pending'},
          {'stepId': 'generate', 'label': '生成 MP4 视频', 'status': 'pending'},
        ],
        'requirements': _testPlanRequirements,
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      final taskId = _taskIdFromTaskRoute(path);
      lastTaskId = taskId.isEmpty ? 'task_video_success' : taskId;
      lastGenerateBody = {...body, 'taskId': lastTaskId};
      return {
        'taskId': lastTaskId,
        'creationType': 'memoir_video',
        'status': 'succeeded',
        'currentStepId': 'review',
        'steps': const <Map<String, dynamic>>[
          {'stepId': 'compose', 'label': '准备视频素材', 'status': 'succeeded'},
          {'stepId': 'generate', 'label': '生成 MP4 视频', 'status': 'succeeded'},
          {'stepId': 'review', 'label': '视频预览', 'status': 'succeeded'},
        ],
        'artifacts': const <Map<String, dynamic>>[
          {
            'artifactId': 'artifact-video-success',
            'kind': 'mp4',
            'localPath': '/tmp/kidmemory-exports/task_video_success.mp4',
          },
        ],
        'error': null,
      };
    }
    return super.post(path, body);
  }
}

class _SlowMemoirVideoCreationJobSidecarApi extends _FakeSidecarApi {
  final jobCompleter = Completer<Map<String, dynamic>>();

  void completeJob() {
    if (jobCompleter.isCompleted) return;
    jobCompleter.complete({
      'taskId': lastGenerateBody?['taskId'] ?? 'task_video_slow',
      'creationType': 'memoir_video',
      'status': 'succeeded',
      'currentStepId': 'review',
      'steps': const <Map<String, dynamic>>[
        {'stepId': 'compose', 'label': '准备视频素材', 'status': 'succeeded'},
        {'stepId': 'generate', 'label': '生成 MP4 视频', 'status': 'succeeded'},
        {'stepId': 'review', 'label': '视频预览', 'status': 'succeeded'},
      ],
      'artifacts': const <Map<String, dynamic>>[
        {
          'artifactId': 'artifact-video-slow',
          'kind': 'mp4',
          'localPath': '/tmp/kidmemory-exports/task_video_slow.mp4',
        },
      ],
      'error': null,
    });
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/creation/tasks') {
      lastTaskBody = body;
      return {
        'taskId': 'task_video_slow',
        'creationType': body['creationType'] ?? 'memoir_video',
        'summary': 'Create a memory video from selected assets',
        'skillName': 'KidMemory Hyperframes memoir video',
        'steps': const <Map<String, dynamic>>[
          {'stepId': 'compose', 'label': '准备视频素材', 'status': 'pending'},
          {'stepId': 'generate', 'label': '生成 MP4 视频', 'status': 'pending'},
        ],
        'requirements': _testPlanRequirements,
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      final taskId = _taskIdFromTaskRoute(path);
      lastTaskId = taskId;
      lastGenerateBody = {...body, 'taskId': taskId};
      return jobCompleter.future;
    }
    return super.post(path, body);
  }
}

class _RunningCreationSidecarApi extends _FakeSidecarApi {
  int pollCount = 0;

  Map<String, dynamic> runningJob({String detail = 'Running skill workspace'}) {
    return {
      'taskId': lastGenerateBody?['taskId'] ?? 'task_polling',
      'creationType': 'storybook',
      'status': 'running',
      'currentStepId': 'generate',
      'steps': [
        const {
          'stepId': 'compose',
          'label': 'Compose selected assets',
          'status': 'succeeded',
        },
        const {
          'stepId': 'plan',
          'label': 'Confirm persisted agent plan',
          'status': 'succeeded',
        },
        {
          'stepId': 'generate',
          'label': 'Generate PDF draft',
          'status': 'running',
          'detail': detail,
        },
      ],
      'artifacts': const <Map<String, dynamic>>[],
      'error': null,
    };
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      lastGenerateBody = body;
      lastTaskId = 'task_polling';
      return runningJob();
    }
    return super.post(path, body);
  }

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/creation/tasks/task_polling') {
      pollCount += 1;
      return runningJob(detail: 'Still generating');
    }
    return super.get(path);
  }
}

class _PollingCreationSidecarApi extends _RunningCreationSidecarApi {
  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/creation/tasks/task_polling') {
      pollCount += 1;
      return {
        'taskId': lastGenerateBody?['taskId'] ?? 'task_polling',
        'creationType': 'storybook',
        'status': 'succeeded',
        'currentStepId': 'review',
        'steps': const <Map<String, dynamic>>[
          {
            'stepId': 'compose',
            'label': 'Compose selected assets',
            'status': 'succeeded',
          },
          {
            'stepId': 'generate',
            'label': 'Generate PDF draft',
            'status': 'succeeded',
            'detail': 'Draft generated',
          },
          {
            'stepId': 'review',
            'label': 'Validate final artifact',
            'status': 'succeeded',
            'detail': 'Ready for review',
          },
        ],
        'artifacts': const <Map<String, dynamic>>[],
        'error': null,
      };
    }
    return super.get(path);
  }
}

class _SequencedPlanSidecarApi extends _FakeSidecarApi {
  int _nextPlanNumber = 1;
  final createdTaskIds = <String>[];
  final generatedTaskIds = <String>[];

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/creation/tasks') {
      lastTaskBody = body;
      final nextTaskId = 'task_${_nextPlanNumber++}';
      createdTaskIds.add(nextTaskId);
      return {
        'taskId': nextTaskId,
        'creationType': body['creationType'] ?? 'storybook',
        'summary': 'Create a PDF from selected assets',
        'skillName': 'KidMemory storybook',
        'steps': _testPlanSteps,
        'requirements': _testPlanRequirements,
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      final taskId = _taskIdFromTaskRoute(path);
      lastTaskId = taskId;
      lastGenerateBody = {...body, 'taskId': taskId};
      generatedTaskIds.add(taskId);
      return {
        'taskId': taskId,
        'creationType': 'storybook',
        'status': 'succeeded',
        'currentStepId': 'publish',
        'steps': const <Map<String, dynamic>>[],
        'artifacts': const <Map<String, dynamic>>[],
        'error': null,
      };
    }
    return super.post(path, body);
  }
}

class _SlowExportSidecarApi extends _FakeSidecarApi {
  final exportCompleter = Completer<Map<String, dynamic>>();

  void completeExport() {
    if (!exportCompleter.isCompleted) {
      exportCompleter.complete({
        'artifactId': 'artifact-task-pdf',
        'kind': lastExportBody?['target'] ?? 'pdf',
        'taskId': lastTaskId,
        'localPath': lastExportBody?['targetPath'],
      });
    }
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path.startsWith('/creation/tasks/') && path.endsWith('/export')) {
      lastExportBody = body;
      return exportCompleter.future;
    }
    return super.post(path, body);
  }
}

class _FailingExportSidecarApi extends _FakeSidecarApi {
  int exportRequests = 0;

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path.startsWith('/creation/tasks/') && path.endsWith('/export')) {
      exportRequests += 1;
      lastExportBody = body;
      throw const SidecarApiException('导出服务暂时不可用');
    }
    return super.post(path, body);
  }
}

class _SlowShareSidecarApi extends _FakeSidecarApi {
  final shareCompleter = Completer<Map<String, dynamic>>();
  Map<String, dynamic>? lastShareBody;
  int shareRequests = 0;

  void completeShare() {
    if (!shareCompleter.isCompleted) {
      shareCompleter.complete({
        'shareId': 'share_task_123456',
        'shareUrl': 'http://localhost:3001/share/share_task_123456',
        'artifactId': lastShareBody?['artifactId'],
      });
    }
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path.startsWith('/creation/tasks/') && path.endsWith('/share')) {
      shareRequests += 1;
      lastShareBody = body;
      return shareCompleter.future;
    }
    return super.post(path, body);
  }
}

class _FailingShareSidecarApi extends _FakeSidecarApi {
  Map<String, dynamic>? lastShareBody;
  int shareRequests = 0;

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path.startsWith('/creation/tasks/') && path.endsWith('/share')) {
      shareRequests += 1;
      lastShareBody = body;
      throw const SidecarApiException('分享服务暂时不可用');
    }
    return super.post(path, body);
  }
}

class _SampleFlowSidecarApi extends _FakeSidecarApi {
  bool sampleImported = false;
  int resetSampleCalls = 0;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/children') {
      return {
        'children': [
          {'id': 'child-1', 'name': '澄澄'},
          if (sampleImported) {'id': 'sample-child-001', 'name': '小朋友'},
        ],
      };
    }
    if (path.startsWith('/assets')) {
      return {
        'assets': [
          {
            'id': sampleImported ? 'sample-asset-1' : 'asset-dino-world',
            'title': sampleImported ? '阳光花园' : '恐龙世界',
            'type': 'artwork',
            'description': sampleImported ? '示例素材库' : '描述',
            'tags': [sampleImported ? '示例' : '恐龙'],
            'capturedAt': '2026-05-12',
          },
        ],
      };
    }
    return super.get(path);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/sample/import') {
      sampleImported = true;
      return {'ok': true, 'childId': 'sample-child-001', 'assetCount': 1};
    }
    if (path == '/sample/reset') {
      resetSampleCalls += 1;
      sampleImported = false;
      return {'ok': true, 'deletedAssets': 1};
    }
    return super.post(path, body);
  }
}

class _CoverFailureSidecarApi extends _FakeSidecarApi {
  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/creation/tasks') {
      lastTaskBody = body;
      throw const SidecarApiException('封面图生成失败：免费生图服务暂时不可用');
    }
    return super.post(path, body);
  }
}

class _SupabaseStorageSidecarApi extends _FakeSidecarApi {
  _SupabaseStorageSidecarApi({this.failStorageTest = false});

  final bool failStorageTest;
  Map<String, dynamic>? lastLongImageExportBody;
  Map<String, dynamic>? lastStorageConfigBody;
  final storageSyncArtifactIds = <String>[];
  int storageWorkerRuns = 0;
  int storageTestCalls = 0;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/status') {
      return {
        'ok': true,
        'paths': {'exportDir': '/tmp/kidmemory-exports'},
        'supabaseStorage': {
          'provider': 'supabase',
          'url': 'https://project.supabase.co',
          'bucket': 'kidmemory-exports',
          'serviceRoleKeyConfigured': true,
          'serviceRoleKey': 'secret-service-role',
          'publicBaseUrl': '',
          'signedUrlTtlSeconds': 3600,
          's3': {
            'endpoint': 'https://project.supabase.co/storage/v1/s3',
            'region': 'auto',
            'accessKeyIdConfigured': false,
            'secretAccessKeyConfigured': false,
            'configured': false,
          },
          'configured': true,
          'authMode': 'rest',
        },
      };
    }
    if (path == '/storage/export-artifacts/artifact-task-jpg/share') {
      return {
        'ok': true,
        'url': 'https://project.supabase.co/signed/task_123456.jpg',
        'expiresInSeconds': 3600,
        'text':
            'KidMemory 作品集：https://project.supabase.co/signed/task_123456.jpg\n链接有效期：3600 秒',
      };
    }
    return super.get(path);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/config/supabase-storage') {
      lastStorageConfigBody = body;
      return {
        'ok': true,
        'config': {
          'provider': body['provider'] ?? 'supabase',
          'url': body['url'] ?? 'https://project.supabase.co',
          'bucket': body['bucket'] ?? 'kidmemory-exports',
          'serviceRoleKeyConfigured': body['serviceRoleKey'] != null,
          'publicBaseUrl': body['publicBaseUrl'] ?? '',
          'signedUrlTtlSeconds': body['signedUrlTtlSeconds'] ?? 3600,
          'configured': true,
          'authMode': body['serviceRoleKey'] != null ? 'rest' : 's3',
          's3CredentialsDetected': true,
          's3': {
            'endpoint':
                body['s3Endpoint'] ??
                'https://project-ref.storage.supabase.co/storage/v1/s3',
            'region': body['s3Region'] ?? 'auto',
            'accessKeyIdConfigured': body['s3AccessKeyId'] != null,
            'secretAccessKeyConfigured': body['s3SecretAccessKey'] != null,
            'configured': true,
          },
        },
      };
    }
    if (path == '/config/supabase-storage/test') {
      storageTestCalls += 1;
      if (failStorageTest) {
        return {
          'ok': false,
          'message': '云端分享连接不可用',
          'cleanup': {'ok': true},
        };
      }
      return {
        'ok': true,
        'message': '测试通过',
        'cleanup': {'ok': true},
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/export')) {
      lastLongImageExportBody = body;
      return {
        'artifactId': 'artifact-task-jpg',
        'taskId': lastTaskId,
        'kind': body['target'] ?? 'long_image_jpg',
        'localPath': body['targetPath'],
        'storageProvider': 'local',
        'storageStatus': 'local_only',
      };
    }
    if (path == '/storage/export-artifacts/artifact-task-jpg/sync') {
      storageSyncArtifactIds.add('artifact-task-jpg');
      return {
        'enqueued': true,
        'targetId': 'artifact-task-jpg',
        'status': 'pending',
      };
    }
    if (path == '/storage/sync/run') {
      storageWorkerRuns += 1;
      return {
        'processed': 1,
        'succeeded': 1,
        'retried': 0,
        'failed': 0,
        'skipped': 0,
      };
    }
    return super.post(path, body);
  }
}

class _RelativePathSidecarApi extends _FakeSidecarApi {
  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/status') {
      return {
        'ok': true,
        'paths': {'exportDir': '.kidmemory/exports'},
      };
    }
    return super.get(path);
  }
}

class _UnconfiguredSidecarApi extends _FakeSidecarApi {
  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/status') {
      return {
        'ok': true,
        'openai': {'baseUrl': '', 'model': '', 'apiKeyConfigured': false},
      };
    }
    if (path == '/api/config/agent-configs/default') {
      return {};
    }
    return super.get(path);
  }
}

class _DisconnectedSidecarApi extends SidecarApi {
  @override
  Future<Map<String, dynamic>> get(String path) async => {};

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    return {};
  }
}

class _NoChildrenSidecarApi extends SidecarApi {
  final children = <Map<String, String>>[];
  String? lastChildrenName;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/config/status') return {'ok': true};
    if (path == '/children') return {'children': children};
    if (path.startsWith('/assets')) return {'assets': []};
    return {};
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path.startsWith('/config/check/') || path == '/schema/init') {
      return {'ok': true};
    }
    if (path == '/children') {
      final child = {'id': '${body['id']}', 'name': '${body['name']}'};
      children.add(child);
      lastChildrenName = child['name'];
      return {'child': child};
    }
    return {'ok': true};
  }
}

class _SampleImportFailureApi extends _FakeSidecarApi {
  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/sample/import') return {};
    return super.post(path, body);
  }
}

class _MergedSearchSidecarApi extends _FakeSidecarApi {
  Map<String, dynamic>? lastSearchBody;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    if (path.startsWith('/search/indexing-status')) {
      return {
        'pending': 1,
        'running': 1,
        'retryWait': 0,
        'failed': 0,
        'searchable': 24,
      };
    }
    return super.get(path);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    if (path == '/search/query') {
      lastSearchBody = body;
      return {
        'total': 1,
        'items': [
          {
            'asset': {
              'id': 'asset-sun',
              'title': '太阳画',
              'type': 'artwork',
              'description': '画了太阳和户外花朵',
              'tags': ['太阳', '户外'],
              'capturedAt': '2026-05-12',
              'previewUrl': 'http://127.0.0.1:4317/assets/asset-sun/preview',
            },
            'reasons': ['标签匹配：太阳 / 户外'],
          },
        ],
      };
    }
    return super.post(path, body);
  }
}

class _MultiChildSidecarApi extends SidecarApi {
  Map<String, dynamic>? lastGenerateBody;
  final deletedAssetIds = <String>[];
  final deletedChildIds = <String>[];
  final calls = <String>[];
  String? lastChildrenName;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    calls.add('GET $path');
    if (path == '/config/status') return {'ok': true};
    if (path == '/children') {
      return {
        'children': [
          {'id': 'child-1', 'name': '澄澄'},
          {'id': 'child-2', 'name': '甜甜'},
        ],
      };
    }
    if (path == '/assets?childId=child-2') {
      return {
        'assets': [
          {
            'id': 'asset-child-2',
            'title': '甜甜的画',
            'type': 'artwork',
            'description': '描述',
            'tags': ['甜甜'],
            'capturedAt': '2026-05-12',
          },
        ],
      };
    }
    if (path.startsWith('/assets')) {
      return {
        'assets': [
          {
            'id': 'asset-dino-world',
            'title': '澄澄的画',
            'type': 'artwork',
            'description': '描述',
            'tags': ['澄澄'],
            'capturedAt': '2026-05-12',
          },
        ],
      };
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    calls.add('POST $path');
    if (path.startsWith('/config/check/')) {
      return {'ok': true};
    }
    if (path == '/schema/init') {
      return {'ok': true};
    }
    if (path == '/children') {
      lastChildrenName = '${body['name']}';
      return {
        'child': {'id': body['id'], 'name': body['name'], 'metadata': {}},
      };
    }
    if (path == '/creation/tasks') {
      lastGenerateBody = {
        ...body,
        if (!body.containsKey('settings')) 'settings': {'childId': 'child-2'},
      };
      return {
        'taskId': 'task_123456',
        'creationType': body['creationType'] ?? 'storybook',
        'summary': 'Create a PDF from selected assets',
        'skillName': 'KidMemory storybook',
        'steps': _testPlanSteps,
        'requirements': _testPlanRequirements,
      };
    }
    if (path.startsWith('/creation/tasks/') && path.endsWith('/generate')) {
      return {
        'taskId': 'task_123456',
        'creationType': 'storybook',
        'status': 'succeeded',
        'currentStepId': 'publish',
        'steps': const <Map<String, dynamic>>[],
        'artifacts': const <Map<String, dynamic>>[],
        'error': null,
      };
    }
    return {'ok': true};
  }

  @override
  Future<Map<String, dynamic>> patch(
    String path, [
    Map<String, dynamic> body = const {},
  ]) async {
    calls.add('PATCH $path');
    if (path.startsWith('/children/')) {
      lastChildrenName = '${body['name']}';
      return {
        'child': {
          'id': path.split('/').last,
          'name': body['name'],
          'birthday': body['birthday'],
          'notes': body['notes'],
        },
      };
    }
    return {'ok': true};
  }

  @override
  Future<Map<String, dynamic>> delete(String path) async {
    calls.add('DELETE $path');
    if (path.startsWith('/children/')) {
      deletedChildIds.add(path.split('/').last);
    } else {
      deletedAssetIds.add(path.split('/').last);
    }
    return {'ok': true};
  }
}
