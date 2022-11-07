import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';

class GroupCreationController extends GetxController {
  TextEditingController groupName = TextEditingController();
  var imagepath = "".obs;
  var userImgUrl = "".obs;
  var name = "".obs;
  var count = "25".obs;
  var loading = false.obs;

  final _obj = ''.obs;
  set obj(value) => _obj.value = value;
  get obj => _obj.value;
}