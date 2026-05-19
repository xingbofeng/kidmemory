import 'package:flutter/material.dart';

import '../../app/app_step.dart';
import '../../../l10n/app_localizations.dart';

abstract final class AppIconAssets {
  static const libraryRoot = 'assets/icons/library';

  static const bearHead = '$libraryRoot/01-小熊头像.png';
  static const sparkles = '$libraryRoot/02-星光.png';
  static const child = '$libraryRoot/03-孩子.png';
  static const folder = '$libraryRoot/04-文件夹.png';
  static const wand = '$libraryRoot/05-魔法棒.png';
  static const settings = '$libraryRoot/06-设置.png';
  static const shield = '$libraryRoot/07-安全盾牌.png';
  static const image = '$libraryRoot/08-图片.png';
  static const palette = '$libraryRoot/09-调色盘.png';
  static const camera = '$libraryRoot/10-相机.png';
  static const tag = '$libraryRoot/11-标签.png';
  static const book = '$libraryRoot/12-书本.png';
  static const bearDocument = '$libraryRoot/14-小熊文档.png';
  static const pdf = '$libraryRoot/15-PDF文件.png';
  static const grid = '$libraryRoot/16-网格.png';
  static const refresh = '$libraryRoot/17-刷新.png';
  static const view = '$libraryRoot/18-查看.png';
  static const complete = '$libraryRoot/19-完成.png';
  static const time = '$libraryRoot/20-时间.png';
  static const timeline = '$libraryRoot/21-清单时间.png';
  static const search = '$libraryRoot/22-搜索.png';
  static const filter = '$libraryRoot/23-筛选.png';
  static const sort = '$libraryRoot/24-排序.png';
  static const download = '$libraryRoot/25-下载.png';
  static const upload = '$libraryRoot/26-上传.png';
  static const delete = '$libraryRoot/27-删除.png';
  static const edit = '$libraryRoot/28-铅笔.png';
  static const add = '$libraryRoot/29-新增.png';
  static const dashedAdd = '$libraryRoot/30-虚线新增.png';
  static const more = '$libraryRoot/31-更多.png';
  static const leftArrow = '$libraryRoot/32-左箭头.png';
  static const rightArrow = '$libraryRoot/33-右箭头.png';
  static const upArrow = '$libraryRoot/34-上箭头.png';
  static const downArrow = '$libraryRoot/35-下箭头.png';
  static const play = '$libraryRoot/36-播放.png';
  static const pause = '$libraryRoot/37-暂停.png';
  static const stop = '$libraryRoot/38-停止.png';
  static const flag = '$libraryRoot/39-旗帜.png';
  static const star = '$libraryRoot/40-星星.png';
  static const info = '$libraryRoot/42-信息.png';
  static const cloudUpload = '$libraryRoot/43-云端上传.png';
  static const cloudDownload = '$libraryRoot/44-云端下载.png';
  static const link = '$libraryRoot/45-链接.png';
  static const unlock = '$libraryRoot/46-解锁.png';
  static const lock = '$libraryRoot/47-锁定.png';
  static const members = '$libraryRoot/48-成员.png';
  static const user = '$libraryRoot/49-用户.png';
  static const sun = '$libraryRoot/50-太阳.png';
  static const leaf = '$libraryRoot/51-叶子.png';
  static const flower = '$libraryRoot/52-花朵.png';
  static const birthdayCake = '$libraryRoot/53-生日蛋糕.png';
  static const hotAirBalloon = '$libraryRoot/54-热气球.png';
  static const rainbow = '$libraryRoot/55-彩虹.png';
  static const home = '$libraryRoot/56-小房子.png';
  static const a4File = '$libraryRoot/57-A4文件.png';
  static const imageFile = '$libraryRoot/58-图片文件.png';
  static const userShield = '$libraryRoot/59-用户盾牌.png';
  static const brush = '$libraryRoot/60-画笔.png';
  static const magicStar = '$libraryRoot/61-魔法星星.png';
  static const emptyTag = '$libraryRoot/62-空标签.png';
  static const music = '$libraryRoot/63-音乐.png';
  static const puzzle = '$libraryRoot/64-拼图.png';

  static const byName = <String, String>{
    'bearHead': bearHead,
    'sparkles': sparkles,
    'child': child,
    'folder': folder,
    'wand': wand,
    'settings': settings,
    'shield': shield,
    'image': image,
    'palette': palette,
    'camera': camera,
    'tag': tag,
    'book': book,
    'bearDocument': bearDocument,
    'pdf': pdf,
    'grid': grid,
    'refresh': refresh,
    'view': view,
    'complete': complete,
    'time': time,
    'timeline': timeline,
    'search': search,
    'filter': filter,
    'sort': sort,
    'download': download,
    'upload': upload,
    'delete': delete,
    'edit': edit,
    'add': add,
    'dashedAdd': dashedAdd,
    'more': more,
    'leftArrow': leftArrow,
    'rightArrow': rightArrow,
    'upArrow': upArrow,
    'downArrow': downArrow,
    'play': play,
    'pause': pause,
    'stop': stop,
    'flag': flag,
    'star': star,
    'info': info,
    'cloudUpload': cloudUpload,
    'cloudDownload': cloudDownload,
    'link': link,
    'unlock': unlock,
    'lock': lock,
    'members': members,
    'user': user,
    'sun': sun,
    'leaf': leaf,
    'flower': flower,
    'birthdayCake': birthdayCake,
    'hotAirBalloon': hotAirBalloon,
    'rainbow': rainbow,
    'home': home,
    'a4File': a4File,
    'imageFile': imageFile,
    'userShield': userShield,
    'brush': brush,
    'magicStar': magicStar,
    'emptyTag': emptyTag,
    'music': music,
    'puzzle': puzzle,
  };
}

const bearHeadIconAsset = AppIconAssets.bearHead;
const sparklesIconAsset = AppIconAssets.sparkles;
const childIconAsset = AppIconAssets.child;
const folderIconAsset = AppIconAssets.folder;
const wandIconAsset = AppIconAssets.wand;
const settingsIconAsset = AppIconAssets.settings;
const shieldIconAsset = AppIconAssets.shield;
const imageIconAsset = AppIconAssets.image;
const paletteIconAsset = AppIconAssets.palette;
const cameraIconAsset = AppIconAssets.camera;
const tagIconAsset = AppIconAssets.tag;
const bookIconAsset = AppIconAssets.book;
const bearDocumentIconAsset = AppIconAssets.bearDocument;
const pdfIconAsset = AppIconAssets.pdf;
const gridIconAsset = AppIconAssets.grid;
const refreshIconAsset = AppIconAssets.refresh;
const viewIconAsset = AppIconAssets.view;
const completeIconAsset = AppIconAssets.complete;
const timeIconAsset = AppIconAssets.time;
const timelineIconAsset = AppIconAssets.timeline;
const searchIconAsset = AppIconAssets.search;
const filterIconAsset = AppIconAssets.filter;
const sortIconAsset = AppIconAssets.sort;
const downloadIconAsset = AppIconAssets.download;
const uploadIconAsset = AppIconAssets.upload;
const deleteIconAsset = AppIconAssets.delete;
const editIconAsset = AppIconAssets.edit;
const addIconAsset = AppIconAssets.add;
const dashedAddIconAsset = AppIconAssets.dashedAdd;
const moreIconAsset = AppIconAssets.more;
const leftArrowIconAsset = AppIconAssets.leftArrow;
const rightArrowIconAsset = AppIconAssets.rightArrow;
const upArrowIconAsset = AppIconAssets.upArrow;
const downArrowIconAsset = AppIconAssets.downArrow;
const playIconAsset = AppIconAssets.play;
const pauseIconAsset = AppIconAssets.pause;
const stopIconAsset = AppIconAssets.stop;
const flagIconAsset = AppIconAssets.flag;
const starIconAsset = AppIconAssets.star;
const infoIconAsset = AppIconAssets.info;
const cloudUploadIconAsset = AppIconAssets.cloudUpload;
const cloudDownloadIconAsset = AppIconAssets.cloudDownload;
const linkIconAsset = AppIconAssets.link;
const unlockIconAsset = AppIconAssets.unlock;
const lockIconAsset = AppIconAssets.lock;
const membersIconAsset = AppIconAssets.members;
const userIconAsset = AppIconAssets.user;
const sunIconAsset = AppIconAssets.sun;
const leafIconAsset = AppIconAssets.leaf;
const flowerIconAsset = AppIconAssets.flower;
const birthdayCakeIconAsset = AppIconAssets.birthdayCake;
const hotAirBalloonIconAsset = AppIconAssets.hotAirBalloon;
const rainbowIconAsset = AppIconAssets.rainbow;
const homeIconAsset = AppIconAssets.home;
const a4FileIconAsset = AppIconAssets.a4File;
const imageFileIconAsset = AppIconAssets.imageFile;
const userShieldIconAsset = AppIconAssets.userShield;
const brushIconAsset = AppIconAssets.brush;
const magicStarIconAsset = AppIconAssets.magicStar;
const emptyTagIconAsset = AppIconAssets.emptyTag;
const musicIconAsset = AppIconAssets.music;
const puzzleIconAsset = AppIconAssets.puzzle;

const inlineIconSize = 24.0;
const compactInlineIconSize = 22.0;
const buttonIconSize = 24.0;
const navIconSize = 30.0;
const setupBadgeSize = 34.0;
const _smallAssetIconVisualScale = 1.24;

class Sidebar extends StatelessWidget {
  const Sidebar({
    required this.step,
    required this.navigationLocked,
    required this.hasChildProfile,
    required this.onStep,
    super.key,
  });

  final AppStep step;
  final bool navigationLocked;
  final bool hasChildProfile;
  final ValueChanged<AppStep> onStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Color(0xfff8f8f7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          bottomLeft: Radius.circular(22),
        ),
        border: Border(right: BorderSide(color: Color(0xffebe7e1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BearBadge(size: 56),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KidMemory',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xff352318),
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.sidebarLocalProfileTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xff8c7663),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  NavItem(
                    iconAsset: childIconAsset,
                    label: AppLocalizations.of(context)!.childProfileTitle,
                    icon: Icons.child_care_rounded,
                    active: step == AppStep.child,
                    enabled: !navigationLocked,
                    onTap: () => onStep(AppStep.child),
                  ),
                  NavItem(
                    iconAsset: folderIconAsset,
                    label: AppLocalizations.of(context)!.assetLibraryTitle,
                    icon: Icons.grid_view_rounded,
                    active: step == AppStep.assets,
                    enabled: !navigationLocked && hasChildProfile,
                    onTap: () => onStep(AppStep.assets),
                  ),
                  NavItem(
                    iconAsset: wandIconAsset,
                    label: AppLocalizations.of(context)!.assetStudioTitle,
                    icon: Icons.auto_awesome_rounded,
                    active: step == AppStep.generate,
                    enabled: !navigationLocked,
                    onTap: () => onStep(AppStep.generate),
                  ),
                  NavItem(
                    iconAsset: settingsIconAsset,
                    label: AppLocalizations.of(context)!.sidebarSettingsTitle,
                    icon: Icons.settings_rounded,
                    active: step == AppStep.setup,
                    enabled: true,
                    onTap: () => onStep(AppStep.setup),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _SidebarSignature(),
          const SizedBox(height: 14),
          const Text(
            'KidMemory · Local-first',
            style: TextStyle(color: Color(0xff8c7663)),
          ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  const NavItem({
    required this.label,
    required this.active,
    required this.enabled,
    required this.onTap,
    this.icon,
    this.iconAsset,
    super.key,
  });

  final IconData? icon;
  final String? iconAsset;
  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        cursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: enabled ? onTap : null,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: active ? const Color(0xffe6f5e8) : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              border: active
                  ? Border.all(color: const Color(0xffb6dec0))
                  : null,
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                if (active)
                  Positioned(
                    left: 0,
                    top: 12,
                    bottom: 12,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xff3f8c55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Opacity(
                    opacity: enabled ? 1 : 0.48,
                    child: Row(
                        children: [
                          Icon(
                            icon ?? Icons.circle_outlined,
                            size: 22,
                            color: active
                                ? const Color(0xff14773c)
                                : const Color(0xff6f6258),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: active
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: active
                                ? const Color(0xff14773c)
                                : const Color(0xff3a3028),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

 

class BearBadge extends StatelessWidget {
  const BearBadge({this.size = 72, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Padding(
      padding: EdgeInsets.all(size * 0.02),
      child: AppAssetIcon(bearHeadIconAsset, size: size * 0.94, opacity: 0.96),
    ),
  );
}

class _SidebarSignature extends StatelessWidget {
  const _SidebarSignature();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xfffbfaf8),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xffe8e2d9)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.localPriorityLabel,
          style: TextStyle(
            color: Color(0xff2d241c),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 6),
        Text(
          AppLocalizations.of(context)!.sidebarSignatureDescription,
          style: TextStyle(
            color: Color(0xff8c7663),
            height: 1.45,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class GardenMark extends StatelessWidget {
  const GardenMark({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 360,
    height: 78,
    child: Center(
      child: AppAssetIcon(bearHeadIconAsset, size: 56, opacity: 0.9),
    ),
  );
}

class ProjectIconMark extends StatelessWidget {
  const ProjectIconMark({
    this.size = 128,
    this.asset = bearHeadIconAsset,
    super.key,
  });

  final double size;
  final String asset;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Center(child: AppAssetIcon(asset, size: size)),
  );
}

class AppAssetIcon extends StatelessWidget {
  const AppAssetIcon(
    this.asset, {
    this.fallbackIcon,
    this.size = 24,
    this.opacity = 1,
    super.key,
  });

  final String? asset;
  final IconData? fallbackIcon;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final assetPath = asset?.trim() ?? '';
    if (assetPath.isEmpty) {
      return Icon(
        fallbackIcon ?? Icons.circle,
        size: size,
        color: const Color(0xff5d5148).withValues(alpha: opacity),
      );
    }
    final visualScale = assetPath.contains('/library/') && size <= 40
        ? _smallAssetIconVisualScale
        : 1.0;
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: size,
        height: size,
        child: ClipRect(
          child: Transform.scale(
            scale: visualScale,
            child: Image.asset(
              assetPath,
              width: size,
              height: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}

class NumberBadge extends StatelessWidget {
  const NumberBadge(this.value, {super.key});

  final String value;

  @override
  Widget build(BuildContext context) => Container(
    width: setupBadgeSize,
    height: setupBadgeSize,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xffffefc8),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xffffbd54)),
    ),
    child: Text(
      value,
      style: const TextStyle(
        color: Color(0xffe88719),
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}
