import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';

import '../../../data/utils.dart';

class ImageViewController extends GetxController {
  var imageName = ''.obs;
  var imagePath = ''.obs;
  var imageUrl = ''.obs;
  @override
  void onInit() {
    super.onInit();
    imageName(NavUtils.arguments['imageName']);
    imagePath(NavUtils.arguments['imagePath']);
    if(NavUtils.arguments['imageUrl'].toString().startsWith("http")) {
      imageUrl(NavUtils.arguments['imageUrl']);
    }else {
      imageUrl(SessionManagement.getMediaEndPoint().checkNull() +
          NavUtils.arguments['imageUrl'].toString());
    }
  }


}
