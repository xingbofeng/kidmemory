import '../../shared/models/library_models.dart';
import 'sidecar_api.dart';

class DesktopSidecarGateway {
  const DesktopSidecarGateway(this._api);

  final SidecarApi _api;

  Future<ReadinessSnapshotDto> loadReadiness() async {
    final uiConfig = await _api.get('/config/ui');
    final config = await _api.getStrict('/config/status');
    final schema = await _api.postStrict('/schema/init');
    final postgres = await _api.postStrict('/config/check/postgres');
    final pgvector = await _api.postStrict('/config/check/pgvector');
    final openai = await _api.postStrict('/config/check/openai');
    return ReadinessSnapshotDto(
      uiConfig: uiConfig,
      config: ReadinessConfigDto.fromJson(config),
      schema: ReadinessCheckDto.fromJson(schema),
      postgres: ReadinessCheckDto.fromJson(postgres),
      pgvector: ReadinessCheckDto.fromJson(pgvector),
      openai: ReadinessCheckDto.fromJson(openai),
    );
  }

  Future<DatasetSnapshotDto> loadDataset({
    required String? selectedChildId,
  }) async {
    final childrenResponse = await _api.getStrict('/children');
    final childrenRows = _mapListAt(
      childrenResponse,
      'children',
    ).map(ChildRecordDto.fromJson).toList();
    final children = childrenRows
        .map((row) => ChildVm(id: row.id, name: row.name))
        .toList();

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
    ).map(AssetRecordDto.fromJson).toList();

    return DatasetSnapshotDto(
      children: children,
      activeChildId: activeChildId,
      assetRows: assetRows,
    );
  }

  Future<CreateBookJobResultDto> createBookJobDto({
    required CreateBookJobRequest payload,
  }) async {
    final raw = await _api.postStrict('/books/jobs', payload.toPayload());
    return CreateBookJobResultDto.fromJson(raw);
  }

  Future<BookExportResultDto> exportBookDto({
    required ExportBookRequest payload,
  }) async {
    final raw = payload.format == 'pdf'
        ? await _api.postStrict('/books/jobs/${payload.jobId}/export/pdf', {
            'targetPath': payload.targetPath,
          })
        : await _api.postStrict(
            '/books/jobs/${payload.jobId}/export/long-image',
            {'targetPath': payload.targetPath, 'format': payload.format},
          );
    return BookExportResultDto.fromJson(raw);
  }

  Future<AssetSearchResultDto> searchAssetsDto({
    required AssetSearchRequestPayload payload,
  }) async {
    final raw = await _api.post('/search/query', payload.toPayload());
    return AssetSearchResultDto.fromJson(raw);
  }

  Future<IndexingStatusDto> getIndexingStatusDto({
    required String childId,
  }) async {
    final raw = await _api.get('/search/indexing-status?childId=$childId');
    return IndexingStatusDto.fromJson(raw);
  }

  Future<ImportSampleResultDto> importSampleDatasetDto() async {
    final raw = await _api.post('/sample/import', {'persist': true});
    return ImportSampleResultDto.fromJson(raw);
  }

  Future<ResetSampleResultDto> resetSampleDatasetDto({
    required String childId,
  }) async {
    final raw = await _api.post('/sample/reset', {'childId': childId});
    return ResetSampleResultDto.fromJson(raw);
  }

  Future<EnsureChildResultDto> ensureChildDto({
    required String id,
    required String name,
  }) async {
    final raw = await _api.post('/children', {'id': id, 'name': name});
    return EnsureChildResultDto.fromJson(raw);
  }

  Future<ImportAssetsResultDto> importAssetsDto({
    required ImportAssetsRequest payload,
  }) async {
    final raw = await _api.post('/assets/import', payload.toPayload());
    return ImportAssetsResultDto.fromJson(raw);
  }

  Future<UpdateAssetResultDto> updateAssetDto({
    required String assetId,
    required UpdateAssetRequest payload,
  }) async {
    final raw = await _api.post('/assets/$assetId/update', payload.toPayload());
    return UpdateAssetResultDto.fromJson(raw);
  }

  Future<OperationResultDto> deleteAssetDto({required String assetId}) async {
    final raw = await _api.delete('/assets/$assetId');
    return OperationResultDto.fromJson(raw);
  }

  Future<EnqueueResultDto> enqueueAssetSyncDto({
    required String assetId,
  }) async {
    final raw = await _api.post('/storage/assets/$assetId/sync');
    return EnqueueResultDto.fromJson(raw);
  }

  Future<StorageSyncRunResultDto> runStorageSyncDto({
    required int limit,
  }) async {
    final raw = await _api.post('/storage/sync/run', {'limit': limit});
    return StorageSyncRunResultDto.fromJson(raw);
  }

  Future<EnqueueResultDto> enqueueExportArtifactSyncDto({
    required String artifactId,
    required String childId,
  }) async {
    final raw = await _api.post('/storage/export-artifacts/$artifactId/sync', {
      'childId': childId,
    });
    return EnqueueResultDto.fromJson(raw);
  }

  Future<ArtifactShareResultDto> getExportArtifactShareDto({
    required String artifactId,
  }) async {
    final raw = await _api.get('/storage/export-artifacts/$artifactId/share');
    return ArtifactShareResultDto.fromJson(raw);
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
    final raw = await _api.post('/config/check/openai');
    return ReadinessCheckDto.fromJson(raw);
  }

  Future<ReadinessCheckDto> initSchemaDto() async {
    final raw = await _api.post('/schema/init');
    return ReadinessCheckDto.fromJson(raw);
  }

  Future<ConfigStatusDto> getConfigStatusDto() async {
    final raw = await _api.get('/config/status');
    return ConfigStatusDto.fromJson(raw);
  }

  Future<OperationResultDto> configurePostgresDto({
    required PostgresConfigRequest payload,
  }) async {
    final raw = await _api.post('/config/postgres', payload.toPayload());
    return OperationResultDto.fromJson(raw);
  }

  Future<OperationResultDto> configureOpenAiDto({
    required OpenAiConfigRequest payload,
  }) async {
    final raw = await _api.post('/config/openai', payload.toPayload());
    return OperationResultDto.fromJson(raw);
  }

  Future<ConfigurePathsResultDto> configurePathsDto({
    required PathsConfigRequest payload,
  }) async {
    final raw = await _api.post('/config/paths', payload.toPayload());
    return ConfigurePathsResultDto.fromJson(raw);
  }

  Future<ConfigureSupabaseStorageResultDto> configureSupabaseStorageDto({
    required SupabaseStorageConfigRequest payload,
  }) async {
    final raw = await _api.post(
      '/config/supabase-storage',
      payload.toPayload(),
    );
    return ConfigureSupabaseStorageResultDto.fromJson(raw);
  }

  Future<SupabaseStorageTestResultDto> testSupabaseStorageDto() async {
    final raw = await _api.post('/config/supabase-storage/test');
    return SupabaseStorageTestResultDto.fromJson(raw);
  }
}

class PostgresConfigRequest {
  const PostgresConfigRequest({
    required this.host,
    required this.port,
    required this.database,
    required this.user,
    this.password,
  });

  final String host;
  final int port;
  final String database;
  final String user;
  final String? password;

  Map<String, dynamic> toPayload() {
    return {
      'host': host,
      'port': port,
      'database': database,
      'user': user,
      if (password != null && password!.isNotEmpty) 'password': password,
    };
  }
}

class OpenAiConfigRequest {
  const OpenAiConfigRequest({
    required this.baseUrl,
    required this.model,
    this.apiKey,
  });

  final String baseUrl;
  final String model;
  final String? apiKey;

  Map<String, dynamic> toPayload() {
    return {
      'baseUrl': baseUrl,
      'model': model,
      if (apiKey != null && apiKey!.isNotEmpty) 'apiKey': apiKey,
    };
  }
}

class PathsConfigRequest {
  const PathsConfigRequest({
    required this.dataDir,
    required this.workspaceDir,
    required this.exportDir,
  });

  final String dataDir;
  final String workspaceDir;
  final String exportDir;

  Map<String, dynamic> toPayload() {
    return {
      'dataDir': dataDir,
      'workspaceDir': workspaceDir,
      'exportDir': exportDir,
    };
  }
}

class SupabaseStorageConfigRequest {
  const SupabaseStorageConfigRequest({
    required this.url,
    required this.bucket,
    this.serviceRoleKey,
    required this.publicBaseUrl,
    required this.signedUrlTtlSeconds,
    required this.s3Endpoint,
    required this.s3Region,
    this.s3AccessKeyId,
    this.s3SecretAccessKey,
  });

  final String url;
  final String bucket;
  final String? serviceRoleKey;
  final String publicBaseUrl;
  final int signedUrlTtlSeconds;
  final String s3Endpoint;
  final String s3Region;
  final String? s3AccessKeyId;
  final String? s3SecretAccessKey;

  Map<String, dynamic> toPayload() {
    return {
      'url': url,
      'bucket': bucket,
      if (serviceRoleKey != null && serviceRoleKey!.isNotEmpty)
        'serviceRoleKey': serviceRoleKey,
      'publicBaseUrl': publicBaseUrl,
      'signedUrlTtlSeconds': signedUrlTtlSeconds,
      's3Endpoint': s3Endpoint,
      's3Region': s3Region,
      if (s3AccessKeyId != null && s3AccessKeyId!.isNotEmpty)
        's3AccessKeyId': s3AccessKeyId,
      if (s3SecretAccessKey != null && s3SecretAccessKey!.isNotEmpty)
        's3SecretAccessKey': s3SecretAccessKey,
    };
  }
}

class UpdateAssetRequest {
  const UpdateAssetRequest({
    required this.title,
    required this.description,
    required this.tags,
    required this.capturedAt,
    required this.type,
  });

  final String title;
  final String description;
  final List<String> tags;
  final String? capturedAt;
  final String type;

  Map<String, dynamic> toPayload() {
    return {
      'title': title,
      'description': description,
      'tags': tags,
      'capturedAt': capturedAt,
      'type': type,
    };
  }
}

class CreateBookJobRequest {
  const CreateBookJobRequest({
    required this.assetIds,
    required this.childId,
    this.coverPolicy = 'auto',
  });

  final List<String> assetIds;
  final String? childId;
  final String coverPolicy;

  Map<String, dynamic> toPayload() {
    return {
      'assetIds': assetIds,
      'childId': childId,
      'coverPolicy': coverPolicy,
    };
  }
}

class ExportBookRequest {
  const ExportBookRequest({
    required this.jobId,
    required this.targetPath,
    required this.format,
  });

  final String jobId;
  final String targetPath;
  final String format;
}

class AssetSearchRequestPayload {
  const AssetSearchRequestPayload({
    required this.childId,
    required this.query,
    required this.types,
    this.page = 1,
    this.pageSize = 30,
  });

  final String childId;
  final String query;
  final List<String> types;
  final int page;
  final int pageSize;

  Map<String, dynamic> toPayload() {
    return {
      'childId': childId,
      'query': query,
      'page': page,
      'pageSize': pageSize,
      'filters': <String, dynamic>{if (types.isNotEmpty) 'types': types},
    };
  }
}

class ImportAssetsRequest {
  const ImportAssetsRequest({
    required this.childId,
    required this.paths,
    this.recursive = true,
  });

  final String childId;
  final List<String> paths;
  final bool recursive;

  Map<String, dynamic> toPayload() {
    return {'childId': childId, 'paths': paths, 'recursive': recursive};
  }
}

class ReadinessSnapshotDto {
  const ReadinessSnapshotDto({
    required this.uiConfig,
    required this.config,
    required this.schema,
    required this.postgres,
    required this.pgvector,
    required this.openai,
  });

  final Map<String, dynamic> uiConfig;
  final ReadinessConfigDto config;
  final ReadinessCheckDto schema;
  final ReadinessCheckDto postgres;
  final ReadinessCheckDto pgvector;
  final ReadinessCheckDto openai;
}

class DatasetSnapshotDto {
  const DatasetSnapshotDto({
    required this.children,
    required this.activeChildId,
    required this.assetRows,
  });

  final List<ChildVm> children;
  final String? activeChildId;
  final List<AssetRecordDto> assetRows;
}

class ConfigStatusDto {
  const ConfigStatusDto({
    required this.postgresConfig,
    required this.openAiConfig,
    required this.supabaseStorageConfig,
    required this.pathConfig,
  });

  factory ConfigStatusDto.fromJson(Map<String, dynamic> raw) {
    return ConfigStatusDto(
      postgresConfig: PostgresConfigDto.fromJson(_mapAt(raw, 'postgres')),
      openAiConfig: OpenAiConfigDto.fromJson(_mapAt(raw, 'openai')),
      supabaseStorageConfig: SupabaseStorageConfigDto.fromJson(
        _mapAt(raw, 'supabaseStorage'),
      ),
      pathConfig: PathConfigDto.fromJson(_mapAt(raw, 'paths')),
    );
  }

  final PostgresConfigDto postgresConfig;
  final OpenAiConfigDto openAiConfig;
  final SupabaseStorageConfigDto supabaseStorageConfig;
  final PathConfigDto pathConfig;
}

class ReadinessConfigDto {
  const ReadinessConfigDto({
    required this.raw,
    required this.pathConfig,
    required this.openAiConfig,
    required this.supabaseStorageConfig,
  });

  factory ReadinessConfigDto.fromJson(Map<String, dynamic> raw) {
    return ReadinessConfigDto(
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

class PathConfigDto {
  const PathConfigDto({
    required this.dataDir,
    required this.workspaceDir,
    required this.exportDir,
  });

  factory PathConfigDto.fromJson(Map<String, dynamic> raw) {
    return PathConfigDto(
      dataDir: _stringAt(raw, 'dataDir'),
      workspaceDir: _stringAt(raw, 'workspaceDir'),
      exportDir: _stringAt(raw, 'exportDir'),
    );
  }

  final String dataDir;
  final String workspaceDir;
  final String exportDir;
}

class OpenAiConfigDto {
  const OpenAiConfigDto({required this.baseUrl, required this.model});

  factory OpenAiConfigDto.fromJson(Map<String, dynamic> raw) {
    return OpenAiConfigDto(
      baseUrl: _stringAt(raw, 'baseUrl'),
      model: _stringAt(raw, 'model'),
    );
  }

  final String baseUrl;
  final String model;
}

class PostgresConfigDto {
  const PostgresConfigDto({
    required this.host,
    required this.port,
    required this.database,
    required this.user,
  });

  factory PostgresConfigDto.fromJson(Map<String, dynamic> raw) {
    return PostgresConfigDto(
      host: _stringAt(raw, 'host'),
      port: _intOrDefault(raw['port'], 5432),
      database: _stringAt(raw, 'database'),
      user: _stringAt(raw, 'user'),
    );
  }

  final String host;
  final int port;
  final String database;
  final String user;
}

class SupabaseStorageConfigDto {
  const SupabaseStorageConfigDto({
    required this.raw,
    required this.configured,
    required this.url,
    required this.bucket,
    required this.serviceRoleKeyConfigured,
    required this.publicBaseUrl,
    required this.signedUrlTtlSeconds,
    required this.s3CredentialsDetected,
    required this.authMode,
    required this.diagnosticMessage,
    required this.s3,
  });

  factory SupabaseStorageConfigDto.fromJson(Map<String, dynamic> raw) {
    final s3Map = _asMap(raw['s3']);
    return SupabaseStorageConfigDto(
      raw: raw,
      configured: _boolAt(raw, 'configured'),
      url: _stringAt(raw, 'url'),
      bucket: _stringAt(raw, 'bucket'),
      serviceRoleKeyConfigured: _boolAt(raw, 'serviceRoleKeyConfigured'),
      publicBaseUrl: _stringAt(raw, 'publicBaseUrl'),
      signedUrlTtlSeconds: _intOrDefault(raw['signedUrlTtlSeconds'], 3600),
      s3CredentialsDetected: _boolAt(raw, 's3CredentialsDetected'),
      authMode: _stringAt(raw, 'authMode'),
      diagnosticMessage: _stringAt(raw, 'diagnosticMessage'),
      s3: SupabaseS3ConfigDto.fromJson(s3Map),
    );
  }

  final Map<String, dynamic> raw;
  final bool configured;
  final String url;
  final String bucket;
  final bool serviceRoleKeyConfigured;
  final String publicBaseUrl;
  final int signedUrlTtlSeconds;
  final bool s3CredentialsDetected;
  final String authMode;
  final String diagnosticMessage;
  final SupabaseS3ConfigDto s3;
}

class SupabaseS3ConfigDto {
  const SupabaseS3ConfigDto({
    required this.endpoint,
    required this.region,
    required this.accessKeyConfigured,
    required this.secretKeyConfigured,
  });

  factory SupabaseS3ConfigDto.fromJson(Map<String, dynamic> raw) {
    return SupabaseS3ConfigDto(
      endpoint: _stringAt(raw, 'endpoint'),
      region: _stringAt(raw, 'region'),
      accessKeyConfigured: _boolAt(raw, 'accessKeyIdConfigured'),
      secretKeyConfigured: _boolAt(raw, 'secretAccessKeyConfigured'),
    );
  }

  final String endpoint;
  final String region;
  final bool accessKeyConfigured;
  final bool secretKeyConfigured;
}

class ReadinessCheckDto {
  const ReadinessCheckDto({required this.raw});

  factory ReadinessCheckDto.fromJson(Map<String, dynamic> raw) {
    return ReadinessCheckDto(raw: raw);
  }

  final Map<String, dynamic> raw;

  bool get isEmpty => raw.isEmpty;
  bool? get okOrNull => isEmpty ? null : isOk;
  bool get isOk => _boolAt(raw, 'ok') || _boolAt(raw, 'ready');
  bool get needsConfiguration => raw['ok'] == false || raw['ready'] == false;
  bool get blocksGeneration => _boolAt(raw, 'blocksGeneration');
  String get service => _stringAt(raw, 'service').toLowerCase();
  String get message => _stringAt(raw, 'message');
}

class OperationResultDto {
  const OperationResultDto({
    required this.raw,
    required this.ok,
    required this.message,
    required this.code,
  });

  factory OperationResultDto.fromJson(Map<String, dynamic> raw) {
    return OperationResultDto(
      raw: raw,
      ok: _boolAt(raw, 'ok') || _boolAt(raw, 'success'),
      message: _stringAt(raw, 'message'),
      code: _stringAt(raw, 'code'),
    );
  }

  final Map<String, dynamic> raw;
  final bool ok;
  final String message;
  final String code;
}

class ConfigurePathsResultDto extends OperationResultDto {
  const ConfigurePathsResultDto({
    required super.raw,
    required super.ok,
    required super.message,
    required super.code,
    required this.pathConfig,
  });

  factory ConfigurePathsResultDto.fromJson(Map<String, dynamic> raw) {
    final base = OperationResultDto.fromJson(raw);
    final pathMap = _asMap(raw['paths']);
    return ConfigurePathsResultDto(
      raw: base.raw,
      ok: base.ok,
      message: base.message,
      code: base.code,
      pathConfig: PathConfigDto.fromJson(pathMap),
    );
  }

  final PathConfigDto pathConfig;
}

class ConfigureSupabaseStorageResultDto extends OperationResultDto {
  const ConfigureSupabaseStorageResultDto({
    required super.raw,
    required super.ok,
    required super.message,
    required super.code,
    required this.config,
  });

  factory ConfigureSupabaseStorageResultDto.fromJson(Map<String, dynamic> raw) {
    final base = OperationResultDto.fromJson(raw);
    final configMap = _asMap(raw['config'], fallback: raw);
    return ConfigureSupabaseStorageResultDto(
      raw: base.raw,
      ok: base.ok,
      message: base.message,
      code: base.code,
      config: SupabaseStorageConfigDto.fromJson(configMap),
    );
  }

  final SupabaseStorageConfigDto config;
}

class SupabaseStorageTestResultDto extends OperationResultDto {
  const SupabaseStorageTestResultDto({
    required super.raw,
    required super.ok,
    required super.message,
    required super.code,
    required this.cleanupOk,
  });

  factory SupabaseStorageTestResultDto.fromJson(Map<String, dynamic> raw) {
    final base = OperationResultDto.fromJson(raw);
    final cleanupMap = _asMap(raw['cleanup']);
    return SupabaseStorageTestResultDto(
      raw: base.raw,
      ok: base.ok,
      message: base.message,
      code: base.code,
      cleanupOk: cleanupMap.isEmpty ? true : _boolAt(cleanupMap, 'ok'),
    );
  }

  final bool cleanupOk;
}

class EnqueueResultDto {
  const EnqueueResultDto({
    required this.raw,
    required this.enqueued,
    required this.reason,
  });

  factory EnqueueResultDto.fromJson(Map<String, dynamic> raw) {
    return EnqueueResultDto(
      raw: raw,
      enqueued: raw['enqueued'] != false && raw['reason'] == null,
      reason: _stringAt(raw, 'reason'),
    );
  }

  final Map<String, dynamic> raw;
  final bool enqueued;
  final String reason;
}

class StorageSyncRunResultDto {
  const StorageSyncRunResultDto({
    required this.raw,
    required this.failed,
    required this.retried,
  });

  factory StorageSyncRunResultDto.fromJson(Map<String, dynamic> raw) {
    return StorageSyncRunResultDto(
      raw: raw,
      failed: _intOrDefault(raw['failed'], 0),
      retried: _intOrDefault(raw['retried'], 0),
    );
  }

  final Map<String, dynamic> raw;
  final int failed;
  final int retried;
}

class ArtifactShareResultDto extends OperationResultDto {
  const ArtifactShareResultDto({
    required super.raw,
    required super.ok,
    required super.message,
    required super.code,
    required this.url,
    required this.text,
  });

  factory ArtifactShareResultDto.fromJson(Map<String, dynamic> raw) {
    final base = OperationResultDto.fromJson(raw);
    return ArtifactShareResultDto(
      raw: base.raw,
      ok: base.ok,
      message: base.message,
      code: base.code,
      url: _stringAt(raw, 'url'),
      text: _stringAt(raw, 'text'),
    );
  }

  final String url;
  final String text;
}

class BookExportResultDto {
  const BookExportResultDto({
    required this.raw,
    required this.exported,
    required this.artifactId,
  });

  factory BookExportResultDto.fromJson(Map<String, dynamic> raw) {
    final exportedMap = _asMap(raw['exported']);
    final artifactMap = _asMap(raw['artifact']);
    return BookExportResultDto(
      raw: raw,
      exported: ExportedPayloadDto.fromJson(exportedMap),
      artifactId: _stringAt(artifactMap, 'id'),
    );
  }

  final Map<String, dynamic> raw;
  final ExportedPayloadDto exported;
  final String artifactId;
}

class ExportedPayloadDto {
  const ExportedPayloadDto({
    required this.ok,
    required this.path,
    required this.message,
  });

  factory ExportedPayloadDto.fromJson(Map<String, dynamic> raw) {
    return ExportedPayloadDto(
      ok: _boolAt(raw, 'ok'),
      path: _stringAt(raw, 'path'),
      message: _stringAt(raw, 'message'),
    );
  }

  final bool ok;
  final String path;
  final String message;
}

class IndexingStatusDto {
  const IndexingStatusDto({
    required this.pending,
    required this.running,
    required this.retryWait,
    required this.failed,
    required this.searchable,
  });

  factory IndexingStatusDto.fromJson(Map<String, dynamic> raw) {
    return IndexingStatusDto(
      pending: _intOrDefault(raw['pending'], 0),
      running: _intOrDefault(raw['running'], 0),
      retryWait: _intOrDefault(raw['retryWait'], 0),
      failed: _intOrDefault(raw['failed'], 0),
      searchable: _intOrDefault(raw['searchable'], 0),
    );
  }

  final int pending;
  final int running;
  final int retryWait;
  final int failed;
  final int searchable;
}

class ImportSampleResultDto extends OperationResultDto {
  const ImportSampleResultDto({
    required super.raw,
    required super.ok,
    required super.message,
    required super.code,
    required this.childId,
    required this.assetCount,
  });

  factory ImportSampleResultDto.fromJson(Map<String, dynamic> raw) {
    final base = OperationResultDto.fromJson(raw);
    return ImportSampleResultDto(
      raw: base.raw,
      ok: base.ok,
      message: base.message,
      code: base.code,
      childId: _stringAt(raw, 'childId'),
      assetCount: _intOrDefault(raw['assetCount'], 0),
    );
  }

  final String childId;
  final int assetCount;
}

class EnsureChildResultDto {
  const EnsureChildResultDto({
    required this.raw,
    required this.childId,
    required this.childName,
  });

  factory EnsureChildResultDto.fromJson(Map<String, dynamic> raw) {
    final map = _asMap(raw['child']);
    final childDto = ChildRecordDto.fromJson(map);
    return EnsureChildResultDto(
      raw: raw,
      childId: childDto.id,
      childName: childDto.name,
    );
  }

  final Map<String, dynamic> raw;
  final String childId;
  final String childName;
  bool get hasChild => childId.isNotEmpty;
}

class ChildRecordDto {
  const ChildRecordDto({required this.id, required this.name});

  factory ChildRecordDto.fromJson(Map<String, dynamic> raw) {
    final id = _stringAt(raw, 'id');
    final name = _stringAny(raw, const ['name', 'id']);
    return ChildRecordDto(id: id, name: name);
  }

  final String id;
  final String name;
}

class AssetSearchResultDto extends OperationResultDto {
  const AssetSearchResultDto({
    required super.raw,
    required super.ok,
    required super.message,
    required super.code,
    required this.total,
    required this.items,
  });

  factory AssetSearchResultDto.fromJson(Map<String, dynamic> raw) {
    final base = OperationResultDto.fromJson(raw);
    final items = _listAt(raw, 'items')
        .whereType<Map<String, dynamic>>()
        .map(AssetSearchItemDto.fromJson)
        .toList();
    return AssetSearchResultDto(
      raw: base.raw,
      ok: base.ok,
      message: base.message,
      code: base.code,
      total: _intOrDefault(raw['total'], items.length),
      items: items,
    );
  }

  final int total;
  final List<AssetSearchItemDto> items;
}

class AssetSearchItemDto {
  const AssetSearchItemDto({required this.asset, required this.reasons});

  factory AssetSearchItemDto.fromJson(Map<String, dynamic> raw) {
    final assetMap = _asMap(raw['asset']);
    final reasons = _listAt(raw, 'reasons')
        .map((reason) => '$reason')
        .where((reason) => reason.trim().isNotEmpty)
        .toList();
    return AssetSearchItemDto(
      asset: AssetRecordDto.fromJson(assetMap),
      reasons: reasons,
    );
  }

  final AssetRecordDto asset;
  final List<String> reasons;
}

class AssetRecordDto {
  const AssetRecordDto({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.tags,
    required this.capturedAt,
    required this.imagePath,
    required this.thumbnailPath,
    required this.previewUrl,
    required this.originalFilename,
    required this.storageStatus,
  });

  factory AssetRecordDto.fromJson(Map<String, dynamic> row) {
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

  final String id;
  final String title;
  final String type;
  final String description;
  final List<String> tags;
  final String capturedAt;
  final String imagePath;
  final String thumbnailPath;
  final String previewUrl;
  final String originalFilename;
  final String storageStatus;
}

class ImportAssetsResultDto {
  const ImportAssetsResultDto({
    required this.raw,
    required this.imported,
    required this.duplicates,
    required this.failed,
    required this.skipped,
    required this.message,
    required this.title,
    required this.failedReasons,
  });

  factory ImportAssetsResultDto.fromJson(Map<String, dynamic> raw) {
    final failedReasons = _nestedListAt(raw, 'failed')
        .map((item) => item is Map ? '${item['reason'] ?? ''}' : '')
        .where((reason) => reason.trim().isNotEmpty)
        .toSet()
        .toList();

    return ImportAssetsResultDto(
      raw: raw,
      imported: _nestedCountAt(raw, 'imported'),
      duplicates: _nestedCountAt(raw, 'duplicates'),
      failed: _nestedCountAt(raw, 'failed'),
      skipped: _nestedCountAt(raw, 'skipped'),
      message: _nestedStringAt(raw, 'message'),
      title: _nestedStringAt(raw, 'title'),
      failedReasons: failedReasons,
    );
  }

  final Map<String, dynamic> raw;
  final int imported;
  final int duplicates;
  final int failed;
  final int skipped;
  final String message;
  final String title;
  final List<String> failedReasons;

  bool get hasCounters =>
      imported > 0 || duplicates > 0 || failed > 0 || skipped > 0;
}

class CreateBookJobResultDto extends OperationResultDto {
  const CreateBookJobResultDto({
    required super.raw,
    required super.ok,
    required super.message,
    required super.code,
    required this.jobId,
    required this.status,
  });

  factory CreateBookJobResultDto.fromJson(Map<String, dynamic> raw) {
    final base = OperationResultDto.fromJson(raw);
    return CreateBookJobResultDto(
      raw: base.raw,
      ok: base.ok,
      message: base.message,
      code: base.code,
      jobId: '${raw['id'] ?? ''}',
      status: '${raw['status'] ?? ''}',
    );
  }

  final String jobId;
  final String status;
  bool get generated => status == 'generated' || ok;
}

class ResetSampleResultDto extends OperationResultDto {
  const ResetSampleResultDto({
    required super.raw,
    required super.ok,
    required super.message,
    required super.code,
    required this.deletedAssets,
  });

  factory ResetSampleResultDto.fromJson(Map<String, dynamic> raw) {
    final base = OperationResultDto.fromJson(raw);
    return ResetSampleResultDto(
      raw: base.raw,
      ok: base.ok,
      message: base.message,
      code: base.code,
      deletedAssets: _intOrDefault(raw['deletedAssets'], 0),
    );
  }

  final int deletedAssets;
}

class UpdateAssetResultDto extends OperationResultDto {
  const UpdateAssetResultDto({
    required super.raw,
    required super.ok,
    required super.message,
    required super.code,
    required this.hasAsset,
  });

  factory UpdateAssetResultDto.fromJson(Map<String, dynamic> raw) {
    final base = OperationResultDto.fromJson(raw);
    return UpdateAssetResultDto(
      raw: base.raw,
      ok: base.ok,
      message: base.message,
      code: base.code,
      hasAsset: raw['asset'] is Map || raw['asset'] != null,
    );
  }

  final bool hasAsset;
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

Object? _nestedValueAt(Map<String, dynamic> raw, String key) {
  if (raw.containsKey(key)) return raw[key];
  for (final nestedKey in const ['summary', 'report']) {
    final nested = raw[nestedKey];
    if (nested is Map && nested.containsKey(key)) return nested[key];
  }
  return null;
}

int _nestedCountAt(Map<String, dynamic> raw, String key) {
  final value = _nestedValueAt(raw, key);
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is List) return value.length;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String _nestedStringAt(Map<String, dynamic> raw, String key) {
  final value = _nestedValueAt(raw, key);
  if (value is! String) return '';
  return value.trim();
}

List<dynamic> _nestedListAt(Map<String, dynamic> raw, String key) {
  final value = _nestedValueAt(raw, key);
  return value is List ? value : const [];
}

int _intOrDefault(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

bool _boolAt(Map<String, dynamic> source, String key, {bool fallback = false}) {
  final value = source[key];
  return value is bool ? value : fallback;
}
