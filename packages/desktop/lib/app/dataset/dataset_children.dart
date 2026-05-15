part of '../desktop_shell.dart';

extension _DesktopShellDatasetChildren on _DesktopShellState {
  Future<void> _createChildProfile() async {
    if (!mounted) return;
    final childNameController = TextEditingController();
    final saved = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加孩子档案'),
          content: TextField(
            controller: childNameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: '孩子名字'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final value = childNameController.text.trim();
                if (value.isEmpty) return;
                Navigator.of(context).pop(value);
              },
              icon: const AppAssetIcon(
                addIconAsset,
                size: compactInlineIconSize,
              ),
              label: const Text('添加'),
            ),
          ],
        );
      },
    );
    if (saved == null || saved.isEmpty) return;
    final childId = 'child-${DateTime.now().millisecondsSinceEpoch}';
    final result = await gateway.ensureChildDto(id: childId, name: saved);
    if (!mounted) return;
    if (!result.hasChild) {
      _showSnackBar('添加失败：请确认 Sidecar 已启动');
      _appendLog('添加孩子档案失败：${jsonEncode(result.raw)}');
      return;
    }
    _setShellState(() => selectedChildId = result.childId);
    await refreshDataset();
    if (!mounted) return;
    _appendLog('添加孩子档案：${result.childId} $saved');
    _showSnackBar('已添加孩子档案：$saved');
  }

  Future<void> _editSelectedChildProfile() async {
    if (selectedChildId == null) {
      _showSnackBar('请先选择一个孩子再编辑资料');
      return;
    }
    final current = children.firstWhere(
      (child) => child.id == selectedChildId,
      orElse: () => children.isNotEmpty
          ? children.first
          : const ChildVm(id: '', name: ''),
    );
    if (!mounted) return;
    final childNameController = TextEditingController(text: current.name);
    final saved = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('编辑资料'),
          content: TextField(
            controller: childNameController,
            decoration: const InputDecoration(labelText: '孩子名字'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = childNameController.text.trim();
                if (value.isEmpty) return;
                Navigator.of(context).pop(value);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
    if (saved == null || saved.isEmpty) return;
    final result = await gateway.ensureChildDto(id: current.id, name: saved);
    if (!mounted) return;
    await refreshDataset();
    if (!result.hasChild) {
      _showSnackBar('编辑失败：无法保存资料');
      _appendLog('编辑资料失败：${jsonEncode(result.raw)}');
      return;
    }
    _appendLog('编辑资料：${current.id} 名字更新为 $saved');
    _showSnackBar('资料已更新为：$saved');
  }
}
