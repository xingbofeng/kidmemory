import 'dart:io';

void main() {
  final dir = Directory('packages/desktop/lib');
  final files = <File>[];
  
  dir.listSync(recursive: true).forEach((entity) {
    if (entity is File && entity.path.endsWith('.dart') &&
        !entity.path.contains('.dart_tool') &&
        !entity.path.contains('build') &&
        !entity.path.contains('app_localizations')) {
      files.add(entity);
    }
  });
  
  files.sort((a, b) => a.path.compareTo(b.path));
  
  final chinesePattern = RegExp(r'[\u4e00-\u9fff]');
  
  final excludeExact = <String>{
    'all', 'childId', 'model', 'success', 'failed', 'errorMessage', 'errorCode',
    'createdAt', 'assetId', 'previewUrl', 'imagePath', 'originalFilename',
    'description', 'title', 'name', 'label', 'value', 'id', 'type',
    'ok', 'text', 'index', 'source', 'path', 'key', 'node', 'anonKey',
    'endpoint', 'bucket', 'region', 'maxItems', 'expiresInMinutes', 
    'preferredProviders', 'agentConfigId', 'child-default',
    'sample-child', 'kidmemory', 'auto', 'defaults', 'generate',
    'downloading', 'pending_remote', 'ready', 'exportTargets',
    'exportTarget', 'export', 'retry_wait', 'share',
    'FLUTTER_TEST', 'KIDMEMORY_SIDECAR_DIR', 'KIDMEMORY_ROOT_DIR',
    'HOME', 'USERPROFILE', 'APPDATA', 'KIDMEMORY_POSTGRES_RUNTIME_DIR',
    'PATH', 'kidmemory-import-', 'desktop.action.export_pdf', 
    'desktop.action.generate_book', 'selectedCount', 'artwork', 'craft', 'photo',
    'node', 'createdb', 'supabaseStorage', 'agentConfig',
    'openAiConfig', 'serviceRoleKeyConfigured', 'publicBaseUrl',
    'diagnosticMessage', 'shareText', 'selectText', 'cleanupMessage',
    'displayMessage', 'schemaMessage', 'okValue', 'messageValue',
    'pgvectorCheck', 'packageName', 'runtimeShareDir', 'pgDefaultDatabase',
    'pgDefaultLoopback', 'bundledPostgresPort', 'explicitDir',
    'Main.step', 'Main.start', 'Main.end',
    '--no-cache', '--noconfirm', '--non-interactive',
    '==> Downloading', '==> Error', 'Error:', 'Error',
    '-sTCP:LISTEN',
  };
  
  bool isCodeString(String s) {
    if (s.startsWith('--') || s.startsWith('-sTCP') || s.startsWith('_pgDefault')) return true;
    if (s.startsWith(r'$') && !s.contains(' ')) return true;
    if (s.startsWith('__')) return true;
    if (s.startsWith('.') && !s.startsWith('. ')) return true;
    if (RegExp(r'^[a-z]+(_[a-z]+)*(/[a-z]+)*$').hasMatch(s) && 
        !s.contains(' ') && !chinesePattern.hasMatch(s)) return true;
    if (RegExp(r'^[a-zA-Z0-9._/-]+$').hasMatch(s) && 
        (s.contains('.png') || s.contains('.dart') || s.contains('.json') || 
         s.contains('.js') || s.contains('.tsv'))) return true;
    if (s.startsWith('${') && s.endsWith('}')) return true;
    return false;
  }
  
  String getModule(String path) {
    if (path.startsWith('features/')) {
      var parts = path.split('/');
      return 'features/${parts[1]}';
    } else if (path.startsWith('app/')) {
      var parts = path.split('/');
      return 'app/${parts[1]}';
    } else if (path.startsWith('shared/')) {
      var parts = path.split('/');
      return 'shared/${parts[1]}';
    } else if (path.startsWith('core/')) {
      var parts = path.split('/');
      return 'core/${parts[1]}';
    } else if (path.startsWith('data/')) {
      return 'data';
    }
    return 'root';
  }
  
  String getFilename(String path) {
    var parts = path.split('/');
    return parts.last;
  }
  
  bool isUIText(String s) {
    if (s.isEmpty || s.length < 2) return false;
    if (isCodeString(s)) return false;
    if (excludeExact.contains(s)) return false;
    if (chinesePattern.hasMatch(s)) return true;
    // English UI text: capitalized words, common UI phrases
    if (RegExp(r'^[A-Z][a-zA-Z\s,.\-!?0-9]+$').hasMatch(s) && s.length <= 80) return true;
    if (s.contains(' ') && !RegExp(r'^[a-z][a-z_]+ [a-z][a-z_]+$').hasMatch(s)) return true;
    return false;
  }
  
  var results = <String, List<String>>{};
  
  for (var file in files) {
    var relPath = file.path.replaceFirst('packages/desktop/lib/', '');
    var content = file.readAsStringSync();
    var strings = <String>{};
    
    var stringRegex = RegExp(r"'(?:[^'\\]|\\.)*'");
    for (var match in stringRegex.allMatches(content)) {
      var s = match.group(0)!;
      s = s.substring(1, s.length - 1);
      
      if (isUIText(s)) {
        strings.add(s);
      }
    }
    
    if (strings.isNotEmpty) {
      results[relPath] = strings.toList()..sort();
    }
  }
  
  // Print organized results
  for (var entry in results.entries) {
    var path = entry.key;
    var strs = entry.value;
    var module = getModule(path);
    var filename = getFilename(path);
    var examples = strs.take(3).map((s) => s.replaceAll("'", "\\'")).join('", "');
    
    print('$module | $filename | ${strs.length} | "$examples"');
  }
  
  // Summary
  var totalFiles = results.length;
  var totalStrings = 0;
  var allUnique = <String>{};
  
  for (var strs in results.values) {
    totalStrings += strs.length;
    allUnique.addAll(strs);
  }
  
  print('\n============================ 汇总 ============================');
  print('包含硬编码字符串的文件数: $totalFiles');
  print('硬编码字符串实例总数 (含重复): $totalStrings');
  print('去重后唯一 UI 字符串数 (约需 i18n key 数): ${allUnique.length}');
  
  // Module stats
  var moduleCounts = <String, int>{};
  var moduleFileSets = <String, Set<String>>{};
  for (var entry in results.entries) {
    var path = entry.key;
    var module = getModule(path);
    moduleCounts[module] = (moduleCounts[module] ?? 0) + entry.value.length;
    moduleFileSets.putIfAbsent(module, () => <String>{});
    moduleFileSets[module]!.add(path);
  }
  
  print('\n--- 模块分布 ---');
  var sortedModules = moduleCounts.keys.toList()..sort();
  for (var m in sortedModules) {
    var fileCount = moduleFileSets[m]!.length;
    print('$m: ${moduleCounts[m]} 个字符串 ($fileCount 个文件)');
  }
}
