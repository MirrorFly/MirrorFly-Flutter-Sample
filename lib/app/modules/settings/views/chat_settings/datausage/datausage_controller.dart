import 'package:get/get.dart';
import '../../../../../common/constants.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

class DataUsageController extends GetxController{

  var wifi = "Wifi";
  var mobile = "Mobile";

  final _openMobileData = false.obs;
  bool get openMobileData => _openMobileData.value;

  final _openWifiData = false.obs;
  bool get openWifiData => _openWifiData.value;

  final _autoDownloadMobilePhoto = false.obs;
  bool get autoDownloadMobilePhoto => _autoDownloadMobilePhoto.value;
  final _autoDownloadMobileVideo = false.obs;
  bool get autoDownloadMobileVideo => _autoDownloadMobileVideo.value;
  final _autoDownloadMobileAudio = false.obs;
  bool get autoDownloadMobileAudio => _autoDownloadMobileAudio.value;
  final _autoDownloadMobileDocument = false.obs;
  bool get autoDownloadMobileDocument => _autoDownloadMobileDocument.value;

  final _autoDownloadWifiPhoto = false.obs;
  bool get autoDownloadWifiPhoto => _autoDownloadWifiPhoto.value;
  final _autoDownloadWifiVideo = false.obs;
  bool get autoDownloadWifiVideo => _autoDownloadWifiVideo.value;
  final _autoDownloadWifiAudio = false.obs;
  bool get autoDownloadWifiAudio => _autoDownloadWifiAudio.value;
  final _autoDownloadWifiDocument = false.obs;
  bool get autoDownloadWifiDocument => _autoDownloadWifiDocument.value;

  @override
  void onInit() async{
    super.onInit();
    _autoDownloadMobilePhoto(await Mirrorfly.getMediaSetting(networkType: 0,type: "Photos"));
    _autoDownloadMobileVideo(await Mirrorfly.getMediaSetting(networkType:0,type: "Videos"));
    _autoDownloadMobileAudio(await Mirrorfly.getMediaSetting(networkType:0,type: "Audio"));
    _autoDownloadMobileDocument(await Mirrorfly.getMediaSetting(networkType:0,type: "Documents"));

    _autoDownloadWifiPhoto(await Mirrorfly.getMediaSetting(networkType:1,type: "Photos"));
    _autoDownloadWifiVideo(await Mirrorfly.getMediaSetting(networkType:1,type: "Videos"));
    _autoDownloadWifiAudio(await Mirrorfly.getMediaSetting(networkType:1,type: "Audio"));
    _autoDownloadWifiDocument(await Mirrorfly.getMediaSetting(networkType:1,type: "Documents"));
  }

  void selectMedia(String item){

  }

  void openMobile() {
    _openMobileData(!openMobileData);
  }
  void openWifi() {
    _openWifiData(!openWifiData);
  }

  setAutoDownloadMobilePhoto(bool value) => _autoDownloadMobilePhoto(value);
  setAutoDownloadMobileAudio(bool value) => _autoDownloadMobileAudio(value);
  setAutoDownloadMobileVideo(bool value) => _autoDownloadMobileVideo(value);
  setAutoDownloadMobileDocument(bool value) => _autoDownloadMobileDocument(value);

  setAutoDownloadWifiPhoto(bool value) => _autoDownloadWifiPhoto(value);
  setAutoDownloadWifiAudio(bool value) => _autoDownloadWifiAudio(value);
  setAutoDownloadWifiVideo(bool value) => _autoDownloadWifiVideo(value);
  setAutoDownloadWifiDocument(bool value) => _autoDownloadWifiDocument(value);

  void onClick(String from, String type){
    LogMessage.d("from", from);
    LogMessage.d("type", type);
    if(from==mobile) {
      switch (type) {
        case Constants.photo:
          setAutoDownloadMobilePhoto(!_autoDownloadMobilePhoto.value);
          break;
        case Constants.audio:
          setAutoDownloadMobileAudio(!_autoDownloadMobileAudio.value);
          break;
        case Constants.video:
          setAutoDownloadMobileVideo(!_autoDownloadMobileVideo.value);
          break;
        case Constants.document:
          setAutoDownloadMobileDocument(!_autoDownloadMobileDocument.value);
          break;
      }
    }else if(from==wifi){
      switch (type) {
        case Constants.photo:
          setAutoDownloadWifiPhoto(!_autoDownloadWifiPhoto.value);
          break;
        case Constants.audio:
          setAutoDownloadWifiAudio(!_autoDownloadWifiAudio.value);
          break;
        case Constants.video:
          setAutoDownloadWifiVideo(!_autoDownloadWifiVideo.value);
          break;
        case Constants.document:
          setAutoDownloadWifiDocument(!_autoDownloadWifiDocument.value);
          break;
      }
    }
    saveDataUsageSettings();
  }

  RxBool getItem(String item,String type){
    if(item==mobile){
      switch(type){
        case Constants.photo:
          return _autoDownloadMobilePhoto;
        case Constants.audio:
          return _autoDownloadMobileAudio;
        case Constants.video:
          return _autoDownloadMobileVideo;
        case Constants.document:
          return _autoDownloadMobileDocument;
      }
    }else if(item==wifi){
      switch(type){
        case Constants.photo:
          return _autoDownloadWifiPhoto;
        case Constants.audio:
          return _autoDownloadWifiAudio;
        case Constants.video:
          return _autoDownloadWifiVideo;
        case Constants.document:
          return _autoDownloadWifiDocument;
      }
    }
    return false.obs;
  }

  saveDataUsageSettings(){
    Mirrorfly.saveMediaSettings(photos: autoDownloadMobilePhoto,videos: autoDownloadMobileVideo,audios: autoDownloadMobileAudio,documents: autoDownloadMobileDocument, networkType: 0);
    Mirrorfly.saveMediaSettings(photos: autoDownloadWifiPhoto,videos: autoDownloadWifiVideo,audios: autoDownloadWifiAudio,documents: autoDownloadWifiDocument, networkType: 1);
  }
}