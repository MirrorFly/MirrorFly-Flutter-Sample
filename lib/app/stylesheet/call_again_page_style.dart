part of 'stylesheet.dart';

class CallAgainPageStyle {
  final Decoration backgroundDecoration;
  final TextStyle callStatusTextStyle;
  final TextStyle callerNameTextStyle;
  final Size profileImageSize;
  final Decoration bottomActionsContainerDecoration;
  final TextStyle bottomActionsContainerTextStyle;
  final ActionButtonStyle cancelActionStyle;
  final ActionButtonStyle callAgainActionStyle;
  final TextStyle actionsTitleStyle;

  const CallAgainPageStyle({
    this.backgroundDecoration = const BoxDecoration(color: Color(0xff0E274E)),
    this.callStatusTextStyle = const TextStyle(
        fontWeight: FontWeight.w300, color: Color(0xffDEDEDE), fontSize: 14),
    this.callerNameTextStyle = const TextStyle(
        fontWeight: FontWeight.w500, color: Colors.white, fontSize: 18),
    this.profileImageSize = const Size(105, 105),
    this.bottomActionsContainerDecoration =
        const BoxDecoration(color: Color(0xff162337)),
    this.bottomActionsContainerTextStyle = const TextStyle(
        fontWeight: FontWeight.w300, color: Colors.white, fontSize: 14),
    this.cancelActionStyle = const ActionButtonStyle(
        activeIconColor: Color(0xff303030), activeBgColor: Colors.white),
    this.callAgainActionStyle = const ActionButtonStyle(
        activeIconColor: Colors.white, activeBgColor: Color(0xff2FC076)),
    this.actionsTitleStyle = const TextStyle(
        fontWeight: FontWeight.w300, color: Colors.white, fontSize: 12),
  });
}
