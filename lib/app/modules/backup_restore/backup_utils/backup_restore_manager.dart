import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:icloud_storage_sync/icloud_storage_sync.dart';
import 'package:icloud_storage_sync/models/icloud_file_download.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/modules/backup_restore/controllers/backup_controller.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import 'package:path_provider/path_provider.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/drive/v3.dart' as drive;


import '../../../data/utils.dart';
import 'backup_utils.dart';

class BackupRestoreManager {
  // Private constructor
  BackupRestoreManager._internal();

  // Singleton instance
  static final BackupRestoreManager instance =
      BackupRestoreManager._internal();



  final icloudSyncPlugin = IcloudStorageSync();

  var _backupFileName = '';

  get backupFileName => _backupFileName;

  var _iCloudContainerID = '';

  final _iCloudRelativePath = 'Backups/MirrorFlyFlutter/UserData/';

  get iCloudRelativePath => _iCloudRelativePath;

  bool _isInitialized = false;

  /// Check if the manager is initialized
  bool get isInitialized => _isInitialized;

  // var _clientId = '';

  // get clientId => _clientId;

  // GoogleSignInAccount? _googleAccountSignedIn;

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  GoogleSignInAccount? get getGoogleAccountSignedIn => googleSignIn.currentUser;

  bool isServerUploadRequired = false;
  bool isEncryptionEnabled = true;

  drive.DriveApi? driveApi;

  bool get isDriveApiInitialized => driveApi != null;

  StreamSubscription<List<int>>? _gDriveDownloadSubscription;

  StreamSubscription<double>? _icloudUploadSubscription;

  StreamController<List<int>>? _gDriveUploadStreamController;
  bool _isgDriveUploadCancelled = false;

  String _cloudBackUpDownloadPath = "";

  get remoteBackupPath => _cloudBackUpDownloadPath;

  Completer<void>? backupCompleter;


  Future<bool> initialize({required iCloudContainerID}) async {
    if (_isInitialized) {
      LogMessage.d("BackupRestoreManager", "Already initialized.");
      return true;
    }
    LogMessage.d(
        "BackupRestoreManager", "Initializing Backup Restore Manager.");

    _iCloudContainerID = iCloudContainerID;
    // _clientId = googleClientId;
    _backupFileName = "Backup_${SessionManagement.getUsername() ?? SessionManagement.getUserJID()?.split("@").first}";
    debugPrint("_backupFileName $_backupFileName");

    /// WorkManager Initialisation
    // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

    if (Platform.isAndroid) {
      // Fetch Google Previous Sign in
      final GoogleSignInAccount? account = getGoogleAccountSignedIn;
      if (account != null) {
        LogMessage.d("BackupRestoreManager", "Account $account");
        return assignAccountAuth(account);
      } else {
        LogMessage.d("BackupRestoreManager", "Account not signed in");
        final GoogleSignInAccount? account =
            await googleSignIn.signInSilently();
        if (account != null) {
          LogMessage.d("BackupRestoreManager", 'User is already signed in!');
          LogMessage.d("BackupRestoreManager", 'Email: ${account.email}');
          LogMessage.d(
              "BackupRestoreManager", 'Display Name: ${account.displayName}');
          LogMessage.d("BackupRestoreManager",
              'Profile Picture URL: ${account.photoUrl}');
          return assignAccountAuth(account);
        } else {
          // No user is signed in
          LogMessage.d(
              "BackupRestoreManager", 'No user is signed in currently.');
          return false;
        }
      }
    } else if (Platform.isIOS) {
      // For iOS returning true by default to check
      return true;
    } else {
      return false;
    }
  }

  Future<bool> assignAccountAuth(GoogleSignInAccount account) async {
    // Get authentication credentials
    final GoogleSignInAuthentication auth = await account.authentication;
    LogMessage.d("BackupRestoreManager", "GoogleSignInAuthentication $auth");
    // Create authenticated HTTP client
    final authClient = authenticatedClient(
      Client(),
      AccessCredentials(
        AccessToken('Bearer', auth.accessToken!, DateTime.now().toUtc()),
        null, // No refresh token needed for a single use
        ['https://www.googleapis.com/auth/drive.file'],
      ),
    );
    LogMessage.d("BackupRestoreManager", "authClient $authClient");

    // Initialize Google Drive API
    driveApi = drive.DriveApi(authClient);

    LogMessage.d("BackupRestoreManager", "driveApi $driveApi");

    return true;
  }

  Future<bool> checkDriveAccess() async {
    if (Platform.isAndroid) {
      // return _checkGoogleDriveAccess();
      return getGoogleAccountSignedIn?.serverAuthCode?.isNotEmpty ?? false;
    } else if (Platform.isIOS) {
      return _checkICloudAccess();
      // return checkICloudSignInStatus();
    } else {
      LogMessage.d("Backup and Restore", "Platform is not Supported");
      return true;
    }
  }

  Future<BackupFile?> checkBackUpFiles() async {
    LogMessage.d("BackupRestoreManager", "checkBackUpFiles called");
    if (Platform.isAndroid) {
      return getBackupFileDetails();
    } else if (Platform.isIOS) {
      LogMessage.d("BackupRestoreManager", "checkBackUpFiles platform is iOS");
      List<CloudFiles> iCloudFiles =
          await icloudSyncPlugin.getCloudFiles(containerId: _iCloudContainerID);
      LogMessage.d("BackupRestoreManager",
          "iCloudFiles found under the container ID ${iCloudFiles.length}");
      // Sort the files by modificationDate in descending order
      iCloudFiles.sort((a, b) => (b.lastSyncDt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.lastSyncDt ?? DateTime.fromMillisecondsSinceEpoch(0)));

      CloudFiles? iCloudFile = iCloudFiles.firstWhereOrNull(
          (file) => file.title == backupFileName);
      if (iCloudFile != null) {

        LogMessage.d("BackupRestoreManager", "===================================================");
        LogMessage.d("BackupRestoreManager", "iCloudFiles found under the container ID filePath: ${iCloudFile.filePath}");
        LogMessage.d("BackupRestoreManager", "iCloudFiles found under the container ID file Id: ${iCloudFile.id}");
        LogMessage.d("BackupRestoreManager", "iCloudFiles found under the container ID file Date: ${iCloudFile.fileDate}");
        LogMessage.d("BackupRestoreManager", "iCloudFiles found under the container ID file hasUploaded: ${iCloudFile.hasUploaded}");
        LogMessage.d("BackupRestoreManager", "iCloudFiles found under the container ID file lastSyncDt: ${iCloudFile.lastSyncDt}");
        LogMessage.d("BackupRestoreManager", "iCloudFiles found under the container ID file relativePath: ${iCloudFile.relativePath}");
        LogMessage.d("BackupRestoreManager", "iCloudFiles found under the container ID file sizeInBytes: ${iCloudFile.sizeInBytes}");
        LogMessage.d("BackupRestoreManager", "iCloudFiles found under the container ID file title: ${iCloudFile.title}");
        LogMessage.d("BackupRestoreManager", "===================================================");
        LogMessage.d("BackupRestoreManager", "backupFileName to check the file presence $backupFileName");

        return BackupFile(
            fileId: iCloudFile.id.toString(),
            fileName: iCloudFile.title,
            fileSize: MediaUtils.fileSize(iCloudFile.sizeInBytes, 2),
            fileCreatedDate:
                BackupUtils().formatDateTime(iCloudFile.lastSyncDt.toString()),
        iCloudRelativePath: iCloudFile.relativePath, filePath: iCloudFile.filePath);
      } else {
        LogMessage.d("BackupRestoreManager",
            "iCloudFiles found under the container ID not found");
        return null;
      }
    } else {
      LogMessage.d("BackupRestoreManager", "Platform is not Supported");
      return null;
    }
  }

  Future<void> uploadFileToGoogleDrive(String filePath,int fileSize, StreamController<int> progressController, List<String> existingFileIds) async {
    LogMessage.d("BackupRestoreManager", "uploadFileToGoogleDrive Started");
    try {
      File backupFile = File(filePath);

      var driveFile = drive.File();
      driveFile.name = backupFile.path.split('/').last;

      var trackedStream = trackProgress(
        backupFile.openRead(),
        fileSize,
            (progress) {
              LogMessage.d("BackupRestoreManager", "upload Started $progress");
          progressController.add((progress * 100).floor());
        },
      );
      // Upload the file
      var response = await driveApi?.files.create(
        driveFile,
        uploadMedia:
            drive.Media(trackedStream, fileSize),
      );
      if (_isgDriveUploadCancelled) {
        LogMessage.d("BackupRestoreManager", "Upload was cancelled.");
        return;
      }
      final uploadedFileId = response?.id;
      progressController.add(100);
      progressController.close();
      LogMessage.d("BackupRestoreManager", "Uploaded file ID: ${response?.id}");
      toToast(getTranslated("androidRemoteBackupSuccess"));

      if (Get.isRegistered<BackupController>()) {
        Get.find<BackupController>().serverUploadSuccess();
      }

      if (uploadedFileId != null) {
        final filesToDelete = existingFileIds.where((id) => id != uploadedFileId).toList();
        if (filesToDelete.isNotEmpty) {
          for (final fileId in filesToDelete) {
            try {
              await driveApi?.files.delete(fileId);

              LogMessage.d(
                  "BackupRestoreManager", "Deleted old backup file: $fileId");
            } catch (e) {
              LogMessage.d("BackupRestoreManager",
                  "Error deleting old file $fileId: $e");
            }
          }
        }else{
          LogMessage.d(
              "BackupRestoreManager", "No backup files found to delete");
        }
      }

    } catch (e) {
      LogMessage.d(
          "BackupRestoreManager", "Error uploading to Google Drive: $e");
      toToast("Backup Failed");
      progressController.addError(e);
      progressController.close();
    }
  }

  Future<BackupFile?> getBackupFileDetails() async {
    String fileFormat = Constants.backupEncryptedFileFormat;

    try {
      final fileList = await driveApi?.files.list(
        q: "'me' in owners and name = '$_backupFileName.$fileFormat'",
        spaces: 'drive',
        orderBy: 'modifiedTime desc', // Get the latest file first
        pageSize: 1,
        $fields: 'files(id, name, size, createdTime, mimeType)',
      );

      if (fileList != null && fileList.files!.isNotEmpty) {
        final latestFile = fileList.files?.first;
        if (!isEncryptionEnabled){
          fileFormat = Constants.backupRawFileFormat;
        }

        LogMessage.d("BackupRestoreManager getLatestFile",
            "Latest File ID: ${latestFile?.id}, Name: ${latestFile?.name}, {$backupFileName}.$fileFormat");
        //
        if (latestFile?.name == "$backupFileName.$fileFormat") {
          return BackupFile(
              fileId: latestFile?.id,
              fileName: latestFile?.name,
              fileSize: MediaUtils.fileSize(int.parse(latestFile?.size ?? "0"), 2),
              fileCreatedDate: BackupUtils()
                  .formatDateTime(latestFile!.createdTime.toString()));
        }else{
          LogMessage.d("BackupRestoreManager getLatestFile",
              "No file found with the name $backupFileName matches");
          return null;
        }
      } else {
        LogMessage.d("BackupRestoreManager getLatestFile",
            "No file found with the name $backupFileName.$fileFormat");
        return null;
      }
    } catch (e) {
      LogMessage.d("BackupRestoreManager listFiles", "Error listing files: $e");
      return null;
    }
  }

  Stream<int> uploadBackupFile({required String filePath, required int fileSize}) async* {
     final StreamController<int> progressController = StreamController<int>();

     List<String> existingBackupFileIds = [];

     // await checkAndDeleteExistingBackup();

     if (Platform.isAndroid) {
       final fileList = await driveApi?.files.list(
         q: "'me' in owners and name contains '$backupFileName.'",
         spaces: 'drive',
         $fields: 'files(id, name)',
       );

       if (fileList != null && fileList.files != null) {
         existingBackupFileIds = fileList.files!.map((f) => f.id!).toList();
       }

      await uploadFileToGoogleDrive(filePath, fileSize, progressController, existingBackupFileIds);
    } else if (Platform.isIOS) {
      debugPrint("Filepath to upload in drive $filePath");
      // final file = File(filePath.replaceFirst('file://', ''));
      final file = File(filePath);
      // debugPrint("Cleaned File Path: $file");
      if (!file.existsSync()) {
        progressController.addError(Exception("File does not exist at the given path: $filePath"));
        progressController.close();
        yield* progressController.stream;
        return;
      } else {
        debugPrint("File exists, proceeding with upload.");
      }

      _icloudUploadSubscription = null;

      LogMessage.d("BackupRestoreManager", "Container ID to upload $_iCloudContainerID");

      LogMessage.d("BackupRestoreManager", "Starting the upload to the iCLoud Drive");
      try {
        icloudSyncPlugin.upload(
          containerId: _iCloudContainerID,
          filePath: file.path,
          onProgress: (progressStream) {
            _icloudUploadSubscription = progressStream.listen(
              (progress) {
                debugPrint("Uploading to server progress: $progress");
                progressController.add(progress.floor());
              },
              onError: (error) {
                debugPrint("Upload failed with error: $error");
                progressController.addError(error);
                progressController.close();
              },
              onDone: () {
                ///Delay is added here, as the iCloud Process some time to update the latest file
                Future.delayed(const Duration(seconds: 1), () async {
                  debugPrint("Upload completed successfully.");
                  progressController.add(100); // Mark 100% completion
                  progressController.close();
                  toToast(getTranslated("iOSRemoteBackupSuccess"));

                  List<String> existingRelativePaths = [];

                  final iCloudFiles = await icloudSyncPlugin.getCloudFiles(containerId: _iCloudContainerID);
                  LogMessage.d("BackupRestoreManager", "iCloudFiles found under the container ID ${iCloudFiles.length}");

                  iCloudFiles.sort((a, b) => (b.lastSyncDt ?? DateTime.fromMillisecondsSinceEpoch(0))
                      .compareTo(a.lastSyncDt ?? DateTime.fromMillisecondsSinceEpoch(0)));

                  final newFileName = file.uri.pathSegments.last;

                  final CloudFiles? latestFile = iCloudFiles.firstWhereOrNull(
                        (file) => file.relativePath != null && file.relativePath!.endsWith(newFileName),
                  );

                  existingRelativePaths = iCloudFiles
                      .where((file) =>
                  file.relativePath != null &&
                      file.relativePath!.endsWith(newFileName) &&
                      file != latestFile)
                      .map((file) => file.relativePath!)
                      .toList();

                  if (existingRelativePaths.isNotEmpty) {
                    await icloudSyncPlugin.deleteMultipleFileToICloud(
                      containerId: _iCloudContainerID,
                      relativePathList: existingRelativePaths,
                    );
                  }else{
                    LogMessage.d("BackupRestoreManager", "iCloudFiles old files are not found to delete");
                  }



                });
              },
              cancelOnError: true,
            );
          },
        );
      } catch (e) {
        debugPrint("Upload failed with exception: $e");
        progressController.addError(e);
        progressController.close();
      }
    } else {
      LogMessage.d("Backup and Restore", "Platform is not Supported");
      progressController.addError(Exception("Platform not supported"));
      progressController.close();
    }
     yield* progressController.stream;
  }


  Future<bool> _checkICloudAccess() async {
    try {
      var iCloudFile =
          await icloudSyncPlugin.gather(containerId: _iCloudContainerID);
      LogMessage.d("BackupRestoreManager Access Success", iCloudFile);
      return true;
    } catch (e) {
      LogMessage.d("BackupRestoreManager", "iCloud access check failed: $e");
      return false;
    }
  }

  /// This is not used as the iCloud url itself supported by SDK for Restore.
  Stream<int> startIcloudFileDownload({required String relativePath}) async*{
    StreamController<int> iCloudProgressController = StreamController<int>();
    _cloudBackUpDownloadPath = "";
    await getBackupUrl().then((result) async {
      final fullFilePath = result != null ? "$result/$relativePath" : '';
      LogMessage.d("BackupRestoreManager", "download backup url: $fullFilePath");
      await icloudSyncPlugin.download(containerId: _iCloudContainerID, relativePath: relativePath, destinationFilePath: fullFilePath, onProgress: (value) {
        value.listen((progress){
          LogMessage.d("BackupRestoreManager", "Download Progress: $progress");
          iCloudProgressController.add((progress).floor());
        }, onDone: () {
          _cloudBackUpDownloadPath = fullFilePath;
          iCloudProgressController.add(100);
          iCloudProgressController.close();
        }, onError: (error) {
          _cloudBackUpDownloadPath = "";
          iCloudProgressController.addError(error);
          iCloudProgressController.close();
        });
      });
    });

    yield* iCloudProgressController.stream;
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

  /*Future<bool> _checkGoogleDriveAccess() async {
    try {
      // Attempt silent sign-in to get the last signed-in user
      final GoogleSignInAccount? account = await googleSignIn.signInSilently();

      if (account != null) {
        LogMessage.d("BackupRestoreManager", 'User is already signed in!');
        LogMessage.d("BackupRestoreManager", 'Email: ${account.email}');
        LogMessage.d(
            "BackupRestoreManager", 'Display Name: ${account.displayName}');
        LogMessage.d(
            "BackupRestoreManager", 'Profile Picture URL: ${account.photoUrl}');
        return true;
      } else {
        // No user is signed in
        LogMessage.d("BackupRestoreManager", 'No user is signed in currently.');
        return false;
      }
    } catch (error) {
      LogMessage.d(
          "BackupRestoreManager", 'Error retrieving signed-in user: $error');
      return false;
    }
  }*/

  Future<GoogleSignInAccount?> selectGoogleAccount() async {
    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account != null) {
        LogMessage.d(
            "BackupRestoreManager", 'Selected account email: ${account.email}');
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
        LogMessage.d(
            "BackupRestoreManager", 'Current user: ${currentUser.email}');
        LogMessage.d("BackupRestoreManager", 'Signing out...');

        await googleSignIn.signOut();
        LogMessage.d("BackupRestoreManager", 'Signed out successfully.');
      }

      final GoogleSignInAccount? newAccount = await googleSignIn.signIn();

      if (newAccount != null) {
        LogMessage.d("BackupRestoreManager",
            'Signed in with new account: ${newAccount.email}');
        LogMessage.d(
            "BackupRestoreManager", 'Display Name: ${newAccount.displayName}');
        return newAccount;
      } else {
        LogMessage.d(
            "BackupRestoreManager", 'User canceled the sign-in process.');
        return null;
      }
    } catch (error) {
      LogMessage.d("BackupRestoreManager", 'Error switching account: $error');
      return null;
    }
  }

  Future<void> startBackup({bool isServerUploadRequired = false, bool enableEncryption = true}) async {
    this.isServerUploadRequired = isServerUploadRequired;
    isEncryptionEnabled = enableEncryption;
    _isgDriveUploadCancelled = false;
    Mirrorfly.startBackup(enableEncryption: enableEncryption);
    // LogMessage.d("BackupRestoreManager", "Starting Backup WorkManager Task");
    // await Workmanager().cancelByUniqueName("backup-process");
    /*Workmanager().registerOneOffTask(
      "backup-process", /// Unique Task ID
      "backupTask", /// Task Name
      inputData: {
        "isServerUploadRequired": isServerUploadRequired,
        "enableEncryption": enableEncryption,
      },
    );*/
  }

  void restoreBackup({required String backupFilePath}) {
    LogMessage.d("BackupRestoreManager", 'Restoring Backup: $backupFilePath');
    Mirrorfly.restoreBackup(backupPath: backupFilePath);
    /*LogMessage.d("BackupRestoreManager", "Starting Restore WorkManager Task");
    Workmanager().registerOneOffTask(
      "restore-process", /// Unique Task ID
      "restoreTask", /// Task Name
      inputData: {
        "backupFilePath": backupFilePath,
      },
    );*/
  }

  Future<String?> getGroupContainerIDPath() async {
    // Check if the app group directory exists
    try {
      final appGroupContainer = Directory(
          '/private/var/mobile/Containers/Shared/AppGroup/$_iCloudContainerID');
      if (await appGroupContainer.exists()) {
        return appGroupContainer.path;
      }
    } catch (e) {
      LogMessage.d(
          "BackupRestoreManager", "Error accessing App Group Container: $e");
    }

    // Fallback to the documents directory
    final documentDirectory = await getApplicationDocumentsDirectory();
    return documentDirectory.path;
  }

  Future<String?> getBackupUrl() async {
    final baseDirectory = await getGroupContainerIDPath();

    if (baseDirectory == null) {
      return null;
    }

    // Append "iCloudBackup" and the backup filename
    final backupDirectory = Directory('$baseDirectory/iCloudBackup');
    if (!await backupDirectory.exists()) {
      await backupDirectory.create(recursive: true);
      LogMessage.d("BackupRestoreManager",
          "Error while accessing Backup Directory, Directory path is not found, Creating the Directory");
    }
    return backupDirectory.path;
  }

  void destroy() {
    LogMessage.d("BackupRestoreManager", "Destroying manager...");
    _isInitialized = false;
    _iCloudContainerID = '';
    _backupFileName = '';
  }

  /*Future<void> downloadFileWithCancel({
    required String fileId,
    required String savePath,
    required drive.DriveApi driveApi,
    required Function(File) onComplete,
    required Function(double) onProgress,
  }) async {
    try {
      final file = File(savePath);
      final media = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      );

      final List<int> data = [];
      int downloadedBytes = 0;
      int totalBytes = 0;

      _downloadSubscription = media.stream.listen(
            (chunk) {
          data.addAll(chunk);
          downloadedBytes += chunk.length;

          // Calculate progress
          if (totalBytes == 0) {
            // Get total file size from metadata if available
            drive.File metadata =
            driveApi.files.get(fileId, $fields: 'size') as drive.File;
            totalBytes = int.parse(metadata.size ?? '0');
          }
          final progress = (downloadedBytes / totalBytes) * 100;
          onProgress(progress);
        },
        onDone: () async {
          await file.writeAsBytes(data);
          onComplete(file);
          _downloadSubscription = null; // Reset subscription
        },
        onError: (error) {
          print("Error downloading file: $error");
          _downloadSubscription = null; // Reset subscription
        },
        cancelOnError: true,
      );
    } catch (e) {
      print("Error during download: $e");
    }
  }*/

  Future<String> getAndroidBackUpFolderPath() async {
    String rootFilePath;

    if (Platform.isAndroid) {
      var sdkVersion = 0;
      if (Platform.isAndroid) {
        var sdk = await DeviceInfoPlugin().androidInfo;
        sdkVersion = sdk.version.sdkInt;
      } else {
        sdkVersion = 0;
      }
      LogMessage.d("BackupRestoreManager", "sdkVersion $sdkVersion");

      if (sdkVersion < 29) {
        // For Android < Q (29), use external storage directory
        rootFilePath = "/storage/emulated/0"; // Equivalent to Environment.getExternalStorageDirectory().absolutePath
      } else {
        // For Android 10+ (Q), use externalMediaDirs[0]
        Directory? externalDir = (await getExternalStorageDirectories())?.first;
        rootFilePath = externalDir?.path ?? "/storage/emulated/0"; // Fallback in case of null
      }
    } else {
      throw UnsupportedError("This function is only for Android");
    }

    // Construct the backup folder path
    String backupFolderPath = "$rootFilePath/MirrorFly/Backups";

    // Logging equivalent
    LogMessage.d("BackupRestoreManager", "Android Cloud Backup Download Path: $backupFolderPath");

    Directory backUpDir = Directory(backupFolderPath);
    if (await backUpDir.exists()){
      return backupFolderPath;
    }else{
      await backUpDir.create(recursive: true);
      return backupFolderPath;
    }
  }

  Stream<int> downloadAndroidBackupFile(BackupFile backupFile) async*{
    final StreamController<int> downloadProgress = StreamController<int>();
    var downloadPath = await getAndroidBackUpFolderPath();
    String fileFormat = Constants.backupEncryptedFileFormat;

    if (!isEncryptionEnabled){
      fileFormat = Constants.backupRawFileFormat;
    }
    final file = File("$downloadPath/$backupFileName.$fileFormat");

    _cloudBackUpDownloadPath = "";

    try {

      // Delete the file if already exists
      if (await file.exists()) {
        await file.delete();
        LogMessage.d("BackupRestoreManager", "File deleted: ${file.path}");
      }else {
        LogMessage.d("BackupRestoreManager", "File not exists, so proceeding for Download");
      }

      // Request the file from Google Drive
      final response = await driveApi?.files.get(
        backupFile.fileId ?? "",
        downloadOptions: drive.DownloadOptions.fullMedia,
      );

      if (response is drive.Media) {
        final totalSize = MediaUtils().parseFileSize(backupFile.fileSize);
        int downloadedSize = 0;

        final sink = file.openWrite();

        // Stream the file data and write to disk
        _gDriveDownloadSubscription = response.stream.listen(
              (chunk) {
            sink.add(chunk);
            downloadedSize += chunk.length;
            // Calculate and report progress
            if (totalSize > 0) {
              final progress = (downloadedSize / totalSize) * 100;
              LogMessage.d("BackupRestoreManager", "Android Backup File Download Progress $progress");
              downloadProgress.add((progress * 100).floor());
            }
          },
          onDone: () async {
            await sink.close();
            LogMessage.d("BackupRestoreManager", "Android Backup File Download complete: ${file.path}");
            _cloudBackUpDownloadPath = file.path;
            downloadProgress.add(100);
            downloadProgress.close();
          },
          onError: (error) {
            LogMessage.d("BackupRestoreManager", "Android Backup File Error during file download: $error");
            sink.close();
            downloadProgress.addError(error);
            downloadProgress.close();
            // throw error;
          },
          cancelOnError: true,
        );
      } else {
        LogMessage.d("BackupRestoreManager", "Android Backup File Unexpected response type: ${response.runtimeType}");
        downloadProgress.addError(response.runtimeType);
        downloadProgress.close();
      }
    } catch (e) {
      LogMessage.d("BackupRestoreManager", "Android Backup File Error downloading file: $e");
      downloadProgress.addError(e);
      downloadProgress.close();
    }
    yield* downloadProgress.stream;
  }

  void _cancelAndroidBackupDownload() {
    if (_gDriveDownloadSubscription != null) {
      _gDriveDownloadSubscription?.cancel();
      _gDriveDownloadSubscription = null;
      debugPrint("Download canceled.");
    } else {
      debugPrint("No active download to cancel.");
    }
  }

  void completeWorkManagerTask() {
    backupCompleter?.complete();
    backupCompleter = null;
  }

  Future<void> checkAndDeleteExistingBackup() async {
    if (Platform.isAndroid){
      await deleteBackupFiles();
    }else if (Platform.isIOS){
    /// Delete the existing iCloud file and then proceed to upload
    List<CloudFiles> iCloudFiles =
        await icloudSyncPlugin.getCloudFiles(containerId: _iCloudContainerID);
    if (iCloudFiles.isNotEmpty) {
      LogMessage.d("BackupRestoreManager", "Deleting the iCLoud Files");
      List<String> relativePaths = iCloudFiles
          .where((file) => file.relativePath != null)
          .map((file) => file.relativePath!)
          .toList();

      await icloudSyncPlugin.deleteMultipleFileToICloud(
          containerId: _iCloudContainerID, relativePathList: relativePaths);

      LogMessage.d("BackupRestoreManager", "Deletion completed on the iCLoud Files");
    }
    }else{
      LogMessage.d("BackupRestoreManager", "No iCloud Files Found to delete");
    }
  }

  Future<void> deleteBackupFiles() async {
    String fileFormat = isEncryptionEnabled
        ? Constants.backupEncryptedFileFormat
        : Constants.backupRawFileFormat;

    try {
      final fileList = await driveApi?.files.list(
        q: "'me' in owners and name contains '$backupFileName.' and name contains '.$fileFormat'",
        spaces: 'drive',
        $fields: 'files(id, name)',
      );

      if (fileList != null && fileList.files!.isNotEmpty) {
        for (var file in fileList.files!) {
          try {
            await driveApi?.files.delete(file.id!);
            LogMessage.d("BackupRestoreManager deleteBackupFiles",
                "Deleted backup file: ${file.name}");
          } catch (deleteError) {
            LogMessage.d("BackupRestoreManager deleteBackupFiles",
                "Error deleting file ${file.name}: $deleteError");
          }
        }
      } else {
        LogMessage.d("BackupRestoreManager deleteBackupFiles",
            "No backup files found for deletion with format .$fileFormat");
      }
    } catch (e) {
      LogMessage.d("BackupRestoreManager deleteBackupFiles",
          "Error listing/deleting backup files: $e");
    }
  }


  void cancelBackup() {
    Mirrorfly.cancelBackup();
  }

  void cancelRestore() {
    Mirrorfly.cancelRestore();
  }

  void cancelRemoteBackupUpload() {
    if(Platform.isAndroid && _gDriveUploadStreamController != null) {
      _isgDriveUploadCancelled = true;
      _gDriveUploadStreamController?.close();
      _gDriveUploadStreamController = null;
      debugPrint("G-drive upload cancelled");
    }else if (Platform.isIOS && _icloudUploadSubscription != null) {
      try {
        _icloudUploadSubscription?.cancel();
        _icloudUploadSubscription = null;
        debugPrint("iCloud upload cancelled");
      } catch (e) {
        debugPrint("Error cancelling iCloud upload: $e");
      }
    }else{
      debugPrint("G-drive/iCloud upload cancel failed");
    }
  }

  void cancelRemoteDownload() {
    if (Platform.isAndroid) {
      _cancelAndroidBackupDownload();
    } else {
      debugPrint("Remote Download process is not supported for the current platform");
    }
  }

  Stream<List<int>> trackProgress(
      Stream<List<int>> inputStream,
      int totalBytes,
      Function(double) onProgress,
      ) {
    int uploadedBytes = 0;

    final controller = StreamController<List<int>>();
    _gDriveUploadStreamController = controller;

    inputStream.listen(
          (chunk) {
        if (_isgDriveUploadCancelled) {
          controller.close(); // cancel the stream
          return;
        }

        uploadedBytes += chunk.length;
        double progress = uploadedBytes / totalBytes;
        onProgress(progress);
        controller.add(chunk);
      },
      onDone: () {
        if (!_isgDriveUploadCancelled) {
          controller.close();
        }
      },
      onError: (error) {
        controller.addError(error);
        controller.close();
      },
      cancelOnError: true,
    );

    return controller.stream;
  }

}




/*@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    BackupRestoreManager.instance.backupCompleter = Completer<void>();
    print("Native called background task: $task");
    print("Native called background inputData: $inputData");
    if (task == BackupRestoreManager.instance.iOSBackgroundProcessingTask) {
      print("Native called background task: background Start backup");
      // bool isServerUploadRequired = inputData?["isServerUploadRequired"];
      // bool enableEncryption = inputData?["enableEncryption"];
      // print("Background task: isServerUploadRequired $isServerUploadRequired");
      // print("Background task: enableEncryption $enableEncryption");
      // BackupRestoreManager.instance.isServerUploadRequired = this.isServerUploadRequired;
      // BackupRestoreManager.instance.isEncryptionEnabled = enableEncryption;
      Mirrorfly.startBackup(enableEncryption:  BackupRestoreManager.instance.isServerUploadRequired);
    }else if (task == "restoreTask"){
      print("Native called background task: background restore backup");
      Mirrorfly.restoreBackup(backupPath: BackupRestoreManager.instance.backupFilePath);
    }else{
      print("Native called background task failed, No Task under this name is found: $task");
    }

    await BackupRestoreManager.instance.backupCompleter?.future;

    return Future.value(true);
  });
}*/




class BackupFile {
  String? fileId;
  String? fileName;
  String? fileSize;
  String? fileCreatedDate;
  String? iCloudRelativePath;
  String? filePath;

  BackupFile({
    this.fileId,
    this.fileName,
    this.fileSize,
    this.fileCreatedDate,
    this.iCloudRelativePath,
    this.filePath,
  });

  Map<String, dynamic> toJson() => {
        "fileId": fileId,
        "fileName": fileName,
        "fileSize": fileSize,
        "fileDate": fileCreatedDate,
        "iCloudRelativePath": iCloudRelativePath,
        "filePath": filePath,
      };
}
