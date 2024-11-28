

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icloud_storage_sync/icloud_storage_sync.dart';
import 'package:icloud_storage_sync/models/icloud_file_download.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';


class BackupRestoreManager {

  // Private constructor
  BackupRestoreManager._internal();

  // Singleton instance
  static final BackupRestoreManager _instance = BackupRestoreManager._internal();

  factory BackupRestoreManager() {
    return _instance;
  }

  final icloudSyncPlugin = IcloudStorageSync();

  var _backupFileName = '';

  get backupFileName => _backupFileName;

  var _iCloudContainerID = '';

  final _iCloudRelativePath = 'Backups/MirrorFlyFlutter/UserData/';

  get iCloudRelativePath => _iCloudRelativePath;

  bool _isInitialized = false;

  /// Check if the manager is initialized
  bool get isInitialized => _isInitialized;

  var _clientId = '';

  get clientId => _clientId;

  final List<String> _scopes = [drive.DriveApi.driveReadonlyScope];

  initialize({required iCloudContainerID, required googleClientId}){

    if (_isInitialized) {
      LogMessage.d("BackupRestoreManager", "Already initialized.");
      return;
    }

    _iCloudContainerID = iCloudContainerID;
    _clientId = googleClientId;
    _backupFileName = "Backup_${SessionManagement.getUsername()}.txt";

    initializeEventListeners();

  }

  Future<bool> checkDriveAccess() async {
    if(Platform.isAndroid){
      return _checkGoogleDriveAccess();
    }else if (Platform.isIOS){
      return _checkICloudAccess();
    }else{
      LogMessage.d("Backup and Restore", "Platform is not Supported");
      return true;
    }
  }

  Future<bool> checkBackUpFiles() async {
    if (Platform.isAndroid) {
      return false;
    }else if (Platform.isIOS){
      List<CloudFiles> iCloudFiles = await icloudSyncPlugin.getCloudFiles(containerId: _iCloudContainerID);
      return iCloudFiles.any((file) => file.filePath == backupFileName);
    }else{
      LogMessage.d("Backup and Restore", "Platform is not Supported");
      return false;
    }
  }

  Future<void> uploadBackupFile({required String filePath}) async {
    if(Platform.isAndroid){

    }else if (Platform.isIOS){
      await icloudSyncPlugin.upload(
        containerId: _iCloudContainerID,
        filePath: filePath,
        destinationRelativePath: iCloudRelativePath,
        onProgress: onBackupUploadProgress,
      );

    }else{
      LogMessage.d("Backup and Restore", "Platform is not Supported");
    }
  }

  Future<void> backupFile() async {
    await Mirrorfly.startBackup();
  }

  void onBackupUploadProgress(Stream<double> p1) {
    debugPrint("Uploading to server progress $p1");
  }

  Future<bool> _checkICloudAccess() async {
    try {
      var iCloudFile = await icloudSyncPlugin.gather(containerId: _iCloudContainerID);
      LogMessage.d("BackupRestoreManager Access Success", iCloudFile);
      return true;
    } catch (e) {
      LogMessage.d("BackupRestoreManager", "iCloud access check failed: $e");
      return false;
    }
  }


  Future<bool> _checkGoogleDriveAccess() async {
    try {
      // Authenticate using Google Sign-In
      final authClient = await clientViaUserConsent(
        ClientId(_clientId, null),
        _scopes,
            (url) {
              LogMessage.d("BackupRestoreManager", "Please visit the following URL and grant access: $url");

        },
      );

      // Create an instance of the Drive API
      final driveApi = drive.DriveApi(authClient);

      // Attempt to list files in Google Drive
      final fileList = await driveApi.files.list();
      LogMessage.d("BackupRestoreManager", "Files in Drive: ${fileList.files?.length ?? 0}");

      // If no exception is thrown, Drive access is available
      authClient.close();
      return true;
    } catch (e) {
      // If an error occurs, Drive access is not available
      LogMessage.d("BackupRestoreManager", "Error checking Google Drive access: $e");
      return false;
    }
  }


  void initializeEventListeners() {
    Mirrorfly.onBackupSuccess.listen((event) {
      debugPrint("onBackupSuccess==> $event");
      uploadBackupFile(filePath: "filePath");
    });

    Mirrorfly.onBackupFailure.listen((event) {

    });

    Mirrorfly.onBackupProgressChanged.listen((event) {

    });

    Mirrorfly.onRestoreSuccess.listen((event) {

    });

    Mirrorfly.onRestoreFailure.listen((event) {

    });

    Mirrorfly.onRestoreProgressChanged.listen((event) {

    });
  }

  void destroy() {
    LogMessage.d("BackupRestoreManager", "Destroying manager...");
    _isInitialized = false;
    _iCloudContainerID = '';
    _backupFileName = '';
  }
}