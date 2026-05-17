// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'KidMemory';

  @override
  String get loading => '加载中...';

  @override
  String get error => '错误';

  @override
  String get success => '成功';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get setupTitle => '环境配置';

  @override
  String get childProfileTitle => '孩子档案';

  @override
  String get assetLibraryTitle => '素材库';

  @override
  String get generateExportTitle => '生成导出';
}
