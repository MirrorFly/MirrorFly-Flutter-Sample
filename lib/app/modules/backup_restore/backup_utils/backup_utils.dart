import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import '../../../common/app_localizations.dart';
import '../../../data/utils.dart';
import 'icloud_instruction_view.dart';

class BackupUtils {
  Future<dynamic> showBackupOptionList(
      {required String selectedValue, required List<String> listValue}) {
    return DialogUtils.createDialog(
      Dialog(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20.0, top: 20, right: 15, bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                getTranslated("backupScheduleTitle"),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 15,
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: listValue.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    var instanceItem = listValue[index];

                    return ListTile(
                      contentPadding: const EdgeInsets.only(left: 10),
                      title: Text(instanceItem,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.normal)),
                      leading: instanceItem == selectedValue
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                            )
                          : const SizedBox.shrink(),
                      onTap: () {
                        if (instanceItem != selectedValue) {
                          debugPrint("selected audio item $instanceItem");
                          NavUtils.back(result: instanceItem);
                        } else {
                          LogMessage.d("routeAudioOption",
                              "clicked on same audio type selected");
                        }
                      },
                    );
                  }),
              TextButton(
                  onPressed: () {
                    NavUtils.back();
                  },
                  child: Text(getTranslated("cancel")))
            ],
          ),
        ),
      ),
    );
  }

  String formatDateTime(String isoString) {
    final DateTime parsedDate = DateTime.parse(isoString).toLocal();
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(parsedDate);

    if (difference.inSeconds < 60) {
      return "Just now";
    } else if (difference.inMinutes == 1) {
      return "1 minute ago";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inHours == 1) {
      return "1 hour ago";
    } else {
      final DateFormat formatter = DateFormat("d MMM yyyy | h.mm a");
      return formatter.format(parsedDate);
    }
  }

  void showIcloudSetupInstruction() {
    showModalBottomSheet(
      context: NavUtils.currentContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return const IcloudInstructionView();
      },
    );
  }
}
