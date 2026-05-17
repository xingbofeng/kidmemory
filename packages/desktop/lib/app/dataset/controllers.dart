part of '../desktop_shell.dart';

class _DesktopShellControllers {
  _DesktopShellControllers({required SidecarApi api})
    : readiness = _ReadinessController(api),
      dataset = _DatasetController(api);

  final _ReadinessController readiness;
  final _DatasetController dataset;
}

class _ReadinessController {
  _ReadinessController(this._api) : _gateway = DesktopSidecarGateway(_api);

  final SidecarApi _api;
  final DesktopSidecarGateway _gateway;

  Future<_ReadinessSnapshot> load() async {
    try {
      final data = await _gateway.loadReadiness();
      return _ReadinessSnapshot(
        uiConfig: data.uiConfig,
        config: data.config,
        schema: data.schema,
        postgres: data.postgres,
        pgvector: data.pgvector,
        openai: data.openai,
      );
    } on SidecarApiException {
      try {
        final uiConfig = await _api.get('/config/ui');
        return _ReadinessSnapshot.unavailable(uiConfig: uiConfig);
      } catch (_) {
        return _ReadinessSnapshot.unavailable(uiConfig: const {});
      }
    }
  }
}

class _DatasetController {
  _DatasetController(SidecarApi api) : _gateway = DesktopSidecarGateway(api);

  final DesktopSidecarGateway _gateway;

  Future<_DatasetSnapshot> refresh({required String? selectedChildId}) async {
    final data = await _gateway.loadDataset(selectedChildId: selectedChildId);
    return _DatasetSnapshot(
      children: data.children,
      activeChildId: data.activeChildId,
      assetRows: data.assetRows,
    );
  }
}
