import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../pages/gallery_media_picker_controller.dart';
import 'change_path_widget.dart';
import 'dropdown.dart';

class SelectedPathDropdownButton extends StatelessWidget {
  /// picker provider
  final GalleryMediaPickerController provider;

  /// global key
  final GlobalKey? dropdownRelativeKey;
  final Color appBarColor;

  /// appBar TextColor
  final Color appBarTextColor;

  /// appBar icon Color
  final Color appBarIconColor;

  /// album background color
  final Color albumBackGroundColor;

  /// album text color
  final Color albumTextColor;

  /// album divider color
  final Color albumDividerColor;

  /// appBar leading widget
  final Widget? appBarLeadingWidget;

  const SelectedPathDropdownButton(
      {Key? key,
      required this.provider,
      required this.dropdownRelativeKey,
      required this.appBarTextColor,
      required this.appBarIconColor,
      required this.appBarColor,
      required this.albumBackGroundColor,
      required this.albumDividerColor,
      required this.albumTextColor,
      this.appBarLeadingWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arrowDownNotifier = ValueNotifier(false);
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: AnimatedBuilder(
        animation: provider.currentAlbumNotifier,
        builder: (_, __) => Row(
          children: [
            /// show drop down
            Expanded(
              child: DropDown<AssetPathEntity>(
                relativeKey: dropdownRelativeKey!,
                child: ((context) =>
                    buildButton(context, arrowDownNotifier))(context),
                dropdownWidgetBuilder: (BuildContext context, close) {
                  /// change path button
                  return ChangePathWidget(
                    provider: provider,
                    close: close,
                    albumBackGroundColor: albumBackGroundColor,
                    albumDividerColor: albumDividerColor,
                    albumTextColor: albumTextColor,
                  );
                },
                onResult: (AssetPathEntity? value) {
                  /// save selected album
                  if (value != null) {
                    provider.currentAlbum = value;
                    //provider.setAssetCount();
                  }
                },
                onShow: (value) {
                  /// change dropdown arrow state
                  arrowDownNotifier.value = value;
                },
              ),
            ),

            /// top custom widget
            Container(
              width: MediaQuery.of(context).size.width / 2,
              alignment: Alignment.bottomLeft,
              child: appBarLeadingWidget ?? Container(),
            )
          ],
        ),
      ),
    );
  }

  Widget buildButton(
    BuildContext context,
    ValueNotifier<bool> arrowDownNotifier,
  ) {
    /// local variables
    final decoration = BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(35),
    );

    /// return void container
    if (provider.pathList.isEmpty || provider.currentAlbum == null) {
      return Container();
    }

    /// return decorated container without data
    if (provider.currentAlbum == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: decoration,
      );
    } else {
      /// return list of available albums
      return Container(
        decoration: decoration,
        padding: const EdgeInsets.only(left: 15, bottom: 15),
        alignment: Alignment.bottomLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// current album name
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.28,
              child: Text(
                provider.currentAlbum!.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: appBarTextColor,
                    fontSize: 18,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const Spacer(),

            /// animated arrow icon
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: AnimatedBuilder(
                animation: arrowDownNotifier,
                builder: (BuildContext context, child) {
                  return AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: arrowDownNotifier.value ? 0.5 : 0,
                    child: child,
                  );
                },
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: appBarIconColor,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
