part of "extensions.dart";

extension ScrollControllerExtension on ScrollController {
  void scrollTo(
      {required int index, required Duration duration, Curve? curve}) {
    var offset = getOffset(GlobalKey(debugLabel: "CHATITEM_$index"));
    LogMessage.d("ScrollTo", offset);
    animateTo(
      offset,
      duration: duration,
      curve: Curves.linear,
    );
  }

  void jumpsTo({required double index}) {
    jumpTo(index);
  }

  double getOffset(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox;
    final boxHeight = box.size.height;
    Offset boxPosition = box.localToGlobal(Offset.zero);
    double boxY = (boxPosition.dy - boxHeight / 2);
    return boxY;
  }

  bool get isAttached => hasClients;
}
