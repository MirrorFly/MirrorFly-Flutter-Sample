import 'package:flutter/material.dart';

import '../common/constants.dart';
import '../data/utils.dart';

class AnimatedFloatingAction extends StatefulWidget {
  final String tooltip;
  final Widget icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Function() audioCallOnPressed;
  final Function() videoCallOnPressed;
  // final List<Widget> icons;

  const AnimatedFloatingAction({super.key, required this.tooltip, required this.icon, required this.audioCallOnPressed, required this.videoCallOnPressed, required this.backgroundColor, required this.foregroundColor});

  @override
  AnimatedFloatingActionState createState() => AnimatedFloatingActionState();
}

class AnimatedFloatingActionState extends State<AnimatedFloatingAction>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  late AnimationController _animationController;
  late Animation<Color?> _buttonColor;
  // late Animation<double> _animateIcon;
  late Animation<double> _translateButton;
  final Curve _curve = Curves.easeOut;
  final double _fabHeight = 56.0;

  @override
  initState() {
    _animationController =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    // _animateIcon =
    //     Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: widget.backgroundColor,
      end: widget.backgroundColor,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reset();
    }
    isOpened = !isOpened;
  }

  /*Widget add() {
    return Container(
      child: FloatingActionButton(
        onPressed: null,
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget image() {
    return Container(
      child: FloatingActionButton(
        onPressed: null,
        tooltip: 'Image',
        child: Icon(Icons.image),
      ),
    );
  }

  Widget inbox() {
    return Container(
      child: FloatingActionButton(
        onPressed: null,
        tooltip: 'Inbox',
        child: Icon(Icons.inbox),
      ),
    );
  }*/

  Widget toggleWidget() {
    return FloatingActionButton(
      heroTag: widget.tooltip,
      backgroundColor: _buttonColor.value,
      onPressed: animate,
      tooltip: widget.tooltip,
      child: widget.icon,
      /*child: AnimatedIcon(
        icon: AnimatedIcons.menu_close,
        progress: _animateIcon,
      ),*/
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
     children: [
       Transform(
         transform: Matrix4.translationValues(
           0.0,
           _translateButton.value * 2.0,
           0.0,
         ),
         child: FloatingActionButton.small(heroTag:"videoCall",onPressed: (){
           animate();
           widget.videoCallOnPressed();
         },backgroundColor:widget.backgroundColor,child: AppUtils.svgIcon(icon:
           videoCallSmallIcon,
           width: 18,
           height: 18,
           colorFilter: ColorFilter.mode(widget.foregroundColor ?? Colors.white, BlendMode.srcIn),
           fit: BoxFit.contain,
         ),),
       ),
       Transform(
         transform: Matrix4.translationValues(
           0.0,
           _translateButton.value,
           0.0,
         ),
         child: FloatingActionButton.small(heroTag:"audioCall",onPressed: (){
           animate();
           widget.audioCallOnPressed();
         },backgroundColor:widget.backgroundColor,child: AppUtils.svgIcon(icon:
           audioCallSmallIcon,
           width: 18,
           height: 18,
           colorFilter: ColorFilter.mode(widget.foregroundColor ?? Colors.white, BlendMode.srcIn),
           fit: BoxFit.contain,
         ),),
       ),
       isOpened ? const Offstage() : const SizedBox(height: 8,),
       toggleWidget()
     ],
    );
  }
}