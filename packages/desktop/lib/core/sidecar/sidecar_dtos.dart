typedef JsonMap = Map<String, dynamic>;

JsonMap _asMap(Object? value) {
  if (value is JsonMap) return value;
  if (value is Map) {
    return value.map((key, entry) => MapEntry(key.toString(), entry));
  }
  return const {};
}

List<dynamic> _asList(Object? value) => value is List ? value : const [];
String? _string(Object? value) => value == null ? null : '$value';
int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}');
}

double? _double(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? ''}');
}

bool? _bool(Object? value) => value is bool ? value : null;
List<String>? _strings(Object? value) => value is List ? value.map((item) => '$item').toList() : null;

class AgentConfigResponseDto {
  AgentConfigResponseDto({
    this.id = '',
    this.name = '',
    this.description,
    this.provider = 'openai',
    this.model = '',
    this.apiKey,
    this.baseUrl,
    this.temperature = 0.7,
    this.maxTokens = 4000,
    this.isDefault,
  });

  factory AgentConfigResponseDto.fromJson(JsonMap json) => AgentConfigResponseDto(
        id: _string(json['id']) ?? '',
        name: _string(json['name']) ?? '',
        description: _string(json['description']),
        provider: _string(json['provider']) ?? 'openai',
        model: _string(json['model']) ?? '',
        apiKey: _string(json['apiKey']),
        baseUrl: _string(json['baseUrl']),
        temperature: _double(json['temperature']) ?? 0.7,
        maxTokens: _int(json['maxTokens']) ?? 4000,
        isDefault: _bool(json['isDefault']),
      );

  final String id;
  final String name;
  final String? description;
  final String provider;
  final String model;
  final String? apiKey;
  final String? baseUrl;
  final double temperature;
  final int maxTokens;
  final bool? isDefault;

  JsonMap toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
        'provider': provider,
        'model': model,
        if (apiKey != null) 'apiKey': apiKey,
        if (baseUrl != null) 'baseUrl': baseUrl,
        'temperature': temperature,
        'maxTokens': maxTokens,
        if (isDefault != null) 'isDefault': isDefault,
      };
}

class CreateAgentConfigRequestDto {
  CreateAgentConfigRequestDto({
    required this.name,
    this.description,
    required this.provider,
    required this.model,
    this.apiKey,
    this.baseUrl,
    this.temperature,
    this.maxTokens,
    this.isDefault,
  });

  final String name;
  final String? description;
  final String provider;
  final String model;
  final String? apiKey;
  final String? baseUrl;
  final double? temperature;
  final int? maxTokens;
  final bool? isDefault;

  JsonMap toJson() => {
        'name': name,
        if (description != null) 'description': description,
        'provider': provider,
        'model': model,
        if (apiKey != null) 'apiKey': apiKey,
        if (baseUrl != null) 'baseUrl': baseUrl,
        if (temperature != null) 'temperature': temperature,
        if (maxTokens != null) 'maxTokens': maxTokens,
        if (isDefault != null) 'isDefault': isDefault,
      };
}

class UpdateAgentConfigRequestDto extends CreateAgentConfigRequestDto {
  UpdateAgentConfigRequestDto({
    required super.name,
    super.description,
    required super.provider,
    required super.model,
    super.apiKey,
    super.baseUrl,
    super.temperature,
    super.maxTokens,
  });
}

class TestAgentConfigResultResponseDto {
  TestAgentConfigResultResponseDto({
    this.success = false,
    this.errorMessage,
    this.message,
    this.modelUsed,
  });
  factory TestAgentConfigResultResponseDto.fromJson(JsonMap json) => TestAgentConfigResultResponseDto(
        success: _bool(json['success']) ?? _bool(json['ok']) ?? false,
        errorMessage: _string(json['errorMessage'] ?? json['error']),
        message: _string(json['message']),
        modelUsed: _string(json['modelUsed']),
      );
  final bool success;
  final String? errorMessage;
  final String? message;
  final String? modelUsed;
  JsonMap toJson() => {
        'success': success,
        if (errorMessage != null) 'errorMessage': errorMessage,
        if (message != null) 'message': message,
        if (modelUsed != null) 'modelUsed': modelUsed,
      };
}

class PostgresConfigRequestDto {
  PostgresConfigRequestDto({required this.host, required this.port, required this.database, required this.user, this.password});
  final String host;
  final int port;
  final String database;
  final String user;
  final String? password;
  JsonMap toJson() => {'host': host, 'port': port, 'database': database, 'user': user, if (password != null) 'password': password};
}

class PathsConfigRequestDto {
  PathsConfigRequestDto({required this.dataDir, required this.workspaceDir, required this.exportDir});
  final String dataDir;
  final String workspaceDir;
  final String exportDir;
  JsonMap toJson() => {'dataDir': dataDir, 'workspaceDir': workspaceDir, 'exportDir': exportDir};
}

class SupabaseStorageConfigRequestDto {
  SupabaseStorageConfigRequestDto({
    required this.url,
    required this.bucket,
    this.serviceRoleKey,
    this.publicBaseUrl,
    this.signedUrlTtlSeconds,
    this.s3Endpoint,
    this.s3Region,
    this.s3AccessKeyId,
    this.s3SecretAccessKey,
  });
  final String url;
  final String bucket;
  final String? serviceRoleKey;
  final String? publicBaseUrl;
  final int? signedUrlTtlSeconds;
  final String? s3Endpoint;
  final String? s3Region;
  final String? s3AccessKeyId;
  final String? s3SecretAccessKey;
  JsonMap toJson() => {
        'url': url,
        'bucket': bucket,
        if (serviceRoleKey != null) 'serviceRoleKey': serviceRoleKey,
        if (publicBaseUrl != null) 'publicBaseUrl': publicBaseUrl,
        if (signedUrlTtlSeconds != null) 'signedUrlTtlSeconds': signedUrlTtlSeconds,
        if (s3Endpoint != null) 's3Endpoint': s3Endpoint,
        if (s3Region != null) 's3Region': s3Region,
        if (s3AccessKeyId != null) 's3AccessKeyId': s3AccessKeyId,
        if (s3SecretAccessKey != null) 's3SecretAccessKey': s3SecretAccessKey,
      };
}

class UpdateAssetRequestDto {
  UpdateAssetRequestDto({this.title, this.description, this.tags, this.capturedAt, this.type});
  final String? title;
  final String? description;
  final List<String>? tags;
  final String? capturedAt;
  final String? type;
  JsonMap toJson() => {if (title != null) 'title': title, if (description != null) 'description': description, if (tags != null) 'tags': tags, if (capturedAt != null) 'capturedAt': capturedAt, if (type != null) 'type': type};
}

class AssetSearchRequestDto {
  AssetSearchRequestDto({required this.childId, required this.query, this.limit, this.page, this.pageSize, this.filters});
  final String childId;
  final String query;
  final int? limit;
  final int? page;
  final int? pageSize;
  final JsonMap? filters;
  JsonMap toJson() => {'childId': childId, 'query': query, if (limit != null) 'limit': limit, if (page != null) 'page': page, if (pageSize != null) 'pageSize': pageSize, if (filters != null) 'filters': filters};
}

class ImportAssetsRequestDto {
  ImportAssetsRequestDto({required this.childId, required this.paths});
  final String childId;
  final List<String> paths;
  JsonMap toJson() => {'childId': childId, 'paths': paths};
}

class ConfigStatusResponseDto {
  ConfigStatusResponseDto({this.postgres, this.openai, this.supabaseStorage, this.paths});
  factory ConfigStatusResponseDto.fromJson(JsonMap json) => ConfigStatusResponseDto(
        postgres: PostgresConfigResponseDto.fromJson(_asMap(json['postgres'])),
        openai: OpenAiConfigResponseDto.fromJson(_asMap(json['openai'])),
        supabaseStorage: SupabaseStorageConfigResponseDto.fromJson(_asMap(json['supabaseStorage'])),
        paths: PathConfigResponseDto.fromJson(_asMap(json['paths'])),
      );
  final PostgresConfigResponseDto? postgres;
  final OpenAiConfigResponseDto? openai;
  final SupabaseStorageConfigResponseDto? supabaseStorage;
  final PathConfigResponseDto? paths;
  JsonMap toJson() => {'postgres': postgres?.toJson(), 'openai': openai?.toJson(), 'supabaseStorage': supabaseStorage?.toJson(), 'paths': paths?.toJson()};
}

class PathConfigResponseDto {
  PathConfigResponseDto({this.dataDir = '', this.workspaceDir = '', this.exportDir = ''});
  factory PathConfigResponseDto.fromJson(JsonMap json) => PathConfigResponseDto(dataDir: _string(json['dataDir']) ?? '', workspaceDir: _string(json['workspaceDir']) ?? '', exportDir: _string(json['exportDir']) ?? '');
  final String? dataDir;
  final String? workspaceDir;
  final String? exportDir;
  JsonMap toJson() => {'dataDir': dataDir, 'workspaceDir': workspaceDir, 'exportDir': exportDir};
}

class OpenAiConfigResponseDto {
  OpenAiConfigResponseDto({this.baseUrl = '', this.model = '', this.apiKeyConfigured = false});
  factory OpenAiConfigResponseDto.fromJson(JsonMap json) => OpenAiConfigResponseDto(baseUrl: _string(json['baseUrl']) ?? '', model: _string(json['model']) ?? '', apiKeyConfigured: _bool(json['apiKeyConfigured']) ?? false);
  final String? baseUrl;
  final String? model;
  final bool? apiKeyConfigured;
  JsonMap toJson() => {'baseUrl': baseUrl, 'model': model, 'apiKeyConfigured': apiKeyConfigured};
}

class PostgresConfigResponseDto {
  PostgresConfigResponseDto({this.host = '', this.port = 5432, this.database = '', this.user = ''});
  factory PostgresConfigResponseDto.fromJson(JsonMap json) => PostgresConfigResponseDto(host: _string(json['host']) ?? '', port: _int(json['port']) ?? 5432, database: _string(json['database']) ?? '', user: _string(json['user']) ?? '');
  final String? host;
  final int? port;
  final String? database;
  final String? user;
  JsonMap toJson() => {'host': host, 'port': port, 'database': database, 'user': user};
}

class SupabaseS3ConfigResponseDto {
  SupabaseS3ConfigResponseDto({this.endpoint = '', this.region = '', this.accessKeyIdConfigured = false, this.secretAccessKeyConfigured = false});
  factory SupabaseS3ConfigResponseDto.fromJson(JsonMap json) => SupabaseS3ConfigResponseDto(endpoint: _string(json['endpoint']) ?? '', region: _string(json['region']) ?? '', accessKeyIdConfigured: _bool(json['accessKeyIdConfigured']) ?? false, secretAccessKeyConfigured: _bool(json['secretAccessKeyConfigured']) ?? false);
  final String? endpoint;
  final String? region;
  final bool? accessKeyIdConfigured;
  final bool? secretAccessKeyConfigured;
  JsonMap toJson() => {'endpoint': endpoint, 'region': region, 'accessKeyIdConfigured': accessKeyIdConfigured, 'secretAccessKeyConfigured': secretAccessKeyConfigured};
}

class SupabaseStorageConfigResponseDto {
  SupabaseStorageConfigResponseDto({this.configured = false, this.url = '', this.bucket = '', this.serviceRoleKeyConfigured = false, this.publicBaseUrl = '', this.signedUrlTtlSeconds = 3600, this.s3CredentialsDetected = false, this.authMode = '', this.diagnosticMessage = '', this.s3});
  factory SupabaseStorageConfigResponseDto.fromJson(JsonMap json) => SupabaseStorageConfigResponseDto(configured: _bool(json['configured']) ?? false, url: _string(json['url']) ?? '', bucket: _string(json['bucket']) ?? '', serviceRoleKeyConfigured: _bool(json['serviceRoleKeyConfigured']) ?? false, publicBaseUrl: _string(json['publicBaseUrl']) ?? '', signedUrlTtlSeconds: _int(json['signedUrlTtlSeconds']) ?? 3600, s3CredentialsDetected: _bool(json['s3CredentialsDetected']) ?? false, authMode: _string(json['authMode']) ?? '', diagnosticMessage: _string(json['diagnosticMessage']) ?? '', s3: SupabaseS3ConfigResponseDto.fromJson(_asMap(json['s3'])));
  final bool? configured;
  final String? url;
  final String? bucket;
  final bool? serviceRoleKeyConfigured;
  final String? publicBaseUrl;
  final int? signedUrlTtlSeconds;
  final bool? s3CredentialsDetected;
  final String? authMode;
  final String? diagnosticMessage;
  final SupabaseS3ConfigResponseDto? s3;
  JsonMap toJson() => {'configured': configured, 'url': url, 'bucket': bucket, 'serviceRoleKeyConfigured': serviceRoleKeyConfigured, 'publicBaseUrl': publicBaseUrl, 'signedUrlTtlSeconds': signedUrlTtlSeconds, 's3CredentialsDetected': s3CredentialsDetected, 'authMode': authMode, 'diagnosticMessage': diagnosticMessage, 's3': s3?.toJson()};
}

class ReadinessCheckResponseDto {
  ReadinessCheckResponseDto({this.ok, this.ready, this.service, this.blocksGeneration, this.message});
  factory ReadinessCheckResponseDto.fromJson(JsonMap json) => ReadinessCheckResponseDto(ok: _bool(json['ok']), ready: _bool(json['ready']), service: _string(json['service']), blocksGeneration: _bool(json['blocksGeneration']), message: _string(json['message']));
  final bool? ok;
  final bool? ready;
  final String? service;
  final bool? blocksGeneration;
  final String? message;
  JsonMap toJson() => {if (ok != null) 'ok': ok, if (ready != null) 'ready': ready, if (service != null) 'service': service, if (blocksGeneration != null) 'blocksGeneration': blocksGeneration, if (message != null) 'message': message};
}

class OperationResultResponseDto {
  OperationResultResponseDto({this.ok, this.success, this.message, this.code});
  factory OperationResultResponseDto.fromJson(JsonMap json) => OperationResultResponseDto(ok: _bool(json['ok']), success: _bool(json['success']), message: _string(json['message']), code: _string(json['code']));
  final bool? ok;
  final bool? success;
  final String? message;
  final String? code;
  JsonMap toJson() => {if (ok != null) 'ok': ok, if (success != null) 'success': success, if (message != null) 'message': message, if (code != null) 'code': code};
}

class ConfigurePathsResponseDto extends OperationResultResponseDto {
  ConfigurePathsResponseDto({super.ok, super.success, super.message, super.code, this.paths});
  factory ConfigurePathsResponseDto.fromJson(JsonMap json) => ConfigurePathsResponseDto(ok: _bool(json['ok']), success: _bool(json['success']), message: _string(json['message']), code: _string(json['code']), paths: PathConfigResponseDto.fromJson(_asMap(json['paths'])));
  final PathConfigResponseDto? paths;
}

class ConfigureSupabaseStorageResponseDto extends OperationResultResponseDto {
  ConfigureSupabaseStorageResponseDto({super.ok, super.success, super.message, super.code, this.config});
  factory ConfigureSupabaseStorageResponseDto.fromJson(JsonMap json) => ConfigureSupabaseStorageResponseDto(ok: _bool(json['ok']), success: _bool(json['success']), message: _string(json['message']), code: _string(json['code']), config: SupabaseStorageConfigResponseDto.fromJson(_asMap(json['config'])));
  final SupabaseStorageConfigResponseDto? config;
}

class SupabaseStorageTestCleanupDto { SupabaseStorageTestCleanupDto({this.ok}); factory SupabaseStorageTestCleanupDto.fromJson(JsonMap json) => SupabaseStorageTestCleanupDto(ok: _bool(json['ok'])); final bool? ok; }
class SupabaseStorageTestResponseDto extends OperationResultResponseDto {
  SupabaseStorageTestResponseDto({super.ok, super.success, super.message, super.code, this.cleanup});
  factory SupabaseStorageTestResponseDto.fromJson(JsonMap json) => SupabaseStorageTestResponseDto(ok: _bool(json['ok']), success: _bool(json['success']), message: _string(json['message']), code: _string(json['code']), cleanup: SupabaseStorageTestCleanupDto.fromJson(_asMap(json['cleanup'])));
  final SupabaseStorageTestCleanupDto? cleanup;
}

class EnqueueResponseDto { EnqueueResponseDto({this.enqueued, this.reason}); factory EnqueueResponseDto.fromJson(JsonMap json) => EnqueueResponseDto(enqueued: _bool(json['enqueued']), reason: _string(json['reason'])); final bool? enqueued; final String? reason; JsonMap toJson() => {if (enqueued != null) 'enqueued': enqueued, if (reason != null) 'reason': reason}; }
class StorageSyncRunResponseDto { StorageSyncRunResponseDto({this.failed, this.retried}); factory StorageSyncRunResponseDto.fromJson(JsonMap json) => StorageSyncRunResponseDto(failed: _int(json['failed']), retried: _int(json['retried'])); final int? failed; final int? retried; JsonMap toJson() => {if (failed != null) 'failed': failed, if (retried != null) 'retried': retried}; }
class ArtifactShareResponseDto extends OperationResultResponseDto { ArtifactShareResponseDto({super.ok, super.success, super.message, super.code, this.url, this.text}); factory ArtifactShareResponseDto.fromJson(JsonMap json) => ArtifactShareResponseDto(ok: _bool(json['ok']), success: _bool(json['success']), message: _string(json['message']), code: _string(json['code']), url: _string(json['url']), text: _string(json['text'])); final String? url; final String? text; }
class IndexingStatusResponseDto { IndexingStatusResponseDto({this.pending, this.running, this.retryWait, this.failed, this.searchable}); factory IndexingStatusResponseDto.fromJson(JsonMap json) => IndexingStatusResponseDto(pending: _int(json['pending']), running: _int(json['running']), retryWait: _int(json['retryWait']), failed: _int(json['failed']), searchable: _int(json['searchable'])); final int? pending; final int? running; final int? retryWait; final int? failed; final int? searchable; }
class ImportSampleResponseDto extends OperationResultResponseDto { ImportSampleResponseDto({super.ok, super.success, super.message, super.code, this.childId, this.assetCount}); factory ImportSampleResponseDto.fromJson(JsonMap json) => ImportSampleResponseDto(ok: _bool(json['ok']), success: _bool(json['success']), message: _string(json['message']), code: _string(json['code']), childId: _string(json['childId']), assetCount: _int(json['assetCount'])); final String? childId; final int? assetCount; }
class ChildRecordResponseDto { ChildRecordResponseDto({this.id, this.name}); factory ChildRecordResponseDto.fromJson(JsonMap json) => ChildRecordResponseDto(id: _string(json['id']), name: _string(json['name'])); final String? id; final String? name; JsonMap toJson() => {if (id != null) 'id': id, if (name != null) 'name': name}; }
class EnsureChildResponseDto { EnsureChildResponseDto({this.child}); factory EnsureChildResponseDto.fromJson(JsonMap json) => EnsureChildResponseDto(child: ChildRecordResponseDto.fromJson(_asMap(json['child']))); final ChildRecordResponseDto? child; JsonMap toJson() => {'child': child?.toJson()}; }

class AssetRecordResponseDto {
  AssetRecordResponseDto({this.id, this.title, this.type, this.description, this.tags, this.capturedAt, this.imagePath, this.thumbnailPath, this.previewUrl, this.originalFilename, this.storageStatus});
  factory AssetRecordResponseDto.fromJson(JsonMap json) => AssetRecordResponseDto(id: _string(json['id']), title: _string(json['title']), type: _string(json['type']), description: _string(json['description']), tags: _strings(json['tags']), capturedAt: _string(json['capturedAt'] ?? json['captured_at']), imagePath: _string(json['imagePath'] ?? json['image_path']), thumbnailPath: _string(json['thumbnailPath'] ?? json['thumbnail_path']), previewUrl: _string(json['previewUrl'] ?? json['preview_url']), originalFilename: _string(json['originalFilename'] ?? json['original_filename']), storageStatus: _string(json['storageStatus'] ?? json['storage_status']));
  final String? id;
  final String? title;
  final String? type;
  final String? description;
  final List<String>? tags;
  final String? capturedAt;
  final String? imagePath;
  final String? thumbnailPath;
  final String? previewUrl;
  final String? originalFilename;
  final String? storageStatus;
  JsonMap toJson() => {if (id != null) 'id': id, if (title != null) 'title': title, if (type != null) 'type': type, if (description != null) 'description': description, if (tags != null) 'tags': tags, if (capturedAt != null) 'capturedAt': capturedAt, if (imagePath != null) 'imagePath': imagePath, if (thumbnailPath != null) 'thumbnailPath': thumbnailPath, if (previewUrl != null) 'previewUrl': previewUrl, if (originalFilename != null) 'originalFilename': originalFilename, if (storageStatus != null) 'storageStatus': storageStatus};
}

class AssetSearchItemResponseDto { AssetSearchItemResponseDto({this.asset, this.reasons}); factory AssetSearchItemResponseDto.fromJson(JsonMap json) => AssetSearchItemResponseDto(asset: AssetRecordResponseDto.fromJson(_asMap(json['asset'])), reasons: _strings(json['reasons'])); final AssetRecordResponseDto? asset; final List<String>? reasons; }
class AssetSearchResponseDto extends OperationResultResponseDto { AssetSearchResponseDto({super.ok, super.success, super.message, super.code, this.total, this.items}); factory AssetSearchResponseDto.fromJson(JsonMap json) => AssetSearchResponseDto(ok: _bool(json['ok']), success: _bool(json['success']), message: _string(json['message']), code: _string(json['code']), total: _int(json['total']), items: _asList(json['items']).map((item) => AssetSearchItemResponseDto.fromJson(_asMap(item))).toList()); final int? total; final List<AssetSearchItemResponseDto>? items; }
class ImportAssetsFailedItemDto { ImportAssetsFailedItemDto({this.reason}); factory ImportAssetsFailedItemDto.fromJson(JsonMap json) => ImportAssetsFailedItemDto(reason: _string(json['reason'])); final String? reason; }
class ImportAssetsResponseDto extends OperationResultResponseDto { ImportAssetsResponseDto({super.ok, super.success, super.message, super.code, this.title, this.imported, this.duplicates, this.failed, this.skipped}); factory ImportAssetsResponseDto.fromJson(JsonMap json) => ImportAssetsResponseDto(ok: _bool(json['ok']), success: _bool(json['success']), message: _string(json['message']), code: _string(json['code']), title: _string(json['title']), imported: _asList(json['imported']), duplicates: _asList(json['duplicates']), failed: _asList(json['failed']).map((item) => ImportAssetsFailedItemDto.fromJson(_asMap(item))).toList(), skipped: _asList(json['skipped'])); final String? title; final List<dynamic>? imported; final List<dynamic>? duplicates; final List<ImportAssetsFailedItemDto>? failed; final List<dynamic>? skipped; }
class ResetSampleResponseDto extends OperationResultResponseDto { ResetSampleResponseDto({super.ok, super.success, super.message, super.code, this.deletedAssets}); factory ResetSampleResponseDto.fromJson(JsonMap json) => ResetSampleResponseDto(ok: _bool(json['ok']), success: _bool(json['success']), message: _string(json['message']), code: _string(json['code']), deletedAssets: _int(json['deletedAssets'])); final int? deletedAssets; }
class UpdateAssetResponseDto { UpdateAssetResponseDto({this.asset}); factory UpdateAssetResponseDto.fromJson(JsonMap json) => UpdateAssetResponseDto(asset: json['asset'] == null ? null : AssetRecordResponseDto.fromJson(_asMap(json['asset']))); final AssetRecordResponseDto? asset; }

class CreateDirectUploadSessionResponseDto {
  CreateDirectUploadSessionResponseDto({this.sessionId = '', this.childId = '', this.bucket = '', this.sessionPath = '', this.supabaseUrl = '', this.anonKey = '', this.publicUrl = '', this.recommendedClientLimit = 0, this.expiresAtHintSeconds = 0, this.token = ''});
  factory CreateDirectUploadSessionResponseDto.fromJson(JsonMap json) => CreateDirectUploadSessionResponseDto(sessionId: _string(json['sessionId']) ?? '', childId: _string(json['childId']) ?? '', bucket: _string(json['bucket']) ?? '', sessionPath: _string(json['sessionPath']) ?? '', supabaseUrl: _string(json['supabaseUrl']) ?? '', anonKey: _string(json['anonKey']) ?? '', publicUrl: _string(json['publicUrl']) ?? '', recommendedClientLimit: _int(json['recommendedClientLimit']) ?? 0, expiresAtHintSeconds: _int(json['expiresAtHintSeconds']) ?? 0, token: _string(json['token']) ?? '');
  final String sessionId;
  final String childId;
  final String bucket;
  final String sessionPath;
  final String supabaseUrl;
  final String anonKey;
  final String publicUrl;
  final int recommendedClientLimit;
  final int expiresAtHintSeconds;
  final String token;
}

class DirectUploadStatusItemDto { DirectUploadStatusItemDto({this.objectKey = '', this.status = '', this.errorCode, this.errorMessage}); factory DirectUploadStatusItemDto.fromJson(JsonMap json) => DirectUploadStatusItemDto(objectKey: _string(json['objectKey']) ?? '', status: _string(json['status']) ?? '', errorCode: _string(json['errorCode']), errorMessage: _string(json['errorMessage'])); final String objectKey; final String status; final String? errorCode; final String? errorMessage; }
class DirectUploadStatusSummaryDto { DirectUploadStatusSummaryDto({this.pendingRemote = 0, this.downloading = 0, this.ready = 0, this.failed = 0}); factory DirectUploadStatusSummaryDto.fromJson(JsonMap json) => DirectUploadStatusSummaryDto(pendingRemote: _int(json['pendingRemote']) ?? 0, downloading: _int(json['downloading']) ?? 0, ready: _int(json['ready']) ?? 0, failed: _int(json['failed']) ?? 0); final int pendingRemote; final int downloading; final int ready; final int failed; }
class GetDirectUploadStatusResponseDto { GetDirectUploadStatusResponseDto({this.items = const <DirectUploadStatusItemDto>[], this.summary}); factory GetDirectUploadStatusResponseDto.fromJson(JsonMap json) => GetDirectUploadStatusResponseDto(items: _asList(json['items']).map((item) => DirectUploadStatusItemDto.fromJson(_asMap(item))).toList(), summary: DirectUploadStatusSummaryDto.fromJson(_asMap(json['summary']))); final List<DirectUploadStatusItemDto> items; final DirectUploadStatusSummaryDto? summary; }
