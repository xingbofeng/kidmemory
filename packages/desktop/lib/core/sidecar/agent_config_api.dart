import 'sidecar_api.dart';

typedef JsonMap = Map<String, dynamic>;

class AgentConfigApi {
  const AgentConfigApi(this._api);

  final SidecarApi _api;

  Future<TestAgentConfigResult> testAgentConfig(AgentConfig config) async {
    final response = await _api.post('/books/agent/test', config.toJson());
    return TestAgentConfigResult.fromJson(response);
  }

  Future<List<AgentConfigDto>> listAgentConfigs() async {
    final configs = await _api.getList('/api/config/agent-configs');
    return configs
        .whereType<JsonMap>()
        .map(AgentConfigDto.fromJson)
        .toList();
  }

  Future<AgentConfigDto?> getDefaultAgentConfig() async {
    final response = await _api.get('/api/config/agent-configs/default');
    if (response.isEmpty) return null;
    return AgentConfigDto.fromJson(response);
  }

  Future<AgentConfigDto> createAgentConfig(
    CreateAgentConfigRequest request,
  ) async {
    final response = await _api.post(
      '/api/config/agent-configs',
      request.toJson(),
    );
    return AgentConfigDto.fromJson(response);
  }

  Future<AgentConfigDto> updateAgentConfig(
    String id,
    UpdateAgentConfigRequest request,
  ) async {
    final response = await _api.put(
      '/api/config/agent-configs/$id',
      request.toJson(),
    );
    return AgentConfigDto.fromJson(response);
  }

  Future<bool> deleteAgentConfig(String id) async {
    final response = await _api.delete('/api/config/agent-configs/$id');
    return _asBool(response, 'success');
  }

  Future<bool> setDefaultAgentConfig(String id) async {
    final response = await _api.post(
      '/api/config/agent-configs/$id/set-default',
    );
    return _asBool(response, 'success');
  }

  Future<TestAgentConfigResult> testAgentConfigById(
    String id, {
    String? testPrompt,
  }) async {
    final body = testPrompt != null
        ? {'testPrompt': testPrompt}
        : <String, dynamic>{};
    final response = await _api.post(
      '/api/config/agent-configs/$id/test',
      body,
    );
    return TestAgentConfigResult.fromJson(response);
  }

  Future<List<AgentRunDto>> listAgentRuns({
    String? childId,
    String? agentConfigId,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (childId != null) queryParams['childId'] = childId;
    if (agentConfigId != null) queryParams['agentConfigId'] = agentConfigId;
    if (limit != null) queryParams['limit'] = limit.toString();

    final query = queryParams.isEmpty
        ? ''
        : '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    final response = await _api.get('/api/agent-runs$query');
    final runs = _asList(response, 'runs');
    return runs.whereType<JsonMap>().map(AgentRunDto.fromJson).toList();
  }
}

class AgentConfig {
  AgentConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
  });

  final String baseUrl;
  final String apiKey;
  final String model;

  Map<String, dynamic> toJson() {
    return {'baseUrl': baseUrl, 'apiKey': apiKey, 'model': model};
  }
}

class TestAgentConfigResult {
  TestAgentConfigResult({
    required this.success,
    this.message,
    this.responseTime,
    this.errorMessage,
    this.modelUsed,
    this.tokensUsed,
  });

  final bool success;
  final String? message;
  final int? responseTime;
  final String? errorMessage;
  final String? modelUsed;
  final int? tokensUsed;

  factory TestAgentConfigResult.fromJson(JsonMap json) {
    final errorMessage = _asNullableString(json, 'errorMessage');
    return TestAgentConfigResult(
      success: _asBool(json, 'success') || _asBool(json, 'ok'),
      message: _asNullableString(json, 'message') ?? errorMessage,
      responseTime: _asNullableInt(json, 'responseTime'),
      errorMessage: errorMessage,
      modelUsed: _asNullableString(json, 'modelUsed'),
      tokensUsed: _asNullableInt(json, 'tokensUsed'),
    );
  }
}

class AgentConfigDto {
  const AgentConfigDto({
    required this.id,
    required this.name,
    this.description,
    required this.provider,
    required this.model,
    this.baseUrl,
    required this.apiKeyConfigured,
    required this.temperature,
    required this.maxTokens,
    this.systemPrompt,
    required this.toolsEnabled,
    required this.workspaceConfig,
    required this.isActive,
    required this.isDefault,
    this.lastTestedAt,
    this.testResult,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final String provider;
  final String model;
  final String? baseUrl;
  final bool apiKeyConfigured;
  final double temperature;
  final int maxTokens;
  final String? systemPrompt;
  final List<String> toolsEnabled;
  final JsonMap workspaceConfig;
  final bool isActive;
  final bool isDefault;
  final String? lastTestedAt;
  final String? testResult;
  final String createdAt;
  final String updatedAt;

  factory AgentConfigDto.fromJson(JsonMap json) {
    return AgentConfigDto(
      id: _asString(json, 'id'),
      name: _asString(json, 'name'),
      description: _asNullableString(json, 'description'),
      provider: _asString(json, 'provider'),
      model: _asString(json, 'model'),
      baseUrl: _asNullableString(json, 'baseUrl'),
      apiKeyConfigured: _asBool(json, 'apiKeyConfigured'),
      temperature: _asDouble(json, 'temperature'),
      maxTokens: _asInt(json, 'maxTokens'),
      systemPrompt: _asNullableString(json, 'systemPrompt'),
      toolsEnabled: _asStringList(json, 'toolsEnabled'),
      workspaceConfig: _asMap(json['workspaceConfig']),
      isActive: _asBool(json, 'isActive'),
      isDefault: _asBool(json, 'isDefault'),
      lastTestedAt: _asNullableString(json, 'lastTestedAt'),
      testResult: _asNullableString(json, 'testResult'),
      createdAt: _asString(json, 'createdAt'),
      updatedAt: _asString(json, 'updatedAt'),
    );
  }
}

class AgentRunDto {
  AgentRunDto({
    required this.id,
    required this.agentConfigId,
    required this.childId,
    this.bookId,
    required this.status,
    required this.inputData,
    this.outputData,
    this.errorMessage,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    this.workspacePath,
    this.executionLog,
    required this.metadata,
  });

  final String id;
  final String agentConfigId;
  final String childId;
  final String? bookId;
  final String status;
  final JsonMap inputData;
  final JsonMap? outputData;
  final String? errorMessage;
  final String? startedAt;
  final String? completedAt;
  final String createdAt;
  final String? workspacePath;
  final String? executionLog;
  final JsonMap metadata;

  factory AgentRunDto.fromJson(JsonMap json) {
    return AgentRunDto(
      id: _asString(json, 'id'),
      agentConfigId: _asString(json, 'agentConfigId'),
      childId: _asString(json, 'childId'),
      bookId: _asNullableString(json, 'bookId'),
      status: _asString(json, 'status'),
      inputData: _asMap(json['inputData']),
      outputData: json['outputData'] == null ? null : _asMap(json['outputData']),
      errorMessage: _asNullableString(json, 'errorMessage'),
      startedAt: _asNullableString(json, 'startedAt'),
      completedAt: _asNullableString(json, 'completedAt'),
      createdAt: _asString(json, 'createdAt'),
      workspacePath: _asNullableString(json, 'workspacePath'),
      executionLog: _asNullableString(json, 'executionLog'),
      metadata: _asMap(json['metadata']),
    );
  }
}

class CreateAgentConfigRequest {
  const CreateAgentConfigRequest({
    required this.name,
    this.description,
    required this.provider,
    required this.model,
    required this.apiKey,
    this.baseUrl,
    this.temperature,
    this.maxTokens,
    this.systemPrompt,
    this.toolsEnabled,
    this.workspaceConfig,
    this.isDefault,
  });

  final String name;
  final String? description;
  final String provider;
  final String model;
  final String apiKey;
  final String? baseUrl;
  final double? temperature;
  final int? maxTokens;
  final String? systemPrompt;
  final List<String>? toolsEnabled;
  final Map<String, dynamic>? workspaceConfig;
  final bool? isDefault;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'provider': provider,
      'model': model,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'systemPrompt': systemPrompt,
      'toolsEnabled': toolsEnabled,
      'workspaceConfig': workspaceConfig,
      'isDefault': isDefault,
    }..removeWhere((key, value) => value == null);
  }
}

JsonMap _asMap(Object? value) {
  if (value is JsonMap) return value;
  if (value is Map) {
    return value.map(
      (key, entry) => MapEntry(key.toString(), entry),
    );
  }
  return const {};
}

List<dynamic> _asList(JsonMap json, String key) {
  final value = json[key];
  return value is List ? value : const [];
}

String _asString(JsonMap json, String key, {String fallback = ''}) {
  final value = json[key];
  return value is String ? value : fallback;
}

String? _asNullableString(JsonMap json, String key) {
  final value = json[key];
  return value is String ? value : null;
}

bool _asBool(JsonMap json, String key, {bool fallback = false}) {
  final value = json[key];
  return value is bool ? value : fallback;
}

int _asInt(JsonMap json, String key, {int fallback = 0}) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int? _asNullableInt(JsonMap json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double _asDouble(JsonMap json, String key, {double fallback = 0}) {
  final value = json[key];
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

List<String> _asStringList(JsonMap json, String key) {
  final value = json[key];
  if (value is! List) return const [];
  return value.map((entry) => '$entry').toList();
}

class UpdateAgentConfigRequest {
  const UpdateAgentConfigRequest({
    this.name,
    this.description,
    this.provider,
    this.model,
    this.apiKey,
    this.baseUrl,
    this.temperature,
    this.maxTokens,
    this.systemPrompt,
    this.toolsEnabled,
    this.workspaceConfig,
    this.isActive,
  });

  final String? name;
  final String? description;
  final String? provider;
  final String? model;
  final String? apiKey;
  final String? baseUrl;
  final double? temperature;
  final int? maxTokens;
  final String? systemPrompt;
  final List<String>? toolsEnabled;
  final Map<String, dynamic>? workspaceConfig;
  final bool? isActive;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'provider': provider,
      'model': model,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'systemPrompt': systemPrompt,
      'toolsEnabled': toolsEnabled,
      'workspaceConfig': workspaceConfig,
      'isActive': isActive,
    }..removeWhere((key, value) => value == null);
  }
}
