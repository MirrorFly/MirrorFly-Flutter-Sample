part of 'stylesheet.dart';

class AddParticipantsPageStyle {
  final AppBarTheme appBarTheme;
  final TabBarTheme tabBarTheme;
  final EditTextFieldStyle searchTextFieldStyle;
  final TabItemStyle tabItemStyle;
  final ContactItemStyle contactItemStyle;
  final CopyMeetLinkStyle copyMeetLinkStyle;
  final ParticipantItemStyle participantItemStyle;
  final TextStyle noDataTextStyle;
  final Decoration buttonDecoration;
  final TextStyle buttonTextStyle;
  final Color buttonIconColor;

  const AddParticipantsPageStyle(
      {this.appBarTheme = const AppBarTheme(
        backgroundColor: Color(0xffF2F2F2),
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff181818),
            fontSize: 20),
        iconTheme: IconThemeData(color: Color(0xff181818)),
        actionsIconTheme: IconThemeData(color: Color(0xff181818)),
      ),
      this.tabBarTheme = const TabBarTheme(
          indicatorColor: AppColor.primaryColor,
          labelColor: AppColor.primaryColor,
          unselectedLabelColor: Color(0xff181818)),
      this.searchTextFieldStyle = const EditTextFieldStyle(),
      this.tabItemStyle = const TabItemStyle(),
      this.contactItemStyle = const ContactItemStyle(),
      this.participantItemStyle = const ParticipantItemStyle(),
      this.copyMeetLinkStyle = const CopyMeetLinkStyle(),
      this.noDataTextStyle = const TextStyle(
          fontWeight: FontWeight.w600, color: Color(0xff181818), fontSize: 14),
      this.buttonDecoration = const BoxDecoration(
          color: AppColor.primaryColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(2), topRight: Radius.circular(2))),
      this.buttonTextStyle = const TextStyle(
        fontWeight: FontWeight.w500,
        color: Colors.white,
        fontSize: 14,
      ),
      this.buttonIconColor = Colors.white});
}

class ParticipantItemStyle {
  final Size profileImageSize;
  final TextStyle textStyle;
  final ActionButtonStyle actionStyle;
  final Color dividerColor;

  const ParticipantItemStyle({
    this.profileImageSize = const Size(48, 48),
    this.textStyle = const TextStyle(
        fontWeight: FontWeight.w600, color: Color(0xff181818), fontSize: 14),
    this.actionStyle = const ActionButtonStyle(
      activeBgColor: Colors.transparent,
      activeIconColor: AppColor.primaryColor,
      inactiveBgColor: Color(0xffe3e2e2),
      inactiveIconColor: Color(0xff969696),
    ),
    this.dividerColor = const Color(0xffEBEBEB),
  });
}
