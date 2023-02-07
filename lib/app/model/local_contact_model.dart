


import 'package:contacts_service/contacts_service.dart';

class LocalContact{

  Contact contact;
  bool isSelected;
  LocalContact({
    required this.contact,
    required this.isSelected
  });

}
class LocalContactPhone{
  List<ContactDetail> contactNo;
  String userName;
  LocalContactPhone({
    required this.contactNo,
    required this.userName
  });
}

class ContactDetail{
  String mobNo;
  String mobNoType;
  bool isSelected;
  ContactDetail({
    required this.mobNo,
    required this.mobNoType,
    required this.isSelected
  });
}

class ShareContactDetails{
  List<String> contactNo;
  String userName;
  ShareContactDetails({
    required this.contactNo,
    required this.userName
  });
}

