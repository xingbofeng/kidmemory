// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KidMemory';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get setupTitle => 'Setup';

  @override
  String get childProfileTitle => 'Child Profile';

  @override
  String get assetStudioTitle => 'Studio';

  @override
  String get assetLibraryTitle => 'Asset Library';

  @override
  String get sidebarSettingsTitle => 'Settings';

  @override
  String get sidebarLocalProfileTitle => 'Local Growth Record';

  @override
  String get localPriorityLabel => 'Local First';

  @override
  String get sidebarSignatureDescription =>
      'Every asset will enter the local growth profile.';

  @override
  String get generateExportTitle => 'Generate & Export';

  @override
  String get directUploadEntryButtonLabel => '扫码上传';

  @override
  String get directUploadDialogTitle => '手机扫码上传';

  @override
  String get directUploadPullBackActionLabel => '拉回本地';

  @override
  String get uploadRemoteStatusTitle => '回拉状态';

  @override
  String get actionCloseLabel => '关闭';

  @override
  String get directUploadRiskNotice => '上传完成后需在电脑端拉回，素材才会正式入库';

  @override
  String get uploadSessionPathLabel => '会话路径';

  @override
  String get uploadAccessLinkLabel => '扫码或复制链接';

  @override
  String get directUploadQrCodeLabel => '扫码上传链接二维码';

  @override
  String get directUploadNoItemsHint => '暂无远端对象，请先在手机端扫码上传';

  @override
  String get actionRetryLabel => '重试';

  @override
  String get uploadStatusPendingPullbackLabel => '等待回拉';

  @override
  String get uploadStatusDownloadingLabel => '回拉中';

  @override
  String get uploadStatusReadyLabel => '已入库';

  @override
  String get uploadStatusFailedLabel => '失败';

  @override
  String get uploadStatusUnknownErrorLabel => '未知错误';

  @override
  String get trustedUploadEntryButtonLabel => '扫码上传';

  @override
  String get errorTitle => '错误';

  @override
  String get trustedUploadSessionNotReadyMessage => '会话未创建';

  @override
  String get trustedUploadDialogTitle => '扫码上传';

  @override
  String get trustedUploadDescription => '后端可信上传：使用 signed upload、自动回拉入库';

  @override
  String get trustedUploadCopyOrScanLabel => '手机扫码或复制链接:';

  @override
  String get trustedUploadNetworkHint => '请确保手机可以访问上方 URL 所在的桌面端网络地址。';

  @override
  String get uploadStatusTotalLabel => '总计';

  @override
  String get uploadStatusWaitingLabel => '等待';

  @override
  String get uploadStatusUploadingLabel => '上传中';

  @override
  String get uploadStatusPullingLabel => '回拉中';

  @override
  String get setupPostgresTitle => '本地资料库';

  @override
  String get setupPgvectorTitle => 'pgvector 检测';

  @override
  String get setupOpenAiTitle => '大模型接口配置';

  @override
  String get setupLocalDataDirTitle => '本地数据目录';

  @override
  String get setupSidecarServiceTitle => 'KidMemory 本地服务';

  @override
  String get setupAgentServiceTitle => 'Agent service configuration';

  @override
  String get setupItemTitle => '配置项';

  @override
  String get setupWaitingConfigLoad => '等待配置读取';

  @override
  String get setupPending => '待检测';

  @override
  String get setupHealthy => '正常';

  @override
  String get setupNeedsAction => '需处理';

  @override
  String get setupPurposeLabel => '用途';

  @override
  String get setupPurposePrefixAscii => '用途:';

  @override
  String get setupPurposePrefixCn => '用途：';

  @override
  String get setupSystemConfigItemSummary => '系统配置项。';

  @override
  String get actionInstallAndConfigure => '安装与配置';

  @override
  String get actionStartSidecar => '启动 Sidecar';

  @override
  String get actionConfigure => '配置';

  @override
  String get actionConfigureDirectory => '配置目录';

  @override
  String get actionEditConfig => '修改配置';

  @override
  String get actionOpenDirectory => '打开目录';

  @override
  String get actionRefreshChecks => '刷新检测';

  @override
  String get actionTest => '测试';

  @override
  String get actionCheck => '检测';

  @override
  String get actionInstall => '安装';

  @override
  String get actionStart => '启动';

  @override
  String get actionDirectory => '目录';

  @override
  String get actionView => '查看';

  @override
  String get actionConfigurePathToken => '__action__:配置';

  @override
  String get setupCompletePreviousStepFirst => '请先完成上一步配置';

  @override
  String get setupDirectoryCannotEdit => '这个目录项暂时不能在桌面端修改';

  @override
  String get setupNoConfigDialog => '这个配置项暂无弹窗配置';

  @override
  String get setupNoAutoInstallFlow => '这个配置项暂无自动安装流程';

  @override
  String get setupHomebrewDirectoryNotWritable => 'Homebrew 目录不可写';

  @override
  String get setupLocalServiceResponsibilities =>
      'KidMemory 的本地服务负责配置、检测和数据任务。通常会随应用自动准备。';

  @override
  String get setupOpenAiConfigSaveFailed => 'OpenAI 配置保存失败';

  @override
  String get setupOpenAiConfigSaved => 'OpenAI 配置已保存';

  @override
  String get setupOpenAiConfigUpdated => 'OpenAI 配置已更新';

  @override
  String get setupOpenAiConfigUpdateFailed => 'OpenAI 配置更新失败';

  @override
  String get setupPostgresNotReadyNeedConfig =>
      'PostgreSQL 仍未就绪，安装 pgvector 前请先完成数据库配置';

  @override
  String get setupPostgresHandledButSidecarNotStarted =>
      'PostgreSQL 已处理，但 Sidecar 未能启动';

  @override
  String get setupPostgresConfigured => 'PostgreSQL 已配置完成';

  @override
  String get setupPostgresNotReadyAutoInstall =>
      'PostgreSQL 未就绪，自动执行 PostgreSQL 安装与配置';

  @override
  String get setupPostgresNotReadyCheckConfigRetry =>
      'PostgreSQL 未就绪，请检查数据库配置后重试';

  @override
  String get setupPostgresNotReadyStartLocalService =>
      'PostgreSQL 还未就绪，请启动本机服务后重试';

  @override
  String get setupStorageRestModeLabel => 'REST 方式（可选）';

  @override
  String get setupStorageS3ModeLabel => 'S3 方式（推荐）';

  @override
  String get setupSidecarStarted => '本地服务已启动';

  @override
  String get setupSidecarStartedSchemaNotReady => '本地服务已启动，资料库初始化未完成';

  @override
  String get setupSidecarConnected => '本地服务已连接';

  @override
  String get setupSidecarStartFailed => '本地服务未能启动';

  @override
  String get setupSidecarStartFailedNodeOrBundled =>
      '本地服务未能启动，请检查运行环境或重新打开 KidMemory';

  @override
  String get setupSidecarDisconnected => '本地服务未连接';

  @override
  String get setupStorageConfigTitle => '云端分享设置';

  @override
  String get setupStorageConfigSaveFailed => '云端分享设置保存失败';

  @override
  String get setupStorageConfigSaved => '云端分享设置已保存';

  @override
  String get setupPgvectorInitFailed => 'pgvector 初始化失败';

  @override
  String get setupPgvectorInitFailedExtMissing => 'pgvector 初始化失败，请确认扩展已安装';

  @override
  String get setupPgvectorNotReady => 'pgvector 尚未就绪';

  @override
  String get setupPgvectorNotReadyInstallExtRetry => 'pgvector 尚未就绪，请安装扩展后重试';

  @override
  String get setupPgvectorReady => 'pgvector 已安装并通过检测';

  @override
  String get setupPgvectorWaitForPostgres =>
      'pgvector 流程检测到 PostgreSQL 未就绪，自动联动执行 PostgreSQL 安装配置';

  @override
  String get setupSchemaInitFailed => 'schema 初始化未成功';

  @override
  String get setupSignedUrlDefaultHint => '不改的话，默认就是 1 小时，填 3600 就可以。';

  @override
  String get setupLocalDataDirectoryDescription =>
      '为 KidMemory 提供核心数据库连接，保存孩子资料、素材和生成历史。';

  @override
  String get actionSave => '保存';

  @override
  String get actionSaveSettings => '保存配置';

  @override
  String get agentSettingsTitle => 'Agent 设置';

  @override
  String get agentSettingsOpenAiDescription =>
      '配置 OpenAI Agent SDK 服务端点，用于生成儿童作品集。支持 OpenAI API 或兼容的本地服务。';

  @override
  String get agentSettingsSectionTitle => 'Agent SDK 配置';

  @override
  String get agentSettingsMissingConfigMessage => '请填写完整的配置信息';

  @override
  String get agentSettingsConnectionTestSuccess => '连接测试成功';

  @override
  String get agentSettingsConnectionTestFailed => '连接测试失败';

  @override
  String get agentSettingsSaveSuccess => 'Agent 配置已成功保存';

  @override
  String get agentSettingsConfigNameLabel => '配置名称';

  @override
  String get agentSettingsNameHelper => '用于在本机区分不同 Agent 配置';

  @override
  String get agentSettingsBaseUrlHint => 'https://api.openai.com 或本地服务地址';

  @override
  String get agentSettingsBaseUrlHelper => '支持 OpenAI API 或兼容的本地 Agent SDK 服务';

  @override
  String get agentSettingsApiKeyHint => 'sk-... 或本地服务的认证密钥';

  @override
  String get agentSettingsApiKeyHelper => '用于认证的 API 密钥';

  @override
  String get agentSettingsModelLabel => '模型名称';

  @override
  String get agentSettingsModelHint => 'gpt-4, gpt-3.5-turbo 等';

  @override
  String get agentSettingsModelDefaultHint => '留空将使用默认模型 gpt-4';

  @override
  String get agentSettingsUsageTitle => '使用说明';

  @override
  String get agentSettingsOpenAiStepTitle => '1. OpenAI API';

  @override
  String get agentSettingsOpenAiStepDescription => '使用官方 OpenAI API 服务';

  @override
  String get agentSettingsLocalStepTitle => '2. 本地服务';

  @override
  String get agentSettingsLocalStepDescription =>
      '运行兼容 OpenAI API 的本地 Agent SDK 服务';

  @override
  String get agentSettingsCustomEndpointStepTitle => '3. 自定义端点';

  @override
  String get agentSettingsCustomEndpointStepDescription =>
      '支持任何兼容 OpenAI API 格式的服务';

  @override
  String get setupStorageSectionIntro =>
      '推荐使用云端私有存储：接口地址、区域、存储空间名称和访问密钥都可以在云端控制台找到。存储空间建议保持私有，KidMemory 会在分享时自动生成带有效期的链接。';

  @override
  String get setupStoragePublicPrefixHint => '公开桶可填完整对象前缀';

  @override
  String get setupStoragePublicAccessPrefixLabel => '公开访问前缀（可选）';

  @override
  String get setupBuiltinPostgresNoPgvector =>
      '内置 PostgreSQL runtime 未包含 pgvector 扩展';

  @override
  String get setupBuiltinPostgresNoPgvectorInstruction =>
      '内置 PostgreSQL runtime 未包含 pgvector 扩展，请补齐后重试。';

  @override
  String get setupCreateLocalDatabase => '创建 KidMemory 本地资料库';

  @override
  String get setupInitStarted => '初始化';

  @override
  String get setupInitDatabaseSchema => '初始化 KidMemory 数据库结构';

  @override
  String get setupInitBuiltinDataDir => '初始化内置 PostgreSQL 数据目录';

  @override
  String get setupRegionLabel => '区域';

  @override
  String get setupStorageApiKeyHelpServiceRole =>
      '去 Supabase 的 Settings > API Keys 里找 service_role / secret key。';

  @override
  String get setupStorageBucketNameHint =>
      '去 Supabase 的 Storage > Buckets 里看 bucket 名。';

  @override
  String get setupStorageS3AccessKeyIdHint =>
      '去 Supabase 的 Storage > Settings > S3 说明页复制 Access Key ID。';

  @override
  String get setupStorageS3SecretKeyHint =>
      '去 Supabase 的 Storage > Settings > S3 说明页复制 Secret Access Key。';

  @override
  String get setupStorageS3EndpointHint =>
      '去 Supabase 的 Storage > Settings > S3 说明页复制 endpoint。';

  @override
  String get setupStorageProjectUrlHint =>
      '去 Supabase 项目首页或 Settings > API 里找 SUPABASE_URL。';

  @override
  String get actionCancel => '取消';

  @override
  String get setupPublicBucketOptionalHint => '只有公开桶才需要；私有桶可以留空，分享时会自动生成签名链接。';

  @override
  String get setupStatusStarting => '启动中';

  @override
  String get setupStartBuiltinPostgres => '启动内置 PostgreSQL 服务';

  @override
  String get setupEnableVectorExtension => '启用 vector 扩展';

  @override
  String get setupEnableVectorExtensionAndInit => '启用 vector 扩展并初始化 schema';

  @override
  String get setupRecheckPostgresConnection => '复查 PostgreSQL 连接';

  @override
  String get setupRecheckPgvectorExtension => '复查 pgvector 扩展';

  @override
  String get setupAutoUseAutoValue => '大多数项目直接填 auto 就行。';

  @override
  String get setupInstalling => '安装中';

  @override
  String get setupInstallCompleted => '安装完成';

  @override
  String get setupIntroAiStorageMessage =>
      '完成以下配置以启用 AI 能力与本地数据存储。我们会帮你检测环境并确保一切就绪。';

  @override
  String get setupChosen => '已选择';

  @override
  String get setupConfigured => '已配置';

  @override
  String get setupStartPostgresWorkflow => '开始 PostgreSQL 安装与配置流程';

  @override
  String get setupOpenApiKeysHelp => '打开 API Keys 官方说明';

  @override
  String get setupOpenS3CompatibilityHelp => '打开 S3 兼容性说明';

  @override
  String get setupOpenS3AuthHelp => '打开 S3 认证说明';

  @override
  String get setupOpenSupabaseApiKeysHelp => '打开 Supabase API Keys 官方说明';

  @override
  String get setupOpenSupabaseS3Docs => '打开 Supabase S3 官方说明';

  @override
  String get setupOpenBucketsHelp => '打开 buckets 官方说明';

  @override
  String get setupStorageEndpointLabel => '接口地址';

  @override
  String get setupOpenAiDescription =>
      '提供文本生成、标签与提示词能力。请配置 Base URL、模型与 API Key。';

  @override
  String get setupInitDatabaseSchemaFailed => '数据库结构初始化失败';

  @override
  String get actionShow => '显示';

  @override
  String get setupNoPostgresRuntimeFound =>
      '未找到可用 PostgreSQL runtime，请确认 Resources/postgres 或设置 KIDMEMORY_POSTGRES_RUNTIME_DIR。';

  @override
  String get setupPostgresRuntimeNotDetected =>
      '未检测到 PostgreSQL runtime，请确认 Resources/postgres 或仓库 third_party/postgres/macos 可用。';

  @override
  String get setupPostgresNotDetected => '未检测到 PostgreSQL，请确认本机服务已安装并启动';

  @override
  String get setupBundledPostgresRuntimeMissing => '未检测到内置 PostgreSQL runtime';

  @override
  String get setupBundledPostgresRuntimeReleaseRequired =>
      '未检测到内置 PostgreSQL runtime，请使用带 runtime 的 Release 包。';

  @override
  String get setupNotConfigured => '未配置';

  @override
  String get setupLocalPathSelected => '本地已选择';

  @override
  String get setupLocalPathUpdated => '本地数据目录已更新';

  @override
  String get setupLocalPathUpdatedSidecarPending =>
      '本地数据目录已更新；sidecar 启动后会继续读取配置';

  @override
  String get setupApiKeyVisibilityHint => '本地明文保存，点击眼睛可显示/隐藏';

  @override
  String get setupLocalServicePreparing => '本地服务准备中';

  @override
  String get setupVerifyBuiltinPgvectorExtension => '校验内置 pgvector 扩展';

  @override
  String get setupBucketNameLabel => '桶名';

  @override
  String get setupCheckPostgresService => '检测 PostgreSQL 服务';

  @override
  String get setupCheckPostgresConnection => '检测 PostgreSQL 连接';

  @override
  String get setupChecking => '检测中';

  @override
  String get setupRuntimeFoundInitialize => '检测到内置 PostgreSQL runtime，开始初始化。';

  @override
  String get setupCheckRequestNoResult => '检测请求已发出，但 sidecar 未返回结果';

  @override
  String get setupDownloading => '正在下载...';

  @override
  String get setupSidecarStarting => '正在启动本地服务...';

  @override
  String get setupInstallingSoftware => '正在安装...';

  @override
  String get setupTestingConnection => '正在测试连接...';

  @override
  String get setupFetchingResources => '正在获取资源...';

  @override
  String get setupConfiguring => '正在配置...';

  @override
  String get setupTestFailed => '测试失败';

  @override
  String get actionTestConnection => '测试连接';

  @override
  String get setupTestConnectionFailed => '测试连接失败';

  @override
  String get setupTestConnectionSuccess => '测试连接成功';

  @override
  String get setupEnvironmentReady => '环境已就绪';

  @override
  String get setupEnvironmentChecking => '环境检测中';

  @override
  String get setupEnvironmentReadyForCreation => '环境检测已通过，可进入正式创作流程。';

  @override
  String get setupCheckResultFromSidecar => '检测结果来自 sidecar';

  @override
  String get setupConnectingLocalService => '正在连接 KidMemory 本地服务';

  @override
  String get setupExportDescriptionHint => '用于保存导出结果与分享文件。';

  @override
  String get setupSignedUrlTTLLabel => '签名链接有效期（秒）';

  @override
  String get setupPageTitle => '设置';

  @override
  String get setupHomebrewPermissionRetryHint => '请修复 Homebrew 权限后重试。';

  @override
  String get setupConfigureStorageFirst => '请先填写云端分享所需参数';

  @override
  String get setupHomebrewPermissionCommandHint =>
      '请在终端执行以下命令修复权限后，再回到 KidMemory 重试：';

  @override
  String get setupSidecarConfigUnavailable => '读取本地服务配置失败，初始化未完成。';

  @override
  String get setupInputApiKey => '输入 API Key';

  @override
  String get setupInputAccessKeyId => '输入或粘贴 Access Key ID';

  @override
  String get setupInputSecretAccessKey => '输入或粘贴 Secret Access Key';

  @override
  String get setupInputServiceRoleKey => '输入或粘贴 Service Role Key';

  @override
  String get setupStorageDialogTitle => '配置云端分享';

  @override
  String get setupOpenAiDialogTitle => '配置大模型接口';

  @override
  String get actionReconnect => '重新连接';

  @override
  String get actionHide => '隐藏';

  @override
  String get setupCheckDependencyHint => '集中检查初始化依赖是否可用。';

  @override
  String get setupNeedsConfiguration => '需配置';

  @override
  String get setupProjectUrlLabel => '项目地址';

  @override
  String get setupTestCleanupFailedSuffix => '，测试对象清理失败';

  @override
  String get sampleDatasetPageTitle => '示例数据集';

  @override
  String get sampleDatasetPageSubtitle =>
      '使用隐私安全的虚拟素材，快速体验 KidMemory 的素材库、创作台和导出流程。';

  @override
  String get sampleDatasetBackTooltip => '返回孩子档案';

  @override
  String get contentMetricTotalLabel => '素材总数';

  @override
  String get contentCategoryArtworkLabel => '儿童画';

  @override
  String get contentCategoryCraftLabel => '手工作品';

  @override
  String get contentLicenseLabel => '素材许可';

  @override
  String get contentAssetTypePhotoLabel => '照片';

  @override
  String get assetLibrarySearchHintText => '搜索素材、标签、描述...';

  @override
  String get assetLibrarySearchingLabel => '搜索中';

  @override
  String get assetLibrarySearchButtonLabel => '搜索';

  @override
  String get assetLibrarySmartPickLabel => '帮我挑素材';

  @override
  String get assetLibrarySmartOrganizeLabel => 'AI 帮我整理素材';

  @override
  String get assetLibraryImportPhotoLabel => '导入图片';

  @override
  String get assetLibraryImportFolderLabel => '导入文件夹';

  @override
  String get assetLibraryImportDescriptionText =>
      '导入本地图片、整个文件夹，或把文件拖拽到素材库后，这里会显示真实缩略图和 metadata 编辑入口。';

  @override
  String get assetLibrarySortLabel => '排序';

  @override
  String get assetLibraryIndexRefreshingLabel => '索引刷新中';

  @override
  String get assetLibraryRefreshIndexLabel => '刷新索引';

  @override
  String get assetLibraryChildLabel => '孩子';

  @override
  String get assetLibraryNoChildProfileText => '暂无孩子档案';

  @override
  String get assetLibraryClearSelectionLabel => '取消选择';

  @override
  String get assetLibraryClearSearchLabel => '清空搜索';

  @override
  String get assetLibraryClearSearchActionLabel => '清除';

  @override
  String get assetLibraryBatchGeneratePictureBookLabel => '生成绘本';

  @override
  String get assetLibraryBatchGenerateVideoLabel => '生成回忆视频';

  @override
  String get assetLibraryBatchGenerateAlbumLabel => '生成纪念册';

  @override
  String get assetLibraryGoToGenerateLabel => '去生成作品集';

  @override
  String get assetLibraryBatchDeletingLabel => '删除中...';

  @override
  String get assetLibraryBatchDeleteButtonLabel => '批量删除';

  @override
  String get assetLibraryEmptyLibraryTitle => '还没有素材';

  @override
  String get assetLibraryNoSelectedAssetsText => '选择一个素材';

  @override
  String get assetLibraryEmptySearchTitle => '没有找到匹配素材';

  @override
  String get assetLibrarySearchFallbackHint => '试试换个关键词，或让 Agent 帮你挑选相关素材。';

  @override
  String get assetLibrarySelectAssetTitle => '选择素材后会在这里汇总。';

  @override
  String get assetLibraryInspectorHintText =>
      '在这里查看和编辑标题、标签、描述，也可以让 Agent 帮你整理素材。';

  @override
  String get sampleDatasetInfoCardTitle => '数据说明';

  @override
  String get sampleDatasetInfoCardDescription => '虚拟脱敏素材，仅用于功能演示。可随时重置为干净状态。';

  @override
  String get sampleDatasetImportStepsTitle => '导入步骤';

  @override
  String get sampleDatasetImportStepsDescription =>
      '确认数据，点击导入，等待完成，然后继续探索生成流程。';

  @override
  String get sampleDatasetExpectedOutputTitle => '预期输出';

  @override
  String get sampleDatasetExpectedOutputDescription =>
      '手动导入素材与标签后，可继续体验创作台与样例 PDF。';

  @override
  String get sampleDatasetAfterImportDescriptionTitle => '导入后将包含';

  @override
  String get sampleDatasetImportingStatusTitle => '正在导入示例数据...';

  @override
  String get sampleDatasetImportingStatusDescription => '创建示例孩子档案、导入示例素材并写入标签。';

  @override
  String get sampleDatasetImportingActionLabel => '导入中...';

  @override
  String get sampleDatasetViewPdfLabel => '查看示例 PDF';

  @override
  String get sampleDatasetNotImportedTitle => '状态：未导入';

  @override
  String get sampleDatasetImportInstructionText => '点击导入后，示例素材会写入本地数据库。';

  @override
  String get sampleDatasetImportButtonLabel => '导入示例数据集';

  @override
  String get sampleDatasetBrowseAssetsLabel => '浏览示例素材';

  @override
  String get sampleDatasetGenerateSampleBookLabel => '生成示例绘本';

  @override
  String get sampleDatasetImportedTitle => '示例数据已导入';

  @override
  String get sampleDatasetImportedStatusText => '你可以继续浏览示例素材，或体验生成流程。';

  @override
  String get sampleDatasetResetDataLabel => '重置数据';

  @override
  String get sampleDatasetResetDataHint => '请检查本地数据库和示例素材文件。';

  @override
  String get sampleDatasetRetryImportButtonLabel => '重试导入';

  @override
  String get sampleDatasetImportFailedTitle => '导入失败';

  @override
  String get sampleDatasetPlaceholderSunlightGardenLabel => '阳光花园';

  @override
  String get sampleDatasetPlaceholderGrassFieldLabel => '草地男孩';

  @override
  String get sampleDatasetPlaceholderBirthdayCakeLabel => '生日蛋糕';

  @override
  String get sampleDatasetPlaceholderBirthdayBoyLabel => '生日男孩';

  @override
  String get sampleDatasetPlaceholderOceanWorldLabel => '海底世界';

  @override
  String get sampleDatasetPlaceholderDinosaurWorldLabel => '恐龙世界';

  @override
  String get sampleDatasetPlaceholderHappinessFamilyLabel => '幸福一家';

  @override
  String get sampleDatasetPlaceholderDrawingLabel => '小熊画';

  @override
  String get sampleDatasetPlaceholderSunlightGardenPath =>
      'asset://assets/sample_dataset/raster/阳光花园.png';

  @override
  String get sampleDatasetPlaceholderGrassFieldPath =>
      'asset://assets/sample_dataset/raster/草地男孩.png';

  @override
  String get sampleDatasetPlaceholderBirthdayCakePath =>
      'asset://assets/sample_dataset/raster/生日蛋糕.png';

  @override
  String get sampleDatasetPlaceholderBirthdayBoyPath =>
      'asset://assets/sample_dataset/raster/生日男孩.png';

  @override
  String get sampleDatasetPlaceholderOceanWorldPath =>
      'asset://assets/sample_dataset/raster/海底世界.png';

  @override
  String get sampleDatasetPlaceholderDinosaurWorldPath =>
      'asset://assets/sample_dataset/raster/恐龙世界.png';

  @override
  String get sampleDatasetPlaceholderHappinessFamilyPath =>
      'asset://assets/sample_dataset/raster/幸福一家.png';

  @override
  String get sampleDatasetPlaceholderDrawingPath =>
      'asset://assets/sample_dataset/raster/小熊画.png';

  @override
  String get contentPreparingStatusLabel => '正在准备...';

  @override
  String get contentProcessingStatusLabel => '正在处理中...';

  @override
  String get contentNeedsConfigurationLabel => '需配置';

  @override
  String get contentNotConfiguredLabel => '未配置';

  @override
  String get contentDisconnectedLabel => '未连接';

  @override
  String get contentWaitingLabel => '准备中';

  @override
  String get contentTestLabel => '测试';

  @override
  String get contentCheckLabel => '检测';

  @override
  String get contentConfigureLabel => '配置';

  @override
  String get contentModifyLabel => '修改';

  @override
  String get contentDirectoryLabel => '目录';

  @override
  String get contentConnectLabel => '连接';

  @override
  String get contentModelLabel => '大模型';

  @override
  String get contentArtworkDescriptionText => '包含当前示例孩子的儿童画素材';

  @override
  String get contentCraftDescriptionText => '包含纸板、手工和结构化素材';

  @override
  String get contentPhotoDescriptionText => '含拍照素材与扫描件';

  @override
  String get contentTagInfoText => '包含主题、颜色、场景和创作类型标签';

  @override
  String get contentAssetPreviewFallbackTitle => '作品预览';

  @override
  String get contentPreviewCloseHint => '点击右上角可关闭预览';

  @override
  String get contentTypeFilterAllLabel => '全部';

  @override
  String get contentDrawingCountLabel => '绘画数量';

  @override
  String get contentPhotoCountLabel => '照片数量';

  @override
  String get contentGeneratedPdfLabel => '已生成 PDF';

  @override
  String get contentAssetDistributionTitle => '素材分布';

  @override
  String get contentAssetDistributionSummaryText => '绘画作品 49% 照片 35% 手工作品 9%';

  @override
  String get contentRecentWorksTitle => '最近作品';

  @override
  String get contentPortfolioRecordTitle => '作品集记录';

  @override
  String get contentSampleBookTitleSpring => '春日拾光 · 2025-04-01 · 24页';

  @override
  String get contentSampleBookTitleBirthday => '三岁生日纪念册 · 2024-06-20 · 32页';

  @override
  String get contentSampleBookTitleDaycare => '幼儿园生活点滴 · 2024-01-15 · 28页';

  @override
  String get contentBannerHeaderSubtitle => '每一个笑容，都值得被珍藏。';

  @override
  String get contentBannerHeaderTitle => '每一幅画，都是成长的印记';

  @override
  String get contentAssetSearchHint => '搜索素材名称、标签或来源...';

  @override
  String get contentPagerPreviousTooltip => '上一页';

  @override
  String get contentPagerNextTooltip => '下一页';

  @override
  String get contentCollectionTotalCountLabel => '1,248 个';

  @override
  String get contentNoTagReasonHint => '待补充标签';

  @override
  String get contentDateMissingLabel => '未填写日期';

  @override
  String get contentUnnamedPhotoLabel => '未命名照片';

  @override
  String get contentUnnamedCraftLabel => '未命名手工';

  @override
  String get contentUnnamedDrawingLabel => '未命名绘画';

  @override
  String get contentPreviewWaitingForGenerationLabel => '等待生成';

  @override
  String get contentPreviewCompletedLabel => '预览完成 可预览全部内容';

  @override
  String get contentPreviewWaitingLabel => '预览等待 生成后可查看';

  @override
  String get contentExportCompletedFileLabel => '已导出 文件完成';

  @override
  String get contentExportFormatSelectionHint => '可导出 生成后选择格式';

  @override
  String get contentNoSelectedAssetsHint => '暂无已选素材';

  @override
  String get contentViewAllLabel => '查看全部';

  @override
  String get contentCoverAppearsAfterGenerationLabel => '封面将在生成后出现';

  @override
  String get contentStoryPagesWaitingLabel => '故事页面等待生成';

  @override
  String get contentExportBeforePreviewHint => '导出前先完成预览';

  @override
  String get contentTaskProgressLogTitle => '任务进度日志';

  @override
  String get contentViewDetailsLabel => '查看详细日志';

  @override
  String get contentPreviewWaitingTitle => '页面预览（等待生成）';

  @override
  String get contentPreviewAvailableAfterGenerationHint => '预览会在生成完成后显示';

  @override
  String get contentSectionCoverLabel => '1 封面';

  @override
  String get contentSectionStoriesLabel => '2 素材故事';

  @override
  String get contentSectionGrowthRecordsLabel => '3 成长记录';

  @override
  String get contentAssetTypeCraftLabel => '手工';

  @override
  String get contentCategoryDrawingLabel => '绘画';

  @override
  String get contentOpenLabel => '打开';

  @override
  String get contentTagLabel => '标签';

  @override
  String get generateExportS83 => '0 / 建议 6+';

  @override
  String get generateExportS102 => 'AI 帮我挑素材';

  @override
  String get generateExportS105 => 'Agent 执行计划';

  @override
  String get generateExportS107 => 'Agent 正在规划';

  @override
  String get generateExportS108 => 'Agent 活动';

  @override
  String get generateExportS128 => 'PDF 已导出';

  @override
  String get generateExportS214 => '不可用';

  @override
  String get generateExportS218 => '云端分享';

  @override
  String get generateExportS219 => '仅本地';

  @override
  String get generateExportS220 => '仅本地文件';

  @override
  String get generateExportS226 => '任务执行失败';

  @override
  String get generateExportS227 => '任务状态';

  @override
  String get generateExportS237 => '你想为孩子创作什么？';

  @override
  String get generateExportS243 => '例如：用春游照片做一本 8 页绘本';

  @override
  String get generateExportS245 => '保存 / 分享';

  @override
  String get generateExportS255 => '儿童绘本';

  @override
  String get generateExportS270 => '准备大纲';

  @override
  String get generateExportS272 => '准备开始';

  @override
  String get generateExportS274 => '分享链接';

  @override
  String get generateExportS275 => '分享链接已生成，可直接发送给家人查看。';

  @override
  String get generateExportS279 => '创作类型';

  @override
  String get generateExportS315 => '原因：免费生图服务暂时不可用。请重试，或查看日志了解详情。';

  @override
  String get generateExportS324 => '去素材库选择';

  @override
  String get generateExportS328 => '可在保存目录中查看';

  @override
  String get generateExportS329 => '可复制分享文案';

  @override
  String get generateExportS331 => '可打开或分享';

  @override
  String get generateExportS332 => '可查看预览';

  @override
  String get generateExportS334 => '可预览';

  @override
  String get generateExportS335 => '可预览或导出';

  @override
  String get generateExportS336 => '同步中';

  @override
  String get generateExportS340 => '同步失败';

  @override
  String get generateExportS357 => '复制分享文案';

  @override
  String get generateExportS358 => '复制长图';

  @override
  String get generateExportS404 => '导出 JPG 长图';

  @override
  String get generateExportS405 => '导出 PDF';

  @override
  String get generateExportS406 => '导出 PNG 长图';

  @override
  String get generateExportS407 => '导出作品';

  @override
  String get generateExportS409 => '导出后解锁';

  @override
  String get generateExportS411 => '导出完成后才能打开文件夹或复制长图。';

  @override
  String get generateExportS413 => '导出效果';

  @override
  String get generateExportS415 => '导出物尚未上传分享，暂不能复制分享文案。';

  @override
  String get generateExportS417 => '导出目标';

  @override
  String get generateExportS418 => '导出结果';

  @override
  String get generateExportS419 => '封面';

  @override
  String get generateExportS420 => '封面、故事页和成长记录已准备好，可以继续导出。';

  @override
  String get generateExportS421 => '封面图生成失败';

  @override
  String get generateExportS427 => '尚未创建生成任务';

  @override
  String get generateExportS428 => '尚未导出';

  @override
  String get generateExportS438 => '已同步';

  @override
  String get generateExportS442 => '已完成';

  @override
  String get generateExportS444 => '已导出';

  @override
  String get generateExportS450 => '已生成';

  @override
  String get generateExportS452 => '已生成分享链接';

  @override
  String get generateExportS460 => '已选素材';

  @override
  String get generateExportS470 => '开始生成绘本';

  @override
  String get generateExportS472 => '异常';

  @override
  String get generateExportS473 => '当前任务';

  @override
  String get generateExportS476 => '当前导出不是长图，不能复制长图内容。';

  @override
  String get generateExportS518 => '打开导出文件夹';

  @override
  String get generateExportS532 => '按时间线整理成长记录';

  @override
  String get generateExportS547 => '故事已生成';

  @override
  String get generateExportS548 => '故事页';

  @override
  String get generateExportS553 => '文案风格';

  @override
  String get generateExportS611 => '本地文件';

  @override
  String get generateExportS617 => '本次作品集';

  @override
  String get generateExportS623 => '查看已选素材';

  @override
  String get generateExportS624 => '查看日志';

  @override
  String get generateExportCreateShareDialogTitle => '创建 Web 分享链接';

  @override
  String get generateExportCreateShareDialogBody =>
      '这会将导出作品上传到云端，用于生成 Web 分享链接。';

  @override
  String get generateExportCreateShareLinkLabel => '创建分享链接';

  @override
  String get generateExportShareCreatingStatus => '正在创建 Web 分享链接...';

  @override
  String get generateExportShareCreatedStatus => 'Web 分享链接已创建';

  @override
  String get generateExportShareFailedStatus => '分享链接创建失败';

  @override
  String get generateExportShareReadyHint => '作品已导出，可以创建 Web 分享链接。';

  @override
  String get generateExportCopyLinkLabel => '复制链接';

  @override
  String get generateExportOpenLinkLabel => '打开链接';

  @override
  String get generateExportRetryShareLabel => '重试创建';

  @override
  String get generateExportShareNotReady => '导出作品尚未准备好，暂不能创建分享链接。';

  @override
  String generateExportShareText(String shareUrl) {
    return 'KidMemory 作品：$shareUrl';
  }

  @override
  String generateExportShareExceptionMessage(Object error) {
    return '分享链接创建失败：$error';
  }

  @override
  String get generateExportPreviewFailedTitle => 'PDF preview failed';

  @override
  String get generateExportPreviewFailedBody =>
      'The preview window did not open. Check the reason, open the export folder to inspect the local file, or view logs to continue debugging.';

  @override
  String generateExportPreviewFailureReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String generateExportPreviewFailedStatus(Object error) {
    return 'PDF preview failed: $error';
  }

  @override
  String get generateExportEditRequestLabel => '修改需求';

  @override
  String get generateExportS627 => '查看素材';

  @override
  String get generateExportS644 => '模板';

  @override
  String get generateExportS647 => '正在写故事';

  @override
  String get generateExportS651 => '正在创建作品集';

  @override
  String get generateExportS662 => '正在生成作品集';

  @override
  String get generateExportS663 => '正在生成预览页面，完成后会展示封面、故事页和导出效果。';

  @override
  String get generateExportS698 => '渲染预览';

  @override
  String get generateExportS708 => '状态';

  @override
  String get generateExportS717 => '生成 6-12 页故事绘本';

  @override
  String get generateExportS718 => '生成中';

  @override
  String get generateExportS719 => '生成中...';

  @override
  String get generateExportS721 => '生成儿童绘本';

  @override
  String get generateExportS723 => '生成后可上传分享';

  @override
  String get generateExportS724 => '生成后可导出';

  @override
  String get generateExportS725 => '生成后展示';

  @override
  String get generateExportS726 => '生成后查看日志';

  @override
  String get generateExportS727 => '生成回忆录视频';

  @override
  String get generateExportS729 => '生成失败';

  @override
  String get generateExportS731 => '生成完成';

  @override
  String get generateExportS735 => '生成完成后，可以导出 PDF、长图或创建分享链接。';

  @override
  String get generateExportS738 => '生成带字幕和音乐的短视频';

  @override
  String get generateExportS740 => '生成成长纪念册';

  @override
  String get generateExportS741 => '生成控制台';

  @override
  String get generateExportS742 => '生成故事';

  @override
  String get generateExportS747 => '生成计划';

  @override
  String get generateExportS769 => '确认：调用免费生图';

  @override
  String get generateExportS790 => '第 1 页';

  @override
  String get generateExportS794 => '等待导出';

  @override
  String get generateExportS795 => '等待开始';

  @override
  String get generateExportS796 => '等待开始。点击“开始生成”后，这里会显示素材分析、故事生成、预览渲染和导出进度。';

  @override
  String get generateExportS797 => '等待执行';

  @override
  String get generateExportS800 => '等待选择素材';

  @override
  String get generateExportS802 => '等待重试';

  @override
  String get generateExportS808 => '素材';

  @override
  String get generateExportS813 => '素材已准备';

  @override
  String get generateExportS819 => '素材未选择';

  @override
  String get generateExportS821 => '素材状态';

  @override
  String get generateExportS833 => '继续生成';

  @override
  String get generateExportS841 => '让 Agent 重新挑选';

  @override
  String get generateExportS859 => '请先选择素材，之后即可开始生成。';

  @override
  String get generateExportS860 => '请先选择素材，开始生成才会启用。';

  @override
  String get generateExportS868 =>
      '请选择孩子的照片、画作或手工作品。素材准备好后，Agent 会生成创作计划并开始预览。';

  @override
  String get generateExportS871 => '调整模板、尺寸和导出方式。设置完成后即可开始创作。';

  @override
  String get generateExportS875 => '超时';

  @override
  String get generateExportS883 => '输入目标或选择快捷类型，Agent 会按素材、故事、预览和导出组织创作流程。';

  @override
  String get generateExportS884 => '输出';

  @override
  String get generateExportS889 => '还没有选择素材。请选择孩子的照片、画作或手工作品，建议至少 6 张。';

  @override
  String get generateExportS893 => '这些素材会进入本次创作计划。你可以返回素材库重新选择，或让 Agent 重新挑选。';

  @override
  String get generateExportS895 => '进行中';

  @override
  String get generateExportS907 => '选择素材';

  @override
  String get generateExportS909 => '选择素材和创作方式，KidMemory 会帮你生成绘本、成长纪念册或回忆视频。';

  @override
  String get generateExportS921 => '重新生成';

  @override
  String get generateExportS923 => '重新选择';

  @override
  String get generateExportS930 => '错误原因';

  @override
  String get generateExportS931 => '长图 JPG';

  @override
  String get generateExportS934 => '长图 PNG';

  @override
  String get generateExportS942 => '页面尺寸';

  @override
  String get generateExportS943 => '页面预览';

  @override
  String get generateExportS949 => '预览与导出将在生成后解锁';

  @override
  String get generateExportS951 => '预览全部页面';

  @override
  String get generateExportS954 => '预览将在生成后出现。KidMemory 会在这里展示封面、页面和导出效果。';

  @override
  String get generateExportS956 => '风格';

  @override
  String get generateExportS957 => '默认';

  @override
  String get assetLibraryPageS285 => '创建时间（最新）';

  @override
  String get assetLibraryPageS286 => '创建时间（最早）';

  @override
  String get assetLibraryPageS786 => '种类（绘画/照片/手工）';

  @override
  String get assetLibraryPageS631 => '标题（A-Z）';

  @override
  String get assetLibraryPageS879 => '输入关键词可本地筛选，也可以使用语义搜索';

  @override
  String get assetLibraryPageS847 => '语义索引待加载';

  @override
  String get assetLibraryPageS433 => '已切换孩子档案，可重新搜索';

  @override
  String get assetLibraryPageS599 => '未选择孩子';

  @override
  String get assetLibraryPageS660 => '正在本地筛选素材';

  @override
  String get assetLibraryPageS483 => '当前环境暂未启用语义搜索';

  @override
  String get assetLibraryPageS858 => '请先选择孩子档案再搜索';

  @override
  String get assetLibraryPageS867 => '请输入标题、标签或自然语言描述';

  @override
  String get assetLibraryPageS665 => '正在语义搜索...';

  @override
  String get assetLibraryPageS825 => '索引状态不可用';

  @override
  String get assetLibraryPageS440 => '已回到素材库浏览';

  @override
  String get assetLibraryPageS572 => '暂时无法挑选';

  @override
  String get assetLibraryPageS481 => '当前没有可用素材，请先导入素材后再试。';

  @override
  String get assetLibraryPageS869 => '请选择本次目标：';

  @override
  String get assetLibraryPageS902 => '适合做绘本';

  @override
  String get assetLibraryPageS901 => '适合做成长纪念册';

  @override
  String get assetLibraryPageS900 => '适合做回忆录视频';

  @override
  String get assetLibraryPageS503 => '手动调整';

  @override
  String get assetLibraryPageS919 => '重新挑选';

  @override
  String get assetLibraryPageS765 => '确认使用';

  @override
  String get assetLibraryPageS564 => '智能挑选已应用';

  @override
  String get assetLibraryPageS430 => '已保留当前选择';

  @override
  String get assetLibraryPageS235 => '你可以继续手动勾选素材。';

  @override
  String get assetLibraryPageS531 => '拖入的路径暂时无法导入';

  @override
  String get assetLibraryPageS403 => '导入部分完成';

  @override
  String get assetLibraryPageS392 => '导入完成';

  @override
  String get assetLibraryPageS581 => '未导入素材';

  @override
  String get assetLibraryPageS767 => '确认批量删除';

  @override
  String get assetLibraryPageS296 => '删除';

  @override
  String get assetLibraryPageS619 => '来源';

  @override
  String get assetLibraryPageS284 => '创建时间';

  @override
  String get assetLibraryPageS289 => '创建者';

  @override
  String get assetLibraryPageS782 => '示例档案';

  @override
  String get assetLibraryPageS620 => '来源设备';

  @override
  String get assetLibraryPageS268 => '内置示例';

  @override
  String get assetLibraryPageS368 => '存储位置';

  @override
  String get assetLibraryPageS784 => '示例素材库';

  @override
  String get assetLibraryPageS225 => '从本次作品集移除';

  @override
  String get assetLibraryPageS308 => '加入本次作品集';

  @override
  String get assetLibraryPageS221 => '仅用于本次生成，不会修改原始素材';

  @override
  String get assetLibraryPageS575 => '有未保存修改';

  @override
  String get assetLibraryPageS630 => '标题';

  @override
  String get assetLibraryPageS242 => '例如：春游里的泡泡';

  @override
  String get assetLibraryPageS806 => '类型';

  @override
  String get assetLibraryPageS558 => '日期';

  @override
  String get assetLibraryPageS95 => '2026-05-17 或 2026年5月17日';

  @override
  String get assetLibraryPageS498 => '户外、泡泡、春游';

  @override
  String get assetLibraryPageS535 => '描述';

  @override
  String get assetLibraryPageS843 => '记录这份素材背后的故事';

  @override
  String get assetLibraryPageS614 => '本地状态';

  @override
  String get assetLibraryPageS824 => '索引状态';

  @override
  String get assetLibraryPageS528 => '技术信息';

  @override
  String get assetLibraryPageS316 => '原始文件';

  @override
  String get assetLibraryPageS615 => '本地素材';

  @override
  String get assetLibraryPageS616 => '本地路径';

  @override
  String get assetLibraryPageS597 => '未记录';

  @override
  String get assetLibraryPageS246 => '保存中...';

  @override
  String get assetLibraryPageS247 => '保存修改';

  @override
  String get assetLibraryPageS546 => '放弃修改';

  @override
  String get assetLibraryPageS516 => '打开原图';

  @override
  String get assetLibraryPageS304 => '删除素材';

  @override
  String get assetLibraryPageS249 => '保存成功';

  @override
  String get assetLibraryPageS248 => '保存失败';

  @override
  String get assetLibraryPageS766 => '确认删除素材';

  @override
  String get assetLibraryPageS298 => '删除后将从本地素材库移除，是否继续？';

  @override
  String get assetLibraryPageS434 => '已删除';

  @override
  String get assetLibraryPageS299 => '删除失败';

  @override
  String get assetLibraryPageS447 => '已打开原图';

  @override
  String get assetLibraryPageS437 => '已加入同步队列';

  @override
  String get assetLibraryPageS338 => '同步入队失败，请检查云端分享设置';

  @override
  String get childProfileS715 => '珍藏成长点滴，记录美好时光';

  @override
  String get childProfileS645 => '欢迎使用 KidMemory';

  @override
  String get childProfileS887 => '还没有孩子档案';

  @override
  String get childProfileS693 => 'Add child profile';

  @override
  String get childProfileS625 => '查看示例';

  @override
  String get childProfileS842 => '记录素材';

  @override
  String get childProfileS706 => '照片、视频、笔记';

  @override
  String get childProfileS495 => '成长时间轴';

  @override
  String get childProfileS925 => '重要时刻，一目了然';

  @override
  String get childProfileS231 => '作品集';

  @override
  String get childProfileS714 => '珍藏创作与成果';

  @override
  String get childProfileS224 => '从一份档案开始';

  @override
  String get childProfileS499 => '所有孩子信息和成长素材本地保存';

  @override
  String get childProfileS602 => '本地存储，隐私安心';

  @override
  String get childProfileS500 => '所有数据仅保存在你的设备中';

  @override
  String get childProfileS785 => '离线可用，随时记录';

  @override
  String get childProfileS556 => '无网络也能查看与添加内容';

  @override
  String get childProfileS223 => '从一个孩子开始';

  @override
  String get childProfileS342 => '后续可随时添加更多孩子档案';

  @override
  String get childProfileS238 => '你的数据，只属于你和孩子';

  @override
  String get childProfileS554 => '新增';

  @override
  String get childProfileS834 => '编辑';

  @override
  String get childProfileS401 => '导入素材后，这里会按真实素材更新成长统计和最近作品。';

  @override
  String get childProfileS486 => '当前素材库已连接到本地服务，可用于生成成长作品集。';

  @override
  String get childProfileS480 => '当前档案';

  @override
  String get childProfileS276 => '切换孩子档案';

  @override
  String get childProfileS757 => '男孩';

  @override
  String get childProfileS366 => '女孩';

  @override
  String get childProfileS425 => '小朋友';

  @override
  String get childProfileS400 => '导入素材后显示最近作品';

  @override
  String get childProfileS733 => '生成完成后会显示本地作品集记录';

  @override
  String get childProfileS287 => '创建档案';

  @override
  String get childProfileS222 => '今天';

  @override
  String get childProfileS399 => '导入素材';

  @override
  String get childProfileS487 => '待开始';

  @override
  String get childProfileS720 => '生成作品';

  @override
  String get childProfileS633 => '档案信息';

  @override
  String get childProfileS367 => '姓名';

  @override
  String get childProfileS574 => '最近素材';

  @override
  String get childProfileS566 => '暂无';

  @override
  String get childProfileS497 => '成长里程碑';

  @override
  String get childProfileS799 => '等待第一份素材';

  @override
  String get childProfileS446 => '已开始积累成长素材';

  @override
  String get childProfileS670 => '每一份素材，都会进入本地成长档案';

  @override
  String get childProfileS832 => '统计和时间线来自当前孩子的素材库。';

  @override
  String get childProfileS872 => '调色';

  @override
  String get childProfileS217 => '书本';

  @override
  String get datasetChildrenS690 => '添加孩子档案';

  @override
  String get datasetChildrenS688 => '添加';

  @override
  String get datasetChildrenS689 => '添加失败：请确认 Sidecar 已启动';

  @override
  String get datasetChildrenS854 => '请先添加一个孩子再编辑资料';

  @override
  String get datasetChildrenS835 => '编辑资料';

  @override
  String get datasetChildrenS856 => '请先选择一个孩子档案';

  @override
  String get datasetChildrenS301 => '删除孩子档案';

  @override
  String get datasetChildrenS300 => '删除失败：请先清空这个孩子关联的素材';

  @override
  String get datasetChildrenS906 => '选择生日';

  @override
  String get datasetChildrenS762 => '确定';

  @override
  String get datasetChildrenS748 => '生日';

  @override
  String get datasetChildrenS703 => '点按选择生日';

  @override
  String get datasetChildrenS356 => '备注';

  @override
  String get datasetChildrenS263 => '兴趣、性格、记录偏好等';

  @override
  String get nodeInstallS161 => 'Volta 安装 Node.js';

  @override
  String get nodeInstallS177 => 'fnm 安装 Node.js';

  @override
  String get nodeInstallS123 => 'MacPorts 安装 Node.js';

  @override
  String get nodeInstallS180 => 'nodenv 安装 Node.js';

  @override
  String get nodeInstallS586 => '未找到可用的 macOS Node.js 安装器，请先安装 Node.js 后重试。';

  @override
  String get nodeInstallS115 => 'Homebrew 安装 Node.js';

  @override
  String get nodeInstallS202 => 'winget 安装 Node.js';

  @override
  String get nodeInstallS111 => 'Chocolatey 安装 Node.js';

  @override
  String get nodeInstallS139 => 'Scoop 安装 Node.js';

  @override
  String get nodeInstallS594 => '未检测到可用的 Windows Node.js 安装器。';

  @override
  String get nodeInstallS167 => 'apt-get 安装 Node.js';

  @override
  String get nodeInstallS176 => 'dnf 安装 Node.js';

  @override
  String get nodeInstallS203 => 'yum 安装 Node.js';

  @override
  String get nodeInstallS181 => 'pacman 安装 Node.js';

  @override
  String get nodeInstallS204 => 'zypper 安装 Node.js';

  @override
  String get nodeInstallS166 => 'apk 安装 Node.js';

  @override
  String get nodeInstallS593 => '未检测到可用的 Linux Node.js 安装器。';

  @override
  String get desktopShellDefaultsS101 => 'A4 竖版 210 × 297 mm';

  @override
  String get desktopShellDefaultsS100 => 'A4 横版 297 × 210 mm';

  @override
  String get desktopShellDefaultsS99 => 'A3 竖版 297 × 420 mm';

  @override
  String get desktopShellDefaultsS697 => '温暖童趣 亲切温暖，适合儿童阅读';

  @override
  String get desktopShellDefaultsS787 => '童话叙事 文字更具故事感';

  @override
  String get desktopShellDefaultsS826 => '纪实风 中性偏学术表达';

  @override
  String get desktopShellDefaultsS129 => 'PDF 文件 高质量 PDF（打印级别）';

  @override
  String get desktopShellDefaultsS935 => '长图 PNG 适合移动分享';

  @override
  String get desktopShellDefaultsS932 => '长图 JPG 体积更小';

  @override
  String get feedbackPageS555 => '无法';

  @override
  String get feedbackPageS583 => '未找到';

  @override
  String get feedbackPageS673 => '没有';

  @override
  String get feedbackPageS582 => '未就绪';

  @override
  String get feedbackPageS383 => '完成';

  @override
  String get feedbackPageS429 => '已保存';

  @override
  String get feedbackPageS448 => '已更新';

  @override
  String get sidecarLauncherS679 =>
      'Test environment detected; skipped sidecar auto-start.';

  @override
  String get sidecarLauncherS98 =>
      'Port 4317 is already in use, but KidMemory sidecar health did not respond.';

  @override
  String get sidecarLauncherS584 =>
      'Sidecar runtime directory was not found. Confirm the app bundle contains Resources/sidecar, or set KIDMEMORY_SIDECAR_DIR.';

  @override
  String get sidecarLauncherS146 =>
      'Sidecar is not ready; attempting automatic start.';

  @override
  String get sidecarLauncherS141 => 'Starting Sidecar';

  @override
  String get sidecarLauncherS592 =>
      'No Node.js runtime was found for starting sidecar.';

  @override
  String get sidecarLauncherS591 =>
      'No runnable sidecar entry point was found; skipped automatic start.';

  @override
  String get sidecarLauncherS140 => 'Sidecar initialized successfully.';

  @override
  String get sidecarLauncherS193 =>
      'Sidecar start failed: service did not pass the health check in time.';

  @override
  String get sidecarLauncherS194 =>
      'Sidecar start failed: runtime directory is missing dist/main.js.';

  @override
  String sidecarLauncherLaunchCommandLog(String command) {
    return 'Starting sidecar command: $command';
  }

  @override
  String sidecarLauncherStartedPidLog(int pid) {
    return 'Sidecar process started successfully: PID $pid';
  }

  @override
  String sidecarLauncherStartFailedLog(Object error) {
    return 'Sidecar start failed: $error';
  }

  @override
  String sidecarLauncherTerminatedOldPidLog(String pid) {
    return 'Terminated old sidecar process PID=$pid on port 4317';
  }

  @override
  String sidecarLauncherForceTerminatedOldPidLog(String pid) {
    return 'Old sidecar process did not exit in time; force terminated PID=$pid on port 4317';
  }

  @override
  String sidecarLauncherTerminateOldFailedLog(Object error) {
    return 'Failed to terminate old sidecar process: $error';
  }

  @override
  String sidecarLauncherDirectoryProbeCwdLog(String path) {
    return 'Sidecar directory probe: cwd=$path';
  }

  @override
  String sidecarLauncherDirectoryProbeExecutableLog(String path) {
    return 'Sidecar directory probe: executable=$path';
  }

  @override
  String sidecarLauncherInvalidExplicitDirLog(String path) {
    return 'KIDMEMORY_SIDECAR_DIR does not contain a runnable sidecar (missing dist/main.js): $path';
  }

  @override
  String sidecarLauncherDirectoryProbeCandidateLog(String path, String status) {
    return 'Sidecar directory probe: $path => $status';
  }

  @override
  String sidecarLauncherDirectoryProbeFoundLog(String path) {
    return 'Sidecar directory probe: found $path';
  }

  @override
  String get desktopShellS696 => '温暖童趣';

  @override
  String get desktopShellS101 => 'A4 竖版 210 × 297 mm';

  @override
  String get desktopShellS697 => '温暖童趣 亲切温暖，适合儿童阅读';

  @override
  String get desktopShellS129 => 'PDF 文件 高质量 PDF（打印级别）';

  @override
  String get desktopShellS89 => '11:05:12 准备素材并构建创作空间';

  @override
  String get desktopShellS90 => '11:05:18 调用 sidecar 生成任务';

  @override
  String get desktopShellS91 => '11:05:28 校验 book.json 与 book.html';

  @override
  String get desktopShellS92 => '11:05:52 等待预览 / PDF 导出';

  @override
  String get datasetPreviewS783 => '示例素材';

  @override
  String get datasetPreviewS853 => '请先导入示例数据并完成一次生成，才能查看示例 PDF';

  @override
  String get datasetPreviewS521 => '打开示例 PDF：缺少可用预览来源';

  @override
  String get datasetPreviewS771 => '示例 PDF';

  @override
  String get datasetPreviewS743 => '生成日志详情';

  @override
  String get datasetPreviewS852 => '请先完成生成，再打开预览全部页面';

  @override
  String get datasetPreviewS952 => '预览全部页面：缺少 taskId';

  @override
  String get datasetSampleS696 => '温暖童趣';

  @override
  String get datasetSampleS101 => 'A4 竖版 210 × 297 mm';

  @override
  String get datasetSampleS697 => '温暖童趣 亲切温暖，适合儿童阅读';

  @override
  String get datasetSampleS764 => '确定要重置示例数据吗？';

  @override
  String get datasetSampleS894 => '这会删除当前示例档案和示例素材，并重新恢复到初始状态。';

  @override
  String get datasetSampleS595 => '未检测到示例数据档案，请先导入示例数据集';

  @override
  String get sidecarS151 => 'Sidecar 状态检查中';

  @override
  String get sidecarS266 => '内置 PostgreSQL 启动失败，已阻断 sidecar 启动。';

  @override
  String get sidecarS155 => 'Sidecar 重启失败，初始化未完成。';

  @override
  String get sidecarS652 => '正在启动 Sidecar';

  @override
  String get sidecarS145 => 'Sidecar 未就绪，初始化未完成。';

  @override
  String get sidecarS792 => '等待上一步';

  @override
  String get datasetS857 => '请先选择孩子档案';

  @override
  String get datasetS469 => '开始导入示例数据集';

  @override
  String get datasetS657 => '正在导入示例数据集...';

  @override
  String get datasetS776 => '示例数据集导入失败：sidecar 无响应或数据库未就绪';

  @override
  String get datasetS391 => '导入失败：Sidecar 未连接或数据库未就绪';

  @override
  String get datasetS781 => '示例数据集已导入，素材库已刷新';

  @override
  String get datasetS779 => '示例数据集导入未完成，请检查 sidecar';

  @override
  String get exportActionsS850 => '请先完成导出，再打开导出文件夹';

  @override
  String get exportActionsS414 => '导出文件夹';

  @override
  String get exportActionsS416 =>
      'The export has not finished cloud share sync yet, so the share text cannot be copied.';

  @override
  String get exportActionsS273 => '分享文案已复制';

  @override
  String get exportActionsS475 => '当前导出不是长图，不能复制长图';

  @override
  String get exportActionsS479 => '当前平台暂不支持直接复制图片内容，已复制长图本地路径';

  @override
  String get importPageS905 => '选择本地数据目录';

  @override
  String get importPageS904 => '选择文件夹';

  @override
  String get importPageS386 => '导入前需要一个孩子档案，请先检查 sidecar 连接';

  @override
  String get importPageS674 => '没有可读取的本地文件，请确认选择的是图片、zip 或可访问的文件夹';

  @override
  String get exportSyncS195 => 'sidecar 未返回导出物记录';

  @override
  String get exportSyncS837 => '缺少孩子档案，暂不能同步导出物';

  @override
  String get exportSyncS337 => '同步入队失败';

  @override
  String get exportSyncS157 => 'Cloud share sync failed';

  @override
  String get exportGenerationStateS736 => '生成完成，可预览并导出 PDF';

  @override
  String get exportGenerationStateS730 => '生成失败，请检查 sidecar 日志';

  @override
  String get datasetExternalS760 => '目录路径为空，无法打开';

  @override
  String get datasetExternalS478 => '当前平台不支持打开本地路径';

  @override
  String get datasetExternalS477 => '当前平台不支持外部打开';

  @override
  String get importPreviewS578 => '未命名素材';

  @override
  String get importSummaryS402 => '导入结果未返回';

  @override
  String get importSummaryS676 => '没有收到 sidecar 导入统计，请检查本地服务状态';

  @override
  String get directUploadS855 => '请先选择一个孩子再创建扫码上传会话';

  @override
  String get directUploadS650 => '正在创建扫码上传会话...';

  @override
  String get textUtilsS557 => '无错误输出';

  @override
  String get exportAssetSyncS862 => 'Configure cloud sharing first';

  @override
  String get exportPageS851 => '请先完成生成，再导出';

  @override
  String get exportPageS410 => '导出失败：缺少 taskId';

  @override
  String get exportPageS649 => '正在准备导出目录...';

  @override
  String get exportPageS702 => '点击导出，准备读取当前导出目录';

  @override
  String setupLocalDataDirUpdatedLog(String path) {
    return 'Local data directory updated: $path';
  }

  @override
  String setupSchemaInitIncompleteLog(String message) {
    return 'Schema initialization is incomplete: $message';
  }

  @override
  String setupReadinessCompleteMessage(int done, int total) {
    return 'Initialization complete, finished $done / $total readiness checks';
  }

  @override
  String setupInitializationFailed(Object error) {
    return 'Initialization failed: $error';
  }

  @override
  String setupStorageTestPassed(String cleanupMessage) {
    return 'Test passed$cleanupMessage';
  }

  @override
  String setupManualCheckTriggeredLog(String title) {
    return 'Manually triggered setup check: $title';
  }

  @override
  String setupTestConnectionFailedWithMessage(String message) {
    return 'Connection test failed: $message';
  }

  @override
  String setupOpenDirectoryPickerFailed(Object error) {
    return 'Failed to open directory picker: $error';
  }

  @override
  String setupLocalDataDirPickFailedLog(Object error) {
    return 'Local data directory selection failed: $error';
  }

  @override
  String setupHomebrewNotWritableForPackage(String packageName) {
    return 'Homebrew directory is not writable, cannot install $packageName.';
  }

  @override
  String setupHomebrewBlockedPaths(String paths) {
    return 'Blocked paths: $paths';
  }

  @override
  String setupPermissionDeniedInstallWithOutput(String packageName) {
    return 'The current user does not have permission to install $packageName automatically.';
  }

  @override
  String setupPermissionDeniedInstallRetry(String packageName) {
    return 'The current user does not have permission to install $packageName automatically. Fix Homebrew permissions and retry.';
  }

  @override
  String setupInstallCommandFailed(String output) {
    return 'Install command failed: $output';
  }

  @override
  String setupInstallConfigureFailed(String error) {
    return 'Install and configuration failed: $error';
  }

  @override
  String setupCommandTimeoutMessage(int minutes) {
    return 'The command ran for more than $minutes minutes and was stopped automatically. Check the network, Homebrew, or database service status and retry.';
  }

  @override
  String setupOpenSupabaseDocsFailed(Object error) {
    return 'Failed to open the official Supabase docs: $error';
  }

  @override
  String setupAutoStartUnsupported(String title) {
    return 'Automatic start is not supported yet: $title';
  }

  @override
  String setupConfigItemRecorded(String title) {
    return 'Configuration item \"$title\" was recorded and will be checked later';
  }

  @override
  String setupInvalidPostgresRuntimeDir(String path) {
    return 'KIDMEMORY_POSTGRES_RUNTIME_DIR is invalid (must contain bin/lib/share): $path';
  }

  @override
  String setupBundledPostgresPortLog(int port) {
    return 'Bundled PostgreSQL will use port $port';
  }

  @override
  String setupPgvectorWorkflowStartedLog(String localPgv) {
    return 'Started pgvector installation and configuration (local pgvector: $localPgv)';
  }

  @override
  String datasetSearchCompletedStatus(int count) {
    return 'Search completed, $count results';
  }

  @override
  String datasetSearchIndexingBaseStatus(int searchable, int indexing) {
    return '$searchable searchable · $indexing indexing';
  }

  @override
  String datasetSearchIndexingFailedStatus(String base, int failed) {
    return '$base · $failed failed';
  }

  @override
  String datasetSampleImportCompletedLog(int count) {
    return 'Sample dataset import completed: $count assets';
  }

  @override
  String datasetSampleImportIncompleteLog(String raw) {
    return 'Sample dataset import incomplete: $raw';
  }

  @override
  String datasetSampleImportExceptionLog(Object error) {
    return 'Sample dataset import exception: $error';
  }

  @override
  String datasetSampleImportFailedWithError(Object error) {
    return 'Sample dataset import failed: $error';
  }

  @override
  String datasetChildAddFailedLog(String raw) {
    return 'Add child profile failed: $raw';
  }

  @override
  String datasetChildAddedLog(String childId, String name) {
    return 'Added child profile: $childId $name';
  }

  @override
  String datasetChildAddedMessage(String name) {
    return 'Added child profile: $name';
  }

  @override
  String datasetChildEditedLog(String childId, String name) {
    return 'Edited profile: $childId updated to $name';
  }

  @override
  String datasetChildEditedMessage(String name) {
    return 'Profile updated to: $name';
  }

  @override
  String datasetChildDeleteConfirmMessage(String name) {
    return 'Delete \"$name\"? Clear this child\'s linked assets before deleting.';
  }

  @override
  String datasetChildDeletedLog(String childId, String name) {
    return 'Deleted child profile: $childId $name';
  }

  @override
  String datasetChildDeletedMessage(String name) {
    return 'Deleted child profile: $name';
  }

  @override
  String datasetChildDeleteFailedLog(String childId, Object error) {
    return 'Delete child profile failed: $childId $error';
  }

  @override
  String get datasetChildNameLabel => 'Child name';

  @override
  String datasetExternalOpenSucceededLog(String label, String target) {
    return '$label opened successfully: $target';
  }

  @override
  String datasetExternalOpenFailedMessage(String label, Object error) {
    return '$label open failed: $error';
  }

  @override
  String datasetSampleResetLog(String childId, int count) {
    return 'Sample data reset: $childId, removed $count assets';
  }

  @override
  String datasetPreviewOpenSampleAssetLog(String assetId) {
    return 'Opened sample asset preview: $assetId';
  }

  @override
  String datasetPreviewOpenHistoryLog(String taskId) {
    return 'Opened historical work preview: $taskId';
  }

  @override
  String datasetPreviewLogStatusLine(String status) {
    return 'Status: $status';
  }

  @override
  String datasetPreviewOpenPageLog(String taskId) {
    return 'Opened preview page: $taskId';
  }

  @override
  String installRunnerAttemptLog(String action) {
    return 'Trying: $action';
  }

  @override
  String installRunnerCommandSucceededLog(String action) {
    return 'Install command succeeded: $action';
  }

  @override
  String installRunnerTimeoutLog(String action) {
    return 'Install timed out ($action); process terminated.';
  }

  @override
  String installRunnerFailedWithOutputLog(String action, String output) {
    return 'Install failed ($action): $output';
  }

  @override
  String installRunnerFailedWithErrorLog(String action, Object error) {
    return 'Install failed ($action): $error';
  }

  @override
  String exportCreateDirectoryFailedMessage(Object error) {
    return 'Failed to create export directory: $error';
  }

  @override
  String exportInProgressStatus(String destinationPath) {
    return 'Exporting to $destinationPath';
  }

  @override
  String exportPreparingDestinationLog(String destinationPath) {
    return 'Preparing export to $destinationPath';
  }

  @override
  String exportSucceededLog(String exportLabel, String actualPath) {
    return '$exportLabel export succeeded: $actualPath';
  }

  @override
  String exportFailedLog(String exportLabel) {
    return '$exportLabel export failed';
  }

  @override
  String exportExceptionMessage(String exportLabel, Object error) {
    return '$exportLabel export exception: $error';
  }

  @override
  String exportGenerationStartedLog(int count) {
    return 'Started generation with $count selected assets';
  }

  @override
  String exportGenerationCompletedLog(String taskId) {
    return 'Generation completed with taskId: $taskId';
  }

  @override
  String exportGenerationExceptionMessage(Object error) {
    return 'Generation exception: $error';
  }

  @override
  String exportResultSucceededStatus(String exportLabel, String actualPath) {
    return '$exportLabel exported: $actualPath';
  }

  @override
  String exportResultFailedStatus(String exportLabel) {
    return '$exportLabel export failed; retry available';
  }

  @override
  String directUploadPullbackFailedMessage(Object error) {
    return '扫码上传回拉失败：$error';
  }

  @override
  String directUploadCreateSessionFailedMessage(String message) {
    return '创建扫码上传会话失败：$message';
  }

  @override
  String importSummaryFallbackImportedMessage(int count) {
    return 'Asset library refreshed; added $count items. Sidecar did not return full import counters.';
  }

  @override
  String importSummaryCountersWithFailures(
    int importedCount,
    int duplicatesCount,
    int skippedCount,
    int failedCount,
    String failedReasons,
  ) {
    return 'Imported $importedCount · duplicates $duplicatesCount · skipped $skippedCount · failed $failedCount: $failedReasons';
  }

  @override
  String get importSummaryFailedReasonSeparator => ', ';

  @override
  String importStagingFailedLog(String path, Object error) {
    return 'Import staging failed: $path ($error)';
  }

  @override
  String get generationTemplateWarmChildhood => 'Warm childhood';

  @override
  String get generationTemplateFairyTaleMemory => 'Fairy-tale growth memory';

  @override
  String get generationTemplateSimpleDocumentary => 'Simple documentary';

  @override
  String contentMetricItemCount(int count) {
    return '$count items';
  }

  @override
  String contentMetricImageCount(int count) {
    return '$count images';
  }

  @override
  String contentMetricCraftCount(int count) {
    return '$count crafts';
  }

  @override
  String agentSettingsConnectionTestFailedWithError(Object error) {
    return 'Connection test failed: $error';
  }

  @override
  String agentSettingsSaveFailedWithError(Object error) {
    return 'Failed to save configuration: $error';
  }

  @override
  String assetLibrarySubtitle(String childName) {
    return 'Manage $childName\'s photos, drawings, and crafts. Select assets to create picture books, memory videos, or keepsake albums.';
  }

  @override
  String assetLibrarySearchResultsStatus(String status, int count) {
    return '$status · $count results';
  }

  @override
  String assetLibrarySearchFailedStatus(Object error) {
    return 'Search failed: $error';
  }

  @override
  String assetLibrarySmartPickedCount(int count) {
    return 'The assistant picked $count assets for you';
  }

  @override
  String assetLibrarySmartPickAppliedMessage(int count) {
    return 'Selected $count assets. You can fine-tune them manually.';
  }

  @override
  String assetLibraryImportFailedMessage(Object error) {
    return 'Import failed: $error';
  }

  @override
  String assetLibraryImportSummaryMessage(
    int imported,
    int duplicates,
    int skipped,
    int failed,
  ) {
    return 'Imported $imported · duplicates $duplicates · skipped $skipped · failed $failed';
  }

  @override
  String assetLibraryDeleteSelectedConfirm(int count) {
    return 'Delete $count selected assets?';
  }

  @override
  String assetLibraryDeletedSelectedMessage(int count) {
    return 'Deleted $count assets';
  }

  @override
  String assetLibraryDateYmd(int year, int month, int day) {
    return '$year-$month-$day';
  }

  @override
  String assetLibraryOpenOriginalFailedMessage(Object error) {
    return 'Failed to open original file: $error';
  }

  @override
  String assetLibraryCurrentChildChip(String childName) {
    return 'Current child: $childName';
  }

  @override
  String assetLibraryAssetCountChip(int count) {
    return '$count assets';
  }

  @override
  String assetLibraryCollectionSelectedCount(int count) {
    return '$count assets in this collection';
  }

  @override
  String assetLibrarySelectedAssetsCount(int count) {
    return '$count assets selected';
  }

  @override
  String get assetLibraryResyncLabel => 'Resync';

  @override
  String get assetLibrarySyncToStorageLabel => 'Sync to storage';

  @override
  String get assetLibrarySyncedToStorageText => 'Synced to storage.';

  @override
  String get assetLibrarySyncRunningOrRetryText =>
      'Sync is running or waiting to retry.';

  @override
  String get assetLibraryLocalSyncFallbackText =>
      'Stored locally; sync to storage when ready.';

  @override
  String get assetLibraryStatusSynced => 'Synced';

  @override
  String get assetLibraryStatusSyncing => 'Syncing';

  @override
  String get assetLibraryStatusRetryWaiting => 'Retry pending';

  @override
  String get assetLibraryStatusFailed => 'Sync failed';

  @override
  String get assetLibraryStatusLocalOnly => 'Local only';

  @override
  String get generateExportDefaultPageSize => 'A4 portrait  210 x 297 mm';

  @override
  String get generateExportDefaultStyle =>
      'Warm childhood  Friendly and suitable for children';

  @override
  String get generateExportDefaultPdfTarget =>
      'PDF file  High-quality PDF for print';

  @override
  String generateExportExportedState(String exportLabel) {
    return '$exportLabel exported';
  }

  @override
  String get generateExportCoverConfirmBody =>
      'A free image-generation service will create the cover.\nKid photos will not be uploaded; only a text description is sent.';

  @override
  String generateExportSelectedAssetsLabel(int count) {
    return '$count assets selected';
  }

  @override
  String get generateExportTaskGoalLabel => 'Goal';

  @override
  String get generateExportTaskGoalPictureBook => 'Children\'s picture book';

  @override
  String get generateExportSuggestedAssetsLabel => 'Suggested assets';

  @override
  String get generateExportSuggestedAssetsValue => 'At least 6';

  @override
  String generateExportLongImageOption(String sizeText) {
    return '$sizeText / long image';
  }

  @override
  String generateExportSummaryText(
    int selectedCount,
    String generationState,
    String styleText,
    String sizeText,
    String exportLabel,
  ) {
    return 'Assets             $selectedCount\nGeneration state   $generationState\nWriting style      $styleText\nPage size          $sizeText\nExport target      $exportLabel';
  }

  @override
  String generateExportSelectedAssetsShort(int count) {
    return '$count selected';
  }

  @override
  String generateExportAssetInputSelectedTitle(int count) {
    return 'Assets · $count selected';
  }

  @override
  String generateExportPagePreviewCount(int pageCount) {
    return 'Page preview (about $pageCount pages)';
  }

  @override
  String generateExportActivityEmptyMessage(String statusMessage) {
    return 'After you click Start generation, Agent analysis, manuscript building, preview rendering, and export status will appear here.\nCurrent status: $statusMessage';
  }

  @override
  String generateExportCurrentStatusLine(String statusMessage) {
    return 'Current status: $statusMessage';
  }

  @override
  String generateExportReasonLine(String reason) {
    return 'Reason: $reason';
  }

  @override
  String generateExportReadyToExportSubtitle(String exportLabel) {
    return 'Generation is complete. Preview or export $exportLabel.';
  }

  @override
  String generateExportDirectoryHint(String exportLabel) {
    return 'Exports are written to the current export directory. After completion, use Open export folder to view the $exportLabel file.';
  }

  @override
  String generateExportReadinessAssetRatio(int selectedCount) {
    return '$selectedCount / suggested 6+';
  }

  @override
  String get generateExportCloudShareLabel => 'Cloud sharing';

  @override
  String get generateExportCloudShareValue => 'Upload after generation';

  @override
  String get generateExportPreviewReadinessMessage => 'Ready: export can start';

  @override
  String get generateExportPreviewSetupUrlTitle => '1. Configure Supabase URL';

  @override
  String get generateExportPreviewSetupUrlBody =>
      'Confirm that the project URL and key are filled in.';

  @override
  String get generateExportPreviewStateDetected => 'Detected';

  @override
  String get generateExportPreviewSetupBucketTitle => '2. Configure bucket';

  @override
  String get generateExportPreviewSetupBucketBody =>
      'Confirm that the export data bucket exists.';

  @override
  String get generateExportPreviewActionOpen => 'Open';

  @override
  String get generateExportPreviewStateConfigured => 'Configured';

  @override
  String get generateExportPreviewSetupPermissionTitle =>
      '3. Storage permissions';

  @override
  String get generateExportPreviewSetupPermissionBody =>
      'Confirm that service-role key permissions allow storage reads and writes.';

  @override
  String get generateExportPreviewStatePassed => 'Passed';

  @override
  String get generateExportPreviewSetupSignatureTitle =>
      '4. Directory and signing';

  @override
  String get generateExportPreviewSetupSignatureBody =>
      'Confirm that the signed URL TTL configuration matches expectations.';

  @override
  String get generateExportPreviewStateNormal => 'Normal';

  @override
  String get generateExportPreviewSetupConnectionTitle => '5. Connection test';

  @override
  String get generateExportPreviewSetupConnectionBody =>
      'Successfully connected to the export service.';

  @override
  String get generateExportPreviewStateConnected => 'Connected';

  @override
  String get generateExportPreviewSignedUrlPassed =>
      'Signed URL validation passed';

  @override
  String get generateExportPreviewExportCompleted => 'Export job completed';

  @override
  String get generateExportPreviewLogReadingSamples => 'Reading samples';

  @override
  String get generateExportPreviewLogCoverGenerated => 'Cover generated';

  @override
  String get generateExportPreviewLogExportSubmitted => 'Export job submitted';

  @override
  String get generateExportPreviewExportImage => 'Export as image';

  @override
  String get generateExportPreviewExportPdf => 'Export as PDF';

  @override
  String get generateExportPreviewExportLongImage => 'Export as long image';

  @override
  String get generateExportPreviewSelectedPageSize => 'A4 portrait';

  @override
  String get generateExportPreviewSelectedStyle => 'Natural and gentle';

  @override
  String generateExportPreviewShareText(String url, int seconds) {
    return 'KidMemory portfolio: $url\nLink valid for $seconds seconds';
  }

  @override
  String directUploadChildIdLine(String childId) {
    return 'Child: $childId';
  }

  @override
  String directUploadClientLimitHint(int count) {
    return 'Recommended ≤$count items per batch. This is a UX limit, not a security limit.';
  }

  @override
  String trustedUploadCreateSessionFailed(Object error) {
    return 'Failed to create upload session: $error';
  }

  @override
  String trustedUploadCloseSessionFailed(Object error) {
    return 'Failed to close session: $error';
  }

  @override
  String trustedUploadRetryFailed(Object error) {
    return 'Retry failed: $error';
  }

  @override
  String trustedUploadRemainingMinutes(int minutes) {
    return 'Time remaining: $minutes minutes';
  }

  @override
  String trustedUploadMaxItems(int count) {
    return 'Limit: $count images';
  }

  @override
  String get trustedUploadCopiedMessage => 'Copied to clipboard';

  @override
  String trustedUploadLoadFailed(String error) {
    return 'Load failed: $error';
  }

  @override
  String get trustedUploadNoItemsMessage =>
      'No upload items yet\nChoose images on your phone to upload';

  @override
  String trustedUploadItemFailed(String message) {
    return 'Failed: $message';
  }

  @override
  String contentMetricTagCount(int count) {
    return '$count tags';
  }

  @override
  String get contentNoRecentWorksMessage => 'No recent works';

  @override
  String get contentTimelineBirth => '😊\nBirth';

  @override
  String get contentTimelineFirstSmile => '🖍️\nFirst smile';

  @override
  String get contentTimelineFirstDrawing => '🎨\nFirst drawing';

  @override
  String get contentTimelineDaycare => '🏫\nDaycare started';

  @override
  String get contentTimelineBicycle => '🚲\nLearned to ride';

  @override
  String get contentTimelineNewYearArtwork => '🏮\nNew Year artwork';

  @override
  String get contentProfileSampleDetails =>
      'Profile information\n\nGender               Boy\nBirthplace           Shanghai\nZodiac               Gemini\nBlood type           A\nCreated              2024-06-18\nLast updated         2025-05-30\n\nGrowth milestones\nFirst drawing   2022-03-15\nStarted daycare 2023-09-01\nFirst exhibition 2024-05-20\nLearned to ride a bicycle 2024-10-12';

  @override
  String contentPaginationStatus(
    int currentPage,
    int totalPages,
    int pageSize,
  ) {
    return 'Page $currentPage / $totalPages · $pageSize per page';
  }

  @override
  String contentGenerationCompletePages(int currentPage, int totalPages) {
    return 'Generated     $currentPage/$totalPages pages';
  }

  @override
  String contentFlowPrepareAssets(int count) {
    return '🗂️  Prepare assets\n$count assets selected';
  }

  @override
  String get contentFlowAgentGenerated =>
      '✅  Agent structure\nPortfolio content generated';

  @override
  String get contentFlowAgentWaiting =>
      '⏳  Agent structure\nWaiting for generation';

  @override
  String get contentFlowExportCompleted =>
      '📄  Export file\nHigh-quality file generated';

  @override
  String get contentFlowExportWaiting => '📄  Export file\nWaiting to export';

  @override
  String contentSelectedAssetsTitle(int count) {
    return 'Selected assets ($count)';
  }

  @override
  String contentPagePreviewCount(int pageCount) {
    return 'Page preview ($pageCount pages)';
  }

  @override
  String get contentTimelineSourceText =>
      'Stage: live log\nSource: local task center';

  @override
  String get datasetChildrenClearBirthday => 'Clear birthday';

  @override
  String get childProfileEmptyDescription =>
      'Add a child first, then start recording assets, growth timeline\nand portfolios to preserve every moment worth remembering.';

  @override
  String childProfileLinkedAssets(int count) {
    return 'Linked assets: $count';
  }

  @override
  String childProfileAssetChip(int count) {
    return 'Assets $count';
  }

  @override
  String childProfileArtworkChip(int count) {
    return 'Drawings $count';
  }

  @override
  String childProfilePhotoChip(int count) {
    return 'Photos $count';
  }

  @override
  String get childProfilePortraitSmileKeyword => 'smile';

  @override
  String get childProfileGrowthStatsTitle => 'Growth Stats';

  @override
  String get childProfileAssetDistributionTitle => 'Asset Distribution';

  @override
  String get childProfileRecentWorksTitle => 'Recent Works';

  @override
  String get childProfileGrowthTimelineTitle => 'Growth Timeline';

  @override
  String childProfileAssetCountValue(int count) {
    return '$count items';
  }

  @override
  String get childProfileTimelineAutoUpdate =>
      'Timeline updates automatically by asset date';

  @override
  String get childProfilePortfolioSavedLocally =>
      'Portfolio records are saved locally';

  @override
  String get creationPhasePreparing => 'Prepare';

  @override
  String get creationPhasePlanning => 'Planning';

  @override
  String get creationPhasePlanReady => 'Plan ready';

  @override
  String get creationPhaseCreatingJob => 'Creating job';

  @override
  String get creationPhaseEnvironmentPreparing => 'Preparing video environment';

  @override
  String get creationPhaseGenerating => 'Generating';

  @override
  String get creationPhaseReviewing => 'Ready to review';

  @override
  String get creationPhaseExporting => 'Exporting locally';

  @override
  String get creationPhasePublished => 'Ready to share';

  @override
  String get creationPhaseFailed => 'Creation failed';

  @override
  String get creationPlanningStatus =>
      'Analyzing assets, selecting a skill, and generating a plan';

  @override
  String get creationPlanningAnalyzeAssetsTitle => 'Analyze assets';

  @override
  String creationPlanningAnalyzeAssetsBody(Object count) {
    return 'Reading $count selected photos, artwork, and tags';
  }

  @override
  String get creationPlanningSelectSkillTitle => 'Select Skill';

  @override
  String get creationPlanningSelectSkillBody =>
      'Matching storybook, memory book, or memoir video capability';

  @override
  String get creationPlanningGeneratePlanTitle => 'Generate plan';

  @override
  String get creationPlanningGeneratePlanBody =>
      'Organizing story structure, steps, and prerequisites';

  @override
  String get creationPlanReadyStatus =>
      'The creation plan is ready. Confirm it before generation starts.';

  @override
  String get creationPlanMissingStatus =>
      'The creation plan is missing. Please plan again.';

  @override
  String get creationPlanReadySubtitle =>
      'Review the agent plan, skill, and prerequisites before creating the generation job.';

  @override
  String get creationPlanConfirmationTitle => 'Confirm creation plan';

  @override
  String get creationPlanSkillLabel => 'Skill';

  @override
  String get creationPlanUnknownSkill => 'Waiting for backend';

  @override
  String get creationPlanStepsLabel => 'Plan steps';

  @override
  String get creationPlanRequirementsLabel => 'Prerequisites';

  @override
  String get creationConfirmPlanAction => 'Confirm plan and generate';

  @override
  String creationGenerationFailedWithStep(Object step, Object reason) {
    return 'Generation failed: $step could not finish. $reason';
  }

  @override
  String creationFailureStepLine(Object step) {
    return 'Failed step: $step';
  }

  @override
  String creationFailureCodeLine(Object code) {
    return 'Error code: $code';
  }

  @override
  String get creationReplanAction => 'Plan again';

  @override
  String get creationCreatingJobStatus => 'Creating the generation job';

  @override
  String get creationEnvironmentPreparingStatus =>
      'Preparing video generation environment';

  @override
  String get creationPlanInvalidatedStatus => '创作设置已更新，请重新规划。';

  @override
  String get creationGeneratingStatus => 'Running the generation job';

  @override
  String get generateExportCloudStorageLabel => 'Cloud storage';

  @override
  String get generateExportLocalServiceLabel => 'Local service';

  @override
  String get generateExportMp4Target => 'MP4 video  memoir video';

  @override
  String get creationPhasePlanConfirm => 'Confirm plan';

  @override
  String get creationPhasePreviewResult => 'Review result';

  @override
  String get creationPhaseExportShare => 'Export and share';

  @override
  String get creationFlowTitle => 'Creation flow';

  @override
  String get generationBackendStepsTitle => 'Generation steps';

  @override
  String get generationLocalProgressTitle => 'Creation progress';

  @override
  String get generateExportStartPlanningAction => 'Start planning';

  @override
  String get generateExportMp4Action => 'Export MP4';

  @override
  String get generateExportOpenVideoPreviewAction => 'Open video preview';

  @override
  String get generateExportVideoPreviewUnavailable =>
      'The video file is not ready yet. Regenerate or view logs.';

  @override
  String get generateExportVideoKeyword => 'video';

  @override
  String get directUploadServiceUnavailableMessage =>
      'QR upload is temporarily unavailable. Please try again later.';

  @override
  String get directUploadSessionIncompleteMessage =>
      'QR upload session could not be created. Check upload settings and try again.';

  @override
  String get directUploadConfigIncompleteMessage =>
      'QR upload settings are incomplete. Check upload settings and try again.';

  @override
  String get feedbackRequestKeyword => 'please';

  @override
  String get generateExportGoalSubtitle =>
      'Describe the goal, and KidMemory will generate matching content.';

  @override
  String get generateExportGoalHint =>
      'For example: make an 8-page storybook from spring outing photos';

  @override
  String get generateExportCreationTypeTitle => 'Choose creation type';

  @override
  String get generateExportStorybookDescription =>
      'Turn photos and stories into a polished storybook';

  @override
  String get generateExportStorybookTag => '6-24 pages';

  @override
  String get generateExportMemoryBookDescription =>
      'Organize growth records and treasured moments';

  @override
  String get generateExportMemoryBookTag => '10-40 pages';

  @override
  String get generateExportMemoryVideoDescription =>
      'Generate a video with subtitles and music';

  @override
  String get generateExportMemoryVideoTag => '1-10 minutes';

  @override
  String get generateExportSelectAssetsBeforeStart =>
      'Select assets first before creating something wonderful for your child.';

  @override
  String generateExportSelectedAssetCount(int count) {
    return '$count assets selected';
  }

  @override
  String get generateExportAssetRecommendation =>
      'Select at least 6 assets for better results';

  @override
  String get generateExportAssetProgressCurrent => '0 (current)';

  @override
  String get generateExportAssetProgressRecommended => '6 (recommended)';

  @override
  String get generateExportAssetProgressBetter => '12+ (better)';

  @override
  String get generateExportAssetPreparationTitle => 'Asset preparation';

  @override
  String get generateExportAssetPreparationSubtitle =>
      'Choose from the asset library, or let AI help pick the right assets';

  @override
  String get generateExportNoSelectedAssets => 'No assets selected yet';

  @override
  String get generateExportSelectedAssetsReadyHint =>
      'These assets will be used for this creation. You can add more.';

  @override
  String get generateExportSelectAssetsEmptyHint =>
      'Choose photos, videos, or audio from the asset library to start.';

  @override
  String get creationStagePrepareSubtitle => 'Clarify goals and assets';

  @override
  String get creationStagePlanSubtitle => 'Generate a creation plan';

  @override
  String get creationStageGenerateTitle => 'Generating';

  @override
  String get creationStageGenerateSubtitle => 'AI is creating';

  @override
  String get creationStagePreviewTitle => 'Preview result';

  @override
  String get creationStagePreviewSubtitle => 'Review the generated work';

  @override
  String get creationStageShareTitle => 'Export and share';

  @override
  String get creationStageShareSubtitle => 'Save or share the work';

  @override
  String get generateExportCreationSummaryTitle => 'Creation summary';

  @override
  String get generateExportSummaryTypeEmpty => 'Not selected yet';

  @override
  String get generateExportSummaryGoalLabel => 'Goal status';

  @override
  String get generateExportSummaryGoalEmpty => 'No goal entered';

  @override
  String generateExportSummarySelectedAssetsValue(int count) {
    return '$count items / at least 6 recommended';
  }

  @override
  String get generateExportSummaryNextStepLabel => 'Next step';

  @override
  String get generateExportSummaryNextStepValue =>
      'Select assets and start planning';

  @override
  String get generateExportMaterialTip =>
      'Great assets are the first step to a great creation. Visit the asset library first.';
}
