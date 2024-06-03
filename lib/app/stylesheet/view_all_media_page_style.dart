part of 'stylesheet.dart';

class ViewAllMediaPageStyle{
  const ViewAllMediaPageStyle({
    this.appBarTheme = const AppBarTheme(color: Colors.white),
    this.tabBarTheme = const TabBarTheme(
        indicatorColor: Color(0xff3276E2),
        labelColor: Color(0xff3276E2),
        unselectedLabelColor: Color(0xff181818)),
    this.tabItemStyle = const TabItemStyle(),
    this.noDataTextStyle = const TextStyle(fontWeight: FontWeight.w600,color: Color(0xff767676),fontSize: 14),
    this.groupedMediaItem = const GroupedMediaItem()
});
  final AppBarTheme appBarTheme;
  final TabBarTheme tabBarTheme;
  final TabItemStyle tabItemStyle;
  final TextStyle noDataTextStyle;
  final GroupedMediaItem groupedMediaItem;
}

class GroupedMediaItem{
  const GroupedMediaItem({
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
      descriptionTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff111111),fontSize: 8),
      linkTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff7889B3),fontSize: 12),
      iconBgColor: Color(0xff97A5C7)
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
  const MediaItemStyle({this.bgColor = Colors.transparent});
  final Color bgColor;
}

class DocumentItemStyle{
  const DocumentItemStyle({
    this.titleTextStyle = const TextStyle(fontWeight: FontWeight.normal,color: Color(0xff181818),fontSize: 12),
    this.sizeTextStyle = const TextStyle(fontWeight: FontWeight.w300,color: Color(0xff757575),fontSize: 10),
    this.dateTextStyle = const TextStyle(fontWeight: FontWeight.w300,color: Color(0xff757575),fontSize: 10),
});
  final TextStyle titleTextStyle;
  final TextStyle sizeTextStyle;
  final TextStyle dateTextStyle;
}

class LinkItemStyle{
  const LinkItemStyle({
    this.titleTextStyle = const TextStyle(fontWeight: FontWeight.normal,color: Colors.black,fontSize: 12),
    this.descriptionTextStyle = const TextStyle(fontWeight: FontWeight.normal,color: Color(0xff111111),fontSize: 8),
    this.linkTextStyle = const TextStyle(fontWeight: FontWeight.normal,color: Color(0xff7889B3),fontSize: 12),
    this.iconBgColor = const Color(0xff97A5C7)
});
  final TextStyle titleTextStyle;
  final TextStyle descriptionTextStyle;
  final TextStyle linkTextStyle;
  final Color iconBgColor;
}