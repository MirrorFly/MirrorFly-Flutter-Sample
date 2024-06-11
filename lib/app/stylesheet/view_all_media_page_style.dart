part of 'stylesheet.dart';

class ViewAllMediaPageStyle{
  const ViewAllMediaPageStyle({
    this.appBarTheme = const AppBarTheme(color: Colors.white,
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff181818),fontSize: 20),
      iconTheme: IconThemeData(color: Color(0xff181818)),
      actionsIconTheme: IconThemeData(color: Color(0xff181818)),),
    this.tabBarTheme = const TabBarTheme(
        indicatorColor: AppColor.primaryColor,
        labelColor: AppColor.primaryColor,
        unselectedLabelColor: Color(0xff181818),indicatorSize: TabBarIndicatorSize.tab),
    this.tabItemStyle = const TabItemStyle(),
    this.noDataTextStyle = const TextStyle(fontWeight: FontWeight.w600,color: Color(0xff767676),fontSize: 14),
    this.groupedMediaItem = const GroupedMediaItemStyle()
});
  final AppBarTheme appBarTheme;
  final TabBarTheme tabBarTheme;
  final TabItemStyle tabItemStyle;
  final TextStyle noDataTextStyle;
  final GroupedMediaItemStyle groupedMediaItem;
}

class GroupedMediaItemStyle{
  const GroupedMediaItemStyle({
    this.titleStyle = const TextStyle(fontWeight: FontWeight.w500,color: Color(0xff323232),fontSize: 14),
    this.mediaImageItemStyle = const MediaItemStyle(),
    this.mediaVideoItemStyle = const MediaItemStyle(),
    this.mediaAudioItemStyle = const MediaItemStyle(bgColor: Color(0xff97A5C7)),
    this.documentItemStyle = const DocumentItemStyle(
      titleTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff181818),fontSize: 12),
      sizeTextStyle: TextStyle(fontWeight: FontWeight.w300,color: Color(0xff757575),fontSize: 10),
      dateTextStyle: TextStyle(fontWeight: FontWeight.w300,color: Color(0xff757575),fontSize: 10)
    ),
    this.linkItemStyle = const LinkItemStyle(
      titleTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Colors.black,fontSize: 12),
      descriptionTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff707070),fontSize: 8),
      linkTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff7889B3),fontSize: 12),
      iconColor: Colors.white,
      outerDecoration: BoxDecoration(
          color: Color(0xffE2E8F7),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      innerDecoration: BoxDecoration(
          color: Color(0xffD0D8EB),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      iconDecoration: BoxDecoration(
          color: Color(0xff97A5C7),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8)))
    )
});
  final TextStyle titleStyle;
  final MediaItemStyle mediaImageItemStyle;
  final MediaItemStyle mediaVideoItemStyle;
  final MediaItemStyle mediaAudioItemStyle;
  final DocumentItemStyle documentItemStyle;
  final LinkItemStyle linkItemStyle;
}

class MediaItemStyle{
  const MediaItemStyle({this.iconColor = Colors.white,this.bgColor = Colors.transparent});
  final Color bgColor;
  final Color iconColor;
}

class DocumentItemStyle{
  const DocumentItemStyle({
    this.titleTextStyle = const TextStyle(fontWeight: FontWeight.normal,color: Color(0xff181818),fontSize: 12),
    this.sizeTextStyle = const TextStyle(fontWeight: FontWeight.w300,color: Color(0xff757575),fontSize: 10),
    this.dateTextStyle = const TextStyle(fontWeight: FontWeight.w300,color: Color(0xff757575),fontSize: 10),
    this.dividerColor = const Color(0xffFAFAFA)
});
  final TextStyle titleTextStyle;
  final TextStyle sizeTextStyle;
  final TextStyle dateTextStyle;
  final Color dividerColor;
}

class LinkItemStyle{
  const LinkItemStyle({
    this.titleTextStyle = const TextStyle(fontWeight: FontWeight.normal,color: Colors.black,fontSize: 12),
    this.descriptionTextStyle = const TextStyle(fontWeight: FontWeight.normal,color: Color(0xff111111),fontSize: 8),
    this.linkTextStyle = const TextStyle(fontWeight: FontWeight.normal,color: Color(0xff7889B3),fontSize: 12),
    this.iconColor = Colors.white,
    this.outerDecoration = const BoxDecoration(
  color: Color(0xffE2E8F7),
  borderRadius: BorderRadius.all(Radius.circular(6))),
    this.innerDecoration = const BoxDecoration(
  color: Color(0xffD0D8EB),
  borderRadius: BorderRadius.all(Radius.circular(6))),
    this.iconDecoration = const BoxDecoration(
  color: Color(0xff97A5C7),
  borderRadius: BorderRadius.only(
  topLeft: Radius.circular(6),
  bottomLeft: Radius.circular(6)))
});
  final TextStyle titleTextStyle;
  final TextStyle descriptionTextStyle;
  final TextStyle linkTextStyle;
  final Color iconColor;
  final Decoration outerDecoration;
  final Decoration innerDecoration;
  final Decoration iconDecoration;
}