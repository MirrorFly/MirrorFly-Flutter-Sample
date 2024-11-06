import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../app_style_config.dart';

class ChatAppBarIcon extends StatelessWidget {
  const ChatAppBarIcon({super.key, this.icon, this.svgPath, this.size, this.iconTheme}): assert(
  (icon != null) ^ (svgPath != null),
  'Only one of icon, iconButton, or svgPath should be provided',
  );

  final IconData? icon;
  final String? svgPath;
  final double? size;
  final IconThemeData? iconTheme;

  @override
  Widget build(BuildContext context) {
    final effectiveIconTheme = iconTheme ?? AppStyleConfig.chatPageStyle.appBarTheme.actionsIconTheme;
    if (svgPath != null) {
      return SvgPicture.asset(
        svgPath!,
        height: size,
        width: size,
        colorFilter: ColorFilter.mode(effectiveIconTheme?.color ?? Colors.black, BlendMode.srcIn),
      );
    } else if (icon != null) {
      return Icon(
        icon,
        size: size,
        color: effectiveIconTheme?.color,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
