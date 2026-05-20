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
  String get assetStudioTitle => '创作台';

  @override
  String get assetLibraryTitle => '素材库';

  @override
  String get sidebarSettingsTitle => '设置';

  @override
  String get sidebarLocalProfileTitle => '本地成长档案';

  @override
  String get localPriorityLabel => '本地优先';

  @override
  String get sidebarSignatureDescription => '每一份素材，都会进入本地成长档案。';

  @override
  String get generateExportTitle => '生成导出';

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
  String get setupAgentServiceTitle => 'Agent 服务配置';

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
  String get generateExportPreviewFailedTitle => 'PDF 预览失败';

  @override
  String get generateExportPreviewFailedBody =>
      '预览窗口没有打开。你可以查看失败原因，打开导出文件夹确认本地文件，或查看日志继续排查。';

  @override
  String generateExportPreviewFailureReason(String reason) {
    return '原因：$reason';
  }

  @override
  String generateExportPreviewFailedStatus(Object error) {
    return 'PDF 预览失败：$error';
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
  String get childProfileS693 => '添加孩子档案';

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
  String get sidecarLauncherS679 => '测试环境，跳过 sidecar 自动启动。';

  @override
  String get sidecarLauncherS98 => '4317 端口已被占用，但未响应 KidMemory sidecar health。';

  @override
  String get sidecarLauncherS584 =>
      '未找到 sidecar 运行目录。请确认 app bundle 中包含 Resources/sidecar，或设置 KIDMEMORY_SIDECAR_DIR。';

  @override
  String get sidecarLauncherS146 => 'Sidecar 未就绪，开始尝试自动启动。';

  @override
  String get sidecarLauncherS141 => 'Sidecar 启动中';

  @override
  String get sidecarLauncherS592 => '未检测到可用于启动 sidecar 的 Node.js。';

  @override
  String get sidecarLauncherS591 => '未检测到可启动的 sidecar 入口，已跳过自动启动。';

  @override
  String get sidecarLauncherS140 => 'Sidecar 初始化成功。';

  @override
  String get sidecarLauncherS193 => 'sidecar 启动失败：服务未在预期时间内通过 health 检查。';

  @override
  String get sidecarLauncherS194 => 'sidecar 启动失败：运行目录缺少 dist/main.js。';

  @override
  String sidecarLauncherLaunchCommandLog(String command) {
    return '启动 sidecar 命令：$command';
  }

  @override
  String sidecarLauncherStartedPidLog(int pid) {
    return 'Sidecar 进程启动成功：PID $pid';
  }

  @override
  String sidecarLauncherStartFailedLog(Object error) {
    return 'sidecar 启动失败：$error';
  }

  @override
  String sidecarLauncherTerminatedOldPidLog(String pid) {
    return '已终止旧 sidecar 进程 PID=$pid（端口 4317）';
  }

  @override
  String sidecarLauncherForceTerminatedOldPidLog(String pid) {
    return '旧 sidecar 进程未及时退出，已强制终止 PID=$pid（端口 4317）';
  }

  @override
  String sidecarLauncherTerminateOldFailedLog(Object error) {
    return '终止旧 sidecar 进程失败：$error';
  }

  @override
  String sidecarLauncherDirectoryProbeCwdLog(String path) {
    return 'sidecar 目录探测: cwd=$path';
  }

  @override
  String sidecarLauncherDirectoryProbeExecutableLog(String path) {
    return 'sidecar 目录探测: executable=$path';
  }

  @override
  String sidecarLauncherInvalidExplicitDirLog(String path) {
    return 'KIDMEMORY_SIDECAR_DIR 未包含可运行 sidecar（缺少 dist/main.js）：$path';
  }

  @override
  String sidecarLauncherDirectoryProbeCandidateLog(String path, String status) {
    return 'sidecar 目录探测: $path => $status';
  }

  @override
  String sidecarLauncherDirectoryProbeFoundLog(String path) {
    return 'sidecar 目录探测: 命中 $path';
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
  String get datasetPreviewS952 => '预览全部页面：缺少 jobId';

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
  String get exportActionsS416 => '导出物尚未完成云端分享同步，暂不能复制分享文案';

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
  String get exportSyncS157 => '云端分享同步失败';

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
  String get exportAssetSyncS862 => '请先配置云端分享设置';

  @override
  String get exportPageS851 => '请先完成生成，再导出';

  @override
  String get exportPageS410 => '导出失败：缺少 jobId';

  @override
  String get exportPageS649 => '正在准备导出目录...';

  @override
  String get exportPageS702 => '点击导出，准备读取当前导出目录';

  @override
  String setupLocalDataDirUpdatedLog(String path) {
    return '本地数据目录已更新：$path';
  }

  @override
  String setupSchemaInitIncompleteLog(String message) {
    return 'schema 初始化未完成：$message';
  }

  @override
  String setupReadinessCompleteMessage(int done, int total) {
    return '初始化成功，已完成 $done / $total 项 readiness 检测';
  }

  @override
  String setupInitializationFailed(Object error) {
    return '初始化失败：$error';
  }

  @override
  String setupStorageTestPassed(String cleanupMessage) {
    return '测试通过$cleanupMessage';
  }

  @override
  String setupManualCheckTriggeredLog(String title) {
    return '手动触发配置检测：$title';
  }

  @override
  String setupTestConnectionFailedWithMessage(String message) {
    return '测试连接失败：$message';
  }

  @override
  String setupOpenDirectoryPickerFailed(Object error) {
    return '打开目录选择器失败：$error';
  }

  @override
  String setupLocalDataDirPickFailedLog(Object error) {
    return '本地数据目录选择失败：$error';
  }

  @override
  String setupHomebrewNotWritableForPackage(String packageName) {
    return 'Homebrew 目录不可写，无法安装 $packageName。';
  }

  @override
  String setupHomebrewBlockedPaths(String paths) {
    return '不可写路径：$paths';
  }

  @override
  String setupPermissionDeniedInstallWithOutput(String packageName) {
    return '当前用户没有安装权限，无法自动安装 $packageName。';
  }

  @override
  String setupPermissionDeniedInstallRetry(String packageName) {
    return '当前用户没有安装权限，无法自动安装 $packageName。请修复 Homebrew 权限后重试。';
  }

  @override
  String setupInstallCommandFailed(String output) {
    return '安装命令失败：$output';
  }

  @override
  String setupInstallConfigureFailed(String error) {
    return '安装与配置失败：$error';
  }

  @override
  String setupCommandTimeoutMessage(int minutes) {
    return '命令执行超过 $minutes 分钟，已自动停止；请检查网络、Homebrew 或数据库服务状态后重试。';
  }

  @override
  String setupOpenSupabaseDocsFailed(Object error) {
    return '打开 Supabase 官方说明失败：$error';
  }

  @override
  String setupAutoStartUnsupported(String title) {
    return '暂不支持自动启动：$title';
  }

  @override
  String setupConfigItemRecorded(String title) {
    return '配置项“$title”已记录，稍后继续检测';
  }

  @override
  String setupInvalidPostgresRuntimeDir(String path) {
    return 'KIDMEMORY_POSTGRES_RUNTIME_DIR 无效（需包含 bin/lib/share）：$path';
  }

  @override
  String setupBundledPostgresPortLog(int port) {
    return '内置 PostgreSQL 将使用端口 $port';
  }

  @override
  String setupPgvectorWorkflowStartedLog(String localPgv) {
    return '开始 pgvector 安装与配置流程（本地 pgvector: $localPgv）';
  }

  @override
  String datasetSearchCompletedStatus(int count) {
    return '搜索完成，共 $count 条';
  }

  @override
  String datasetSearchIndexingBaseStatus(int searchable, int indexing) {
    return '可语义搜索 $searchable · 索引中 $indexing';
  }

  @override
  String datasetSearchIndexingFailedStatus(String base, int failed) {
    return '$base · 失败 $failed';
  }

  @override
  String datasetSampleImportCompletedLog(int count) {
    return '示例数据集导入完成：$count 个素材';
  }

  @override
  String datasetSampleImportIncompleteLog(String raw) {
    return '示例数据集导入未完成：$raw';
  }

  @override
  String datasetSampleImportExceptionLog(Object error) {
    return '示例数据集导入异常：$error';
  }

  @override
  String datasetSampleImportFailedWithError(Object error) {
    return '示例数据集导入失败：$error';
  }

  @override
  String datasetChildAddFailedLog(String raw) {
    return '添加孩子档案失败：$raw';
  }

  @override
  String datasetChildAddedLog(String childId, String name) {
    return '添加孩子档案：$childId $name';
  }

  @override
  String datasetChildAddedMessage(String name) {
    return '已添加孩子档案：$name';
  }

  @override
  String datasetChildEditedLog(String childId, String name) {
    return '编辑资料：$childId 更新为 $name';
  }

  @override
  String datasetChildEditedMessage(String name) {
    return '资料已更新为：$name';
  }

  @override
  String datasetChildDeleteConfirmMessage(String name) {
    return '确定删除「$name」吗？删除前需要先清空这个孩子关联的素材。';
  }

  @override
  String datasetChildDeletedLog(String childId, String name) {
    return '删除孩子档案：$childId $name';
  }

  @override
  String datasetChildDeletedMessage(String name) {
    return '已删除孩子档案：$name';
  }

  @override
  String datasetChildDeleteFailedLog(String childId, Object error) {
    return '删除孩子档案失败：$childId $error';
  }

  @override
  String get datasetChildNameLabel => '孩子名字';

  @override
  String datasetExternalOpenSucceededLog(String label, String target) {
    return '$label 打开成功：$target';
  }

  @override
  String datasetExternalOpenFailedMessage(String label, Object error) {
    return '$label 打开失败：$error';
  }

  @override
  String datasetSampleResetLog(String childId, int count) {
    return '示例数据已重置：$childId，移除 $count 个素材';
  }

  @override
  String datasetPreviewOpenSampleAssetLog(String assetId) {
    return '打开示例素材预览：$assetId';
  }

  @override
  String datasetPreviewOpenHistoryLog(String jobId) {
    return '打开历史作品预览：$jobId';
  }

  @override
  String datasetPreviewLogStatusLine(String status) {
    return '状态：$status';
  }

  @override
  String datasetPreviewOpenPageLog(String jobId) {
    return '打开预览页面：$jobId';
  }

  @override
  String installRunnerAttemptLog(String action) {
    return '正在尝试：$action';
  }

  @override
  String installRunnerCommandSucceededLog(String action) {
    return '安装命令成功：$action';
  }

  @override
  String installRunnerTimeoutLog(String action) {
    return '安装超时（$action），已终止进程。';
  }

  @override
  String installRunnerFailedWithOutputLog(String action, String output) {
    return '安装失败（$action）：$output';
  }

  @override
  String installRunnerFailedWithErrorLog(String action, Object error) {
    return '安装失败（$action）：$error';
  }

  @override
  String exportCreateDirectoryFailedMessage(Object error) {
    return '创建导出目录失败：$error';
  }

  @override
  String exportInProgressStatus(String destinationPath) {
    return '正在导出到 $destinationPath';
  }

  @override
  String exportPreparingDestinationLog(String destinationPath) {
    return '准备导出到 $destinationPath';
  }

  @override
  String exportSucceededLog(String exportLabel, String actualPath) {
    return '$exportLabel 导出成功：$actualPath';
  }

  @override
  String exportFailedLog(String exportLabel) {
    return '$exportLabel 导出失败';
  }

  @override
  String exportExceptionMessage(String exportLabel, Object error) {
    return '$exportLabel 导出异常：$error';
  }

  @override
  String exportGenerationStartedLog(int count) {
    return '开始生成，当前选中 $count 张素材';
  }

  @override
  String exportGenerationCompletedLog(String jobId) {
    return '生成完成，已获得 jobId: $jobId';
  }

  @override
  String exportGenerationExceptionMessage(Object error) {
    return '生成异常：$error';
  }

  @override
  String exportResultSucceededStatus(String exportLabel, String actualPath) {
    return '$exportLabel 已导出：$actualPath';
  }

  @override
  String exportResultFailedStatus(String exportLabel) {
    return '$exportLabel 导出失败，可重试';
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
    return '素材库已刷新，新增 $count 项；sidecar 未返回完整导入统计';
  }

  @override
  String importSummaryCountersWithFailures(
    int importedCount,
    int duplicatesCount,
    int skippedCount,
    int failedCount,
    String failedReasons,
  ) {
    return '成功 $importedCount · 重复 $duplicatesCount · 跳过 $skippedCount · 失败 $failedCount：$failedReasons';
  }

  @override
  String get importSummaryFailedReasonSeparator => '、';

  @override
  String importStagingFailedLog(String path, Object error) {
    return '导入暂存失败：$path ($error)';
  }

  @override
  String get generationTemplateWarmChildhood => '温暖童趣';

  @override
  String get generationTemplateFairyTaleMemory => '童话式成长记忆';

  @override
  String get generationTemplateSimpleDocumentary => '简约纪实';

  @override
  String contentMetricItemCount(int count) {
    return '$count 项';
  }

  @override
  String contentMetricImageCount(int count) {
    return '$count 张';
  }

  @override
  String contentMetricCraftCount(int count) {
    return '$count 件';
  }

  @override
  String agentSettingsConnectionTestFailedWithError(Object error) {
    return '连接测试失败: $error';
  }

  @override
  String agentSettingsSaveFailedWithError(Object error) {
    return '保存配置失败: $error';
  }

  @override
  String assetLibrarySubtitle(String childName) {
    return '管理$childName的照片、绘画和手工作品。选择素材后可以生成绘本、回忆视频或成长纪念册。';
  }

  @override
  String assetLibrarySearchResultsStatus(String status, int count) {
    return '$status · 结果 $count 项';
  }

  @override
  String assetLibrarySearchFailedStatus(Object error) {
    return '搜索失败：$error';
  }

  @override
  String assetLibrarySmartPickedCount(int count) {
    return '智能助手已为你挑选 $count 张素材';
  }

  @override
  String assetLibrarySmartPickAppliedMessage(int count) {
    return '已选 $count 张素材，可继续手动微调。';
  }

  @override
  String assetLibraryImportFailedMessage(Object error) {
    return '导入失败：$error';
  }

  @override
  String assetLibraryImportSummaryMessage(
    int imported,
    int duplicates,
    int skipped,
    int failed,
  ) {
    return '成功 $imported · 重复 $duplicates · 跳过 $skipped · 失败 $failed';
  }

  @override
  String assetLibraryDeleteSelectedConfirm(int count) {
    return '将删除已选 $count 项素材，是否继续？';
  }

  @override
  String assetLibraryDeletedSelectedMessage(int count) {
    return '已删除 $count 项素材';
  }

  @override
  String assetLibraryDateYmd(int year, int month, int day) {
    return '$year年$month月$day日';
  }

  @override
  String assetLibraryOpenOriginalFailedMessage(Object error) {
    return '打开原图失败：$error';
  }

  @override
  String assetLibraryCurrentChildChip(String childName) {
    return '当前孩子：$childName';
  }

  @override
  String assetLibraryAssetCountChip(int count) {
    return '素材 $count';
  }

  @override
  String assetLibraryCollectionSelectedCount(int count) {
    return '本次作品集素材 $count 项';
  }

  @override
  String assetLibrarySelectedAssetsCount(int count) {
    return '已选择 $count 项素材';
  }

  @override
  String get assetLibraryResyncLabel => '重新同步';

  @override
  String get assetLibrarySyncToStorageLabel => '同步到存储';

  @override
  String get assetLibrarySyncedToStorageText => '已同步到存储。';

  @override
  String get assetLibrarySyncRunningOrRetryText => '同步正在进行或等待重试。';

  @override
  String get assetLibraryLocalSyncFallbackText => '当前仅保存在本地，可同步到存储。';

  @override
  String get assetLibraryStatusSynced => '已同步';

  @override
  String get assetLibraryStatusSyncing => '同步中';

  @override
  String get assetLibraryStatusRetryWaiting => '等待重试';

  @override
  String get assetLibraryStatusFailed => '同步失败';

  @override
  String get assetLibraryStatusLocalOnly => '仅本地';

  @override
  String get generateExportDefaultPageSize => 'A4 竖版  210 × 297 mm';

  @override
  String get generateExportDefaultStyle => '温暖童趣  亲切温暖，适合儿童阅读';

  @override
  String get generateExportDefaultPdfTarget => 'PDF 文件  高质量 PDF（打印级别）';

  @override
  String generateExportExportedState(String exportLabel) {
    return '$exportLabel 已导出';
  }

  @override
  String get generateExportCoverConfirmBody =>
      '将使用免费生图服务生成封面图。\n不会上传孩子照片，只会发送文字描述。';

  @override
  String generateExportSelectedAssetsLabel(int count) {
    return '已选 $count 张素材';
  }

  @override
  String get generateExportTaskGoalLabel => '目标';

  @override
  String get generateExportTaskGoalPictureBook => '儿童绘本';

  @override
  String get generateExportSuggestedAssetsLabel => '建议素材';

  @override
  String get generateExportSuggestedAssetsValue => '至少 6 张';

  @override
  String generateExportLongImageOption(String sizeText) {
    return '$sizeText / 长图';
  }

  @override
  String generateExportSummaryText(
    int selectedCount,
    String generationState,
    String styleText,
    String sizeText,
    String exportLabel,
  ) {
    return '素材数量          $selectedCount 项\n生成状态          $generationState\n文案风格          $styleText\n页面尺寸          $sizeText\n导出目标          $exportLabel';
  }

  @override
  String generateExportSelectedAssetsShort(int count) {
    return '已选择 $count 张';
  }

  @override
  String generateExportAssetInputSelectedTitle(int count) {
    return '素材 · 已选择 $count 张';
  }

  @override
  String generateExportPagePreviewCount(int pageCount) {
    return '页面预览（约 $pageCount 页）';
  }

  @override
  String generateExportActivityEmptyMessage(String statusMessage) {
    return '点击“开始生成”后，这里会记录 Agent 分析素材、构建书稿、渲染预览与导出状态。\n当前状态：$statusMessage';
  }

  @override
  String generateExportCurrentStatusLine(String statusMessage) {
    return '当前状态：$statusMessage';
  }

  @override
  String generateExportReasonLine(String reason) {
    return '原因：$reason';
  }

  @override
  String generateExportReadyToExportSubtitle(String exportLabel) {
    return '生成完成后可预览或导出 $exportLabel。';
  }

  @override
  String generateExportDirectoryHint(String exportLabel) {
    return '导出将写入当前导出目录，完成后可在“打开导出文件夹”中查看 $exportLabel 文件';
  }

  @override
  String generateExportReadinessAssetRatio(int selectedCount) {
    return '$selectedCount / 建议 6+';
  }

  @override
  String get generateExportCloudShareLabel => '云端分享';

  @override
  String get generateExportCloudShareValue => '生成后可上传';

  @override
  String get generateExportPreviewReadinessMessage => '准备完成：可继续开始导出';

  @override
  String get generateExportPreviewSetupUrlTitle => '1. 配置 Supabase URL';

  @override
  String get generateExportPreviewSetupUrlBody => '确认已填写项目 URL 与密钥。';

  @override
  String get generateExportPreviewStateDetected => '已检测';

  @override
  String get generateExportPreviewSetupBucketTitle => '2. 配置 Bucket';

  @override
  String get generateExportPreviewSetupBucketBody => '确认导出数据 Bucket 已创建。';

  @override
  String get generateExportPreviewActionOpen => '前往';

  @override
  String get generateExportPreviewStateConfigured => '已配置';

  @override
  String get generateExportPreviewSetupPermissionTitle => '3. 存储权限';

  @override
  String get generateExportPreviewSetupPermissionBody => '确认服务角色密钥权限可用于存储读写。';

  @override
  String get generateExportPreviewStatePassed => '通过';

  @override
  String get generateExportPreviewSetupSignatureTitle => '4. 目录与签名';

  @override
  String get generateExportPreviewSetupSignatureBody => '确认 URL 签名有效期配置符合预期。';

  @override
  String get generateExportPreviewStateNormal => '正常';

  @override
  String get generateExportPreviewSetupConnectionTitle => '5. 连接测试';

  @override
  String get generateExportPreviewSetupConnectionBody => '已成功尝试连接导出服务。';

  @override
  String get generateExportPreviewStateConnected => '连接成功';

  @override
  String get generateExportPreviewSignedUrlPassed => '签名 URL 校验通过';

  @override
  String get generateExportPreviewExportCompleted => '导出任务已完成';

  @override
  String get generateExportPreviewLogReadingSamples => '正在读取样本';

  @override
  String get generateExportPreviewLogCoverGenerated => '已生成封面';

  @override
  String get generateExportPreviewLogExportSubmitted => '导出任务提交成功';

  @override
  String get generateExportPreviewExportImage => '导出为图片';

  @override
  String get generateExportPreviewExportPdf => '导出为 PDF';

  @override
  String get generateExportPreviewExportLongImage => '导出为长图';

  @override
  String get generateExportPreviewSelectedPageSize => 'A4 竖版';

  @override
  String get generateExportPreviewSelectedStyle => '自然温和';

  @override
  String generateExportPreviewShareText(String url, int seconds) {
    return 'KidMemory 作品集：$url\n链接有效期：$seconds 秒';
  }

  @override
  String directUploadChildIdLine(String childId) {
    return '孩子：$childId';
  }

  @override
  String directUploadClientLimitHint(int count) {
    return '建议每次≤$count张 · 仅为体验约束，并非安全约束';
  }

  @override
  String trustedUploadCreateSessionFailed(Object error) {
    return '创建上传会话失败: $error';
  }

  @override
  String trustedUploadCloseSessionFailed(Object error) {
    return '关闭会话失败: $error';
  }

  @override
  String trustedUploadRetryFailed(Object error) {
    return '重试失败: $error';
  }

  @override
  String trustedUploadRemainingMinutes(int minutes) {
    return '剩余时间: $minutes 分钟';
  }

  @override
  String trustedUploadMaxItems(int count) {
    return '上限: $count 张';
  }

  @override
  String get trustedUploadCopiedMessage => '已复制到剪贴板';

  @override
  String trustedUploadLoadFailed(String error) {
    return '加载失败: $error';
  }

  @override
  String get trustedUploadNoItemsMessage => '暂无上传项\n请在手机端选择图片上传';

  @override
  String trustedUploadItemFailed(String message) {
    return '失败: $message';
  }

  @override
  String contentMetricTagCount(int count) {
    return '$count 个';
  }

  @override
  String get contentNoRecentWorksMessage => '暂无最近作品';

  @override
  String get contentTimelineBirth => '😊\n出生';

  @override
  String get contentTimelineFirstSmile => '🖍️\n第一次微笑';

  @override
  String get contentTimelineFirstDrawing => '🎨\n第一次画画';

  @override
  String get contentTimelineDaycare => '🏫\n幼儿园入学';

  @override
  String get contentTimelineBicycle => '🚲\n学会骑车';

  @override
  String get contentTimelineNewYearArtwork => '🏮\n新年画作';

  @override
  String get contentProfileSampleDetails =>
      '档案信息\n\n性别                 男孩\n出生地               上海市\n星座                 双子座\n血型                 A型\n创建时间             2024-06-18\n最后更新             2025-05-30\n\n成长里程碑\n第一次画画     2022-03-15\n幼儿园入学     2023-09-01\n第一次画展     2024-05-20\n学会骑自行车   2024-10-12';

  @override
  String contentPaginationStatus(
    int currentPage,
    int totalPages,
    int pageSize,
  ) {
    return '第 $currentPage / $totalPages 页 · 每页 $pageSize 条';
  }

  @override
  String contentGenerationCompletePages(int currentPage, int totalPages) {
    return '生成完成     $currentPage/$totalPages 页';
  }

  @override
  String contentFlowPrepareAssets(int count) {
    return '🗂️  准备素材\n已选择 $count 张素材';
  }

  @override
  String get contentFlowAgentGenerated => '✅  Agent 生成结构\n已生成作品集内容';

  @override
  String get contentFlowAgentWaiting => '⏳  Agent 生成结构\n等待生成';

  @override
  String get contentFlowExportCompleted => '📄  导出文件\n已生成高质量文件';

  @override
  String get contentFlowExportWaiting => '📄  导出文件\n等待导出';

  @override
  String contentSelectedAssetsTitle(int count) {
    return '已选择素材（$count）';
  }

  @override
  String contentPagePreviewCount(int pageCount) {
    return '页面预览（共 $pageCount 页）';
  }

  @override
  String get contentTimelineSourceText => '阶段：实时记录\n来源：本地任务中心';

  @override
  String get datasetChildrenClearBirthday => '清空生日';

  @override
  String get childProfileEmptyDescription =>
      '先添加孩子，再开始记录素材、成长时间轴\n和作品集，珍藏每一个值得记住的瞬间。';

  @override
  String childProfileLinkedAssets(int count) {
    return '已关联素材：$count 项';
  }

  @override
  String childProfileAssetChip(int count) {
    return '素材 $count';
  }

  @override
  String childProfileArtworkChip(int count) {
    return '绘画 $count';
  }

  @override
  String childProfilePhotoChip(int count) {
    return '照片 $count';
  }

  @override
  String get childProfilePortraitSmileKeyword => '笑';

  @override
  String get childProfileGrowthStatsTitle => '成长统计';

  @override
  String get childProfileAssetDistributionTitle => '素材分布';

  @override
  String get childProfileRecentWorksTitle => '最近作品';

  @override
  String get childProfileGrowthTimelineTitle => '成长时间轴';

  @override
  String childProfileAssetCountValue(int count) {
    return '$count 项';
  }

  @override
  String get childProfileTimelineAutoUpdate => '时间线按素材日期自动更新';

  @override
  String get childProfilePortfolioSavedLocally => '作品集记录保存在本地';

  @override
  String get creationPhasePreparing => '准备创作';

  @override
  String get creationPhasePlanning => '规划中';

  @override
  String get creationPhasePlanReady => '计划待确认';

  @override
  String get creationPhaseCreatingJob => '创建任务中';

  @override
  String get creationPhaseEnvironmentPreparing => '准备视频环境';

  @override
  String get creationPhaseGenerating => '生成中';

  @override
  String get creationPhaseReviewing => '可预览';

  @override
  String get creationPhaseExporting => '正在导出到本地';

  @override
  String get creationPhasePublished => '可发布';

  @override
  String get creationPhaseFailed => '创作失败';

  @override
  String get creationPlanningStatus => '正在分析素材、选择 Skill 并生成计划';

  @override
  String get creationPlanningAnalyzeAssetsTitle => '分析素材';

  @override
  String creationPlanningAnalyzeAssetsBody(Object count) {
    return '正在读取 $count 张素材的照片、画作和标签';
  }

  @override
  String get creationPlanningSelectSkillTitle => '选择 Skill';

  @override
  String get creationPlanningSelectSkillBody => '正在匹配绘本、成长纪念册或回忆视频能力';

  @override
  String get creationPlanningGeneratePlanTitle => '生成计划';

  @override
  String get creationPlanningGeneratePlanBody => '正在组织故事结构、步骤和前置条件';

  @override
  String get creationPlanReadyStatus => '创作计划已生成，请确认后开始生成。';

  @override
  String get creationPlanMissingStatus => '创作计划缺失，请重新规划。';

  @override
  String get creationPlanReadySubtitle =>
      '请检查 Agent 计划、Skill 与前置条件，确认后再创建生成任务。';

  @override
  String get creationPlanConfirmationTitle => '确认创作计划';

  @override
  String get creationPlanSkillLabel => '使用 Skill';

  @override
  String get creationPlanUnknownSkill => '等待后端返回';

  @override
  String get creationPlanStepsLabel => '计划步骤';

  @override
  String get creationPlanRequirementsLabel => '前置条件';

  @override
  String get creationConfirmPlanAction => '确认计划并开始生成';

  @override
  String creationGenerationFailedWithStep(Object step, Object reason) {
    return '生成失败：$step 未能完成。$reason';
  }

  @override
  String creationFailureStepLine(Object step) {
    return '失败步骤：$step';
  }

  @override
  String creationFailureCodeLine(Object code) {
    return '错误代码：$code';
  }

  @override
  String get creationReplanAction => '重新规划';

  @override
  String get creationCreatingJobStatus => '正在创建生成任务';

  @override
  String get creationEnvironmentPreparingStatus => '正在准备视频生成环境';

  @override
  String get creationPlanInvalidatedStatus => '创作设置已更新，请重新规划。';

  @override
  String get creationGeneratingStatus => '正在执行生成任务';

  @override
  String get generateExportCloudStorageLabel => '云端存储';

  @override
  String get generateExportLocalServiceLabel => '本地服务';

  @override
  String get generateExportMp4Target => 'MP4 视频  回忆录视频';

  @override
  String get creationPhasePlanConfirm => '计划确认';

  @override
  String get creationPhasePreviewResult => '结果预览';

  @override
  String get creationPhaseExportShare => '导出分享';

  @override
  String get creationFlowTitle => '创作流程';

  @override
  String get generationBackendStepsTitle => '生成步骤';

  @override
  String get generationLocalProgressTitle => '创作进度';

  @override
  String get generateExportStartPlanningAction => '开始规划';

  @override
  String get generateExportMp4Action => '导出 MP4';

  @override
  String get generateExportOpenVideoPreviewAction => '打开视频预览';

  @override
  String get generateExportVideoPreviewUnavailable => '视频文件还未准备好，请重新生成或查看日志。';

  @override
  String get generateExportVideoKeyword => '视频';

  @override
  String get directUploadServiceUnavailableMessage => '扫码上传服务暂时不可用，请稍后重试';

  @override
  String get directUploadSessionIncompleteMessage => '扫码上传会话创建失败，请检查上传配置后重试';

  @override
  String get directUploadConfigIncompleteMessage => '扫码上传配置未完成，请检查上传设置后重试';

  @override
  String get feedbackRequestKeyword => '请';
}
