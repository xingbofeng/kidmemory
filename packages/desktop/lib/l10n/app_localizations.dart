import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// 应用标题
  ///
  /// In zh, this message translates to:
  /// **'KidMemory'**
  String get appTitle;

  /// 加载提示
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get loading;

  /// 错误提示
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get error;

  /// 成功提示
  ///
  /// In zh, this message translates to:
  /// **'成功'**
  String get success;

  /// 取消按钮
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// 确认按钮
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// 设置页面标题
  ///
  /// In zh, this message translates to:
  /// **'环境配置'**
  String get setupTitle;

  /// 孩子档案页面标题
  ///
  /// In zh, this message translates to:
  /// **'孩子档案'**
  String get childProfileTitle;

  /// 创作台页面标题
  ///
  /// In zh, this message translates to:
  /// **'创作台'**
  String get assetStudioTitle;

  /// 素材库页面标题
  ///
  /// In zh, this message translates to:
  /// **'素材库'**
  String get assetLibraryTitle;

  /// 侧边栏设置入口标题
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get sidebarSettingsTitle;

  /// 侧边栏本地成长档案标题
  ///
  /// In zh, this message translates to:
  /// **'本地成长档案'**
  String get sidebarLocalProfileTitle;

  /// 本地优先标签
  ///
  /// In zh, this message translates to:
  /// **'本地优先'**
  String get localPriorityLabel;

  /// 侧边栏标语
  ///
  /// In zh, this message translates to:
  /// **'每一份素材，都会进入本地成长档案。'**
  String get sidebarSignatureDescription;

  /// 生成导出页面标题
  ///
  /// In zh, this message translates to:
  /// **'生成导出'**
  String get generateExportTitle;

  /// Direct upload 入口按钮文字
  ///
  /// In zh, this message translates to:
  /// **'扫码上传 · Direct'**
  String get directUploadEntryButtonLabel;

  /// Direct upload 弹窗标题
  ///
  /// In zh, this message translates to:
  /// **'扫码上传 · Direct'**
  String get directUploadDialogTitle;

  /// Direct upload 回拉按钮文案
  ///
  /// In zh, this message translates to:
  /// **'拉回本地'**
  String get directUploadPullBackActionLabel;

  /// Direct upload 回拉状态区域标题
  ///
  /// In zh, this message translates to:
  /// **'回拉状态'**
  String get uploadRemoteStatusTitle;

  /// actionCloseLabel
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get actionCloseLabel;

  /// Direct upload 风险说明
  ///
  /// In zh, this message translates to:
  /// **'Supabase 直传验证版 — 对象需电脑端回拉后才算入库'**
  String get directUploadRiskNotice;

  /// Direct upload 会话路径字段标签
  ///
  /// In zh, this message translates to:
  /// **'会话路径'**
  String get uploadSessionPathLabel;

  /// Direct upload 链接信息标签
  ///
  /// In zh, this message translates to:
  /// **'扫码或复制链接'**
  String get uploadAccessLinkLabel;

  /// Direct upload 二维码无障碍标签
  ///
  /// In zh, this message translates to:
  /// **'Direct Upload 扫码链接二维码'**
  String get directUploadQrCodeLabel;

  /// Direct upload 无对象提示
  ///
  /// In zh, this message translates to:
  /// **'暂无远端对象，请先在手机端扫码上传'**
  String get directUploadNoItemsHint;

  /// 通用重试按钮文案
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get actionRetryLabel;

  /// 上传状态：等待回拉
  ///
  /// In zh, this message translates to:
  /// **'等待回拉'**
  String get uploadStatusPendingPullbackLabel;

  /// 上传状态：回拉中
  ///
  /// In zh, this message translates to:
  /// **'回拉中'**
  String get uploadStatusDownloadingLabel;

  /// 上传状态：已入库
  ///
  /// In zh, this message translates to:
  /// **'已入库'**
  String get uploadStatusReadyLabel;

  /// 上传状态：失败
  ///
  /// In zh, this message translates to:
  /// **'失败'**
  String get uploadStatusFailedLabel;

  /// 错误详情：未知错误
  ///
  /// In zh, this message translates to:
  /// **'未知错误'**
  String get uploadStatusUnknownErrorLabel;

  /// Trusted upload 入口按钮文字
  ///
  /// In zh, this message translates to:
  /// **'扫码上传'**
  String get trustedUploadEntryButtonLabel;

  /// 错误标题
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get errorTitle;

  /// 会话未创建时的错误提示
  ///
  /// In zh, this message translates to:
  /// **'会话未创建'**
  String get trustedUploadSessionNotReadyMessage;

  /// Trusted upload 弹窗标题
  ///
  /// In zh, this message translates to:
  /// **'扫码上传'**
  String get trustedUploadDialogTitle;

  /// Trusted upload 说明文案
  ///
  /// In zh, this message translates to:
  /// **'后端可信上传：使用 signed upload、自动回拉入库'**
  String get trustedUploadDescription;

  /// Trusted upload 链接说明文案
  ///
  /// In zh, this message translates to:
  /// **'手机扫码或复制链接:'**
  String get trustedUploadCopyOrScanLabel;

  /// Trusted upload 网络连接提示
  ///
  /// In zh, this message translates to:
  /// **'请确保手机可以访问上方 URL 所在的桌面端网络地址。'**
  String get trustedUploadNetworkHint;

  /// 上传状态汇总标签：总数
  ///
  /// In zh, this message translates to:
  /// **'总计'**
  String get uploadStatusTotalLabel;

  /// 上传状态汇总标签：等待
  ///
  /// In zh, this message translates to:
  /// **'等待'**
  String get uploadStatusWaitingLabel;

  /// 上传状态汇总标签：上传中
  ///
  /// In zh, this message translates to:
  /// **'上传中'**
  String get uploadStatusUploadingLabel;

  /// 上传状态汇总标签：回拉中
  ///
  /// In zh, this message translates to:
  /// **'回拉中'**
  String get uploadStatusPullingLabel;

  /// No description provided for @setupPostgresTitle.
  ///
  /// In zh, this message translates to:
  /// **'PostgreSQL 配置'**
  String get setupPostgresTitle;

  /// No description provided for @setupPgvectorTitle.
  ///
  /// In zh, this message translates to:
  /// **'pgvector 检测'**
  String get setupPgvectorTitle;

  /// No description provided for @setupOpenAiTitle.
  ///
  /// In zh, this message translates to:
  /// **'大模型接口配置'**
  String get setupOpenAiTitle;

  /// No description provided for @setupLocalDataDirTitle.
  ///
  /// In zh, this message translates to:
  /// **'本地数据目录'**
  String get setupLocalDataDirTitle;

  /// No description provided for @setupSidecarServiceTitle.
  ///
  /// In zh, this message translates to:
  /// **'Sidecar 本地服务'**
  String get setupSidecarServiceTitle;

  /// No description provided for @setupItemTitle.
  ///
  /// In zh, this message translates to:
  /// **'配置项'**
  String get setupItemTitle;

  /// No description provided for @setupWaitingConfigLoad.
  ///
  /// In zh, this message translates to:
  /// **'等待配置读取'**
  String get setupWaitingConfigLoad;

  /// No description provided for @setupPending.
  ///
  /// In zh, this message translates to:
  /// **'待检测'**
  String get setupPending;

  /// No description provided for @setupHealthy.
  ///
  /// In zh, this message translates to:
  /// **'正常'**
  String get setupHealthy;

  /// No description provided for @setupNeedsAction.
  ///
  /// In zh, this message translates to:
  /// **'需处理'**
  String get setupNeedsAction;

  /// No description provided for @setupPurposeLabel.
  ///
  /// In zh, this message translates to:
  /// **'用途'**
  String get setupPurposeLabel;

  /// No description provided for @setupPurposePrefixAscii.
  ///
  /// In zh, this message translates to:
  /// **'用途:'**
  String get setupPurposePrefixAscii;

  /// No description provided for @setupPurposePrefixCn.
  ///
  /// In zh, this message translates to:
  /// **'用途：'**
  String get setupPurposePrefixCn;

  /// No description provided for @setupSystemConfigItemSummary.
  ///
  /// In zh, this message translates to:
  /// **'系统配置项。'**
  String get setupSystemConfigItemSummary;

  /// No description provided for @actionInstallAndConfigure.
  ///
  /// In zh, this message translates to:
  /// **'安装与配置'**
  String get actionInstallAndConfigure;

  /// No description provided for @actionStartSidecar.
  ///
  /// In zh, this message translates to:
  /// **'启动 Sidecar'**
  String get actionStartSidecar;

  /// No description provided for @actionConfigure.
  ///
  /// In zh, this message translates to:
  /// **'配置'**
  String get actionConfigure;

  /// No description provided for @actionConfigureDirectory.
  ///
  /// In zh, this message translates to:
  /// **'配置目录'**
  String get actionConfigureDirectory;

  /// No description provided for @actionEditConfig.
  ///
  /// In zh, this message translates to:
  /// **'修改配置'**
  String get actionEditConfig;

  /// No description provided for @actionOpenDirectory.
  ///
  /// In zh, this message translates to:
  /// **'打开目录'**
  String get actionOpenDirectory;

  /// No description provided for @actionRefreshChecks.
  ///
  /// In zh, this message translates to:
  /// **'刷新检测'**
  String get actionRefreshChecks;

  /// No description provided for @actionTest.
  ///
  /// In zh, this message translates to:
  /// **'测试'**
  String get actionTest;

  /// No description provided for @actionCheck.
  ///
  /// In zh, this message translates to:
  /// **'检测'**
  String get actionCheck;

  /// No description provided for @actionInstall.
  ///
  /// In zh, this message translates to:
  /// **'安装'**
  String get actionInstall;

  /// No description provided for @actionStart.
  ///
  /// In zh, this message translates to:
  /// **'启动'**
  String get actionStart;

  /// No description provided for @actionDirectory.
  ///
  /// In zh, this message translates to:
  /// **'目录'**
  String get actionDirectory;

  /// No description provided for @actionView.
  ///
  /// In zh, this message translates to:
  /// **'查看'**
  String get actionView;

  /// No description provided for @actionConfigurePathToken.
  ///
  /// In zh, this message translates to:
  /// **'__action__:配置'**
  String get actionConfigurePathToken;

  /// No description provided for @setupCompletePreviousStepFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先完成上一步配置'**
  String get setupCompletePreviousStepFirst;

  /// No description provided for @setupDirectoryCannotEdit.
  ///
  /// In zh, this message translates to:
  /// **'这个目录项暂时不能在桌面端修改'**
  String get setupDirectoryCannotEdit;

  /// No description provided for @setupNoConfigDialog.
  ///
  /// In zh, this message translates to:
  /// **'这个配置项暂无弹窗配置'**
  String get setupNoConfigDialog;

  /// No description provided for @setupNoAutoInstallFlow.
  ///
  /// In zh, this message translates to:
  /// **'这个配置项暂无自动安装流程'**
  String get setupNoAutoInstallFlow;

  /// No description provided for @setupHomebrewDirectoryNotWritable.
  ///
  /// In zh, this message translates to:
  /// **'Homebrew 目录不可写'**
  String get setupHomebrewDirectoryNotWritable;

  /// No description provided for @setupLocalServiceResponsibilities.
  ///
  /// In zh, this message translates to:
  /// **'KidMemory 的本地服务负责配置、检测和数据任务。通常会随应用自动准备。'**
  String get setupLocalServiceResponsibilities;

  /// No description provided for @setupOpenAiConfigSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'OpenAI 配置保存失败'**
  String get setupOpenAiConfigSaveFailed;

  /// No description provided for @setupOpenAiConfigSaved.
  ///
  /// In zh, this message translates to:
  /// **'OpenAI 配置已保存'**
  String get setupOpenAiConfigSaved;

  /// No description provided for @setupOpenAiConfigUpdated.
  ///
  /// In zh, this message translates to:
  /// **'OpenAI 配置已更新'**
  String get setupOpenAiConfigUpdated;

  /// No description provided for @setupOpenAiConfigUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'OpenAI 配置更新失败'**
  String get setupOpenAiConfigUpdateFailed;

  /// No description provided for @setupPostgresNotReadyNeedConfig.
  ///
  /// In zh, this message translates to:
  /// **'PostgreSQL 仍未就绪，安装 pgvector 前请先完成数据库配置'**
  String get setupPostgresNotReadyNeedConfig;

  /// No description provided for @setupPostgresHandledButSidecarNotStarted.
  ///
  /// In zh, this message translates to:
  /// **'PostgreSQL 已处理，但 Sidecar 未能启动'**
  String get setupPostgresHandledButSidecarNotStarted;

  /// No description provided for @setupPostgresConfigured.
  ///
  /// In zh, this message translates to:
  /// **'PostgreSQL 已配置完成'**
  String get setupPostgresConfigured;

  /// No description provided for @setupPostgresNotReadyAutoInstall.
  ///
  /// In zh, this message translates to:
  /// **'PostgreSQL 未就绪，自动执行 PostgreSQL 安装与配置'**
  String get setupPostgresNotReadyAutoInstall;

  /// No description provided for @setupPostgresNotReadyCheckConfigRetry.
  ///
  /// In zh, this message translates to:
  /// **'PostgreSQL 未就绪，请检查数据库配置后重试'**
  String get setupPostgresNotReadyCheckConfigRetry;

  /// No description provided for @setupPostgresNotReadyStartLocalService.
  ///
  /// In zh, this message translates to:
  /// **'PostgreSQL 还未就绪，请启动本机服务后重试'**
  String get setupPostgresNotReadyStartLocalService;

  /// No description provided for @setupStorageRestModeLabel.
  ///
  /// In zh, this message translates to:
  /// **'REST 方式（可选）'**
  String get setupStorageRestModeLabel;

  /// No description provided for @setupStorageS3ModeLabel.
  ///
  /// In zh, this message translates to:
  /// **'S3 方式（推荐）'**
  String get setupStorageS3ModeLabel;

  /// No description provided for @setupSidecarStarted.
  ///
  /// In zh, this message translates to:
  /// **'Sidecar 已启动'**
  String get setupSidecarStarted;

  /// No description provided for @setupSidecarStartedSchemaNotReady.
  ///
  /// In zh, this message translates to:
  /// **'Sidecar 已启动，schema 初始化未完成'**
  String get setupSidecarStartedSchemaNotReady;

  /// No description provided for @setupSidecarConnected.
  ///
  /// In zh, this message translates to:
  /// **'Sidecar 已连接'**
  String get setupSidecarConnected;

  /// No description provided for @setupSidecarStartFailed.
  ///
  /// In zh, this message translates to:
  /// **'Sidecar 未能启动'**
  String get setupSidecarStartFailed;

  /// No description provided for @setupSidecarStartFailedNodeOrBundled.
  ///
  /// In zh, this message translates to:
  /// **'Sidecar 未能启动，请检查 Node.js 或 bundled sidecar'**
  String get setupSidecarStartFailedNodeOrBundled;

  /// No description provided for @setupSidecarDisconnected.
  ///
  /// In zh, this message translates to:
  /// **'Sidecar 未连接'**
  String get setupSidecarDisconnected;

  /// No description provided for @setupStorageConfigTitle.
  ///
  /// In zh, this message translates to:
  /// **'Storage 配置'**
  String get setupStorageConfigTitle;

  /// No description provided for @setupStorageConfigSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'Supabase Storage 配置保存失败'**
  String get setupStorageConfigSaveFailed;

  /// No description provided for @setupStorageConfigSaved.
  ///
  /// In zh, this message translates to:
  /// **'Supabase Storage 配置已保存'**
  String get setupStorageConfigSaved;

  /// No description provided for @setupPgvectorInitFailed.
  ///
  /// In zh, this message translates to:
  /// **'pgvector 初始化失败'**
  String get setupPgvectorInitFailed;

  /// No description provided for @setupPgvectorInitFailedExtMissing.
  ///
  /// In zh, this message translates to:
  /// **'pgvector 初始化失败，请确认扩展已安装'**
  String get setupPgvectorInitFailedExtMissing;

  /// No description provided for @setupPgvectorNotReady.
  ///
  /// In zh, this message translates to:
  /// **'pgvector 尚未就绪'**
  String get setupPgvectorNotReady;

  /// No description provided for @setupPgvectorNotReadyInstallExtRetry.
  ///
  /// In zh, this message translates to:
  /// **'pgvector 尚未就绪，请安装扩展后重试'**
  String get setupPgvectorNotReadyInstallExtRetry;

  /// No description provided for @setupPgvectorReady.
  ///
  /// In zh, this message translates to:
  /// **'pgvector 已安装并通过检测'**
  String get setupPgvectorReady;

  /// No description provided for @setupPgvectorWaitForPostgres.
  ///
  /// In zh, this message translates to:
  /// **'pgvector 流程检测到 PostgreSQL 未就绪，自动联动执行 PostgreSQL 安装配置'**
  String get setupPgvectorWaitForPostgres;

  /// No description provided for @setupSchemaInitFailed.
  ///
  /// In zh, this message translates to:
  /// **'schema 初始化未成功'**
  String get setupSchemaInitFailed;

  /// No description provided for @setupSignedUrlDefaultHint.
  ///
  /// In zh, this message translates to:
  /// **'不改的话，默认就是 1 小时，填 3600 就可以。'**
  String get setupSignedUrlDefaultHint;

  /// No description provided for @setupLocalDataDirectoryDescription.
  ///
  /// In zh, this message translates to:
  /// **'为 KidMemory 提供核心数据库连接，保存孩子资料、素材和生成历史。'**
  String get setupLocalDataDirectoryDescription;

  /// No description provided for @actionSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get actionSave;

  /// No description provided for @actionSaveSettings.
  ///
  /// In zh, this message translates to:
  /// **'保存配置'**
  String get actionSaveSettings;

  /// No description provided for @agentSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'Agent 设置'**
  String get agentSettingsTitle;

  /// No description provided for @agentSettingsOpenAiDescription.
  ///
  /// In zh, this message translates to:
  /// **'配置 OpenAI Agent SDK 服务端点，用于生成儿童作品集。支持 OpenAI API 或兼容的本地服务。'**
  String get agentSettingsOpenAiDescription;

  /// No description provided for @agentSettingsSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'Agent SDK 配置'**
  String get agentSettingsSectionTitle;

  /// No description provided for @agentSettingsMissingConfigMessage.
  ///
  /// In zh, this message translates to:
  /// **'请填写完整的配置信息'**
  String get agentSettingsMissingConfigMessage;

  /// No description provided for @agentSettingsConnectionTestSuccess.
  ///
  /// In zh, this message translates to:
  /// **'连接测试成功'**
  String get agentSettingsConnectionTestSuccess;

  /// No description provided for @agentSettingsConnectionTestFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接测试失败'**
  String get agentSettingsConnectionTestFailed;

  /// No description provided for @agentSettingsSaveSuccess.
  ///
  /// In zh, this message translates to:
  /// **'Agent 配置已成功保存'**
  String get agentSettingsSaveSuccess;

  /// No description provided for @agentSettingsConfigNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'配置名称'**
  String get agentSettingsConfigNameLabel;

  /// No description provided for @agentSettingsNameHelper.
  ///
  /// In zh, this message translates to:
  /// **'用于在本机区分不同 Agent 配置'**
  String get agentSettingsNameHelper;

  /// No description provided for @agentSettingsBaseUrlHint.
  ///
  /// In zh, this message translates to:
  /// **'https://api.openai.com 或本地服务地址'**
  String get agentSettingsBaseUrlHint;

  /// No description provided for @agentSettingsBaseUrlHelper.
  ///
  /// In zh, this message translates to:
  /// **'支持 OpenAI API 或兼容的本地 Agent SDK 服务'**
  String get agentSettingsBaseUrlHelper;

  /// No description provided for @agentSettingsApiKeyHint.
  ///
  /// In zh, this message translates to:
  /// **'sk-... 或本地服务的认证密钥'**
  String get agentSettingsApiKeyHint;

  /// No description provided for @agentSettingsApiKeyHelper.
  ///
  /// In zh, this message translates to:
  /// **'用于认证的 API 密钥'**
  String get agentSettingsApiKeyHelper;

  /// No description provided for @agentSettingsModelLabel.
  ///
  /// In zh, this message translates to:
  /// **'模型名称'**
  String get agentSettingsModelLabel;

  /// No description provided for @agentSettingsModelHint.
  ///
  /// In zh, this message translates to:
  /// **'gpt-4, gpt-3.5-turbo 等'**
  String get agentSettingsModelHint;

  /// No description provided for @agentSettingsModelDefaultHint.
  ///
  /// In zh, this message translates to:
  /// **'留空将使用默认模型 gpt-4'**
  String get agentSettingsModelDefaultHint;

  /// No description provided for @agentSettingsUsageTitle.
  ///
  /// In zh, this message translates to:
  /// **'使用说明'**
  String get agentSettingsUsageTitle;

  /// No description provided for @agentSettingsOpenAiStepTitle.
  ///
  /// In zh, this message translates to:
  /// **'1. OpenAI API'**
  String get agentSettingsOpenAiStepTitle;

  /// No description provided for @agentSettingsOpenAiStepDescription.
  ///
  /// In zh, this message translates to:
  /// **'使用官方 OpenAI API 服务'**
  String get agentSettingsOpenAiStepDescription;

  /// No description provided for @agentSettingsLocalStepTitle.
  ///
  /// In zh, this message translates to:
  /// **'2. 本地服务'**
  String get agentSettingsLocalStepTitle;

  /// No description provided for @agentSettingsLocalStepDescription.
  ///
  /// In zh, this message translates to:
  /// **'运行兼容 OpenAI API 的本地 Agent SDK 服务'**
  String get agentSettingsLocalStepDescription;

  /// No description provided for @agentSettingsCustomEndpointStepTitle.
  ///
  /// In zh, this message translates to:
  /// **'3. 自定义端点'**
  String get agentSettingsCustomEndpointStepTitle;

  /// No description provided for @agentSettingsCustomEndpointStepDescription.
  ///
  /// In zh, this message translates to:
  /// **'支持任何兼容 OpenAI API 格式的服务'**
  String get agentSettingsCustomEndpointStepDescription;

  /// No description provided for @setupStorageSectionIntro.
  ///
  /// In zh, this message translates to:
  /// **'先用 S3 方式最省事：接口地址、区域、桶名、Access Key 和 Secret Key 都在 Supabase 控制台里能找到。bucket 建议保持私有，KidMemory 会在分享时自动生成带有效期的链接。'**
  String get setupStorageSectionIntro;

  /// No description provided for @setupStoragePublicPrefixHint.
  ///
  /// In zh, this message translates to:
  /// **'公开桶可填完整对象前缀'**
  String get setupStoragePublicPrefixHint;

  /// No description provided for @setupStoragePublicAccessPrefixLabel.
  ///
  /// In zh, this message translates to:
  /// **'公开访问前缀（可选）'**
  String get setupStoragePublicAccessPrefixLabel;

  /// No description provided for @setupBuiltinPostgresNoPgvector.
  ///
  /// In zh, this message translates to:
  /// **'内置 PostgreSQL runtime 未包含 pgvector 扩展'**
  String get setupBuiltinPostgresNoPgvector;

  /// No description provided for @setupBuiltinPostgresNoPgvectorInstruction.
  ///
  /// In zh, this message translates to:
  /// **'内置 PostgreSQL runtime 未包含 pgvector 扩展，请补齐后重试。'**
  String get setupBuiltinPostgresNoPgvectorInstruction;

  /// No description provided for @setupCreateLocalDatabase.
  ///
  /// In zh, this message translates to:
  /// **'创建 KidMemory 本地资料库'**
  String get setupCreateLocalDatabase;

  /// No description provided for @setupInitStarted.
  ///
  /// In zh, this message translates to:
  /// **'初始化'**
  String get setupInitStarted;

  /// No description provided for @setupInitDatabaseSchema.
  ///
  /// In zh, this message translates to:
  /// **'初始化 KidMemory 数据库结构'**
  String get setupInitDatabaseSchema;

  /// No description provided for @setupInitBuiltinDataDir.
  ///
  /// In zh, this message translates to:
  /// **'初始化内置 PostgreSQL 数据目录'**
  String get setupInitBuiltinDataDir;

  /// No description provided for @setupRegionLabel.
  ///
  /// In zh, this message translates to:
  /// **'区域'**
  String get setupRegionLabel;

  /// No description provided for @setupStorageApiKeyHelpServiceRole.
  ///
  /// In zh, this message translates to:
  /// **'去 Supabase 的 Settings > API Keys 里找 service_role / secret key。'**
  String get setupStorageApiKeyHelpServiceRole;

  /// No description provided for @setupStorageBucketNameHint.
  ///
  /// In zh, this message translates to:
  /// **'去 Supabase 的 Storage > Buckets 里看 bucket 名。'**
  String get setupStorageBucketNameHint;

  /// No description provided for @setupStorageS3AccessKeyIdHint.
  ///
  /// In zh, this message translates to:
  /// **'去 Supabase 的 Storage > Settings > S3 说明页复制 Access Key ID。'**
  String get setupStorageS3AccessKeyIdHint;

  /// No description provided for @setupStorageS3SecretKeyHint.
  ///
  /// In zh, this message translates to:
  /// **'去 Supabase 的 Storage > Settings > S3 说明页复制 Secret Access Key。'**
  String get setupStorageS3SecretKeyHint;

  /// No description provided for @setupStorageS3EndpointHint.
  ///
  /// In zh, this message translates to:
  /// **'去 Supabase 的 Storage > Settings > S3 说明页复制 endpoint。'**
  String get setupStorageS3EndpointHint;

  /// No description provided for @setupStorageProjectUrlHint.
  ///
  /// In zh, this message translates to:
  /// **'去 Supabase 项目首页或 Settings > API 里找 SUPABASE_URL。'**
  String get setupStorageProjectUrlHint;

  /// No description provided for @actionCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get actionCancel;

  /// No description provided for @setupPublicBucketOptionalHint.
  ///
  /// In zh, this message translates to:
  /// **'只有公开桶才需要；私有桶可以留空，分享时会自动生成签名链接。'**
  String get setupPublicBucketOptionalHint;

  /// No description provided for @setupStatusStarting.
  ///
  /// In zh, this message translates to:
  /// **'启动中'**
  String get setupStatusStarting;

  /// No description provided for @setupStartBuiltinPostgres.
  ///
  /// In zh, this message translates to:
  /// **'启动内置 PostgreSQL 服务'**
  String get setupStartBuiltinPostgres;

  /// No description provided for @setupEnableVectorExtension.
  ///
  /// In zh, this message translates to:
  /// **'启用 vector 扩展'**
  String get setupEnableVectorExtension;

  /// No description provided for @setupEnableVectorExtensionAndInit.
  ///
  /// In zh, this message translates to:
  /// **'启用 vector 扩展并初始化 schema'**
  String get setupEnableVectorExtensionAndInit;

  /// No description provided for @setupRecheckPostgresConnection.
  ///
  /// In zh, this message translates to:
  /// **'复查 PostgreSQL 连接'**
  String get setupRecheckPostgresConnection;

  /// No description provided for @setupRecheckPgvectorExtension.
  ///
  /// In zh, this message translates to:
  /// **'复查 pgvector 扩展'**
  String get setupRecheckPgvectorExtension;

  /// No description provided for @setupAutoUseAutoValue.
  ///
  /// In zh, this message translates to:
  /// **'大多数项目直接填 auto 就行。'**
  String get setupAutoUseAutoValue;

  /// No description provided for @setupInstalling.
  ///
  /// In zh, this message translates to:
  /// **'安装中'**
  String get setupInstalling;

  /// No description provided for @setupInstallCompleted.
  ///
  /// In zh, this message translates to:
  /// **'安装完成'**
  String get setupInstallCompleted;

  /// No description provided for @setupIntroAiStorageMessage.
  ///
  /// In zh, this message translates to:
  /// **'完成以下配置以启用 AI 能力与本地数据存储。我们会帮你检测环境并确保一切就绪。'**
  String get setupIntroAiStorageMessage;

  /// No description provided for @setupChosen.
  ///
  /// In zh, this message translates to:
  /// **'已选择'**
  String get setupChosen;

  /// No description provided for @setupConfigured.
  ///
  /// In zh, this message translates to:
  /// **'已配置'**
  String get setupConfigured;

  /// No description provided for @setupStartPostgresWorkflow.
  ///
  /// In zh, this message translates to:
  /// **'开始 PostgreSQL 安装与配置流程'**
  String get setupStartPostgresWorkflow;

  /// No description provided for @setupOpenApiKeysHelp.
  ///
  /// In zh, this message translates to:
  /// **'打开 API Keys 官方说明'**
  String get setupOpenApiKeysHelp;

  /// No description provided for @setupOpenS3CompatibilityHelp.
  ///
  /// In zh, this message translates to:
  /// **'打开 S3 兼容性说明'**
  String get setupOpenS3CompatibilityHelp;

  /// No description provided for @setupOpenS3AuthHelp.
  ///
  /// In zh, this message translates to:
  /// **'打开 S3 认证说明'**
  String get setupOpenS3AuthHelp;

  /// No description provided for @setupOpenSupabaseApiKeysHelp.
  ///
  /// In zh, this message translates to:
  /// **'打开 Supabase API Keys 官方说明'**
  String get setupOpenSupabaseApiKeysHelp;

  /// No description provided for @setupOpenSupabaseS3Docs.
  ///
  /// In zh, this message translates to:
  /// **'打开 Supabase S3 官方说明'**
  String get setupOpenSupabaseS3Docs;

  /// No description provided for @setupOpenBucketsHelp.
  ///
  /// In zh, this message translates to:
  /// **'打开 buckets 官方说明'**
  String get setupOpenBucketsHelp;

  /// No description provided for @setupStorageEndpointLabel.
  ///
  /// In zh, this message translates to:
  /// **'接口地址'**
  String get setupStorageEndpointLabel;

  /// No description provided for @setupOpenAiDescription.
  ///
  /// In zh, this message translates to:
  /// **'提供文本生成、标签与提示词能力。请配置 Base URL、模型与 API Key。'**
  String get setupOpenAiDescription;

  /// No description provided for @setupInitDatabaseSchemaFailed.
  ///
  /// In zh, this message translates to:
  /// **'数据库结构初始化失败'**
  String get setupInitDatabaseSchemaFailed;

  /// No description provided for @actionShow.
  ///
  /// In zh, this message translates to:
  /// **'显示'**
  String get actionShow;

  /// No description provided for @setupNoPostgresRuntimeFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到可用 PostgreSQL runtime，请确认 Resources/postgres 或设置 KIDMEMORY_POSTGRES_RUNTIME_DIR。'**
  String get setupNoPostgresRuntimeFound;

  /// No description provided for @setupPostgresRuntimeNotDetected.
  ///
  /// In zh, this message translates to:
  /// **'未检测到 PostgreSQL runtime，请确认 Resources/postgres 或仓库 third_party/postgres/macos 可用。'**
  String get setupPostgresRuntimeNotDetected;

  /// No description provided for @setupPostgresNotDetected.
  ///
  /// In zh, this message translates to:
  /// **'未检测到 PostgreSQL，请确认本机服务已安装并启动'**
  String get setupPostgresNotDetected;

  /// No description provided for @setupBundledPostgresRuntimeMissing.
  ///
  /// In zh, this message translates to:
  /// **'未检测到内置 PostgreSQL runtime'**
  String get setupBundledPostgresRuntimeMissing;

  /// No description provided for @setupBundledPostgresRuntimeReleaseRequired.
  ///
  /// In zh, this message translates to:
  /// **'未检测到内置 PostgreSQL runtime，请使用带 runtime 的 Release 包。'**
  String get setupBundledPostgresRuntimeReleaseRequired;

  /// No description provided for @setupNotConfigured.
  ///
  /// In zh, this message translates to:
  /// **'未配置'**
  String get setupNotConfigured;

  /// No description provided for @setupLocalPathSelected.
  ///
  /// In zh, this message translates to:
  /// **'本地已选择'**
  String get setupLocalPathSelected;

  /// No description provided for @setupLocalPathUpdated.
  ///
  /// In zh, this message translates to:
  /// **'本地数据目录已更新'**
  String get setupLocalPathUpdated;

  /// No description provided for @setupLocalPathUpdatedSidecarPending.
  ///
  /// In zh, this message translates to:
  /// **'本地数据目录已更新；sidecar 启动后会继续读取配置'**
  String get setupLocalPathUpdatedSidecarPending;

  /// No description provided for @setupApiKeyVisibilityHint.
  ///
  /// In zh, this message translates to:
  /// **'本地明文保存，点击眼睛可显示/隐藏'**
  String get setupApiKeyVisibilityHint;

  /// No description provided for @setupLocalServicePreparing.
  ///
  /// In zh, this message translates to:
  /// **'本地服务准备中'**
  String get setupLocalServicePreparing;

  /// No description provided for @setupVerifyBuiltinPgvectorExtension.
  ///
  /// In zh, this message translates to:
  /// **'校验内置 pgvector 扩展'**
  String get setupVerifyBuiltinPgvectorExtension;

  /// No description provided for @setupBucketNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'桶名'**
  String get setupBucketNameLabel;

  /// No description provided for @setupCheckPostgresService.
  ///
  /// In zh, this message translates to:
  /// **'检测 PostgreSQL 服务'**
  String get setupCheckPostgresService;

  /// No description provided for @setupCheckPostgresConnection.
  ///
  /// In zh, this message translates to:
  /// **'检测 PostgreSQL 连接'**
  String get setupCheckPostgresConnection;

  /// No description provided for @setupChecking.
  ///
  /// In zh, this message translates to:
  /// **'检测中'**
  String get setupChecking;

  /// No description provided for @setupRuntimeFoundInitialize.
  ///
  /// In zh, this message translates to:
  /// **'检测到内置 PostgreSQL runtime，开始初始化。'**
  String get setupRuntimeFoundInitialize;

  /// No description provided for @setupCheckRequestNoResult.
  ///
  /// In zh, this message translates to:
  /// **'检测请求已发出，但 sidecar 未返回结果'**
  String get setupCheckRequestNoResult;

  /// No description provided for @setupDownloading.
  ///
  /// In zh, this message translates to:
  /// **'正在下载...'**
  String get setupDownloading;

  /// No description provided for @setupSidecarStarting.
  ///
  /// In zh, this message translates to:
  /// **'正在启动 Sidecar...'**
  String get setupSidecarStarting;

  /// No description provided for @setupInstallingSoftware.
  ///
  /// In zh, this message translates to:
  /// **'正在安装...'**
  String get setupInstallingSoftware;

  /// No description provided for @setupTestingConnection.
  ///
  /// In zh, this message translates to:
  /// **'正在测试连接...'**
  String get setupTestingConnection;

  /// No description provided for @setupFetchingResources.
  ///
  /// In zh, this message translates to:
  /// **'正在获取资源...'**
  String get setupFetchingResources;

  /// No description provided for @setupConfiguring.
  ///
  /// In zh, this message translates to:
  /// **'正在配置...'**
  String get setupConfiguring;

  /// No description provided for @setupTestFailed.
  ///
  /// In zh, this message translates to:
  /// **'测试失败'**
  String get setupTestFailed;

  /// No description provided for @actionTestConnection.
  ///
  /// In zh, this message translates to:
  /// **'测试连接'**
  String get actionTestConnection;

  /// No description provided for @setupTestConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'测试连接失败'**
  String get setupTestConnectionFailed;

  /// No description provided for @setupTestConnectionSuccess.
  ///
  /// In zh, this message translates to:
  /// **'测试连接成功'**
  String get setupTestConnectionSuccess;

  /// No description provided for @setupEnvironmentReady.
  ///
  /// In zh, this message translates to:
  /// **'环境已就绪'**
  String get setupEnvironmentReady;

  /// No description provided for @setupEnvironmentChecking.
  ///
  /// In zh, this message translates to:
  /// **'环境检测中'**
  String get setupEnvironmentChecking;

  /// No description provided for @setupEnvironmentReadyForCreation.
  ///
  /// In zh, this message translates to:
  /// **'环境检测已通过，可进入正式创作流程。'**
  String get setupEnvironmentReadyForCreation;

  /// No description provided for @setupCheckResultFromSidecar.
  ///
  /// In zh, this message translates to:
  /// **'检测结果来自 sidecar'**
  String get setupCheckResultFromSidecar;

  /// No description provided for @setupConnectingLocalService.
  ///
  /// In zh, this message translates to:
  /// **'正在连接 KidMemory 本地服务'**
  String get setupConnectingLocalService;

  /// No description provided for @setupExportDescriptionHint.
  ///
  /// In zh, this message translates to:
  /// **'用于保存导出结果与分享文件。'**
  String get setupExportDescriptionHint;

  /// No description provided for @setupSignedUrlTTLLabel.
  ///
  /// In zh, this message translates to:
  /// **'签名链接有效期（秒）'**
  String get setupSignedUrlTTLLabel;

  /// No description provided for @setupPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get setupPageTitle;

  /// No description provided for @setupHomebrewPermissionRetryHint.
  ///
  /// In zh, this message translates to:
  /// **'请修复 Homebrew 权限后重试。'**
  String get setupHomebrewPermissionRetryHint;

  /// No description provided for @setupConfigureStorageFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先配置 Supabase REST 或 S3 所需参数'**
  String get setupConfigureStorageFirst;

  /// No description provided for @setupHomebrewPermissionCommandHint.
  ///
  /// In zh, this message translates to:
  /// **'请在终端执行以下命令修复权限后，再回到 KidMemory 重试：'**
  String get setupHomebrewPermissionCommandHint;

  /// No description provided for @setupSidecarConfigUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'读取 sidecar 配置失败，初始化未完成。'**
  String get setupSidecarConfigUnavailable;

  /// No description provided for @setupInputApiKey.
  ///
  /// In zh, this message translates to:
  /// **'输入 API Key'**
  String get setupInputApiKey;

  /// No description provided for @setupInputAccessKeyId.
  ///
  /// In zh, this message translates to:
  /// **'输入或粘贴 Access Key ID'**
  String get setupInputAccessKeyId;

  /// No description provided for @setupInputSecretAccessKey.
  ///
  /// In zh, this message translates to:
  /// **'输入或粘贴 Secret Access Key'**
  String get setupInputSecretAccessKey;

  /// No description provided for @setupInputServiceRoleKey.
  ///
  /// In zh, this message translates to:
  /// **'输入或粘贴 Service Role Key'**
  String get setupInputServiceRoleKey;

  /// No description provided for @setupStorageDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'配置 Supabase Storage'**
  String get setupStorageDialogTitle;

  /// No description provided for @setupOpenAiDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'配置大模型接口'**
  String get setupOpenAiDialogTitle;

  /// No description provided for @actionReconnect.
  ///
  /// In zh, this message translates to:
  /// **'重新连接'**
  String get actionReconnect;

  /// No description provided for @actionHide.
  ///
  /// In zh, this message translates to:
  /// **'隐藏'**
  String get actionHide;

  /// No description provided for @setupCheckDependencyHint.
  ///
  /// In zh, this message translates to:
  /// **'集中检查初始化依赖是否可用。'**
  String get setupCheckDependencyHint;

  /// No description provided for @setupNeedsConfiguration.
  ///
  /// In zh, this message translates to:
  /// **'需配置'**
  String get setupNeedsConfiguration;

  /// No description provided for @setupProjectUrlLabel.
  ///
  /// In zh, this message translates to:
  /// **'项目地址'**
  String get setupProjectUrlLabel;

  /// No description provided for @setupTestCleanupFailedSuffix.
  ///
  /// In zh, this message translates to:
  /// **'，测试对象清理失败'**
  String get setupTestCleanupFailedSuffix;

  /// sampleDatasetPageTitle
  ///
  /// In zh, this message translates to:
  /// **'示例数据集'**
  String get sampleDatasetPageTitle;

  /// sampleDatasetPageSubtitle
  ///
  /// In zh, this message translates to:
  /// **'使用隐私安全的虚拟素材，快速体验 KidMemory 的素材库、创作台和导出流程。'**
  String get sampleDatasetPageSubtitle;

  /// sampleDatasetBackTooltip
  ///
  /// In zh, this message translates to:
  /// **'返回孩子档案'**
  String get sampleDatasetBackTooltip;

  /// contentMetricTotalLabel
  ///
  /// In zh, this message translates to:
  /// **'素材总数'**
  String get contentMetricTotalLabel;

  /// contentCategoryArtworkLabel
  ///
  /// In zh, this message translates to:
  /// **'儿童画'**
  String get contentCategoryArtworkLabel;

  /// contentCategoryCraftLabel
  ///
  /// In zh, this message translates to:
  /// **'手工作品'**
  String get contentCategoryCraftLabel;

  /// contentLicenseLabel
  ///
  /// In zh, this message translates to:
  /// **'素材许可'**
  String get contentLicenseLabel;

  /// contentAssetTypePhotoLabel
  ///
  /// In zh, this message translates to:
  /// **'照片'**
  String get contentAssetTypePhotoLabel;

  /// assetLibrarySearchHintText
  ///
  /// In zh, this message translates to:
  /// **'搜索素材、标签、描述...'**
  String get assetLibrarySearchHintText;

  /// assetLibrarySearchingLabel
  ///
  /// In zh, this message translates to:
  /// **'搜索中'**
  String get assetLibrarySearchingLabel;

  /// assetLibrarySearchButtonLabel
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get assetLibrarySearchButtonLabel;

  /// assetLibrarySmartPickLabel
  ///
  /// In zh, this message translates to:
  /// **'帮我挑素材'**
  String get assetLibrarySmartPickLabel;

  /// assetLibrarySmartOrganizeLabel
  ///
  /// In zh, this message translates to:
  /// **'AI 帮我整理素材'**
  String get assetLibrarySmartOrganizeLabel;

  /// assetLibraryImportPhotoLabel
  ///
  /// In zh, this message translates to:
  /// **'导入图片'**
  String get assetLibraryImportPhotoLabel;

  /// assetLibraryImportFolderLabel
  ///
  /// In zh, this message translates to:
  /// **'导入文件夹'**
  String get assetLibraryImportFolderLabel;

  /// assetLibraryImportDescriptionText
  ///
  /// In zh, this message translates to:
  /// **'导入本地图片、整个文件夹，或把文件拖拽到素材库后，这里会显示真实缩略图和 metadata 编辑入口。'**
  String get assetLibraryImportDescriptionText;

  /// assetLibrarySortLabel
  ///
  /// In zh, this message translates to:
  /// **'排序'**
  String get assetLibrarySortLabel;

  /// assetLibraryIndexRefreshingLabel
  ///
  /// In zh, this message translates to:
  /// **'索引刷新中'**
  String get assetLibraryIndexRefreshingLabel;

  /// assetLibraryRefreshIndexLabel
  ///
  /// In zh, this message translates to:
  /// **'刷新索引'**
  String get assetLibraryRefreshIndexLabel;

  /// assetLibraryChildLabel
  ///
  /// In zh, this message translates to:
  /// **'孩子'**
  String get assetLibraryChildLabel;

  /// assetLibraryNoChildProfileText
  ///
  /// In zh, this message translates to:
  /// **'暂无孩子档案'**
  String get assetLibraryNoChildProfileText;

  /// assetLibraryClearSelectionLabel
  ///
  /// In zh, this message translates to:
  /// **'取消选择'**
  String get assetLibraryClearSelectionLabel;

  /// assetLibraryClearSearchLabel
  ///
  /// In zh, this message translates to:
  /// **'清空搜索'**
  String get assetLibraryClearSearchLabel;

  /// assetLibraryClearSearchActionLabel
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get assetLibraryClearSearchActionLabel;

  /// assetLibraryBatchGeneratePictureBookLabel
  ///
  /// In zh, this message translates to:
  /// **'生成绘本'**
  String get assetLibraryBatchGeneratePictureBookLabel;

  /// assetLibraryBatchGenerateVideoLabel
  ///
  /// In zh, this message translates to:
  /// **'生成回忆视频'**
  String get assetLibraryBatchGenerateVideoLabel;

  /// assetLibraryBatchGenerateAlbumLabel
  ///
  /// In zh, this message translates to:
  /// **'生成纪念册'**
  String get assetLibraryBatchGenerateAlbumLabel;

  /// assetLibraryGoToGenerateLabel
  ///
  /// In zh, this message translates to:
  /// **'去生成作品集'**
  String get assetLibraryGoToGenerateLabel;

  /// assetLibraryBatchDeletingLabel
  ///
  /// In zh, this message translates to:
  /// **'删除中...'**
  String get assetLibraryBatchDeletingLabel;

  /// assetLibraryBatchDeleteButtonLabel
  ///
  /// In zh, this message translates to:
  /// **'批量删除'**
  String get assetLibraryBatchDeleteButtonLabel;

  /// assetLibraryEmptyLibraryTitle
  ///
  /// In zh, this message translates to:
  /// **'还没有素材'**
  String get assetLibraryEmptyLibraryTitle;

  /// assetLibraryNoSelectedAssetsText
  ///
  /// In zh, this message translates to:
  /// **'选择一个素材'**
  String get assetLibraryNoSelectedAssetsText;

  /// assetLibraryEmptySearchTitle
  ///
  /// In zh, this message translates to:
  /// **'没有找到匹配素材'**
  String get assetLibraryEmptySearchTitle;

  /// assetLibrarySearchFallbackHint
  ///
  /// In zh, this message translates to:
  /// **'试试换个关键词，或让 Agent 帮你挑选相关素材。'**
  String get assetLibrarySearchFallbackHint;

  /// assetLibrarySelectAssetTitle
  ///
  /// In zh, this message translates to:
  /// **'选择素材后会在这里汇总。'**
  String get assetLibrarySelectAssetTitle;

  /// assetLibraryInspectorHintText
  ///
  /// In zh, this message translates to:
  /// **'在这里查看和编辑标题、标签、描述，也可以让 Agent 帮你整理素材。'**
  String get assetLibraryInspectorHintText;

  /// sampleDatasetInfoCardTitle
  ///
  /// In zh, this message translates to:
  /// **'数据说明'**
  String get sampleDatasetInfoCardTitle;

  /// sampleDatasetInfoCardDescription
  ///
  /// In zh, this message translates to:
  /// **'虚拟脱敏素材，仅用于功能演示。可随时重置为干净状态。'**
  String get sampleDatasetInfoCardDescription;

  /// sampleDatasetImportStepsTitle
  ///
  /// In zh, this message translates to:
  /// **'导入步骤'**
  String get sampleDatasetImportStepsTitle;

  /// sampleDatasetImportStepsDescription
  ///
  /// In zh, this message translates to:
  /// **'确认数据，点击导入，等待完成，然后继续探索生成流程。'**
  String get sampleDatasetImportStepsDescription;

  /// sampleDatasetExpectedOutputTitle
  ///
  /// In zh, this message translates to:
  /// **'预期输出'**
  String get sampleDatasetExpectedOutputTitle;

  /// sampleDatasetExpectedOutputDescription
  ///
  /// In zh, this message translates to:
  /// **'手动导入素材与标签后，可继续体验创作台与样例 PDF。'**
  String get sampleDatasetExpectedOutputDescription;

  /// sampleDatasetAfterImportDescriptionTitle
  ///
  /// In zh, this message translates to:
  /// **'导入后将包含'**
  String get sampleDatasetAfterImportDescriptionTitle;

  /// sampleDatasetImportingStatusTitle
  ///
  /// In zh, this message translates to:
  /// **'正在导入示例数据...'**
  String get sampleDatasetImportingStatusTitle;

  /// sampleDatasetImportingStatusDescription
  ///
  /// In zh, this message translates to:
  /// **'创建示例孩子档案、导入示例素材并写入标签。'**
  String get sampleDatasetImportingStatusDescription;

  /// sampleDatasetImportingActionLabel
  ///
  /// In zh, this message translates to:
  /// **'导入中...'**
  String get sampleDatasetImportingActionLabel;

  /// sampleDatasetViewPdfLabel
  ///
  /// In zh, this message translates to:
  /// **'查看示例 PDF'**
  String get sampleDatasetViewPdfLabel;

  /// sampleDatasetNotImportedTitle
  ///
  /// In zh, this message translates to:
  /// **'状态：未导入'**
  String get sampleDatasetNotImportedTitle;

  /// sampleDatasetImportInstructionText
  ///
  /// In zh, this message translates to:
  /// **'点击导入后，示例素材会写入本地数据库。'**
  String get sampleDatasetImportInstructionText;

  /// sampleDatasetImportButtonLabel
  ///
  /// In zh, this message translates to:
  /// **'导入示例数据集'**
  String get sampleDatasetImportButtonLabel;

  /// sampleDatasetBrowseAssetsLabel
  ///
  /// In zh, this message translates to:
  /// **'浏览示例素材'**
  String get sampleDatasetBrowseAssetsLabel;

  /// sampleDatasetGenerateSampleBookLabel
  ///
  /// In zh, this message translates to:
  /// **'生成示例绘本'**
  String get sampleDatasetGenerateSampleBookLabel;

  /// sampleDatasetImportedTitle
  ///
  /// In zh, this message translates to:
  /// **'示例数据已导入'**
  String get sampleDatasetImportedTitle;

  /// sampleDatasetImportedStatusText
  ///
  /// In zh, this message translates to:
  /// **'你可以继续浏览示例素材，或体验生成流程。'**
  String get sampleDatasetImportedStatusText;

  /// sampleDatasetResetDataLabel
  ///
  /// In zh, this message translates to:
  /// **'重置数据'**
  String get sampleDatasetResetDataLabel;

  /// sampleDatasetResetDataHint
  ///
  /// In zh, this message translates to:
  /// **'请检查本地数据库和示例素材文件。'**
  String get sampleDatasetResetDataHint;

  /// sampleDatasetRetryImportButtonLabel
  ///
  /// In zh, this message translates to:
  /// **'重试导入'**
  String get sampleDatasetRetryImportButtonLabel;

  /// sampleDatasetImportFailedTitle
  ///
  /// In zh, this message translates to:
  /// **'导入失败'**
  String get sampleDatasetImportFailedTitle;

  /// sampleDatasetPlaceholderSunlightGardenLabel
  ///
  /// In zh, this message translates to:
  /// **'阳光花园'**
  String get sampleDatasetPlaceholderSunlightGardenLabel;

  /// sampleDatasetPlaceholderGrassFieldLabel
  ///
  /// In zh, this message translates to:
  /// **'草地男孩'**
  String get sampleDatasetPlaceholderGrassFieldLabel;

  /// sampleDatasetPlaceholderBirthdayCakeLabel
  ///
  /// In zh, this message translates to:
  /// **'生日蛋糕'**
  String get sampleDatasetPlaceholderBirthdayCakeLabel;

  /// sampleDatasetPlaceholderBirthdayBoyLabel
  ///
  /// In zh, this message translates to:
  /// **'生日男孩'**
  String get sampleDatasetPlaceholderBirthdayBoyLabel;

  /// sampleDatasetPlaceholderOceanWorldLabel
  ///
  /// In zh, this message translates to:
  /// **'海底世界'**
  String get sampleDatasetPlaceholderOceanWorldLabel;

  /// sampleDatasetPlaceholderDinosaurWorldLabel
  ///
  /// In zh, this message translates to:
  /// **'恐龙世界'**
  String get sampleDatasetPlaceholderDinosaurWorldLabel;

  /// sampleDatasetPlaceholderHappinessFamilyLabel
  ///
  /// In zh, this message translates to:
  /// **'幸福一家'**
  String get sampleDatasetPlaceholderHappinessFamilyLabel;

  /// sampleDatasetPlaceholderDrawingLabel
  ///
  /// In zh, this message translates to:
  /// **'小熊画'**
  String get sampleDatasetPlaceholderDrawingLabel;

  /// sampleDatasetPlaceholderSunlightGardenPath
  ///
  /// In zh, this message translates to:
  /// **'asset://assets/sample_dataset/raster/阳光花园.png'**
  String get sampleDatasetPlaceholderSunlightGardenPath;

  /// sampleDatasetPlaceholderGrassFieldPath
  ///
  /// In zh, this message translates to:
  /// **'asset://assets/sample_dataset/raster/草地男孩.png'**
  String get sampleDatasetPlaceholderGrassFieldPath;

  /// sampleDatasetPlaceholderBirthdayCakePath
  ///
  /// In zh, this message translates to:
  /// **'asset://assets/sample_dataset/raster/生日蛋糕.png'**
  String get sampleDatasetPlaceholderBirthdayCakePath;

  /// sampleDatasetPlaceholderBirthdayBoyPath
  ///
  /// In zh, this message translates to:
  /// **'asset://assets/sample_dataset/raster/生日男孩.png'**
  String get sampleDatasetPlaceholderBirthdayBoyPath;

  /// sampleDatasetPlaceholderOceanWorldPath
  ///
  /// In zh, this message translates to:
  /// **'asset://assets/sample_dataset/raster/海底世界.png'**
  String get sampleDatasetPlaceholderOceanWorldPath;

  /// sampleDatasetPlaceholderDinosaurWorldPath
  ///
  /// In zh, this message translates to:
  /// **'asset://assets/sample_dataset/raster/恐龙世界.png'**
  String get sampleDatasetPlaceholderDinosaurWorldPath;

  /// sampleDatasetPlaceholderHappinessFamilyPath
  ///
  /// In zh, this message translates to:
  /// **'asset://assets/sample_dataset/raster/幸福一家.png'**
  String get sampleDatasetPlaceholderHappinessFamilyPath;

  /// sampleDatasetPlaceholderDrawingPath
  ///
  /// In zh, this message translates to:
  /// **'asset://assets/sample_dataset/raster/小熊画.png'**
  String get sampleDatasetPlaceholderDrawingPath;

  /// contentPreparingStatusLabel
  ///
  /// In zh, this message translates to:
  /// **'正在准备...'**
  String get contentPreparingStatusLabel;

  /// contentProcessingStatusLabel
  ///
  /// In zh, this message translates to:
  /// **'正在处理中...'**
  String get contentProcessingStatusLabel;

  /// contentNeedsConfigurationLabel
  ///
  /// In zh, this message translates to:
  /// **'需配置'**
  String get contentNeedsConfigurationLabel;

  /// contentNotConfiguredLabel
  ///
  /// In zh, this message translates to:
  /// **'未配置'**
  String get contentNotConfiguredLabel;

  /// contentDisconnectedLabel
  ///
  /// In zh, this message translates to:
  /// **'未连接'**
  String get contentDisconnectedLabel;

  /// contentWaitingLabel
  ///
  /// In zh, this message translates to:
  /// **'准备中'**
  String get contentWaitingLabel;

  /// contentTestLabel
  ///
  /// In zh, this message translates to:
  /// **'测试'**
  String get contentTestLabel;

  /// contentCheckLabel
  ///
  /// In zh, this message translates to:
  /// **'检测'**
  String get contentCheckLabel;

  /// contentConfigureLabel
  ///
  /// In zh, this message translates to:
  /// **'配置'**
  String get contentConfigureLabel;

  /// contentModifyLabel
  ///
  /// In zh, this message translates to:
  /// **'修改'**
  String get contentModifyLabel;

  /// contentDirectoryLabel
  ///
  /// In zh, this message translates to:
  /// **'目录'**
  String get contentDirectoryLabel;

  /// contentConnectLabel
  ///
  /// In zh, this message translates to:
  /// **'连接'**
  String get contentConnectLabel;

  /// contentModelLabel
  ///
  /// In zh, this message translates to:
  /// **'大模型'**
  String get contentModelLabel;

  /// contentArtworkDescriptionText
  ///
  /// In zh, this message translates to:
  /// **'包含当前示例孩子的儿童画素材'**
  String get contentArtworkDescriptionText;

  /// contentCraftDescriptionText
  ///
  /// In zh, this message translates to:
  /// **'包含纸板、手工和结构化素材'**
  String get contentCraftDescriptionText;

  /// contentPhotoDescriptionText
  ///
  /// In zh, this message translates to:
  /// **'含拍照素材与扫描件'**
  String get contentPhotoDescriptionText;

  /// contentTagInfoText
  ///
  /// In zh, this message translates to:
  /// **'包含主题、颜色、场景和创作类型标签'**
  String get contentTagInfoText;

  /// contentAssetPreviewFallbackTitle
  ///
  /// In zh, this message translates to:
  /// **'作品预览'**
  String get contentAssetPreviewFallbackTitle;

  /// contentPreviewCloseHint
  ///
  /// In zh, this message translates to:
  /// **'点击右上角可关闭预览'**
  String get contentPreviewCloseHint;

  /// contentTypeFilterAllLabel
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get contentTypeFilterAllLabel;

  /// contentDrawingCountLabel
  ///
  /// In zh, this message translates to:
  /// **'绘画数量'**
  String get contentDrawingCountLabel;

  /// contentPhotoCountLabel
  ///
  /// In zh, this message translates to:
  /// **'照片数量'**
  String get contentPhotoCountLabel;

  /// contentGeneratedPdfLabel
  ///
  /// In zh, this message translates to:
  /// **'已生成 PDF'**
  String get contentGeneratedPdfLabel;

  /// contentAssetDistributionTitle
  ///
  /// In zh, this message translates to:
  /// **'素材分布'**
  String get contentAssetDistributionTitle;

  /// contentAssetDistributionSummaryText
  ///
  /// In zh, this message translates to:
  /// **'绘画作品 49% 照片 35% 手工作品 9%'**
  String get contentAssetDistributionSummaryText;

  /// contentRecentWorksTitle
  ///
  /// In zh, this message translates to:
  /// **'最近作品'**
  String get contentRecentWorksTitle;

  /// contentPortfolioRecordTitle
  ///
  /// In zh, this message translates to:
  /// **'作品集记录'**
  String get contentPortfolioRecordTitle;

  /// contentSampleBookTitleSpring
  ///
  /// In zh, this message translates to:
  /// **'春日拾光 · 2025-04-01 · 24页'**
  String get contentSampleBookTitleSpring;

  /// contentSampleBookTitleBirthday
  ///
  /// In zh, this message translates to:
  /// **'三岁生日纪念册 · 2024-06-20 · 32页'**
  String get contentSampleBookTitleBirthday;

  /// contentSampleBookTitleDaycare
  ///
  /// In zh, this message translates to:
  /// **'幼儿园生活点滴 · 2024-01-15 · 28页'**
  String get contentSampleBookTitleDaycare;

  /// contentBannerHeaderSubtitle
  ///
  /// In zh, this message translates to:
  /// **'每一个笑容，都值得被珍藏。'**
  String get contentBannerHeaderSubtitle;

  /// contentBannerHeaderTitle
  ///
  /// In zh, this message translates to:
  /// **'每一幅画，都是成长的印记'**
  String get contentBannerHeaderTitle;

  /// contentAssetSearchHint
  ///
  /// In zh, this message translates to:
  /// **'搜索素材名称、标签或来源...'**
  String get contentAssetSearchHint;

  /// contentPagerPreviousTooltip
  ///
  /// In zh, this message translates to:
  /// **'上一页'**
  String get contentPagerPreviousTooltip;

  /// contentPagerNextTooltip
  ///
  /// In zh, this message translates to:
  /// **'下一页'**
  String get contentPagerNextTooltip;

  /// contentCollectionTotalCountLabel
  ///
  /// In zh, this message translates to:
  /// **'1,248 个'**
  String get contentCollectionTotalCountLabel;

  /// contentNoTagReasonHint
  ///
  /// In zh, this message translates to:
  /// **'待补充标签'**
  String get contentNoTagReasonHint;

  /// contentDateMissingLabel
  ///
  /// In zh, this message translates to:
  /// **'未填写日期'**
  String get contentDateMissingLabel;

  /// contentUnnamedPhotoLabel
  ///
  /// In zh, this message translates to:
  /// **'未命名照片'**
  String get contentUnnamedPhotoLabel;

  /// contentUnnamedCraftLabel
  ///
  /// In zh, this message translates to:
  /// **'未命名手工'**
  String get contentUnnamedCraftLabel;

  /// contentUnnamedDrawingLabel
  ///
  /// In zh, this message translates to:
  /// **'未命名绘画'**
  String get contentUnnamedDrawingLabel;

  /// contentPreviewWaitingForGenerationLabel
  ///
  /// In zh, this message translates to:
  /// **'等待生成'**
  String get contentPreviewWaitingForGenerationLabel;

  /// contentPreviewCompletedLabel
  ///
  /// In zh, this message translates to:
  /// **'预览完成 可预览全部内容'**
  String get contentPreviewCompletedLabel;

  /// contentPreviewWaitingLabel
  ///
  /// In zh, this message translates to:
  /// **'预览等待 生成后可查看'**
  String get contentPreviewWaitingLabel;

  /// contentExportCompletedFileLabel
  ///
  /// In zh, this message translates to:
  /// **'已导出 文件完成'**
  String get contentExportCompletedFileLabel;

  /// contentExportFormatSelectionHint
  ///
  /// In zh, this message translates to:
  /// **'可导出 生成后选择格式'**
  String get contentExportFormatSelectionHint;

  /// contentNoSelectedAssetsHint
  ///
  /// In zh, this message translates to:
  /// **'暂无已选素材'**
  String get contentNoSelectedAssetsHint;

  /// contentViewAllLabel
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get contentViewAllLabel;

  /// contentCoverAppearsAfterGenerationLabel
  ///
  /// In zh, this message translates to:
  /// **'封面将在生成后出现'**
  String get contentCoverAppearsAfterGenerationLabel;

  /// contentStoryPagesWaitingLabel
  ///
  /// In zh, this message translates to:
  /// **'故事页面等待生成'**
  String get contentStoryPagesWaitingLabel;

  /// contentExportBeforePreviewHint
  ///
  /// In zh, this message translates to:
  /// **'导出前先完成预览'**
  String get contentExportBeforePreviewHint;

  /// contentTaskProgressLogTitle
  ///
  /// In zh, this message translates to:
  /// **'任务进度日志'**
  String get contentTaskProgressLogTitle;

  /// contentViewDetailsLabel
  ///
  /// In zh, this message translates to:
  /// **'查看详细日志'**
  String get contentViewDetailsLabel;

  /// contentPreviewWaitingTitle
  ///
  /// In zh, this message translates to:
  /// **'页面预览（等待生成）'**
  String get contentPreviewWaitingTitle;

  /// contentPreviewAvailableAfterGenerationHint
  ///
  /// In zh, this message translates to:
  /// **'预览会在生成完成后显示'**
  String get contentPreviewAvailableAfterGenerationHint;

  /// contentSectionCoverLabel
  ///
  /// In zh, this message translates to:
  /// **'1 封面'**
  String get contentSectionCoverLabel;

  /// contentSectionStoriesLabel
  ///
  /// In zh, this message translates to:
  /// **'2 素材故事'**
  String get contentSectionStoriesLabel;

  /// contentSectionGrowthRecordsLabel
  ///
  /// In zh, this message translates to:
  /// **'3 成长记录'**
  String get contentSectionGrowthRecordsLabel;

  /// contentAssetTypeCraftLabel
  ///
  /// In zh, this message translates to:
  /// **'手工'**
  String get contentAssetTypeCraftLabel;

  /// contentCategoryDrawingLabel
  ///
  /// In zh, this message translates to:
  /// **'绘画'**
  String get contentCategoryDrawingLabel;

  /// contentOpenLabel
  ///
  /// In zh, this message translates to:
  /// **'打开'**
  String get contentOpenLabel;

  /// contentTagLabel
  ///
  /// In zh, this message translates to:
  /// **'标签'**
  String get contentTagLabel;

  /// generateExportS83
  ///
  /// In zh, this message translates to:
  /// **'0 / 建议 6+'**
  String get generateExportS83;

  /// generateExportS102
  ///
  /// In zh, this message translates to:
  /// **'AI 帮我挑素材'**
  String get generateExportS102;

  /// generateExportS105
  ///
  /// In zh, this message translates to:
  /// **'Agent 执行计划'**
  String get generateExportS105;

  /// generateExportS107
  ///
  /// In zh, this message translates to:
  /// **'Agent 正在规划'**
  String get generateExportS107;

  /// generateExportS108
  ///
  /// In zh, this message translates to:
  /// **'Agent 活动'**
  String get generateExportS108;

  /// generateExportS128
  ///
  /// In zh, this message translates to:
  /// **'PDF 已导出'**
  String get generateExportS128;

  /// generateExportS214
  ///
  /// In zh, this message translates to:
  /// **'不可用'**
  String get generateExportS214;

  /// generateExportS218
  ///
  /// In zh, this message translates to:
  /// **'云端分享'**
  String get generateExportS218;

  /// generateExportS219
  ///
  /// In zh, this message translates to:
  /// **'仅本地'**
  String get generateExportS219;

  /// generateExportS220
  ///
  /// In zh, this message translates to:
  /// **'仅本地文件'**
  String get generateExportS220;

  /// generateExportS226
  ///
  /// In zh, this message translates to:
  /// **'任务执行失败'**
  String get generateExportS226;

  /// generateExportS227
  ///
  /// In zh, this message translates to:
  /// **'任务状态'**
  String get generateExportS227;

  /// generateExportS237
  ///
  /// In zh, this message translates to:
  /// **'你想为孩子创作什么？'**
  String get generateExportS237;

  /// generateExportS243
  ///
  /// In zh, this message translates to:
  /// **'例如：用春游照片做一本 8 页绘本'**
  String get generateExportS243;

  /// generateExportS245
  ///
  /// In zh, this message translates to:
  /// **'保存 / 分享'**
  String get generateExportS245;

  /// generateExportS255
  ///
  /// In zh, this message translates to:
  /// **'儿童绘本'**
  String get generateExportS255;

  /// generateExportS270
  ///
  /// In zh, this message translates to:
  /// **'准备大纲'**
  String get generateExportS270;

  /// generateExportS272
  ///
  /// In zh, this message translates to:
  /// **'准备开始'**
  String get generateExportS272;

  /// generateExportS274
  ///
  /// In zh, this message translates to:
  /// **'分享链接'**
  String get generateExportS274;

  /// generateExportS275
  ///
  /// In zh, this message translates to:
  /// **'分享链接已生成，可直接发送给家人查看。'**
  String get generateExportS275;

  /// generateExportS279
  ///
  /// In zh, this message translates to:
  /// **'创作类型'**
  String get generateExportS279;

  /// generateExportS315
  ///
  /// In zh, this message translates to:
  /// **'原因：免费生图服务暂时不可用。你可以重试，或跳过封面继续导出。'**
  String get generateExportS315;

  /// generateExportS324
  ///
  /// In zh, this message translates to:
  /// **'去素材库选择'**
  String get generateExportS324;

  /// generateExportS328
  ///
  /// In zh, this message translates to:
  /// **'可在保存目录中查看'**
  String get generateExportS328;

  /// generateExportS329
  ///
  /// In zh, this message translates to:
  /// **'可复制分享文案'**
  String get generateExportS329;

  /// generateExportS331
  ///
  /// In zh, this message translates to:
  /// **'可打开或分享'**
  String get generateExportS331;

  /// generateExportS332
  ///
  /// In zh, this message translates to:
  /// **'可查看预览'**
  String get generateExportS332;

  /// generateExportS334
  ///
  /// In zh, this message translates to:
  /// **'可预览'**
  String get generateExportS334;

  /// generateExportS335
  ///
  /// In zh, this message translates to:
  /// **'可预览或导出'**
  String get generateExportS335;

  /// generateExportS336
  ///
  /// In zh, this message translates to:
  /// **'同步中'**
  String get generateExportS336;

  /// generateExportS340
  ///
  /// In zh, this message translates to:
  /// **'同步失败'**
  String get generateExportS340;

  /// generateExportS357
  ///
  /// In zh, this message translates to:
  /// **'复制分享文案'**
  String get generateExportS357;

  /// generateExportS358
  ///
  /// In zh, this message translates to:
  /// **'复制长图'**
  String get generateExportS358;

  /// generateExportS404
  ///
  /// In zh, this message translates to:
  /// **'导出 JPG 长图'**
  String get generateExportS404;

  /// generateExportS405
  ///
  /// In zh, this message translates to:
  /// **'导出 PDF'**
  String get generateExportS405;

  /// generateExportS406
  ///
  /// In zh, this message translates to:
  /// **'导出 PNG 长图'**
  String get generateExportS406;

  /// generateExportS407
  ///
  /// In zh, this message translates to:
  /// **'导出作品'**
  String get generateExportS407;

  /// generateExportS409
  ///
  /// In zh, this message translates to:
  /// **'导出后解锁'**
  String get generateExportS409;

  /// generateExportS411
  ///
  /// In zh, this message translates to:
  /// **'导出完成后才能打开文件夹或复制长图。'**
  String get generateExportS411;

  /// generateExportS413
  ///
  /// In zh, this message translates to:
  /// **'导出效果'**
  String get generateExportS413;

  /// generateExportS415
  ///
  /// In zh, this message translates to:
  /// **'导出物尚未上传分享，暂不能复制分享文案。'**
  String get generateExportS415;

  /// generateExportS417
  ///
  /// In zh, this message translates to:
  /// **'导出目标'**
  String get generateExportS417;

  /// generateExportS418
  ///
  /// In zh, this message translates to:
  /// **'导出结果'**
  String get generateExportS418;

  /// generateExportS419
  ///
  /// In zh, this message translates to:
  /// **'封面'**
  String get generateExportS419;

  /// generateExportS420
  ///
  /// In zh, this message translates to:
  /// **'封面、故事页和成长记录已准备好，可以继续导出。'**
  String get generateExportS420;

  /// generateExportS421
  ///
  /// In zh, this message translates to:
  /// **'封面图生成失败'**
  String get generateExportS421;

  /// generateExportS427
  ///
  /// In zh, this message translates to:
  /// **'尚未创建生成任务'**
  String get generateExportS427;

  /// generateExportS428
  ///
  /// In zh, this message translates to:
  /// **'尚未导出'**
  String get generateExportS428;

  /// generateExportS438
  ///
  /// In zh, this message translates to:
  /// **'已同步'**
  String get generateExportS438;

  /// generateExportS442
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get generateExportS442;

  /// generateExportS444
  ///
  /// In zh, this message translates to:
  /// **'已导出'**
  String get generateExportS444;

  /// generateExportS450
  ///
  /// In zh, this message translates to:
  /// **'已生成'**
  String get generateExportS450;

  /// generateExportS452
  ///
  /// In zh, this message translates to:
  /// **'已生成分享链接'**
  String get generateExportS452;

  /// generateExportS460
  ///
  /// In zh, this message translates to:
  /// **'已选素材'**
  String get generateExportS460;

  /// generateExportS470
  ///
  /// In zh, this message translates to:
  /// **'开始生成绘本'**
  String get generateExportS470;

  /// generateExportS472
  ///
  /// In zh, this message translates to:
  /// **'异常'**
  String get generateExportS472;

  /// generateExportS473
  ///
  /// In zh, this message translates to:
  /// **'当前任务'**
  String get generateExportS473;

  /// generateExportS476
  ///
  /// In zh, this message translates to:
  /// **'当前导出不是长图，不能复制长图内容。'**
  String get generateExportS476;

  /// generateExportS518
  ///
  /// In zh, this message translates to:
  /// **'打开导出文件夹'**
  String get generateExportS518;

  /// generateExportS532
  ///
  /// In zh, this message translates to:
  /// **'按时间线整理成长记录'**
  String get generateExportS532;

  /// generateExportS547
  ///
  /// In zh, this message translates to:
  /// **'故事已生成'**
  String get generateExportS547;

  /// generateExportS548
  ///
  /// In zh, this message translates to:
  /// **'故事页'**
  String get generateExportS548;

  /// generateExportS553
  ///
  /// In zh, this message translates to:
  /// **'文案风格'**
  String get generateExportS553;

  /// generateExportS611
  ///
  /// In zh, this message translates to:
  /// **'本地文件'**
  String get generateExportS611;

  /// generateExportS617
  ///
  /// In zh, this message translates to:
  /// **'本次作品集'**
  String get generateExportS617;

  /// generateExportS623
  ///
  /// In zh, this message translates to:
  /// **'查看已选素材'**
  String get generateExportS623;

  /// generateExportS624
  ///
  /// In zh, this message translates to:
  /// **'查看日志'**
  String get generateExportS624;

  /// generateExportS627
  ///
  /// In zh, this message translates to:
  /// **'查看素材'**
  String get generateExportS627;

  /// generateExportS644
  ///
  /// In zh, this message translates to:
  /// **'模板'**
  String get generateExportS644;

  /// generateExportS647
  ///
  /// In zh, this message translates to:
  /// **'正在写故事'**
  String get generateExportS647;

  /// generateExportS651
  ///
  /// In zh, this message translates to:
  /// **'正在创建作品集'**
  String get generateExportS651;

  /// generateExportS662
  ///
  /// In zh, this message translates to:
  /// **'正在生成作品集'**
  String get generateExportS662;

  /// generateExportS663
  ///
  /// In zh, this message translates to:
  /// **'正在生成预览页面，完成后会展示封面、故事页和导出效果。'**
  String get generateExportS663;

  /// generateExportS698
  ///
  /// In zh, this message translates to:
  /// **'渲染预览'**
  String get generateExportS698;

  /// generateExportS708
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get generateExportS708;

  /// generateExportS717
  ///
  /// In zh, this message translates to:
  /// **'生成 6-12 页故事绘本'**
  String get generateExportS717;

  /// generateExportS718
  ///
  /// In zh, this message translates to:
  /// **'生成中'**
  String get generateExportS718;

  /// generateExportS719
  ///
  /// In zh, this message translates to:
  /// **'生成中...'**
  String get generateExportS719;

  /// generateExportS721
  ///
  /// In zh, this message translates to:
  /// **'生成儿童绘本'**
  String get generateExportS721;

  /// generateExportS723
  ///
  /// In zh, this message translates to:
  /// **'生成后可上传分享'**
  String get generateExportS723;

  /// generateExportS724
  ///
  /// In zh, this message translates to:
  /// **'生成后可导出'**
  String get generateExportS724;

  /// generateExportS725
  ///
  /// In zh, this message translates to:
  /// **'生成后展示'**
  String get generateExportS725;

  /// generateExportS726
  ///
  /// In zh, this message translates to:
  /// **'生成后查看日志'**
  String get generateExportS726;

  /// generateExportS727
  ///
  /// In zh, this message translates to:
  /// **'生成回忆录视频'**
  String get generateExportS727;

  /// generateExportS729
  ///
  /// In zh, this message translates to:
  /// **'生成失败'**
  String get generateExportS729;

  /// generateExportS731
  ///
  /// In zh, this message translates to:
  /// **'生成完成'**
  String get generateExportS731;

  /// generateExportS735
  ///
  /// In zh, this message translates to:
  /// **'生成完成后，可以导出 PDF、长图或创建分享链接。'**
  String get generateExportS735;

  /// generateExportS738
  ///
  /// In zh, this message translates to:
  /// **'生成带字幕和音乐的短视频'**
  String get generateExportS738;

  /// generateExportS740
  ///
  /// In zh, this message translates to:
  /// **'生成成长纪念册'**
  String get generateExportS740;

  /// generateExportS741
  ///
  /// In zh, this message translates to:
  /// **'生成控制台'**
  String get generateExportS741;

  /// generateExportS742
  ///
  /// In zh, this message translates to:
  /// **'生成故事'**
  String get generateExportS742;

  /// generateExportS747
  ///
  /// In zh, this message translates to:
  /// **'生成计划'**
  String get generateExportS747;

  /// generateExportS769
  ///
  /// In zh, this message translates to:
  /// **'确认：调用免费生图'**
  String get generateExportS769;

  /// generateExportS790
  ///
  /// In zh, this message translates to:
  /// **'第 1 页'**
  String get generateExportS790;

  /// generateExportS794
  ///
  /// In zh, this message translates to:
  /// **'等待导出'**
  String get generateExportS794;

  /// generateExportS795
  ///
  /// In zh, this message translates to:
  /// **'等待开始'**
  String get generateExportS795;

  /// generateExportS796
  ///
  /// In zh, this message translates to:
  /// **'等待开始。点击“开始生成”后，这里会显示素材分析、故事生成、预览渲染和导出进度。'**
  String get generateExportS796;

  /// generateExportS797
  ///
  /// In zh, this message translates to:
  /// **'等待执行'**
  String get generateExportS797;

  /// generateExportS800
  ///
  /// In zh, this message translates to:
  /// **'等待选择素材'**
  String get generateExportS800;

  /// generateExportS802
  ///
  /// In zh, this message translates to:
  /// **'等待重试'**
  String get generateExportS802;

  /// generateExportS808
  ///
  /// In zh, this message translates to:
  /// **'素材'**
  String get generateExportS808;

  /// generateExportS813
  ///
  /// In zh, this message translates to:
  /// **'素材已准备'**
  String get generateExportS813;

  /// generateExportS819
  ///
  /// In zh, this message translates to:
  /// **'素材未选择'**
  String get generateExportS819;

  /// generateExportS821
  ///
  /// In zh, this message translates to:
  /// **'素材状态'**
  String get generateExportS821;

  /// generateExportS833
  ///
  /// In zh, this message translates to:
  /// **'继续生成'**
  String get generateExportS833;

  /// generateExportS841
  ///
  /// In zh, this message translates to:
  /// **'让 Agent 重新挑选'**
  String get generateExportS841;

  /// generateExportS859
  ///
  /// In zh, this message translates to:
  /// **'请先选择素材，之后即可开始生成。'**
  String get generateExportS859;

  /// generateExportS860
  ///
  /// In zh, this message translates to:
  /// **'请先选择素材，开始生成才会启用。'**
  String get generateExportS860;

  /// generateExportS868
  ///
  /// In zh, this message translates to:
  /// **'请选择孩子的照片、画作或手工作品。素材准备好后，Agent 会生成创作计划并开始预览。'**
  String get generateExportS868;

  /// generateExportS871
  ///
  /// In zh, this message translates to:
  /// **'调整模板、尺寸和导出方式。设置完成后即可开始创作。'**
  String get generateExportS871;

  /// generateExportS875
  ///
  /// In zh, this message translates to:
  /// **'超时'**
  String get generateExportS875;

  /// generateExportS876
  ///
  /// In zh, this message translates to:
  /// **'跳过封面'**
  String get generateExportS876;

  /// generateExportS877
  ///
  /// In zh, this message translates to:
  /// **'跳过封面继续导出'**
  String get generateExportS877;

  /// generateExportS883
  ///
  /// In zh, this message translates to:
  /// **'输入目标或选择快捷类型，Agent 会按素材、故事、预览和导出组织创作流程。'**
  String get generateExportS883;

  /// generateExportS884
  ///
  /// In zh, this message translates to:
  /// **'输出'**
  String get generateExportS884;

  /// generateExportS889
  ///
  /// In zh, this message translates to:
  /// **'还没有选择素材。请选择孩子的照片、画作或手工作品，建议至少 6 张。'**
  String get generateExportS889;

  /// generateExportS893
  ///
  /// In zh, this message translates to:
  /// **'这些素材会进入本次创作计划。你可以返回素材库重新选择，或让 Agent 重新挑选。'**
  String get generateExportS893;

  /// generateExportS895
  ///
  /// In zh, this message translates to:
  /// **'进行中'**
  String get generateExportS895;

  /// generateExportS907
  ///
  /// In zh, this message translates to:
  /// **'选择素材'**
  String get generateExportS907;

  /// generateExportS909
  ///
  /// In zh, this message translates to:
  /// **'选择素材和创作方式，KidMemory 会帮你生成绘本、成长纪念册或回忆视频。'**
  String get generateExportS909;

  /// generateExportS921
  ///
  /// In zh, this message translates to:
  /// **'重新生成'**
  String get generateExportS921;

  /// generateExportS923
  ///
  /// In zh, this message translates to:
  /// **'重新选择'**
  String get generateExportS923;

  /// generateExportS930
  ///
  /// In zh, this message translates to:
  /// **'错误原因'**
  String get generateExportS930;

  /// generateExportS931
  ///
  /// In zh, this message translates to:
  /// **'长图 JPG'**
  String get generateExportS931;

  /// generateExportS934
  ///
  /// In zh, this message translates to:
  /// **'长图 PNG'**
  String get generateExportS934;

  /// generateExportS942
  ///
  /// In zh, this message translates to:
  /// **'页面尺寸'**
  String get generateExportS942;

  /// generateExportS943
  ///
  /// In zh, this message translates to:
  /// **'页面预览'**
  String get generateExportS943;

  /// generateExportS949
  ///
  /// In zh, this message translates to:
  /// **'预览与导出将在生成后解锁'**
  String get generateExportS949;

  /// generateExportS951
  ///
  /// In zh, this message translates to:
  /// **'预览全部页面'**
  String get generateExportS951;

  /// generateExportS954
  ///
  /// In zh, this message translates to:
  /// **'预览将在生成后出现。KidMemory 会在这里展示封面、页面和导出效果。'**
  String get generateExportS954;

  /// generateExportS956
  ///
  /// In zh, this message translates to:
  /// **'风格'**
  String get generateExportS956;

  /// generateExportS957
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get generateExportS957;

  /// assetLibraryPageS285
  ///
  /// In zh, this message translates to:
  /// **'创建时间（最新）'**
  String get assetLibraryPageS285;

  /// assetLibraryPageS286
  ///
  /// In zh, this message translates to:
  /// **'创建时间（最早）'**
  String get assetLibraryPageS286;

  /// assetLibraryPageS786
  ///
  /// In zh, this message translates to:
  /// **'种类（绘画/照片/手工）'**
  String get assetLibraryPageS786;

  /// assetLibraryPageS631
  ///
  /// In zh, this message translates to:
  /// **'标题（A-Z）'**
  String get assetLibraryPageS631;

  /// assetLibraryPageS879
  ///
  /// In zh, this message translates to:
  /// **'输入关键词可本地筛选，也可以使用语义搜索'**
  String get assetLibraryPageS879;

  /// assetLibraryPageS847
  ///
  /// In zh, this message translates to:
  /// **'语义索引待加载'**
  String get assetLibraryPageS847;

  /// assetLibraryPageS433
  ///
  /// In zh, this message translates to:
  /// **'已切换孩子档案，可重新搜索'**
  String get assetLibraryPageS433;

  /// assetLibraryPageS599
  ///
  /// In zh, this message translates to:
  /// **'未选择孩子'**
  String get assetLibraryPageS599;

  /// assetLibraryPageS660
  ///
  /// In zh, this message translates to:
  /// **'正在本地筛选素材'**
  String get assetLibraryPageS660;

  /// assetLibraryPageS483
  ///
  /// In zh, this message translates to:
  /// **'当前环境暂未启用语义搜索'**
  String get assetLibraryPageS483;

  /// assetLibraryPageS858
  ///
  /// In zh, this message translates to:
  /// **'请先选择孩子档案再搜索'**
  String get assetLibraryPageS858;

  /// assetLibraryPageS867
  ///
  /// In zh, this message translates to:
  /// **'请输入标题、标签或自然语言描述'**
  String get assetLibraryPageS867;

  /// assetLibraryPageS665
  ///
  /// In zh, this message translates to:
  /// **'正在语义搜索...'**
  String get assetLibraryPageS665;

  /// assetLibraryPageS825
  ///
  /// In zh, this message translates to:
  /// **'索引状态不可用'**
  String get assetLibraryPageS825;

  /// assetLibraryPageS440
  ///
  /// In zh, this message translates to:
  /// **'已回到素材库浏览'**
  String get assetLibraryPageS440;

  /// assetLibraryPageS572
  ///
  /// In zh, this message translates to:
  /// **'暂时无法挑选'**
  String get assetLibraryPageS572;

  /// assetLibraryPageS481
  ///
  /// In zh, this message translates to:
  /// **'当前没有可用素材，请先导入素材后再试。'**
  String get assetLibraryPageS481;

  /// assetLibraryPageS869
  ///
  /// In zh, this message translates to:
  /// **'请选择本次目标：'**
  String get assetLibraryPageS869;

  /// assetLibraryPageS902
  ///
  /// In zh, this message translates to:
  /// **'适合做绘本'**
  String get assetLibraryPageS902;

  /// assetLibraryPageS901
  ///
  /// In zh, this message translates to:
  /// **'适合做成长纪念册'**
  String get assetLibraryPageS901;

  /// assetLibraryPageS900
  ///
  /// In zh, this message translates to:
  /// **'适合做回忆录视频'**
  String get assetLibraryPageS900;

  /// assetLibraryPageS503
  ///
  /// In zh, this message translates to:
  /// **'手动调整'**
  String get assetLibraryPageS503;

  /// assetLibraryPageS919
  ///
  /// In zh, this message translates to:
  /// **'重新挑选'**
  String get assetLibraryPageS919;

  /// assetLibraryPageS765
  ///
  /// In zh, this message translates to:
  /// **'确认使用'**
  String get assetLibraryPageS765;

  /// assetLibraryPageS564
  ///
  /// In zh, this message translates to:
  /// **'智能挑选已应用'**
  String get assetLibraryPageS564;

  /// assetLibraryPageS430
  ///
  /// In zh, this message translates to:
  /// **'已保留当前选择'**
  String get assetLibraryPageS430;

  /// assetLibraryPageS235
  ///
  /// In zh, this message translates to:
  /// **'你可以继续手动勾选素材。'**
  String get assetLibraryPageS235;

  /// assetLibraryPageS531
  ///
  /// In zh, this message translates to:
  /// **'拖入的路径暂时无法导入'**
  String get assetLibraryPageS531;

  /// assetLibraryPageS403
  ///
  /// In zh, this message translates to:
  /// **'导入部分完成'**
  String get assetLibraryPageS403;

  /// assetLibraryPageS392
  ///
  /// In zh, this message translates to:
  /// **'导入完成'**
  String get assetLibraryPageS392;

  /// assetLibraryPageS581
  ///
  /// In zh, this message translates to:
  /// **'未导入素材'**
  String get assetLibraryPageS581;

  /// assetLibraryPageS767
  ///
  /// In zh, this message translates to:
  /// **'确认批量删除'**
  String get assetLibraryPageS767;

  /// assetLibraryPageS296
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get assetLibraryPageS296;

  /// assetLibraryPageS619
  ///
  /// In zh, this message translates to:
  /// **'来源'**
  String get assetLibraryPageS619;

  /// assetLibraryPageS284
  ///
  /// In zh, this message translates to:
  /// **'创建时间'**
  String get assetLibraryPageS284;

  /// assetLibraryPageS289
  ///
  /// In zh, this message translates to:
  /// **'创建者'**
  String get assetLibraryPageS289;

  /// assetLibraryPageS782
  ///
  /// In zh, this message translates to:
  /// **'示例档案'**
  String get assetLibraryPageS782;

  /// assetLibraryPageS620
  ///
  /// In zh, this message translates to:
  /// **'来源设备'**
  String get assetLibraryPageS620;

  /// assetLibraryPageS268
  ///
  /// In zh, this message translates to:
  /// **'内置示例'**
  String get assetLibraryPageS268;

  /// assetLibraryPageS368
  ///
  /// In zh, this message translates to:
  /// **'存储位置'**
  String get assetLibraryPageS368;

  /// assetLibraryPageS784
  ///
  /// In zh, this message translates to:
  /// **'示例素材库'**
  String get assetLibraryPageS784;

  /// assetLibraryPageS225
  ///
  /// In zh, this message translates to:
  /// **'从本次作品集移除'**
  String get assetLibraryPageS225;

  /// assetLibraryPageS308
  ///
  /// In zh, this message translates to:
  /// **'加入本次作品集'**
  String get assetLibraryPageS308;

  /// assetLibraryPageS221
  ///
  /// In zh, this message translates to:
  /// **'仅用于本次生成，不会修改原始素材'**
  String get assetLibraryPageS221;

  /// assetLibraryPageS575
  ///
  /// In zh, this message translates to:
  /// **'有未保存修改'**
  String get assetLibraryPageS575;

  /// assetLibraryPageS630
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get assetLibraryPageS630;

  /// assetLibraryPageS242
  ///
  /// In zh, this message translates to:
  /// **'例如：春游里的泡泡'**
  String get assetLibraryPageS242;

  /// assetLibraryPageS806
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get assetLibraryPageS806;

  /// assetLibraryPageS558
  ///
  /// In zh, this message translates to:
  /// **'日期'**
  String get assetLibraryPageS558;

  /// assetLibraryPageS95
  ///
  /// In zh, this message translates to:
  /// **'2026-05-17 或 2026年5月17日'**
  String get assetLibraryPageS95;

  /// assetLibraryPageS498
  ///
  /// In zh, this message translates to:
  /// **'户外、泡泡、春游'**
  String get assetLibraryPageS498;

  /// assetLibraryPageS535
  ///
  /// In zh, this message translates to:
  /// **'描述'**
  String get assetLibraryPageS535;

  /// assetLibraryPageS843
  ///
  /// In zh, this message translates to:
  /// **'记录这份素材背后的故事'**
  String get assetLibraryPageS843;

  /// assetLibraryPageS614
  ///
  /// In zh, this message translates to:
  /// **'本地状态'**
  String get assetLibraryPageS614;

  /// assetLibraryPageS824
  ///
  /// In zh, this message translates to:
  /// **'索引状态'**
  String get assetLibraryPageS824;

  /// assetLibraryPageS528
  ///
  /// In zh, this message translates to:
  /// **'技术信息'**
  String get assetLibraryPageS528;

  /// assetLibraryPageS316
  ///
  /// In zh, this message translates to:
  /// **'原始文件'**
  String get assetLibraryPageS316;

  /// assetLibraryPageS615
  ///
  /// In zh, this message translates to:
  /// **'本地素材'**
  String get assetLibraryPageS615;

  /// assetLibraryPageS616
  ///
  /// In zh, this message translates to:
  /// **'本地路径'**
  String get assetLibraryPageS616;

  /// assetLibraryPageS597
  ///
  /// In zh, this message translates to:
  /// **'未记录'**
  String get assetLibraryPageS597;

  /// assetLibraryPageS246
  ///
  /// In zh, this message translates to:
  /// **'保存中...'**
  String get assetLibraryPageS246;

  /// assetLibraryPageS247
  ///
  /// In zh, this message translates to:
  /// **'保存修改'**
  String get assetLibraryPageS247;

  /// assetLibraryPageS546
  ///
  /// In zh, this message translates to:
  /// **'放弃修改'**
  String get assetLibraryPageS546;

  /// assetLibraryPageS516
  ///
  /// In zh, this message translates to:
  /// **'打开原图'**
  String get assetLibraryPageS516;

  /// assetLibraryPageS304
  ///
  /// In zh, this message translates to:
  /// **'删除素材'**
  String get assetLibraryPageS304;

  /// assetLibraryPageS249
  ///
  /// In zh, this message translates to:
  /// **'保存成功'**
  String get assetLibraryPageS249;

  /// assetLibraryPageS248
  ///
  /// In zh, this message translates to:
  /// **'保存失败'**
  String get assetLibraryPageS248;

  /// assetLibraryPageS766
  ///
  /// In zh, this message translates to:
  /// **'确认删除素材'**
  String get assetLibraryPageS766;

  /// assetLibraryPageS298
  ///
  /// In zh, this message translates to:
  /// **'删除后将从本地素材库移除，是否继续？'**
  String get assetLibraryPageS298;

  /// assetLibraryPageS434
  ///
  /// In zh, this message translates to:
  /// **'已删除'**
  String get assetLibraryPageS434;

  /// assetLibraryPageS299
  ///
  /// In zh, this message translates to:
  /// **'删除失败'**
  String get assetLibraryPageS299;

  /// assetLibraryPageS447
  ///
  /// In zh, this message translates to:
  /// **'已打开原图'**
  String get assetLibraryPageS447;

  /// assetLibraryPageS437
  ///
  /// In zh, this message translates to:
  /// **'已加入同步队列'**
  String get assetLibraryPageS437;

  /// assetLibraryPageS338
  ///
  /// In zh, this message translates to:
  /// **'同步入队失败，请检查 Supabase Storage 配置'**
  String get assetLibraryPageS338;

  /// childProfileS715
  ///
  /// In zh, this message translates to:
  /// **'珍藏成长点滴，记录美好时光'**
  String get childProfileS715;

  /// childProfileS645
  ///
  /// In zh, this message translates to:
  /// **'欢迎使用 KidMemory'**
  String get childProfileS645;

  /// childProfileS887
  ///
  /// In zh, this message translates to:
  /// **'还没有孩子档案'**
  String get childProfileS887;

  /// childProfileS693
  ///
  /// In zh, this message translates to:
  /// **'添加档案'**
  String get childProfileS693;

  /// childProfileS625
  ///
  /// In zh, this message translates to:
  /// **'查看示例'**
  String get childProfileS625;

  /// childProfileS842
  ///
  /// In zh, this message translates to:
  /// **'记录素材'**
  String get childProfileS842;

  /// childProfileS706
  ///
  /// In zh, this message translates to:
  /// **'照片、视频、笔记'**
  String get childProfileS706;

  /// childProfileS495
  ///
  /// In zh, this message translates to:
  /// **'成长时间轴'**
  String get childProfileS495;

  /// childProfileS925
  ///
  /// In zh, this message translates to:
  /// **'重要时刻，一目了然'**
  String get childProfileS925;

  /// childProfileS231
  ///
  /// In zh, this message translates to:
  /// **'作品集'**
  String get childProfileS231;

  /// childProfileS714
  ///
  /// In zh, this message translates to:
  /// **'珍藏创作与成果'**
  String get childProfileS714;

  /// childProfileS224
  ///
  /// In zh, this message translates to:
  /// **'从一份档案开始'**
  String get childProfileS224;

  /// childProfileS499
  ///
  /// In zh, this message translates to:
  /// **'所有孩子信息和成长素材本地保存'**
  String get childProfileS499;

  /// childProfileS602
  ///
  /// In zh, this message translates to:
  /// **'本地存储，隐私安心'**
  String get childProfileS602;

  /// childProfileS500
  ///
  /// In zh, this message translates to:
  /// **'所有数据仅保存在你的设备中'**
  String get childProfileS500;

  /// childProfileS785
  ///
  /// In zh, this message translates to:
  /// **'离线可用，随时记录'**
  String get childProfileS785;

  /// childProfileS556
  ///
  /// In zh, this message translates to:
  /// **'无网络也能查看与添加内容'**
  String get childProfileS556;

  /// childProfileS223
  ///
  /// In zh, this message translates to:
  /// **'从一个孩子开始'**
  String get childProfileS223;

  /// childProfileS342
  ///
  /// In zh, this message translates to:
  /// **'后续可随时添加更多孩子档案'**
  String get childProfileS342;

  /// childProfileS238
  ///
  /// In zh, this message translates to:
  /// **'你的数据，只属于你和孩子'**
  String get childProfileS238;

  /// childProfileS554
  ///
  /// In zh, this message translates to:
  /// **'新增'**
  String get childProfileS554;

  /// childProfileS834
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get childProfileS834;

  /// childProfileS401
  ///
  /// In zh, this message translates to:
  /// **'导入素材后，这里会按真实素材更新成长统计和最近作品。'**
  String get childProfileS401;

  /// childProfileS486
  ///
  /// In zh, this message translates to:
  /// **'当前素材库已连接到本地 sidecar，可用于生成成长作品集。'**
  String get childProfileS486;

  /// childProfileS480
  ///
  /// In zh, this message translates to:
  /// **'当前档案'**
  String get childProfileS480;

  /// childProfileS276
  ///
  /// In zh, this message translates to:
  /// **'切换孩子档案'**
  String get childProfileS276;

  /// childProfileS757
  ///
  /// In zh, this message translates to:
  /// **'男孩'**
  String get childProfileS757;

  /// childProfileS366
  ///
  /// In zh, this message translates to:
  /// **'女孩'**
  String get childProfileS366;

  /// childProfileS425
  ///
  /// In zh, this message translates to:
  /// **'小朋友'**
  String get childProfileS425;

  /// childProfileS400
  ///
  /// In zh, this message translates to:
  /// **'导入素材后显示最近作品'**
  String get childProfileS400;

  /// childProfileS733
  ///
  /// In zh, this message translates to:
  /// **'生成完成后会显示本地作品集记录'**
  String get childProfileS733;

  /// childProfileS287
  ///
  /// In zh, this message translates to:
  /// **'创建档案'**
  String get childProfileS287;

  /// childProfileS222
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get childProfileS222;

  /// childProfileS399
  ///
  /// In zh, this message translates to:
  /// **'导入素材'**
  String get childProfileS399;

  /// childProfileS487
  ///
  /// In zh, this message translates to:
  /// **'待开始'**
  String get childProfileS487;

  /// childProfileS720
  ///
  /// In zh, this message translates to:
  /// **'生成作品'**
  String get childProfileS720;

  /// childProfileS633
  ///
  /// In zh, this message translates to:
  /// **'档案信息'**
  String get childProfileS633;

  /// childProfileS367
  ///
  /// In zh, this message translates to:
  /// **'姓名'**
  String get childProfileS367;

  /// childProfileS574
  ///
  /// In zh, this message translates to:
  /// **'最近素材'**
  String get childProfileS574;

  /// childProfileS566
  ///
  /// In zh, this message translates to:
  /// **'暂无'**
  String get childProfileS566;

  /// childProfileS497
  ///
  /// In zh, this message translates to:
  /// **'成长里程碑'**
  String get childProfileS497;

  /// childProfileS799
  ///
  /// In zh, this message translates to:
  /// **'等待第一份素材'**
  String get childProfileS799;

  /// childProfileS446
  ///
  /// In zh, this message translates to:
  /// **'已开始积累成长素材'**
  String get childProfileS446;

  /// childProfileS670
  ///
  /// In zh, this message translates to:
  /// **'每一份素材，都会进入本地成长档案'**
  String get childProfileS670;

  /// childProfileS832
  ///
  /// In zh, this message translates to:
  /// **'统计和时间线来自当前孩子的素材库。'**
  String get childProfileS832;

  /// childProfileS872
  ///
  /// In zh, this message translates to:
  /// **'调色'**
  String get childProfileS872;

  /// childProfileS217
  ///
  /// In zh, this message translates to:
  /// **'书本'**
  String get childProfileS217;

  /// datasetChildrenS690
  ///
  /// In zh, this message translates to:
  /// **'添加孩子档案'**
  String get datasetChildrenS690;

  /// datasetChildrenS688
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get datasetChildrenS688;

  /// datasetChildrenS689
  ///
  /// In zh, this message translates to:
  /// **'添加失败：请确认 Sidecar 已启动'**
  String get datasetChildrenS689;

  /// datasetChildrenS854
  ///
  /// In zh, this message translates to:
  /// **'请先添加一个孩子再编辑资料'**
  String get datasetChildrenS854;

  /// datasetChildrenS835
  ///
  /// In zh, this message translates to:
  /// **'编辑资料'**
  String get datasetChildrenS835;

  /// datasetChildrenS856
  ///
  /// In zh, this message translates to:
  /// **'请先选择一个孩子档案'**
  String get datasetChildrenS856;

  /// datasetChildrenS301
  ///
  /// In zh, this message translates to:
  /// **'删除孩子档案'**
  String get datasetChildrenS301;

  /// datasetChildrenS300
  ///
  /// In zh, this message translates to:
  /// **'删除失败：请先清空这个孩子关联的素材'**
  String get datasetChildrenS300;

  /// datasetChildrenS906
  ///
  /// In zh, this message translates to:
  /// **'选择生日'**
  String get datasetChildrenS906;

  /// datasetChildrenS762
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get datasetChildrenS762;

  /// datasetChildrenS748
  ///
  /// In zh, this message translates to:
  /// **'生日'**
  String get datasetChildrenS748;

  /// datasetChildrenS703
  ///
  /// In zh, this message translates to:
  /// **'点按选择生日'**
  String get datasetChildrenS703;

  /// datasetChildrenS356
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get datasetChildrenS356;

  /// datasetChildrenS263
  ///
  /// In zh, this message translates to:
  /// **'兴趣、性格、记录偏好等'**
  String get datasetChildrenS263;

  /// nodeInstallS161
  ///
  /// In zh, this message translates to:
  /// **'Volta 安装 Node.js'**
  String get nodeInstallS161;

  /// nodeInstallS177
  ///
  /// In zh, this message translates to:
  /// **'fnm 安装 Node.js'**
  String get nodeInstallS177;

  /// nodeInstallS123
  ///
  /// In zh, this message translates to:
  /// **'MacPorts 安装 Node.js'**
  String get nodeInstallS123;

  /// nodeInstallS180
  ///
  /// In zh, this message translates to:
  /// **'nodenv 安装 Node.js'**
  String get nodeInstallS180;

  /// nodeInstallS586
  ///
  /// In zh, this message translates to:
  /// **'未找到可用的 macOS Node.js 安装器，请先安装 Node.js 后重试。'**
  String get nodeInstallS586;

  /// nodeInstallS115
  ///
  /// In zh, this message translates to:
  /// **'Homebrew 安装 Node.js'**
  String get nodeInstallS115;

  /// nodeInstallS202
  ///
  /// In zh, this message translates to:
  /// **'winget 安装 Node.js'**
  String get nodeInstallS202;

  /// nodeInstallS111
  ///
  /// In zh, this message translates to:
  /// **'Chocolatey 安装 Node.js'**
  String get nodeInstallS111;

  /// nodeInstallS139
  ///
  /// In zh, this message translates to:
  /// **'Scoop 安装 Node.js'**
  String get nodeInstallS139;

  /// nodeInstallS594
  ///
  /// In zh, this message translates to:
  /// **'未检测到可用的 Windows Node.js 安装器。'**
  String get nodeInstallS594;

  /// nodeInstallS167
  ///
  /// In zh, this message translates to:
  /// **'apt-get 安装 Node.js'**
  String get nodeInstallS167;

  /// nodeInstallS176
  ///
  /// In zh, this message translates to:
  /// **'dnf 安装 Node.js'**
  String get nodeInstallS176;

  /// nodeInstallS203
  ///
  /// In zh, this message translates to:
  /// **'yum 安装 Node.js'**
  String get nodeInstallS203;

  /// nodeInstallS181
  ///
  /// In zh, this message translates to:
  /// **'pacman 安装 Node.js'**
  String get nodeInstallS181;

  /// nodeInstallS204
  ///
  /// In zh, this message translates to:
  /// **'zypper 安装 Node.js'**
  String get nodeInstallS204;

  /// nodeInstallS166
  ///
  /// In zh, this message translates to:
  /// **'apk 安装 Node.js'**
  String get nodeInstallS166;

  /// nodeInstallS593
  ///
  /// In zh, this message translates to:
  /// **'未检测到可用的 Linux Node.js 安装器。'**
  String get nodeInstallS593;

  /// desktopShellDefaultsS101
  ///
  /// In zh, this message translates to:
  /// **'A4 竖版 210 × 297 mm'**
  String get desktopShellDefaultsS101;

  /// desktopShellDefaultsS100
  ///
  /// In zh, this message translates to:
  /// **'A4 横版 297 × 210 mm'**
  String get desktopShellDefaultsS100;

  /// desktopShellDefaultsS99
  ///
  /// In zh, this message translates to:
  /// **'A3 竖版 297 × 420 mm'**
  String get desktopShellDefaultsS99;

  /// desktopShellDefaultsS697
  ///
  /// In zh, this message translates to:
  /// **'温暖童趣 亲切温暖，适合儿童阅读'**
  String get desktopShellDefaultsS697;

  /// desktopShellDefaultsS787
  ///
  /// In zh, this message translates to:
  /// **'童话叙事 文字更具故事感'**
  String get desktopShellDefaultsS787;

  /// desktopShellDefaultsS826
  ///
  /// In zh, this message translates to:
  /// **'纪实风 中性偏学术表达'**
  String get desktopShellDefaultsS826;

  /// desktopShellDefaultsS129
  ///
  /// In zh, this message translates to:
  /// **'PDF 文件 高质量 PDF（打印级别）'**
  String get desktopShellDefaultsS129;

  /// desktopShellDefaultsS935
  ///
  /// In zh, this message translates to:
  /// **'长图 PNG 适合移动分享'**
  String get desktopShellDefaultsS935;

  /// desktopShellDefaultsS932
  ///
  /// In zh, this message translates to:
  /// **'长图 JPG 体积更小'**
  String get desktopShellDefaultsS932;

  /// feedbackPageS555
  ///
  /// In zh, this message translates to:
  /// **'无法'**
  String get feedbackPageS555;

  /// feedbackPageS583
  ///
  /// In zh, this message translates to:
  /// **'未找到'**
  String get feedbackPageS583;

  /// feedbackPageS673
  ///
  /// In zh, this message translates to:
  /// **'没有'**
  String get feedbackPageS673;

  /// feedbackPageS582
  ///
  /// In zh, this message translates to:
  /// **'未就绪'**
  String get feedbackPageS582;

  /// feedbackPageS383
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get feedbackPageS383;

  /// feedbackPageS429
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get feedbackPageS429;

  /// feedbackPageS448
  ///
  /// In zh, this message translates to:
  /// **'已更新'**
  String get feedbackPageS448;

  /// sidecarLauncherS679
  ///
  /// In zh, this message translates to:
  /// **'测试环境，跳过 sidecar 自动启动。'**
  String get sidecarLauncherS679;

  /// sidecarLauncherS98
  ///
  /// In zh, this message translates to:
  /// **'4317 端口已被占用，但未响应 KidMemory sidecar health。'**
  String get sidecarLauncherS98;

  /// sidecarLauncherS584
  ///
  /// In zh, this message translates to:
  /// **'未找到 sidecar 运行目录。请确认 app bundle 中包含 Resources/sidecar，或设置 KIDMEMORY_SIDECAR_DIR。'**
  String get sidecarLauncherS584;

  /// sidecarLauncherS146
  ///
  /// In zh, this message translates to:
  /// **'Sidecar 未就绪，开始尝试自动启动。'**
  String get sidecarLauncherS146;

  /// sidecarLauncherS141
  ///
  /// In zh, this message translates to:
  /// **'Sidecar 启动中'**
  String get sidecarLauncherS141;

  /// sidecarLauncherS592
  ///
  /// In zh, this message translates to:
  /// **'未检测到可用于启动 sidecar 的 Node.js。'**
  String get sidecarLauncherS592;

  /// sidecarLauncherS591
  ///
  /// In zh, this message translates to:
  /// **'未检测到可启动的 sidecar 入口，已跳过自动启动。'**
  String get sidecarLauncherS591;

  /// sidecarLauncherS140
  ///
  /// In zh, this message translates to:
  /// **'Sidecar 初始化成功。'**
  String get sidecarLauncherS140;

  /// sidecarLauncherS193
  ///
  /// In zh, this message translates to:
  /// **'sidecar 启动失败：服务未在预期时间内通过 health 检查。'**
  String get sidecarLauncherS193;

  /// sidecarLauncherS194
  ///
  /// In zh, this message translates to:
  /// **'sidecar 启动失败：运行目录缺少 dist/main.js。'**
  String get sidecarLauncherS194;

  /// desktopShellS696
  ///
  /// In zh, this message translates to:
  /// **'温暖童趣'**
  String get desktopShellS696;

  /// desktopShellS101
  ///
  /// In zh, this message translates to:
  /// **'A4 竖版 210 × 297 mm'**
  String get desktopShellS101;

  /// desktopShellS697
  ///
  /// In zh, this message translates to:
  /// **'温暖童趣 亲切温暖，适合儿童阅读'**
  String get desktopShellS697;

  /// desktopShellS129
  ///
  /// In zh, this message translates to:
  /// **'PDF 文件 高质量 PDF（打印级别）'**
  String get desktopShellS129;

  /// desktopShellS89
  ///
  /// In zh, this message translates to:
  /// **'11:05:12 准备素材并构建 workspace'**
  String get desktopShellS89;

  /// desktopShellS90
  ///
  /// In zh, this message translates to:
  /// **'11:05:18 调用 sidecar 生成任务'**
  String get desktopShellS90;

  /// desktopShellS91
  ///
  /// In zh, this message translates to:
  /// **'11:05:28 校验 book.json 与 book.html'**
  String get desktopShellS91;

  /// desktopShellS92
  ///
  /// In zh, this message translates to:
  /// **'11:05:52 等待预览 / PDF 导出'**
  String get desktopShellS92;

  /// datasetPreviewS783
  ///
  /// In zh, this message translates to:
  /// **'示例素材'**
  String get datasetPreviewS783;

  /// datasetPreviewS853
  ///
  /// In zh, this message translates to:
  /// **'请先导入示例数据并完成一次生成，才能查看示例 PDF'**
  String get datasetPreviewS853;

  /// datasetPreviewS521
  ///
  /// In zh, this message translates to:
  /// **'打开示例 PDF：缺少可用预览来源'**
  String get datasetPreviewS521;

  /// datasetPreviewS771
  ///
  /// In zh, this message translates to:
  /// **'示例 PDF'**
  String get datasetPreviewS771;

  /// datasetPreviewS743
  ///
  /// In zh, this message translates to:
  /// **'生成日志详情'**
  String get datasetPreviewS743;

  /// datasetPreviewS852
  ///
  /// In zh, this message translates to:
  /// **'请先完成生成，再打开预览全部页面'**
  String get datasetPreviewS852;

  /// datasetPreviewS952
  ///
  /// In zh, this message translates to:
  /// **'预览全部页面：缺少 jobId'**
  String get datasetPreviewS952;

  /// datasetSampleS696
  ///
  /// In zh, this message translates to:
  /// **'温暖童趣'**
  String get datasetSampleS696;

  /// datasetSampleS101
  ///
  /// In zh, this message translates to:
  /// **'A4 竖版 210 × 297 mm'**
  String get datasetSampleS101;

  /// datasetSampleS697
  ///
  /// In zh, this message translates to:
  /// **'温暖童趣 亲切温暖，适合儿童阅读'**
  String get datasetSampleS697;

  /// datasetSampleS764
  ///
  /// In zh, this message translates to:
  /// **'确定要重置示例数据吗？'**
  String get datasetSampleS764;

  /// datasetSampleS894
  ///
  /// In zh, this message translates to:
  /// **'这会删除当前示例档案和示例素材，并重新恢复到初始状态。'**
  String get datasetSampleS894;

  /// datasetSampleS595
  ///
  /// In zh, this message translates to:
  /// **'未检测到示例数据档案，请先导入示例数据集'**
  String get datasetSampleS595;

  /// sidecarS151
  ///
  /// In zh, this message translates to:
  /// **'Sidecar 状态检查中'**
  String get sidecarS151;

  /// sidecarS266
  ///
  /// In zh, this message translates to:
  /// **'内置 PostgreSQL 启动失败，已阻断 sidecar 启动。'**
  String get sidecarS266;

  /// sidecarS155
  ///
  /// In zh, this message translates to:
  /// **'Sidecar 重启失败，初始化未完成。'**
  String get sidecarS155;

  /// sidecarS652
  ///
  /// In zh, this message translates to:
  /// **'正在启动 Sidecar'**
  String get sidecarS652;

  /// sidecarS145
  ///
  /// In zh, this message translates to:
  /// **'Sidecar 未就绪，初始化未完成。'**
  String get sidecarS145;

  /// sidecarS792
  ///
  /// In zh, this message translates to:
  /// **'等待上一步'**
  String get sidecarS792;

  /// datasetS857
  ///
  /// In zh, this message translates to:
  /// **'请先选择孩子档案'**
  String get datasetS857;

  /// datasetS469
  ///
  /// In zh, this message translates to:
  /// **'开始导入示例数据集'**
  String get datasetS469;

  /// datasetS657
  ///
  /// In zh, this message translates to:
  /// **'正在导入示例数据集...'**
  String get datasetS657;

  /// datasetS776
  ///
  /// In zh, this message translates to:
  /// **'示例数据集导入失败：sidecar 无响应或数据库未就绪'**
  String get datasetS776;

  /// datasetS391
  ///
  /// In zh, this message translates to:
  /// **'导入失败：Sidecar 未连接或数据库未就绪'**
  String get datasetS391;

  /// datasetS781
  ///
  /// In zh, this message translates to:
  /// **'示例数据集已导入，素材库已刷新'**
  String get datasetS781;

  /// datasetS779
  ///
  /// In zh, this message translates to:
  /// **'示例数据集导入未完成，请检查 sidecar'**
  String get datasetS779;

  /// exportActionsS850
  ///
  /// In zh, this message translates to:
  /// **'请先完成导出，再打开导出文件夹'**
  String get exportActionsS850;

  /// exportActionsS414
  ///
  /// In zh, this message translates to:
  /// **'导出文件夹'**
  String get exportActionsS414;

  /// exportActionsS416
  ///
  /// In zh, this message translates to:
  /// **'导出物尚未同步到 Supabase Storage，暂不能复制分享文案'**
  String get exportActionsS416;

  /// exportActionsS273
  ///
  /// In zh, this message translates to:
  /// **'分享文案已复制'**
  String get exportActionsS273;

  /// exportActionsS475
  ///
  /// In zh, this message translates to:
  /// **'当前导出不是长图，不能复制长图'**
  String get exportActionsS475;

  /// exportActionsS479
  ///
  /// In zh, this message translates to:
  /// **'当前平台暂不支持直接复制图片内容，已复制长图本地路径'**
  String get exportActionsS479;

  /// importPageS905
  ///
  /// In zh, this message translates to:
  /// **'选择本地数据目录'**
  String get importPageS905;

  /// importPageS904
  ///
  /// In zh, this message translates to:
  /// **'选择文件夹'**
  String get importPageS904;

  /// importPageS386
  ///
  /// In zh, this message translates to:
  /// **'导入前需要一个孩子档案，请先检查 sidecar 连接'**
  String get importPageS386;

  /// importPageS674
  ///
  /// In zh, this message translates to:
  /// **'没有可读取的本地文件，请确认选择的是图片、zip 或可访问的文件夹'**
  String get importPageS674;

  /// exportSyncS195
  ///
  /// In zh, this message translates to:
  /// **'sidecar 未返回导出物记录'**
  String get exportSyncS195;

  /// exportSyncS837
  ///
  /// In zh, this message translates to:
  /// **'缺少孩子档案，暂不能同步导出物'**
  String get exportSyncS837;

  /// exportSyncS337
  ///
  /// In zh, this message translates to:
  /// **'同步入队失败'**
  String get exportSyncS337;

  /// exportSyncS157
  ///
  /// In zh, this message translates to:
  /// **'Supabase Storage 同步失败'**
  String get exportSyncS157;

  /// exportGenerationStateS736
  ///
  /// In zh, this message translates to:
  /// **'生成完成，可预览并导出 PDF'**
  String get exportGenerationStateS736;

  /// exportGenerationStateS730
  ///
  /// In zh, this message translates to:
  /// **'生成失败，请检查 sidecar 日志'**
  String get exportGenerationStateS730;

  /// datasetExternalS760
  ///
  /// In zh, this message translates to:
  /// **'目录路径为空，无法打开'**
  String get datasetExternalS760;

  /// datasetExternalS478
  ///
  /// In zh, this message translates to:
  /// **'当前平台不支持打开本地路径'**
  String get datasetExternalS478;

  /// datasetExternalS477
  ///
  /// In zh, this message translates to:
  /// **'当前平台不支持外部打开'**
  String get datasetExternalS477;

  /// importPreviewS578
  ///
  /// In zh, this message translates to:
  /// **'未命名素材'**
  String get importPreviewS578;

  /// importSummaryS402
  ///
  /// In zh, this message translates to:
  /// **'导入结果未返回'**
  String get importSummaryS402;

  /// importSummaryS676
  ///
  /// In zh, this message translates to:
  /// **'没有收到 sidecar 导入统计，请检查本地服务状态'**
  String get importSummaryS676;

  /// directUploadS855
  ///
  /// In zh, this message translates to:
  /// **'请先选择一个孩子再创建扫码上传会话'**
  String get directUploadS855;

  /// directUploadS650
  ///
  /// In zh, this message translates to:
  /// **'正在创建 Direct Upload 扫码会话...'**
  String get directUploadS650;

  /// textUtilsS557
  ///
  /// In zh, this message translates to:
  /// **'无错误输出'**
  String get textUtilsS557;

  /// exportAssetSyncS862
  ///
  /// In zh, this message translates to:
  /// **'请先配置 Supabase Storage'**
  String get exportAssetSyncS862;

  /// exportPageS851
  ///
  /// In zh, this message translates to:
  /// **'请先完成生成，再导出'**
  String get exportPageS851;

  /// exportPageS410
  ///
  /// In zh, this message translates to:
  /// **'导出失败：缺少 jobId'**
  String get exportPageS410;

  /// exportPageS649
  ///
  /// In zh, this message translates to:
  /// **'正在准备导出目录...'**
  String get exportPageS649;

  /// exportPageS702
  ///
  /// In zh, this message translates to:
  /// **'点击导出，准备读取当前导出目录'**
  String get exportPageS702;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
