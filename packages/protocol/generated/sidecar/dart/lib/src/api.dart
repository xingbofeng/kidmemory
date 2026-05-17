//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:kidmemory_protocol/src/auth/api_key_auth.dart';
import 'package:kidmemory_protocol/src/auth/basic_auth.dart';
import 'package:kidmemory_protocol/src/auth/bearer_auth.dart';
import 'package:kidmemory_protocol/src/auth/oauth.dart';
import 'package:kidmemory_protocol/src/api/agent_config_api.dart';
import 'package:kidmemory_protocol/src/api/books_api.dart';
import 'package:kidmemory_protocol/src/api/config_api.dart';
import 'package:kidmemory_protocol/src/api/dataset_api.dart';
import 'package:kidmemory_protocol/src/api/direct_upload_api.dart';
import 'package:kidmemory_protocol/src/api/lan_receiver_api.dart';
import 'package:kidmemory_protocol/src/api/security_monitor_api.dart';
import 'package:kidmemory_protocol/src/api/streamable_http_api.dart';
import 'package:kidmemory_protocol/src/api/web_companion_api.dart';

class KidmemoryProtocol {
  static const String basePath = r'http://127.0.0.1:4317';

  final Dio dio;
  KidmemoryProtocol({
    Dio? dio,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : 
        this.dio = dio ??
            Dio(BaseOptions(
              baseUrl: basePathOverride ?? basePath,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens[name] = token;
    }
  }

  /// Removes the OAuth token associated with the given [name].
  ///
  /// If no [OAuthInterceptor] is registered or no token exists for the given
  /// [name], this method has no effect.
  void removeOAuthToken(String name) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens.remove(name);
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens[name] = token;
    }
  }

  /// Removes the bearer authentication token associated with the given [name].
  ///
  /// If no [BearerAuthInterceptor] is registered or no token exists for the
  /// given [name], this method has no effect.
  void removeBearerAuth(String name) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens.remove(name);
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo[name] = BasicAuthInfo(username, password);
    }
  }

  /// Removes the basic authentication credentials associated with the given [name].
  ///
  /// If no [BasicAuthInterceptor] is registered or no credentials exist for the
  /// given [name], this method has no effect.
  void removeBasicAuth(String name) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo.remove(name);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys[name] = apiKey;
    }
  }

  /// Removes the API key associated with the given [name].
  ///
  /// If no [ApiKeyAuthInterceptor] is registered or no API key exists for the
  /// given [name], this method has no effect.
  void removeApiKey(String name) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys.remove(name);
    }
  }

  /// Get AgentConfigApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AgentConfigApi getAgentConfigApi() {
    return AgentConfigApi(dio);
  }

  /// Get BooksApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  BooksApi getBooksApi() {
    return BooksApi(dio);
  }

  /// Get ConfigApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ConfigApi getConfigApi() {
    return ConfigApi(dio);
  }

  /// Get DatasetApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DatasetApi getDatasetApi() {
    return DatasetApi(dio);
  }

  /// Get DirectUploadApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DirectUploadApi getDirectUploadApi() {
    return DirectUploadApi(dio);
  }

  /// Get LanReceiverApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  LanReceiverApi getLanReceiverApi() {
    return LanReceiverApi(dio);
  }

  /// Get SecurityMonitorApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SecurityMonitorApi getSecurityMonitorApi() {
    return SecurityMonitorApi(dio);
  }

  /// Get StreamableHttpApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  StreamableHttpApi getStreamableHttpApi() {
    return StreamableHttpApi(dio);
  }

  /// Get WebCompanionApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  WebCompanionApi getWebCompanionApi() {
    return WebCompanionApi(dio);
  }
}
