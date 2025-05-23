part of 'stylesheet.dart';

class OngoingCallPageStyle {
  final Color actionIconColor;
  final Decoration backgroundDecoration;
  final TextStyle callerNameTextStyle;
  final TextStyle callDurationTextStyle;
  final TextStyle callStatusTextStyle;
  final CallUserTileStyle pinnedCallUserTileStyle;
  final CallUserTileStyle listCallUserTileStyle;
  final CallUserTileStyle gridCallUserTileStyle;
  final ActionButtonStyle actionButtonsStyle;
  final ButtonStyle disconnectButtonStyle;
  final PIPViewStyle pipViewStyle;

  const OngoingCallPageStyle(
      {this.actionIconColor = Colors.white,
      this.backgroundDecoration = const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          transform: GradientRotation(180),
          colors: [
            Color(0xff152134),
            Color(0xff0D2852),
            Color(0xff152134),
          ],
        ),
      ),
      this.callerNameTextStyle = const TextStyle(
          fontWeight: FontWeight.w500, color: Colors.white, fontSize: 12),
      this.callDurationTextStyle = const TextStyle(
          fontWeight: FontWeight.normal, color: Colors.white, fontSize: 12),
      this.callStatusTextStyle = const TextStyle(
          fontWeight: FontWeight.w300, color: Colors.white, fontSize: 14),
      this.pinnedCallUserTileStyle = const CallUserTileStyle(
          profileImageSize: 100,
          backgroundColor: Color(0xff0D2852),
          borderRadius: BorderRadius.zero),
      this.listCallUserTileStyle = const CallUserTileStyle(
          profileImageSize: 50, backgroundColor: Color(0xff151F32)),
      this.gridCallUserTileStyle = const CallUserTileStyle(
        profileImageSize: 60,
        backgroundColor: Color(0xff151F32),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      this.actionButtonsStyle = const ActionButtonStyle(),
      this.disconnectButtonStyle = const ButtonStyle(),
      this.pipViewStyle = const PIPViewStyle()});
}

class CallUserTileStyle {
  final BorderRadiusGeometry borderRadius;
  final Color backgroundColor;
  final int profileImageSize;
  final TextStyle nameTextStyle;
  final ActionButtonStyle muteActionStyle;
  final ActionButtonStyle speakingIndicatorStyle;
  final TextStyle callStatusTextStyle;

  const CallUserTileStyle({
    this.borderRadius = const BorderRadius.all(Radius.circular(16.6)),
    this.backgroundColor = const Color(0xff0D2852),
    this.profileImageSize = 50,
    this.nameTextStyle = const TextStyle(
        fontWeight: FontWeight.normal, color: Colors.white, fontSize: 14),
    this.muteActionStyle = const ActionButtonStyle(
        activeBgColor: Color(0x00000080), activeIconColor: Colors.white),
    this.speakingIndicatorStyle = const ActionButtonStyle(
        activeBgColor: Color(0xff3ABF87), activeIconColor: Colors.white),
    this.callStatusTextStyle = const TextStyle(
        fontWeight: FontWeight.w300, color: Colors.white, fontSize: 14),
  });
}

class PIPViewStyle {
  final double width;
  final double height;
  final BorderRadiusGeometry borderRadius;
  final CallUserTileStyle userTileStyle;
  final IconStyle closeIconStyle;
  final TextStyle countStyle;
  final Color countBgColor;

  const PIPViewStyle(
      {this.width = 135,
      this.height = 270,
      this.borderRadius = const BorderRadius.all(Radius.circular(13)),
      this.userTileStyle = const CallUserTileStyle(
        borderRadius: BorderRadius.zero,
        backgroundColor: Color(0xff0D2852),
        profileImageSize: 80,
        nameTextStyle: TextStyle(
            fontWeight: FontWeight.normal, color: Colors.white, fontSize: 10),
        speakingIndicatorStyle: ActionButtonStyle(
            activeBgColor: Color(0xff3ABF87), activeIconColor: Colors.white),
        callStatusTextStyle: TextStyle(
            fontWeight: FontWeight.w300, color: Colors.white, fontSize: 10)
      ),
        this.countStyle = const TextStyle(fontWeight: FontWeight.normal,color: Colors.white,fontSize: 8,),
        this.countBgColor = AppColor.primaryColor,
      this.closeIconStyle = const IconStyle(iconColor: Colors.white)});
}
