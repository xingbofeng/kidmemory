import 'package:flutter/material.dart';

import '../../app/app_step.dart';
import '../../../l10n/app_localizations.dart';

abstract final class AppIconAssets {
  static const libraryRoot = 'assets/icons/library';

  static const bearHead = '$libraryRoot/01-bear-head.png';
  static const sparkles = '$libraryRoot/02-sparkles.png';
  static const child = '$libraryRoot/03-child.png';
  static const folder = '$libraryRoot/04-folder.png';
  static const wand = '$libraryRoot/05-wand.png';
  static const settings = '$libraryRoot/06-settings.png';
  static const shield = '$libraryRoot/07-shield.png';
  static const image = '$libraryRoot/08-image.png';
  static const palette = '$libraryRoot/09-palette.png';
  static const camera = '$libraryRoot/10-camera.png';
  static const tag = '$libraryRoot/11-tag.png';
  static const book = '$libraryRoot/12-book.png';
  static const file = '$libraryRoot/13-file.png';
  static const bearDocument = '$libraryRoot/14-bear-document.png';
  static const pdf = '$libraryRoot/15-pdf-file.png';
  static const grid = '$libraryRoot/16-grid.png';
  static const refresh = '$libraryRoot/17-refresh.png';
  static const view = '$libraryRoot/18-view.png';
  static const complete = '$libraryRoot/19-complete.png';
  static const time = '$libraryRoot/20-time.png';
  static const timeline = '$libraryRoot/21-timeline-list.png';
  static const search = '$libraryRoot/22-search.png';
  static const filter = '$libraryRoot/23-filter.png';
  static const sort = '$libraryRoot/24-sort.png';
  static const download = '$libraryRoot/25-download.png';
  static const upload = '$libraryRoot/26-upload.png';
  static const delete = '$libraryRoot/27-delete.png';
  static const edit = '$libraryRoot/28-pencil.png';
  static const add = '$libraryRoot/29-add.png';
  static const dashedAdd = '$libraryRoot/30-dashed-add.png';
  static const more = '$libraryRoot/31-more.png';
  static const leftArrow = '$libraryRoot/32-left-arrow.png';
  static const rightArrow = '$libraryRoot/33-right-arrow.png';
  static const upArrow = '$libraryRoot/34-up-arrow.png';
  static const downArrow = '$libraryRoot/35-down-arrow.png';
  static const play = '$libraryRoot/36-play.png';
  static const pause = '$libraryRoot/37-pause.png';
  static const stop = '$libraryRoot/38-stop.png';
  static const flag = '$libraryRoot/39-flag.png';
  static const star = '$libraryRoot/40-star.png';
  static const heart = '$libraryRoot/41-heart.png';
  static const info = '$libraryRoot/42-info.png';
  static const cloudUpload = '$libraryRoot/43-cloud-upload.png';
  static const cloudDownload = '$libraryRoot/44-cloud-download.png';
  static const link = '$libraryRoot/45-link.png';
  static const unlock = '$libraryRoot/46-unlock.png';
  static const lock = '$libraryRoot/47-lock.png';
  static const members = '$libraryRoot/48-members.png';
  static const user = '$libraryRoot/49-user.png';
  static const sun = '$libraryRoot/50-sun.png';
  static const leaf = '$libraryRoot/51-leaf.png';
  static const flower = '$libraryRoot/52-flower.png';
  static const birthdayCake = '$libraryRoot/53-birthday-cake.png';
  static const hotAirBalloon = '$libraryRoot/54-hot-air-balloon.png';
  static const rainbow = '$libraryRoot/55-rainbow.png';
  static const home = '$libraryRoot/56-home.png';
  static const a4File = '$libraryRoot/57-a4-file.png';
  static const imageFile = '$libraryRoot/58-image-file.png';
  static const userShield = '$libraryRoot/59-user-shield.png';
  static const brush = '$libraryRoot/60-brush.png';
  static const magicStar = '$libraryRoot/61-magic-star.png';
  static const emptyTag = '$libraryRoot/62-empty-tag.png';
  static const music = '$libraryRoot/63-music.png';
  static const puzzle = '$libraryRoot/64-puzzle.png';

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
    'file': file,
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
    'heart': heart,
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
const fileIconAsset = AppIconAssets.file;
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
const heartIconAsset = AppIconAssets.heart;
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
                              AppLocalizations.of(
                                context,
                              )!.sidebarLocalProfileTitle,
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
