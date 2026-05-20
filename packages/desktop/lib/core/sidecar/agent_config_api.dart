import 'sidecar_api.dart';
import 'package:kidmemory_protocol/kidmemory_protocol.dart';

typedef JsonMap = Map<String, dynamic>;

class AgentConfigApi {
  const AgentConfigApi(this._api);

  final SidecarApi _api;

  Future<List<AgentConfigResponseDto>> listAgentConfigs() async {
    final configs = await _api.getList('/api/config/agent-configs');
    return configs
        .whereType<JsonMap>()
        .map((json) => AgentConfigResponseDto.fromJson(_asMap(json)))
        .toList();
  }

  Future<AgentConfigResponseDto?> getDefaultAgentConfig() async {
    final response = await _api.get('/api/config/agent-configs/default');
    if (response.isEmpty) return null;
    return AgentConfigResponseDto.fromJson(_asMap(response));
  }

  Future<AgentConfigResponseDto> createAgentConfig(
    CreateAgentConfigInput request,
  ) async {
    final response = await _api.post(
      '/api/config/agent-configs',
      request.toJson(),
    );
    return AgentConfigResponseDto.fromJson(_asMap(response));
  }

  Future<AgentConfigResponseDto> updateAgentConfig(
    String id,
    UpdateAgentConfigInput request,
  ) async {
    final response = await _api.put(
      '/api/config/agent-configs/$id',
      request.toJson(),
    );
    return AgentConfigResponseDto.fromJson(_asMap(response));
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

  Future<TestAgentConfigResultOutput> testAgentConfigById(
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
    return TestAgentConfigResultOutput.fromJson(_asMap(response));
  }

  Future<List<JsonMap>> listAgentRuns({
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
    return runs.whereType<JsonMap>().map(_asMap).toList();
  }
}

JsonMap _asMap(Object? value) {
  if (value is JsonMap) return value;
  if (value is Map) {
    return value.map((key, entry) => MapEntry(key.toString(), entry));
  }
  return const {};
}

List<dynamic> _asList(JsonMap json, String key) {
  final value = json[key];
  return value is List ? value : const [];
}

bool _asBool(JsonMap json, String key, {bool fallback = false}) {
  final value = json[key];
  return value is bool ? value : fallback;
}

typedef CreateAgentConfigInput = CreateAgentConfigRequestDto;
typedef UpdateAgentConfigInput = UpdateAgentConfigRequestDto;
typedef TestAgentConfigResultOutput = TestAgentConfigResultResponseDto;
