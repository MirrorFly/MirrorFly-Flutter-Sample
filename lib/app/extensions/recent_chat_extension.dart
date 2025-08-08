part of "extensions.dart";

extension RecentChatParsing on RecentChatData {
  String getChatType() {
    return (isGroup.checkNull())
        ? ChatType.groupChat
        : (isBroadCast.checkNull())
            ? ChatType.broadcastChat
            : ChatType.singleChat;
  }

  bool isDeletedContact() {
    return contactType == "deleted_contact";
  }

  bool isItSavedContact() {
    return contactType == 'live_contact';
  }

  bool isUnknownContact() {
    return !isDeletedContact() && !isItSavedContact() && !isGroup.checkNull();
  }

  bool isEmailContact() =>
      !isGroup.checkNull() &&
      isGroupInOfflineMode
          .checkNull(); // for email contact isGroupInOfflineMode will be true

  String getName() {
    if (!Constants.enableContactSync) {
      /*return item.name.toString().checkNull().isEmpty
        ? item.nickName.toString()
        : item.name.toString();*/
      return profileName.checkNull().isEmpty
          ? nickName.checkNull().isNotEmpty
              ? nickName.checkNull()
              : getMobileNumberFromJid(jid.checkNull())
          : profileName.checkNull();
    } else {
      if (jid.checkNull() == SessionManagement.getUserJID()) {
        return getTranslated("you");
      } else if (isDeletedContact()) {
        LogMessage.d('isDeletedContact', isDeletedContact().toString());
        return getTranslated("deletedUser");
      } else if (isUnknownContact() || nickName.checkNull().isEmpty) {
        LogMessage.d('isUnknownContact', jid.toString());
        return getMobileNumberFromJid(jid.checkNull());
      } else {
        LogMessage.d('nickName', nickName.toString());
        return nickName.checkNull();
      }
    }
  }
}
