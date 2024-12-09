

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icloud_storage_sync/icloud_storage_sync.dart';
import 'package:icloud_storage_sync/models/icloud_file_download.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/modules/backup_restore/controllers/backup_controller.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import 'package:path_provider/path_provider.dart';


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

  // GoogleSignInAccount? _googleAccountSignedIn;


  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  GoogleSignInAccount? get getGoogleAccountSignedIn => googleSignIn.currentUser;

  bool isServerUploadRequired = false;

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
        // destinationRelativePath: iCloudRelativePath,
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


  /*Future<bool> _checkGoogleDriveAccess() async {
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
  }*/

  Future<bool> _checkGoogleDriveAccess() async {
    try {
      // Attempt silent sign-in to get the last signed-in user
      final GoogleSignInAccount? account = await googleSignIn.signInSilently();

      if (account != null) {
        LogMessage.d("BackupRestoreManager", 'User is already signed in!');
        LogMessage.d("BackupRestoreManager", 'Email: ${account.email}');
        LogMessage.d("BackupRestoreManager", 'Display Name: ${account.displayName}');
        LogMessage.d("BackupRestoreManager", 'Profile Picture URL: ${account.photoUrl}');
        return true;
      } else {
        // No user is signed in
        LogMessage.d("BackupRestoreManager", 'No user is signed in currently.');
        return false;
      }
    } catch (error) {
      LogMessage.d("BackupRestoreManager", 'Error retrieving signed-in user: $error');
      return false;
    }
  }

  Future<GoogleSignInAccount?> selectGoogleAccount() async {
    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account != null) {
        LogMessage.d("BackupRestoreManager", 'Selected account email: ${account.email}');
        return account;
      } else {
        LogMessage.d("BackupRestoreManager", 'No account selected');
        return null;
      }
    } catch (error) {
      LogMessage.d("BackupRestoreManager", 'Error selecting account: $error');
      return null;
    }
  }

  Future<GoogleSignInAccount?> switchGoogleAccount() async {
    try {
      final GoogleSignInAccount? currentUser = googleSignIn.currentUser;

      if (currentUser != null) {
        LogMessage.d("BackupRestoreManager", 'Current user: ${currentUser.email}');
        LogMessage.d("BackupRestoreManager", 'Signing out...');

        await googleSignIn.signOut();
        LogMessage.d("BackupRestoreManager", 'Signed out successfully.');
      }

      final GoogleSignInAccount? newAccount = await googleSignIn.signIn();

      if (newAccount != null) {
        LogMessage.d("BackupRestoreManager", 'Signed in with new account: ${newAccount.email}');
        LogMessage.d("BackupRestoreManager", 'Display Name: ${newAccount.displayName}');
        return newAccount;
      } else {
        LogMessage.d("BackupRestoreManager", 'User canceled the sign-in process.');
        return null;
      }
    } catch (error) {
      LogMessage.d("BackupRestoreManager", 'Error switching account: $error');
      return null;
    }
  }


  void initializeEventListeners() {
    Mirrorfly.onBackupSuccess.listen((backUpPath) {
      debugPrint("onBackupSuccess==> $backUpPath");
      if(isServerUploadRequired) {
        uploadBackupFile(filePath: backUpPath);
      }
    });

    Mirrorfly.onBackupFailure.listen((event) {

    });

    Mirrorfly.onBackupProgressChanged.listen((event) {
      if (Get.isRegistered<BackupController>()) {
        Get.find<BackupController>().backUpProgress(event);
      }
    });

    Mirrorfly.onRestoreSuccess.listen((event) {

    });

    Mirrorfly.onRestoreFailure.listen((event) {

    });

    Mirrorfly.onRestoreProgressChanged.listen((event) {

    });
  }

  void startBackup({bool isServerUploadRequired = false}) {
    this.isServerUploadRequired = isServerUploadRequired;
    Mirrorfly.startBackup();
  }

  void restoreBackup() {
    Mirrorfly.restoreBackup(backupPath: "backupFilePath");
  }


  Future<String?> getGroupContainerIDPath() async {

    // Check if the app group directory exists
    try {
      final appGroupContainer = Directory('/private/var/mobile/Containers/Shared/AppGroup/$_iCloudContainerID');
      if (await appGroupContainer.exists()) {
        return appGroupContainer.path;
      }
    } catch (e) {
      LogMessage.d("BackupRestoreManager", "Error accessing App Group Container: $e");
    }

    // Fallback to the documents directory
    final documentDirectory = await getApplicationDocumentsDirectory();
    return documentDirectory.path;
  }

  Future<String?> getBackupUrl(String username) async {
    final baseDirectory = await getGroupContainerIDPath();

    if (baseDirectory == null) {
      return null;
    }

    // Append "iCloudBackup" and the backup filename
    final backupDirectory = Directory('$baseDirectory/iCloudBackup');
    if (!await backupDirectory.exists()) {
      // await backupDirectory.create(recursive: true);
      LogMessage.d("BackupRestoreManager", "Error while accessing Backup Directory, Directory path is not found");
    }

    return '${backupDirectory.path}/Backup_$username.txt';
  }



  void destroy() {
    LogMessage.d("BackupRestoreManager", "Destroying manager...");
    _isInitialized = false;
    _iCloudContainerID = '';
    _backupFileName = '';
  }
}