part of '../desktop_shell.dart';

extension _DesktopShellDatasetChildren on _DesktopShellState {
  Future<void> _createChildProfile() async {
    if (!mounted) return;
    final saved = await _showChildProfileDialog(
      title: AppLocalizations.of(context)!.datasetChildrenS690,
      actionLabel: AppLocalizations.of(context)!.datasetChildrenS688,
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
      _showSnackBar(AppLocalizations.of(context)!.datasetChildrenS689);
      _appendLog(
        AppLocalizations.of(
          context,
        )!.datasetChildAddFailedLog(jsonEncode(result.raw)),
      );
      return;
    }
    _setShellState(() => selectedChildId = result.childId);
    await refreshDataset();
    if (!mounted) return;
    _appendLog(
      AppLocalizations.of(
        context,
      )!.datasetChildAddedLog(result.childId, saved.name),
    );
    _showSnackBar(
      AppLocalizations.of(context)!.datasetChildAddedMessage(saved.name),
    );
  }

  Future<void> _editSelectedChildProfile(ChildVm current) async {
    if (current.id.trim().isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.datasetChildrenS854);
      return;
    }
    final saved = await _showChildProfileDialog(
      title: AppLocalizations.of(context)!.datasetChildrenS835,
      actionLabel: AppLocalizations.of(context)!.actionSave,
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
    if (!mounted) return;
    _appendLog(
      AppLocalizations.of(
        context,
      )!.datasetChildEditedLog(current.id, saved.name),
    );
    _showSnackBar(
      AppLocalizations.of(context)!.datasetChildEditedMessage(saved.name),
    );
  }

  Future<void> _deleteSelectedChildProfile(ChildVm current) async {
    if (current.id.trim().isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.datasetChildrenS856);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.datasetChildrenS301),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(
                context,
              )!.datasetChildDeleteConfirmMessage(current.name),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(
                context,
              )!.datasetChildDeleteConfirmWarning,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xffb84938),
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.assetLibraryPageS296),
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
          result.messageValue.isNotEmpty
              ? result.messageValue
              : AppLocalizations.of(context)!.assetLibraryPageS299,
        );
        return;
      }
      if (selectedChildId == current.id) {
        _setShellState(() => selectedChildId = null);
      }
      await refreshDataset();
      if (!mounted) return;
      _appendLog(
        AppLocalizations.of(
          context,
        )!.datasetChildDeletedLog(current.id, current.name),
      );
      _showSnackBar(
        AppLocalizations.of(context)!.datasetChildDeletedMessage(current.name),
      );
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context)!.datasetChildrenS300);
      _appendLog(
        AppLocalizations.of(
          context,
        )!.datasetChildDeleteFailedLog(current.id, error),
      );
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
      helpText: AppLocalizations.of(context)!.datasetChildrenS906,
      cancelText: AppLocalizations.of(context)!.actionCancel,
      confirmText: AppLocalizations.of(context)!.datasetChildrenS762,
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  )!.datasetChildNameLabel,
                ),
                onSubmitted: (_) => _pickBirthday(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _birthdayController,
                readOnly: true,
                showCursor: false,
                enableInteractiveSelection: false,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.datasetChildrenS748,
                  hintText: AppLocalizations.of(context)!.datasetChildrenS703,
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.datasetChildrenS356,
                  hintText: AppLocalizations.of(context)!.datasetChildrenS263,
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(_birthdayController.clear),
          child: Text(
            AppLocalizations.of(context)!.datasetChildrenClearBirthday,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.actionCancel),
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
