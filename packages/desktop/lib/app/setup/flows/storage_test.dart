part of '../../desktop_shell.dart';

extension _DesktopShellSetupStorageTest on _DesktopShellState {
  Future<void> _testSupabaseStorage() async {
    if (!supabaseStorage.configured || supabaseStorage.testing) {
      _showSnackBar('请先配置 Supabase REST 或 S3 所需参数');
      return;
    }
    _setShellState(() {
      supabaseStorage = supabaseStorage.copyWith(
        testing: true,
        testMessage: '正在测试连接...',
      );
    });
    final result = await gateway.testSupabaseStorageDto();
    if (!mounted) return;
    final cleanupMessage = result.cleanupOk ? '' : '，测试对象清理失败';
    final message = result.ok
        ? '测试通过$cleanupMessage'
        : (result.message.isNotEmpty
              ? result.message
              : (result.code.isNotEmpty ? result.code : '测试失败'));
    _setShellState(() {
      supabaseStorage = supabaseStorage.copyWith(
        testing: false,
        testMessage: message,
      );
    });
    _showSnackBar(result.ok ? message : 'Supabase Storage $message');
  }
}
