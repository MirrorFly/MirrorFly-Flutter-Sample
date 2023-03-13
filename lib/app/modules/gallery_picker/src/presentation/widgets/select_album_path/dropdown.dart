import 'package:flutter/material.dart';

import '../../../core/functions.dart';

typedef DropdownWidgetBuilder<T> = Widget Function(
    BuildContext context, ValueSetter<T> close);

class DropDown<T> extends StatefulWidget {
  final Widget child;
  final DropdownWidgetBuilder<T> dropdownWidgetBuilder;
  final ValueChanged<T?>? onResult;
  final ValueChanged<bool>? onShow;
  final GlobalKey? relativeKey;

  const DropDown({
    Key? key,
    required this.child,
    required this.dropdownWidgetBuilder,
    this.onResult,
    this.onShow,
    this.relativeKey,
  }) : super(key: key);
  @override
  DropDownState<T> createState() => DropDownState<T>();
}

class DropDownState<T> extends State<DropDown<T>>
    with TickerProviderStateMixin {
  FeatureController<T?>? controller;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// return album list
      child: widget.child,

      /// on tap dropdown
      onTap: () async {
        if (controller != null) {
          controller!.close(null);
          return;
        }

        /// render overlay
        final height = MediaQuery.of(context).size.height;
        final ctx = widget.relativeKey?.currentContext ?? context;
        RenderBox box = ctx.findRenderObject() as RenderBox;
        final offsetStart = box.localToGlobal(Offset.zero);
        final dialogHeight = height - (offsetStart.dy + box.paintBounds.bottom);
        widget.onShow?.call(true);
        controller = GalleryFunctions.showDropDown<T>(
          context: context,
          height: dialogHeight,
          builder: (_, close) {
            return widget.dropdownWidgetBuilder.call(context, close);
          },
          tickerProvider: this,
        );
        var result = await controller!.closed;
        controller = null;
        widget.onResult!(result);
        widget.onShow?.call(false);
      },
    );
  }
}
