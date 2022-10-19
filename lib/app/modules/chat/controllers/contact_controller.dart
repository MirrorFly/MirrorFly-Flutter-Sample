import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/model/chatMessageModel.dart';
import 'package:mirror_fly_demo/app/nativecall/platformRepo.dart';

import '../../../model/userlistModel.dart';

class ContactController extends GetxController {
  ScrollController scrollcontroller = ScrollController();
  var pageNum = 1;
  var isPageLoading = true.obs;
  var scrollable = true.obs;
  var userslist = <Profile>[].obs;
  var mainuserslist = List<Profile>.empty(growable: true).obs;
  final TextEditingController searchQuery = TextEditingController();
  var search=false.obs;
  var _IsSearching = false;
  var _searchText = "";
  var _first = true;

  @override
  void onInit() {
    super.onInit();
    scrollcontroller.addListener(_scrollListener);
    //searchQuery.addListener(_searchListener);
    fetchUsers(false);
  }

  _scrollListener() {
    if(scrollcontroller.hasClients) {
      if (scrollcontroller.position.extentAfter <= 0 &&
          isPageLoading.value == false) {
        if (scrollable.value) {
          //isPageLoading.value = true;
          fetchUsers(false);
        }
      }
    }
  }
  searchListener(String text)async{
    debugPrint("searching .. ");
    if (text.isEmpty) {
      _IsSearching = false;
      _searchText = "";
      pageNum=1;
    }
    else {
      isPageLoading(true);
      _IsSearching = true;
      _searchText = text;
      pageNum=1;
    }
    fetchUsers(true);

  }

  backfromSearch(){
    search.value=false;
    searchQuery.text="";
    _searchText ="";
    //if(!_IsSearching){
      //isPageLoading.value=true;
      pageNum=1;
      //fetchUsers(true);
    //}
    userslist(mainuserslist);

  }

  fetchUsers(bool frmsearch) {
    PlatformRepo().getUsers(pageNum,_searchText).then((data) {
      var item = userListFromJson(data);
      frmsearch ? userslist(item.data) : userslist.addAll(item.data!);
      pageNum=pageNum+1;
      isPageLoading.value = false;
      scrollable.value = item.data!.length == 20;
      userslist.refresh();
      if(_first){
        _first=false;
        mainuserslist(item.data!);
      }
    })
    .catchError((error){
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    });
  }
  
  get users => userslist.value;

  String imagepath(String? imgurl){

    if(imgurl==null || imgurl==""){
     return "";
    }
    PlatformRepo().imagePath(imgurl).then((value){
      return value ?? "";
    });
    return "";
  }
}
