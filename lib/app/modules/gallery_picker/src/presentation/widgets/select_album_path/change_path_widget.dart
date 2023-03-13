import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../pages/gallery_media_picker_controller.dart';

class ChangePathWidget extends StatefulWidget {
  final GalleryMediaPickerController provider;
  final ValueSetter<AssetPathEntity> close;

  /// album background color
  final Color albumBackGroundColor;

  /// album text color
  final Color albumTextColor;

  /// album divider color
  final Color albumDividerColor;
  const ChangePathWidget({
    Key? key,
    required this.provider,
    required this.close,
    required this.albumBackGroundColor,
    required this.albumDividerColor,
    required this.albumTextColor,
  }) : super(key: key);

  @override
  ChangePathWidgetState createState() => ChangePathWidgetState();
}

class ChangePathWidgetState extends State<ChangePathWidget> {
  GalleryMediaPickerController get provider => widget.provider;

  ScrollController? controller;
  double itemHeight = 65;

  @override
  void initState() {
    super.initState();
    final index = provider.pathList.indexOf(provider.currentAlbum!);
    controller = ScrollController(initialScrollOffset: itemHeight * index);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.albumBackGroundColor,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return false;
        },
        child: MediaQuery.removePadding(
          removeTop: true,
          removeBottom: true,
          context: context,
          child: ListView.builder(
            controller: controller,
            itemCount: provider.pathList.length,
            itemBuilder: _buildItem,
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = provider.pathList[index];
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => widget.close.call(item),
      child: Stack(
        children: <Widget>[
          /// list of album
          SizedBox(
            height: 65.0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  item.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: widget.albumTextColor, fontSize: 18),
                ),
              ),
            ),
          ),

          /// divider
          Positioned(
            height: 1,
            bottom: 0,
            right: 0,
            left: 1,
            child: IgnorePointer(
              child: Container(
                color: widget.albumDividerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
