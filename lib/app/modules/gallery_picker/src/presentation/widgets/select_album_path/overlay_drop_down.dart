import 'package:flutter/material.dart';

import '../../../../../../data/utils.dart';
import 'dropdown.dart';

class OverlayDropDown<T> extends StatelessWidget {
  final double height;
  final Function(T? value) close;
  final AnimationController animationController;
  final DropdownWidgetBuilder<T> builder;
  const OverlayDropDown({
    Key? key,
    required this.height,
    required this.close,
    required this.animationController,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// local variables
    final Size size = NavUtils.size;
    final double screenHeight = size.height;
    final double screenWidth = size.width;
    final double space = screenHeight - height;
    return Padding(
      /// align overlay content behind the button
      padding: EdgeInsets.only(
        top: space,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Builder(
          builder: (ctx) => GestureDetector(
            onTap: () => close,

            /// close overlay
            child: AnimatedBuilder(
              animation: animationController,
              builder: (BuildContext context, child) {
                return Stack(
                  children: [
                    /// full content transparent container
                    GestureDetector(
                      onTap: () => close(null),

                      /// close overlay
                      child: Container(
                        color: Colors.transparent,
                        height: height * animationController.value,
                        width: screenWidth,
                      ),
                    ),

                    /// list of available albums
                    SizedBox(
                      height: height * animationController.value,
                      width: screenWidth * 0.5,
                      child: child,
                    ),
                  ],
                );
              },
              child: builder(ctx, close),
            ),
          ),
        ),
      ),
    );
  }
}
