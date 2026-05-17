part of '../desktop_shell.dart';

extension _DesktopShellDatasetChildren on _DesktopShellState {
  Future<void> _createChildProfile() async {
    if (!mounted) return;
    final saved = await _showChildProfileDialog(
      title: '添加孩子档案',
      actionLabel: '添加',
      actionIcon: const AppAssetIcon(addIconAsset, size: compactInlineIconSize),
    );
    if (saved == null) return;
    final childId = 'child-${DateTime.now().millisecondsSinceEpoch}';
    final result = await gateway.ensureChildDto(
      id: childId,
      name: saved.name,
      birthday: saved.birthday,
      notes: saved.notes,
    );
    if (!mounted) return;
    if (!result.hasChild) {
      _showSnackBar('添加失败：请确认 Sidecar 已启动');
      _appendLog('添加孩子档案失败：${jsonEncode(result.raw)}');
      return;
    }
    _setShellState(() => selectedChildId = result.childId);
    await refreshDataset();
    if (!mounted) return;
    _appendLog('添加孩子档案：${result.childId} ${saved.name}');
    _showSnackBar('已添加孩子档案：${saved.name}');
  }

  Future<void> _editSelectedChildProfile(ChildVm current) async {
    if (current.id.trim().isEmpty) {
      _showSnackBar('请先添加一个孩子再编辑资料');
      return;
    }
    final saved = await _showChildProfileDialog(
      title: '编辑资料',
      actionLabel: '保存',
      initialValue: _ChildProfileFormData.fromChild(current),
    );
    if (saved == null) return;
    await gateway.updateChildDto(
      id: current.id,
      name: saved.name,
      birthday: saved.birthday,
      notes: saved.notes,
    );
    if (!mounted) return;
    await refreshDataset();
    _appendLog('编辑资料：${current.id} 更新为 ${saved.name}');
    _showSnackBar('资料已更新为：${saved.name}');
  }

  Future<void> _deleteSelectedChildProfile(ChildVm current) async {
    if (current.id.trim().isEmpty) {
      _showSnackBar('请先选择一个孩子档案');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除孩子档案'),
        content: Text('确定删除「${current.name}」吗？删除前需要先清空这个孩子关联的素材。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xffb84938),
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final result = await gateway.deleteChildDto(id: current.id);
      if (!mounted) return;
      if (!result.okValue) {
        _showSnackBar(
          result.messageValue.isNotEmpty ? result.messageValue : '删除失败',
        );
        return;
      }
      if (selectedChildId == current.id) {
        _setShellState(() => selectedChildId = null);
      }
      await refreshDataset();
      if (!mounted) return;
      _appendLog('删除孩子档案：${current.id} ${current.name}');
      _showSnackBar('已删除孩子档案：${current.name}');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('删除失败：请先清空这个孩子关联的素材');
      _appendLog('删除孩子档案失败：${current.id} $error');
    }
  }

  Future<_ChildProfileFormData?> _showChildProfileDialog({
    required String title,
    required String actionLabel,
    Widget? actionIcon,
    _ChildProfileFormData initialValue = const _ChildProfileFormData(),
  }) async {
    return showDialog<_ChildProfileFormData>(
      context: context,
      requestFocus: true,
      builder: (context) => _ChildProfileDialog(
        title: title,
        actionLabel: actionLabel,
        actionIcon: actionIcon,
        initialValue: initialValue,
      ),
    );
  }
}

class _ChildProfileFormData {
  const _ChildProfileFormData({
    this.name = '',
    this.birthday = '',
    this.notes = '',
  });

  factory _ChildProfileFormData.fromChild(ChildVm child) {
    return _ChildProfileFormData(
      name: child.name,
      birthday: child.birthday,
      notes: child.notes,
    );
  }

  final String name;
  final String birthday;
  final String notes;
}

class _ChildProfileDialog extends StatefulWidget {
  const _ChildProfileDialog({
    required this.title,
    required this.actionLabel,
    required this.initialValue,
    this.actionIcon,
  });

  final String title;
  final String actionLabel;
  final Widget? actionIcon;
  final _ChildProfileFormData initialValue;

  @override
  State<_ChildProfileDialog> createState() => _ChildProfileDialogState();
}

class _ChildProfileDialogState extends State<_ChildProfileDialog> {
  static final DateFormat _birthdayFormat = DateFormat('yyyy-MM-dd');

  late final TextEditingController _nameController;
  late final TextEditingController _birthdayController;
  late final TextEditingController _notesController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _notesFocusNode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialValue.name);
    _birthdayController = TextEditingController(
      text: widget.initialValue.birthday,
    );
    _notesController = TextEditingController(text: widget.initialValue.notes);
    _nameFocusNode = FocusNode();
    _notesFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdayController.dispose();
    _notesController.dispose();
    _nameFocusNode.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  DateTime? _parseBirthday(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    try {
      return _birthdayFormat.parseStrict(trimmed);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final initialDate =
        _parseBirthday(_birthdayController.text) ??
        DateTime(now.year - 6, now.month, now.day);
    final firstDate = DateTime(1900);
    final lastDate = DateTime(now.year + 1, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: '选择生日',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _birthdayController.text = _birthdayFormat.format(picked);
    });
  }

  void _submit() {
    final value = _ChildProfileFormData(
      name: _nameController.text.trim(),
      birthday: _birthdayController.text.trim(),
      notes: _notesController.text.trim(),
    );
    if (value.name.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: '孩子名字'),
                onSubmitted: (_) => _pickBirthday(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _birthdayController,
                readOnly: true,
                showCursor: false,
                enableInteractiveSelection: false,
                decoration: const InputDecoration(
                  labelText: '生日',
                  hintText: '点按选择生日',
                  suffixIcon: Icon(Icons.calendar_month_outlined),
                ),
                onTap: _pickBirthday,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _notesController,
                focusNode: _notesFocusNode,
                minLines: 3,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: '备注',
                  hintText: '兴趣、性格、记录偏好等',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        widget.actionIcon == null
            ? ElevatedButton(
                onPressed: _submit,
                child: Text(widget.actionLabel),
              )
            : ElevatedButton.icon(
                onPressed: _submit,
                icon: widget.actionIcon!,
                label: Text(widget.actionLabel),
              ),
      ],
    );
  }
}
