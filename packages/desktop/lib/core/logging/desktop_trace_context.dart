class DesktopTraceContext {
  String _traceId = '';

  String get traceId {
    if (_traceId.isEmpty) {
      beginAction();
    }
    return _traceId;
  }

  void beginAction({String? traceId}) {
    final normalized = traceId?.trim() ?? '';
    if (normalized.isNotEmpty) {
      _traceId = normalized;
      return;
    }

    _traceId = 'trc_${DateTime.now().millisecondsSinceEpoch}_${_randomSuffix()}';
  }

  String nextRequestId() {
    return 'req_${DateTime.now().millisecondsSinceEpoch}_${_randomSuffix()}';
  }

  String _randomSuffix() {
    final micros = DateTime.now().microsecondsSinceEpoch;
    return (micros % 0xFFFFFF).toRadixString(16).padLeft(6, '0');
  }
}
