part of "extensions.dart";

extension ProfileParsing on ProfileDetails {
  String getUsername() {
    var value = Mirrorfly.getProfileDetails(jid: jid.checkNull());
    var str = ProfileDetails.fromJson(json.decode(value.toString()));
    return str.getName(); //str.name.checkNull();
  }

  Future<ProfileDetails> getProfileDetails() async {
    var value = await Mirrorfly.getProfileDetails(jid: jid.checkNull());
    var str = ProfileDetails.fromJson(json.decode(value.toString()));
    return str;
  }

  bool isDeletedContact() {
    return contactType == "deleted_contact";
  }

  String getChatType() {
    return (isGroupProfile ?? false) ? ChatType.groupChat : ChatType.singleChat;
  }

  bool isItSavedContact() {
    return contactType == 'live_contact';
  }

  bool isUnknownContact() {
    return !isDeletedContact() &&
        !isItSavedContact() &&
        !isGroupProfile.checkNull();
  }

  bool isEmailContact() =>
      !isGroupProfile.checkNull() &&
      isGroupInOfflineMode
          .checkNull(); // for email contact isGroupInOfflineMode will be true

  String getName() {
    if (!Constants.enableContactSync) {
      if (jid.checkNull() == SessionManagement.getUserJID()) {
        return getTranslated("you");
      }
      /*return item.name.toString().checkNull().isEmpty
        ? item.nickName.toString()
        : item.name.toString();*/
      return name.checkNull().isEmpty
          ? (nickName.checkNull().isEmpty
              ? getMobileNumberFromJid(jid.checkNull())
              : nickName.checkNull())
          : name.checkNull();
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
        return nickName.checkNull().isEmpty
            ? (name.checkNull().isEmpty
                ? getMobileNumberFromJid(jid.checkNull())
                : name.checkNull())
            : nickName.checkNull(); //#FLUTTER-1300
      }
    }
  }
}
