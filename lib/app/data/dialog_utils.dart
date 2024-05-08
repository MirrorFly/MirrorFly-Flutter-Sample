
part of 'utils.dart';

class DialogUtils {
  DialogUtils._();
  // DialogUtils(this.buildContext);

  // final BuildContext buildContext;
  static BuildContext get buildContext => NavUtils.currentContext;

  static createDialog(Widget builder){
    showDialog(context: buildContext, builder: (_){
      return builder;
    });
  }

  // Method to show a loading dialog
  static void showLoading(
      {String? message,
      bool dismiss = false}) {
    showDialog(
      context: buildContext,
      builder: (_) {
        return Dialog(
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
                  const CircularProgressIndicator(
                    color: buttonBgColor,
                  ),
                  const SizedBox(width: 16),
                  Text(message ?? getTranslated("loading")),
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
        context: buildContext,
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
      bool? barrierDismissible}) {
    showDialog(
        context: buildContext,
        builder: (_) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: title != null
                ? Text(
                    title,
                    style: const TextStyle(fontSize: 17),
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
                    style: const TextStyle(
                        color: textHintColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 18),
                  ),
            ),
            contentTextStyle: const TextStyle(
                color: textHintColor, fontWeight: FontWeight.w500),
            actions: actions,
          );
        },
        barrierDismissible: barrierDismissible ?? true);
  }

  // Method to show a dialog with vertical buttons
  static void showVerticalButtonAlert(
      {required List<Widget> actions}) {
    showDialog(
        context: buildContext,
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
        context: buildContext,
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
    if (isDialogOpen(buildContext)) {
      Navigator.of(buildContext).pop();
    }
  }

  // Method to check if any dialog is open
  static bool isDialogOpen(BuildContext context) {
    return ModalRoute.of(context)?.settings.name == '/dialog';
  }

  // Method to show a feature unavailable alert
  static void showFeatureUnavailable() {
    DialogUtils.showAlert(
        message: getTranslated("featureNotAvailableForYourPlan"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(buildContext).pop();
              },
              child: Text(getTranslated("ok"))),
        ]);
  }
}
