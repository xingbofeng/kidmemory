import '../../shared/models/library_models.dart';
// ignore: unused_import
import 'package:kidmemory_protocol/kidmemory_protocol.dart' as protocol;
import 'agent_config_api.dart';
import 'sidecar_api.dart';
import 'sidecar_dtos.dart';

class DesktopSidecarGateway {
  const DesktopSidecarGateway(this._api);

  final SidecarApi _api;

  Future<ReadinessSnapshot> loadReadiness() async {
    final uiConfig = await _api.get('/config/ui');
    final config = await _api.getStrict('/config/status');
    final schema = await _api.postStrict('/schema/init');
    final postgres = await _api.postStrict('/config/check/postgres');
    final pgvector = await _api.postStrict('/config/check/pgvector');
    final openai = await checkOpenAiDto();
    return ReadinessSnapshot(
      uiConfig: uiConfig,
      config: ReadinessConfig.fromJson(config),
      schema: ReadinessCheckDto.fromJson(schema),
      postgres: ReadinessCheckDto.fromJson(postgres),
      pgvector: ReadinessCheckDto.fromJson(pgvector),
      openai: openai,
    );
  }

  Future<DatasetSnapshot> loadDataset({
    required String? selectedChildId,
  }) async {
    final childrenResponse = await _api.getStrict('/children');
    final children = _mapListAt(
      childrenResponse,
      'children',
    ).map(_childVmFromJson).toList();

    final activeChildId =
        selectedChildId ?? (children.isNotEmpty ? children.first.id : null);
    final assetsResponse = activeChildId == null
        ? const <String, dynamic>{'assets': <dynamic>[]}
        : await _api.getStrict(
            '/assets?childId=${Uri.encodeComponent(activeChildId)}',
          );
    final assetRows = _mapListAt(
      assetsResponse,
      'assets',
    ).map(_assetRecordFromJson).toList();

    return DatasetSnapshot(
      children: children,
      activeChildId: activeChildId,
      assetRows: assetRows,
    );
  }

  Future<Map<String, dynamic>> createCreationTaskRaw({
    required String goal,
    required String creationType,
    required List<String> assetIds,
    Map<String, dynamic> settings = const {},
  }) async {
    return _api.postStrict('/creation/tasks', {
      'goal': goal,
      'creationType': creationType,
      'assetIds': assetIds,
    });
  }

  Future<Map<String, dynamic>> generateCreationTaskRaw({
    required String taskId,
  }) async {
    return _api.postStrict(
      '/creation/tasks/${Uri.encodeComponent(taskId)}/generate',
      {},
    );
  }

  Future<Map<String, dynamic>> getCreationTaskRaw({
    required String taskId,
  }) async {
    return _api.getStrict('/creation/tasks/${Uri.encodeComponent(taskId)}');
  }

  Future<Map<String, dynamic>> getCreationTaskEventsRaw({
    required String taskId,
  }) async {
    return _api.getStrict(
      '/creation/tasks/${Uri.encodeComponent(taskId)}/events',
    );
  }

  Future<Map<String, dynamic>> exportCreationTaskRaw({
    required String taskId,
    required String target,
    String? targetPath,
  }) async {
    return _api
        .postStrict('/creation/tasks/${Uri.encodeComponent(taskId)}/export', {
          'target': target,
          if (targetPath != null && targetPath.trim().isNotEmpty)
            'targetPath': targetPath.trim(),
        });
  }

  Future<Map<String, dynamic>> shareCreationTaskRaw({
    required String taskId,
    required String artifactId,
  }) async {
    return _api.postStrict(
      '/creation/tasks/${Uri.encodeComponent(taskId)}/share',
      {'artifactId': artifactId},
    );
  }

  Future<AssetSearchResultDto> searchAssetsDto({
    required AssetSearchRequestDto payload,
  }) async {
    final raw = await _api.post('/search/query', payload.toJson());
    return AssetSearchResponseDto.fromJson(raw);
  }

  Future<IndexingStatusDto> getIndexingStatusDto({
    required String childId,
  }) async {
    final raw = await _api.get('/search/indexing-status?childId=$childId');
    return IndexingStatusResponseDto.fromJson(raw);
  }

  Future<ImportSampleResultDto> importSampleDatasetDto() async {
    final raw = await _api.post('/sample/import', {'persist': true});
    return ImportSampleResponseDto.fromJson(raw);
  }

  Future<ResetSampleResultDto> resetSampleDatasetDto({
    required String childId,
  }) async {
    final raw = await _api.post('/sample/reset', {'childId': childId});
    return ResetSampleResponseDto.fromJson(raw);
  }

  Future<EnsureChildResultDto> ensureChildDto({
    required String id,
    required String name,
    String birthday = '',
    String notes = '',
  }) async {
    final payload = <String, dynamic>{
      'id': id,
      'name': name,
      if (birthday.trim().isNotEmpty) 'birthday': birthday.trim(),
      'notes': notes,
    };
    final raw = await _api.post('/children', payload);
    return EnsureChildResponseDto.fromJson(raw);
  }

  Future<void> updateChildDto({
    required String id,
    required String name,
    String birthday = '',
    String notes = '',
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'birthday': birthday.trim(),
      'notes': notes,
    };
    await _api.patch('/children/$id', payload);
  }

  Future<OperationResultDto> deleteChildDto({required String id}) async {
    final raw = await _api.delete('/children/$id');
    return OperationResultResponseDto.fromJson(raw);
  }

  Future<ImportAssetsResultDto> importAssetsDto({
    required ImportAssetsRequestDto payload,
  }) async {
    final raw = await _api.post('/assets/import', payload.toJson());
    return ImportAssetsResponseDto.fromJson(raw);
  }

  Future<UpdateAssetResultDto> updateAssetDto({
    required String assetId,
    required UpdateAssetRequestDto payload,
  }) async {
    final raw = await _api.patch('/assets/$assetId', payload.toJson());
    return UpdateAssetResponseDto.fromJson(raw);
  }

  Future<OperationResultDto> deleteAssetDto({required String assetId}) async {
    final raw = await _api.delete('/assets/$assetId');
    return OperationResultResponseDto.fromJson(raw);
  }

  Future<EnqueueResultDto> enqueueAssetSyncDto({
    required String assetId,
  }) async {
    final raw = await _api.post('/storage/assets/$assetId/sync');
    return EnqueueResponseDto.fromJson(raw);
  }

  Future<StorageSyncRunResultDto> runStorageSyncDto({
    required int limit,
  }) async {
    final raw = await _api.post('/storage/sync/run', {'limit': limit});
    return StorageSyncRunResponseDto.fromJson(raw);
  }

  Future<EnqueueResultDto> enqueueExportArtifactSyncDto({
    required String artifactId,
    required String childId,
  }) async {
    final raw = await _api.post('/storage/export-artifacts/$artifactId/sync', {
      'childId': childId,
    });
    return EnqueueResponseDto.fromJson(raw);
  }

  Future<ArtifactShareResultDto> getExportArtifactShareDto({
    required String artifactId,
  }) async {
    final raw = await _api.get('/storage/export-artifacts/$artifactId/share');
    return ArtifactShareResponseDto.fromJson(raw);
  }

  Future<ReadinessCheckDto> checkPostgresDto() async {
    final raw = await _api.post('/config/check/postgres');
    return ReadinessCheckDto.fromJson(raw);
  }

  Future<ReadinessCheckDto> checkPgvectorDto() async {
    final raw = await _api.post('/config/check/pgvector');
    return ReadinessCheckDto.fromJson(raw);
  }

  Future<ReadinessCheckDto> checkOpenAiDto() async {
    final agentConfigApi = AgentConfigApi(_api);
    AgentConfigResponseDto? config;
    try {
      config = await agentConfigApi.getDefaultAgentConfig();
    } on SidecarApiException {
      config = null;
    }
    if (config == null) {
      return ReadinessCheckDto(
        ok: false,
        service: 'openai',
        blocksGeneration: false,
        message: 'Agent model endpoint is not configured.',
      );
    }

    try {
      final result = await agentConfigApi.testAgentConfigById(config.id);
      return ReadinessCheckDto(
        ok: result.success,
        service: config.provider,
        blocksGeneration: false,
        message: result.success
            ? 'Agent config readiness check passed'
            : result.errorMessage ?? 'Agent config readiness check failed',
      );
    } on SidecarApiException catch (error) {
      return ReadinessCheckDto(
        ok: false,
        service: config.provider,
        blocksGeneration: false,
        message: error.message,
      );
    }
  }

  Future<ReadinessCheckDto> initSchemaDto() async {
    final raw = await _api.post('/schema/init');
    return ReadinessCheckDto.fromJson(raw);
  }

  Future<ConfigStatusDto> getConfigStatusDto() async {
    final raw = await _api.get('/config/status');
    return ConfigStatusDto.fromJson(raw);
  }

  Future<Map<String, dynamic>> getConfigStatusRaw() async {
    return _api.get('/config/status');
  }

  Future<OperationResultDto> configurePostgresDto({
    required PostgresConfigRequestDto payload,
  }) async {
    final raw = await _api.post('/config/postgres', payload.toJson());
    return OperationResultResponseDto.fromJson(raw);
  }

  Future<ConfigurePathsResultDto> configurePathsDto({
    required PathsConfigRequestDto payload,
  }) async {
    final raw = await _api.post('/config/paths', payload.toJson());
    return ConfigurePathsResponseDto.fromJson(raw);
  }

  Future<ConfigureSupabaseStorageResultDto> configureSupabaseStorageDto({
    required SupabaseStorageConfigRequestDto payload,
  }) async {
    final raw = await _api.post('/config/supabase-storage', payload.toJson());
    return ConfigureSupabaseStorageResponseDto.fromJson(raw);
  }

  Future<SupabaseStorageTestResultDto> testSupabaseStorageDto() async {
    final raw = await _api.post('/config/supabase-storage/test');
    return SupabaseStorageTestResponseDto.fromJson(raw);
  }
}

typedef PostgresConfigInput = PostgresConfigRequestDto;
typedef PathsConfigInput = PathsConfigRequestDto;
typedef SupabaseStorageConfigInput = SupabaseStorageConfigRequestDto;
typedef UpdateAssetInput = UpdateAssetRequestDto;
typedef AssetSearchInputPayload = AssetSearchRequestDto;
typedef ImportAssetsInput = ImportAssetsRequestDto;

class ReadinessSnapshot {
  const ReadinessSnapshot({
    required this.uiConfig,
    required this.config,
    required this.schema,
    required this.postgres,
    required this.pgvector,
    required this.openai,
  });

  final Map<String, dynamic> uiConfig;
  final ReadinessConfig config;
  final ReadinessCheckDto schema;
  final ReadinessCheckDto postgres;
  final ReadinessCheckDto pgvector;
  final ReadinessCheckDto openai;
}

class DatasetSnapshot {
  const DatasetSnapshot({
    required this.children,
    required this.activeChildId,
    required this.assetRows,
  });

  final List<ChildVm> children;
  final String? activeChildId;
  final List<AssetRecordDto> assetRows;
}

typedef ConfigStatusDto = ConfigStatusResponseDto;

class ReadinessConfig {
  const ReadinessConfig({
    required this.raw,
    required this.pathConfig,
    required this.openAiConfig,
    required this.supabaseStorageConfig,
  });

  factory ReadinessConfig.fromJson(Map<String, dynamic> raw) {
    return ReadinessConfig(
      raw: raw,
      pathConfig: PathConfigDto.fromJson(_mapAt(raw, 'paths')),
      openAiConfig: OpenAiConfigDto.fromJson(_mapAt(raw, 'openai')),
      supabaseStorageConfig: SupabaseStorageConfigDto.fromJson(
        _mapAt(raw, 'supabaseStorage'),
      ),
    );
  }

  final Map<String, dynamic> raw;
  final PathConfigDto pathConfig;
  final OpenAiConfigDto openAiConfig;
  final SupabaseStorageConfigDto supabaseStorageConfig;
}

typedef PathConfigDto = PathConfigResponseDto;
typedef OpenAiConfigDto = OpenAiConfigResponseDto;
typedef PostgresConfigDto = PostgresConfigResponseDto;
typedef SupabaseStorageConfigDto = SupabaseStorageConfigResponseDto;
typedef SupabaseS3ConfigDto = SupabaseS3ConfigResponseDto;
typedef ReadinessCheckDto = ReadinessCheckResponseDto;

extension ConfigStatusDtoExt on ConfigStatusDto {
  PostgresConfigDto get postgresConfig =>
      postgres ??
      PostgresConfigDto(host: '', port: 5432, database: '', user: '');
  OpenAiConfigDto get openAiConfig =>
      openai ??
      OpenAiConfigDto(baseUrl: '', model: '', apiKeyConfigured: false);
  SupabaseStorageConfigDto get supabaseStorageConfig =>
      supabaseStorage ??
      SupabaseStorageConfigDto(
        configured: false,
        url: '',
        bucket: '',
        serviceRoleKeyConfigured: false,
        publicBaseUrl: '',
        signedUrlTtlSeconds: 3600,
        s3CredentialsDetected: false,
        authMode: '',
        diagnosticMessage: '',
      );
  PathConfigDto get pathConfig =>
      paths ?? PathConfigDto(dataDir: '', workspaceDir: '', exportDir: '');
}

extension OpenAiConfigDtoExt on OpenAiConfigDto {
  bool get apiKeyConfiguredValue => apiKeyConfigured ?? false;
}

extension PostgresConfigDtoExt on PostgresConfigDto {
  String get hostValue => host ?? '';
  int get portValue => port ?? 5432;
  String get databaseValue => database ?? '';
  String get userValue => user ?? '';
}

extension SupabaseStorageConfigDtoExt on SupabaseStorageConfigDto {
  Map<String, dynamic> get raw => toJson();
  bool get configuredValue => configured ?? false;
  String get urlValue => url ?? '';
  String get bucketValue => bucket ?? '';
  bool get serviceRoleKeyConfiguredValue => serviceRoleKeyConfigured ?? false;
  String get publicBaseUrlValue => publicBaseUrl ?? '';
  int get signedUrlTtlSecondsValue => signedUrlTtlSeconds ?? 3600;
  bool get s3CredentialsDetectedValue => s3CredentialsDetected ?? false;
  String get authModeValue => authMode ?? '';
  String get diagnosticMessageValue => diagnosticMessage ?? '';
  SupabaseS3ConfigDto get s3Config =>
      s3 ??
      SupabaseS3ConfigDto(
        endpoint: '',
        region: '',
        accessKeyIdConfigured: false,
        secretAccessKeyConfigured: false,
      );
}

extension SupabaseS3ConfigDtoExt on SupabaseS3ConfigDto {
  String get endpointValue => endpoint ?? '';
  String get regionValue => region ?? '';
  bool get accessKeyConfigured => accessKeyIdConfigured ?? false;
  bool get secretKeyConfigured => secretAccessKeyConfigured ?? false;
}

extension ReadinessCheckDtoExt on ReadinessCheckDto {
  Map<String, dynamic> get raw => toJson();
  bool get isEmpty => raw.isEmpty;
  bool? get okOrNull => isEmpty ? null : isOk;
  bool get isOk => (ok == true) || (ready == true);
  bool get needsConfiguration => ok == false || ready == false;
  bool get blocksGeneration => this.blocksGeneration ?? false;
  String get service => (this.service ?? '').toLowerCase();
  String get message => this.message ?? '';
}

extension OperationResultDtoExt on OperationResultDto {
  Map<String, dynamic> get raw => toJson();
  bool get okValue => (ok == true) || (success == true);
  String get messageValue => message ?? '';
  String get codeValue => code ?? '';
}

extension ConfigurePathsResultDtoExt on ConfigurePathsResultDto {
  bool get okValue => (ok == true) || (success == true);
  PathConfigDto get pathConfig =>
      paths ?? PathConfigDto(dataDir: '', workspaceDir: '', exportDir: '');
}

extension ConfigureSupabaseStorageResultDtoExt
    on ConfigureSupabaseStorageResultDto {
  bool get okValue => (ok == true) || (success == true);
  SupabaseStorageConfigDto get configValue =>
      config ??
      SupabaseStorageConfigDto(
        configured: false,
        url: '',
        bucket: '',
        serviceRoleKeyConfigured: false,
        publicBaseUrl: '',
        signedUrlTtlSeconds: 3600,
        s3CredentialsDetected: false,
        authMode: '',
        diagnosticMessage: '',
      );
}

extension SupabaseStorageTestResultDtoExt on SupabaseStorageTestResultDto {
  bool get okValue => (ok == true) || (success == true);
  String get messageValue => message ?? '';
  String get codeValue => code ?? '';
  bool get cleanupOk => cleanup?.ok ?? true;
}

extension EnqueueResultDtoExt on EnqueueResultDto {
  bool get enqueuedValue => enqueued != false && reason == null;
  String get reasonValue => reason ?? '';
}

extension StorageSyncRunResultDtoExt on StorageSyncRunResultDto {
  int get failedValue => failed ?? 0;
  int get retriedValue => retried ?? 0;
}

extension ArtifactShareResultDtoExt on ArtifactShareResultDto {
  bool get okValue => (ok == true) || (success == true);
  String get messageValue => message ?? '';
  String get urlValue => url ?? '';
  String get textValue => text ?? '';
}

extension IndexingStatusDtoExt on IndexingStatusDto {
  int get pendingValue => pending ?? 0;
  int get runningValue => running ?? 0;
  int get retryWaitValue => retryWait ?? 0;
  int get failedValue => failed ?? 0;
  int get searchableValue => searchable ?? 0;
}

extension ImportSampleResultDtoExt on ImportSampleResultDto {
  Map<String, dynamic> get raw => toJson();
  bool get okValue => (ok == true) || (success == true);
  String get messageValue => message ?? '';
  String get childIdValue => childId ?? '';
  int get assetCountValue => assetCount ?? 0;
}

extension EnsureChildResultDtoExt on EnsureChildResultDto {
  Map<String, dynamic> get raw => toJson();
  String get childId => child?.id ?? '';
  String get childName => child?.name ?? child?.id ?? '';
  bool get hasChild => childId.isNotEmpty;
}

typedef OperationResultDto = OperationResultResponseDto;
typedef ConfigurePathsResultDto = ConfigurePathsResponseDto;
typedef ConfigureSupabaseStorageResultDto = ConfigureSupabaseStorageResponseDto;
typedef SupabaseStorageTestResultDto = SupabaseStorageTestResponseDto;
typedef EnqueueResultDto = EnqueueResponseDto;
typedef StorageSyncRunResultDto = StorageSyncRunResponseDto;
typedef ArtifactShareResultDto = ArtifactShareResponseDto;
typedef IndexingStatusDto = IndexingStatusResponseDto;
typedef ImportSampleResultDto = ImportSampleResponseDto;
typedef EnsureChildResultDto = EnsureChildResponseDto;

typedef ChildRecordDto = ChildRecordResponseDto;

extension ChildRecordDtoExt on ChildRecordDto {
  String get idValue => id ?? '';
  String get nameValue => (name ?? id ?? '');
}

typedef AssetSearchResultDto = AssetSearchResponseDto;
typedef AssetSearchItemDto = AssetSearchItemResponseDto;

typedef AssetRecordDto = AssetRecordResponseDto;

extension AssetRecordDtoExt on AssetRecordDto {
  String get idValue => id ?? '';
  String get titleValue => title ?? '';
  String get typeValue => type ?? 'artwork';
  String get descriptionValue => description ?? '';
  List<String> get tagsValue => tags ?? const <String>[];
  String get capturedAtValue => capturedAt ?? '';
  String get imagePathValue => imagePath ?? '';
  String get thumbnailPathValue => thumbnailPath ?? imagePathValue;
  String get previewUrlValue => previewUrl ?? '';
  String get originalFilenameValue => originalFilename ?? '';
  String get storageStatusValue => storageStatus ?? '';
}

typedef ImportAssetsResultDto = ImportAssetsResponseDto;
typedef ResetSampleResultDto = ResetSampleResponseDto;
typedef UpdateAssetResultDto = UpdateAssetResponseDto;

extension AssetSearchResultDtoExt on AssetSearchResultDto {
  bool get okValue => (ok == true) || (success == true);
  String get messageValue => message ?? '';
  String get codeValue => code ?? '';
  int get totalValue => total ?? 0;
  List<AssetSearchItemDto> get itemsValue =>
      items ?? const <AssetSearchItemDto>[];
}

extension AssetSearchItemDtoExt on AssetSearchItemDto {
  AssetRecordDto get assetValue => asset ?? AssetRecordDto();
  List<String> get reasonsValue => reasons ?? const <String>[];
}

extension ImportAssetsResultDtoExt on ImportAssetsResultDto {
  Map<String, dynamic> get raw => toJson();
  String get messageValue => message ?? '';
  String get titleValue => title ?? '';
  int get importedCount => imported?.length ?? 0;
  int get duplicatesCount => duplicates?.length ?? 0;
  int get failedCount => failed?.length ?? 0;
  int get skippedCount => skipped?.length ?? 0;
  List<String> get failedReasons =>
      (failed ?? const <ImportAssetsFailedItemDto>[])
          .map((item) => item.reason ?? '')
          .where((reason) => reason.trim().isNotEmpty)
          .toSet()
          .toList();
  bool get hasCounters =>
      importedCount > 0 ||
      duplicatesCount > 0 ||
      failedCount > 0 ||
      skippedCount > 0;
}

extension ResetSampleResultDtoExt on ResetSampleResultDto {
  int get deletedAssetsValue => deletedAssets ?? 0;
}

extension UpdateAssetResultDtoExt on UpdateAssetResultDto {
  bool get hasAsset => asset != null;
}

List<dynamic> _listAt(Map<String, dynamic> source, String key) {
  final value = source[key];
  return value is List ? value : const [];
}

List<Map<String, dynamic>> _mapListAt(Map<String, dynamic> source, String key) {
  return _listAt(source, key).whereType<Map<String, dynamic>>().toList();
}

Map<String, dynamic> _mapAt(Map<String, dynamic> source, String key) {
  final value = source[key];
  return _asMap(value);
}

Map<String, dynamic> _asMap(
  Object? value, {
  Map<String, dynamic> fallback = const {},
}) {
  return value is Map<String, dynamic> ? value : fallback;
}

String _stringAt(Map<String, dynamic> source, String key) {
  final value = source[key];
  return value == null ? '' : '$value';
}

String _stringAny(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value == null) continue;
    final text = '$value';
    if (text.isNotEmpty) return text;
  }
  return '';
}

ChildVm _childVmFromJson(Map<String, dynamic> raw) => ChildVm(
  id: _stringAt(raw, 'id'),
  name: _childDisplayName(raw),
  birthday: _stringAt(raw, 'birthday'),
  notes: _stringAt(raw, 'notes'),
);

String _childDisplayName(Map<String, dynamic> raw) {
  final id = _stringAt(raw, 'id');
  final name = _stringAt(raw, 'name').trim();
  if (name.isNotEmpty) return name;
  if (id.startsWith('sample-child')) return 'Sample child';
  return _stringAny(raw, const ['name', 'id']);
}

AssetRecordDto _assetRecordFromJson(Map<String, dynamic> row) {
  final tags = _listAt(row, 'tags').map((v) => '$v').toList();
  final imagePath = '${row['imagePath'] ?? row['image_path'] ?? ''}';
  return AssetRecordDto(
    id: '${row['id'] ?? ''}',
    title: '${row['title'] ?? ''}',
    type: '${row['type'] ?? 'artwork'}',
    description: '${row['description'] ?? ''}',
    tags: tags,
    capturedAt: '${row['capturedAt'] ?? row['captured_at'] ?? ''}',
    imagePath: imagePath,
    thumbnailPath:
        '${row['thumbnailPath'] ?? row['thumbnail_path'] ?? row['imagePath'] ?? row['image_path'] ?? ''}',
    previewUrl: '${row['previewUrl'] ?? row['preview_url'] ?? ''}',
    originalFilename:
        '${row['originalFilename'] ?? row['original_filename'] ?? ''}',
    storageStatus: '${row['storageStatus'] ?? row['storage_status'] ?? ''}',
  );
}
