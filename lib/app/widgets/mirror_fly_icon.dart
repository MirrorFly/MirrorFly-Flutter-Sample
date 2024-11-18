import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UIKitIcon extends StatelessWidget {
  const UIKitIcon.assetIcon({
    Key? key,
    required this.icon,
  }) : svgPicture = null,
        super(key: key);

  const UIKitIcon.svgIcon({
    Key? key,
    required this.svgPicture,
  }) : icon = null,
        super(key: key);

  final SvgPicture? svgPicture;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    if (svgPicture != null) {
      return svgPicture!;
    } else if (icon != null) {
      return icon!;
    } else {
      return const Offstage();
    }
  }
}

