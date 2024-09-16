// ignore_for_file: unnecessary_null_comparison




import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../../../data/utils.dart';
import '../../core/functions.dart';
import '../../data/models/picked_asset_model.dart';
import '../widgets/gallery_grid/gallery_grid_view.dart';
import '../widgets/select_album_path/current_path_selector.dart';
import 'gallery_media_picker_controller.dart';

class GalleryMediaPicker extends StatefulWidget {
  /// maximum images allowed (default 2)
  final int maxPickImages;

  /// picker mode
  final bool singlePick;

  /// picker provider
  final GalleryMediaPickerController provider;

  /// return all selected paths
  final Function(List<PickedAssetModel> path)? pathList;

  /// dropdown appbar color
  final Color appBarColor;

  /// appBar TextColor
  final Color appBarTextColor;

  /// appBar icon Color
  final Color? appBarIconColor;

  /// gridView background color
  final Color gridViewBackgroundColor;

  /// grid image backGround color
  final Color imageBackgroundColor;

  /// album background color
  final Color? albumBackGroundColor;

  /// album text color
  final Color albumTextColor;

  /// album divider color
  final Color? albumDividerColor;

  /// gallery gridview crossAxisCount
  final int? crossAxisCount;

  /// gallery gridview aspect ratio
  final double? childAspectRatio;

  /// appBar leading widget
  final Widget? appBarLeadingWidget;

  /// appBar height
  final double appBarHeight;

  /// gridView Padding
  final EdgeInsets? gridPadding;

  /// gridView physics
  final ScrollPhysics? gridViewPhysics;

  /// gridView controller
  final ScrollController? gridViewController;

  /// selected background color
  final Color selectedBackgroundColor;

  /// selected check color
  final Color selectedCheckColor;

  /// thumbnail box fit
  final BoxFit thumbnailBoxFix;

  /// selected Check Background Color
  final Color selectedCheckBackgroundColor;

  /// load video
  final bool onlyVideos;

  /// load images
  final bool onlyImages;

  /// image quality thumbnail
  final int? thumbnailQuality;
  const GalleryMediaPicker(
      {Key? key,
      this.maxPickImages = 2,
      this.singlePick = true,
      this.appBarColor = Colors.white,
      this.albumBackGroundColor = Colors.white,
      this.albumDividerColor,
      this.albumTextColor = Colors.black,
      this.appBarIconColor,
      this.appBarTextColor = Colors.black,
      this.crossAxisCount,
      this.gridViewBackgroundColor = Colors.white,
      this.childAspectRatio,
      this.appBarLeadingWidget,
      this.appBarHeight = 100,
      this.imageBackgroundColor = Colors.white,
      this.gridPadding,
      this.gridViewController,
      this.gridViewPhysics,
      this.pathList,
      this.selectedBackgroundColor = Colors.white,
      this.selectedCheckColor = Colors.white,
      this.thumbnailBoxFix = BoxFit.cover,
      this.selectedCheckBackgroundColor = Colors.white,
      this.onlyImages = false,
      this.onlyVideos = false,
      this.thumbnailQuality, required this.provider})
      : super(key: key);

  @override
  State<GalleryMediaPicker> createState() => _GalleryMediaPickerState();
}

class _GalleryMediaPickerState extends State<GalleryMediaPicker> {
  /// create object of PickerDataProvider
  // final GalleryMediaPickerController provider = GalleryMediaPickerController();
  @override
  void initState() {
    _getPermission();
    super.initState();
  }

  /// get photo manager permission
  _getPermission() {
    GalleryFunctions.getPermission(setState, widget.provider);
    GalleryFunctions.onPickMax(widget.provider);
  }

  @override
  void dispose() {
    if (mounted) {
      /// clear all controller list
      widget.provider.pickedFile.clear();
      widget.provider.picked.clear();
      widget.provider.pathList.clear();
      widget.provider.onPickMax.removeListener(() { GalleryFunctions.onPickMax(widget.provider);});
      PhotoManager.stopChangeNotify();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.provider.max = widget.maxPickImages;
    widget.provider.singlePickMode = widget.singlePick;

    return OKToast(
      child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return false;
          },
          child: Column(
            children: [
              /// album drop down
              Center(
                child: Container(
                  color: widget.appBarColor,
                  alignment: Alignment.bottomLeft,
                  height: widget.appBarHeight,
                  padding: const EdgeInsets.only(left: 10),
                  child: SelectedPathDropdownButton(
                    dropdownRelativeKey: GlobalKey(),
                    provider: widget.provider,
                    appBarColor: widget.appBarColor,
                    appBarIconColor:
                        widget.appBarIconColor ?? const Color(0xFFB2B2B2),
                    appBarTextColor: widget.appBarTextColor,
                    albumTextColor: widget.albumTextColor,
                    albumDividerColor:
                        widget.albumDividerColor ?? const Color(0xFF484848),
                    albumBackGroundColor:
                        widget.albumBackGroundColor ?? const Color(0xFF333333),
                    appBarLeadingWidget: widget.appBarLeadingWidget,
                  ),
                ),
              ),

              /// grid view
              Expanded(
                child: SizedBox(
                  height: NavUtils.size.height,
                  width: NavUtils.size.width,
                  child: widget.provider != null
                      ? AnimatedBuilder(
                          animation: widget.provider.currentAlbumNotifier,
                          builder: (BuildContext context, child) =>
                              GalleryGridView(
                            path: widget.provider.currentAlbum,
                            thumbnailQuality: widget.thumbnailQuality ?? 200,
                            provider: widget.provider,
                            padding: widget.gridPadding,
                            childAspectRatio: widget.childAspectRatio ?? 0.5,
                            crossAxisCount: widget.crossAxisCount ?? 3,
                            gridViewBackgroundColor:
                                widget.gridViewBackgroundColor,
                            gridViewController: widget.gridViewController,
                            gridViewPhysics: widget.gridViewPhysics,
                            imageBackgroundColor: widget.imageBackgroundColor,
                            selectedBackgroundColor:
                                widget.selectedBackgroundColor,
                            selectedCheckColor: widget.selectedCheckColor,
                            thumbnailBoxFix: widget.thumbnailBoxFix,
                            selectedCheckBackgroundColor:
                                widget.selectedCheckBackgroundColor,
                            onAssetRemove: (asset, index) {
                              widget.provider.removeEntity(asset);
                            },
                            onAssetItemClick: (asset, index) async {
                              // File? file = await asset.file;
                              // if(checkFileUploadSize(file!.path, asset.typeInt == 1 ? Constants.mImage : Constants.mVideo)) {
                              //   debugPrint("item processed1 ${DateTime.now()} ${file.lengthSync()}");
                                widget.provider.pickEntity(asset);
                                widget.provider.pickPath(PickedAssetModel(
                                  id: asset.id,
                                  // path: file.path,
                                  type: asset.typeInt == 1
                                      ? 'image'
                                      : 'video',
                                  asset: asset,
                                  videoDuration: asset.videoDuration,
                                  createDateTime: asset.createDateTime,
                                  latitude: asset.latitude,
                                  longitude: asset.longitude,
                                  thumbnail: await asset.thumbnailData,
                                  height: asset.height,
                                  width: asset.width,
                                  orientationHeight: asset.orientatedHeight,
                                  orientationWidth: asset.orientatedWidth,
                                  orientationSize: asset.orientatedSize,
                                  // file: await asset.file,
                                  modifiedDateTime: asset.modifiedDateTime,
                                  title: asset.title,
                                  size: asset.size,
                                ));
                                  widget.pathList!(widget.provider.pickedFile);
                              }
                              /*else{
                                toToast(Constants.mediaMaxLimitRestriction.replaceAll("%d", "${asset.typeInt == 1 ? Constants.maxImageFileSize : Constants.maxVideoFileSize}"));
                              }
                            },*/
                          ),
                        )
                      : Container(),
                ),
              )
            ],
          )),
    );
  }
}
