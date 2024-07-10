
part of 'utils.dart';

class DialogUtils {
  DialogUtils._();
  // DialogUtils(this.buildContext);

  static const RouteSettings _routeSettings = RouteSettings(name: '/dialog');
  // final BuildContext buildContext;
  static BuildContext get buildContext => NavUtils.currentContext;

  static createDialog(Widget builder){
    return showDialog(context: buildContext, builder: (_){
      return builder;
    },routeSettings: _routeSettings);
  }

  static bottomSheet(Widget builder,{bool ignoreSafeArea = false, bool isScrollControlled = false,
    bool enableDrag = true,bool isDismissible = true, Color backgroundColor = Colors.transparent, Color barrierColor = Colors.transparent}){
    return showModalBottomSheet(context: buildContext,
        routeSettings: _routeSettings,
        builder: (_){
      return builder;
    },isDismissible: isDismissible,useSafeArea: ignoreSafeArea,backgroundColor: backgroundColor, isScrollControlled: isScrollControlled,enableDrag: enableDrag, barrierColor: barrierColor);
  }

  // Method to show a loading dialog
  static void showLoading(
      {String? message,
      bool dismiss = false,required DialogStyle dialogStyle}) {
    showDialog(
      context: buildContext,routeSettings: _routeSettings,
      builder: (_) {
        return Dialog(
          backgroundColor: dialogStyle.backgroundColor,
          child: PopScope(
            canPop: dismiss,
            onPopInvoked: (didPop) {
              if (didPop) {
                return;
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(message ?? getTranslated("loading"),style: dialogStyle.titleTextStyle,),
                ],
              ),
            ),
          ),
        );
      },
      barrierDismissible: dismiss,
    );
  }

  // Method to show a simple progress loading dialog
  static void progressLoading(
      {bool dismiss = false}) {
    showDialog(
        context: buildContext,routeSettings: _routeSettings,
        builder: (_) {
          return AlertDialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: PopScope(
              canPop: dismiss,
              onPopInvoked: (didPop) {
                if (didPop) {
                  return;
                }
              },
              child: const SizedBox(
                width: 60,
                height: 60,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
        },
        barrierDismissible: dismiss,
        barrierColor: Colors.transparent);
  }

  // Method to show an alert dialog
  static void showAlert(
      {String? title,
      required String message,
      List<Widget>? actions,
      Widget? content,
      bool? barrierDismissible,required DialogStyle dialogStyle}) {
    showDialog(
        context: buildContext,routeSettings: _routeSettings,
        builder: (_) {
          return AlertDialog(
            backgroundColor: dialogStyle.backgroundColor,//Colors.white,
            title: title != null
                ? Text(
                    title,
                    style: dialogStyle.titleTextStyle,
                    // style: const TextStyle(fontSize: 17),
                  )
                : const Offstage(),
            contentPadding: title != null
                ? const EdgeInsets.only(top: 15, right: 25, left: 25, bottom: 0)
                : const EdgeInsets.only(top: 0, right: 25, left: 25, bottom: 5),
            content: PopScope(
              canPop: barrierDismissible ?? true,
              onPopInvoked: (didPop) {
                if (didPop) {
                  return;
                }
              },
              child: content ??
                  Text(
                    message,
                    style: dialogStyle.contentTextStyle,
                    /*style: const TextStyle(
                        color: textHintColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 18),*/
                  ),
            ),
            contentTextStyle: dialogStyle.contentTextStyle,
            // contentTextStyle: const TextStyle(color: textHintColor, fontWeight: FontWeight.w500),
            actions: actions,
          );
        },
        barrierDismissible: barrierDismissible ?? true);
  }

  // Method to show a dialog with vertical buttons
  static void showVerticalButtonAlert(
      {required List<Widget> actions}) {
    showDialog(
        context: buildContext,routeSettings: _routeSettings,
        builder: (_) {
          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: actions,
            ),
          );
        });
  }

  // Method to show a dialog with horizontal buttons
  static void showButtonAlert(
      {required List<Widget> actions}) {
    showDialog(
        context: buildContext,routeSettings: _routeSettings,
        builder: (_) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: actions,
              ),
            ),
          );
        });
  }

  // Method to hide loading dialog
  static void hideLoading() {
    if (isDialogOpen()) {
      Navigator.pop(buildContext);
    }
  }

  // Method to check if any dialog is open
  static bool isDialogOpen() {
    return NavUtils.currentRoute == '/dialog';
  }

  // Method to show a feature unavailable alert
  static void showFeatureUnavailable() {
    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("featureNotAvailableForYourPlan"),
        actions: [
          TextButton(
        style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                Navigator.of(buildContext).pop();
              },
              child: Text(getTranslated("ok"))),
        ]);
  }
}
