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

import '../../data/utils.dart';
import 'backup_utils.dart';

class BackupRestoreManager {
  // Private constructor
  BackupRestoreManager._internal();

  // Singleton instance
  static final BackupRestoreManager _instance =
      BackupRestoreManager._internal();

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

  // var _clientId = '';

  // get clientId => _clientId;

  // GoogleSignInAccount? _googleAccountSignedIn;

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  GoogleSignInAccount? get getGoogleAccountSignedIn => googleSignIn.currentUser;

  bool isServerUploadRequired = false;

  drive.DriveApi? driveApi;

  bool get isDriveApiInitialized => driveApi != null;

  StreamSubscription<List<int>>? _downloadSubscription;

  String _cloudBackUpDownloadPath = "";

  get remoteBackupPath => _cloudBackUpDownloadPath;

  Future<bool> initialize({required iCloudContainerID}) async {
    if (_isInitialized) {
      LogMessage.d("BackupRestoreManager", "Already initialized.");
      return true;
    }
    LogMessage.d(
        "BackupRestoreManager", "Initializing Backup Restore Manager.");

    _iCloudContainerID = iCloudContainerID;
    // _clientId = googleClientId;
    _backupFileName = "Backup_${SessionManagement.getUsername()}";


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
            fileSize: MediaUtils.fileSize(iCloudFile.sizeInBytes),
            fileCreatedDate:
                BackupUtils().formatDateTime(iCloudFile.lastSyncDt.toString()),
        iCloudRelativePath: iCloudFile.relativePath);
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

  Future<void> uploadFileToGoogleDrive(String filePath, StreamController<int> progressController) async {
    LogMessage.d("BackupRestoreManager", "uploadFileToGoogleDrive Started");
    try {
      File backupFile = File(filePath);
      int fileSize = backupFile.lengthSync();

      // Prepare the file metadata
      var driveFile = drive.File();
      driveFile.name = backupFile.path.split('/').last;

      var trackedStream = trackProgress(
        backupFile.openRead(),
        fileSize,
            (progress) {
          // backupController.updateProgress(progress);
          // LogMessage.d("BackupRestoreManager",
          //     "Upload Progress: ${(progress * 100).toStringAsFixed(2)}%");
          progressController.add((progress * 100).floor());
        },
      );
      // Upload the file
      var response = await driveApi?.files.create(
        driveFile,
        uploadMedia:
            drive.Media(trackedStream, fileSize),
      );
      LogMessage.d("BackupRestoreManager", "Uploaded file ID: ${response?.id}");
      toToast(getTranslated("backUpSuccess"));
      if (Get.isRegistered<BackupController>()) {
        Get.find<BackupController>().serverUploadSuccess();
      }
      progressController.add(100); // Mark upload as complete
      progressController.close();
    } catch (e) {
      LogMessage.d(
          "BackupRestoreManager", "Error uploading to Google Drive: $e");
      toToast("Backup Failed");
      progressController.addError(e);
      progressController.close();
    }
  }

  Future<BackupFile?> getBackupFileDetails() async {
    try {
      final fileList = await driveApi?.files.list(
        q: "'me' in owners", // Filter by name
        spaces: 'drive',
        orderBy: 'modifiedTime desc', // Get the latest file first
        pageSize: 1,
        $fields: 'files(id, name, size, createdTime, mimeType)',
      );

      if (fileList != null && fileList.files!.isNotEmpty) {
        final latestFile = fileList.files?.first;
        LogMessage.d("BackupRestoreManager getLatestFile",
            "Latest File ID: ${latestFile?.id}, Name: ${latestFile?.name}, {$backupFileName}.crypto7");
        //
        if (latestFile?.name == "$backupFileName.crypto7") {
          return BackupFile(
              fileId: latestFile?.id,
              fileName: latestFile?.name,
              fileSize: MediaUtils.fileSize(int.parse(latestFile?.size ?? "0")),
              fileCreatedDate: BackupUtils()
                  .formatDateTime(latestFile!.createdTime.toString()));
        }else{
          LogMessage.d("BackupRestoreManager getLatestFile",
              "No file found with the name $backupFileName matches");
          return null;
        }
      } else {
        LogMessage.d("BackupRestoreManager getLatestFile",
            "No file found with the name $backupFileName");
        return null;
      }
    } catch (e) {
      LogMessage.d("BackupRestoreManager listFiles", "Error listing files: $e");
      return null;
    }
  }

  Stream<int> uploadBackupFile({required String filePath}) {
     final StreamController<int> progressController = StreamController<int>();
     if (Platform.isAndroid) {
      uploadFileToGoogleDrive(filePath, progressController);
    } else if (Platform.isIOS) {
      debugPrint("Filepath to upload in drive $filePath");
      final file = File(filePath.replaceFirst('file://', ''));
      debugPrint("Cleaned File Path: $file");
      if (!file.existsSync()) {
        progressController.addError(Exception("File does not exist at the given path: $filePath"));
        progressController.close();
        return progressController.stream;
      } else {
        debugPrint("File exists, proceeding with upload.");
      }

      debugPrint("Container ID to upload $_iCloudContainerID");

      try {
        icloudSyncPlugin.upload(
          containerId: _iCloudContainerID,
          filePath: file.path,
          onProgress: (progressStream) {
            progressStream.listen(
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
                debugPrint("Upload completed successfully.");
                progressController.add(100); // Mark 100% completion
                progressController.close();
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
     return progressController.stream;
  }

  Future<void> backupFile() async {
    await Mirrorfly.startBackup();
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

  Stream<int> startIcloudFileDownload({required String relativePath}) async*{
    StreamController<int> iCloudProgressController = StreamController<int>();
    _cloudBackUpDownloadPath = "";
    await getBackupUrl().then((result) async {
      LogMessage.d("BackupRestoreManager", "download backup url: $result");
      await icloudSyncPlugin.download(containerId: _iCloudContainerID, relativePath: relativePath, destinationFilePath: result ?? '', onProgress: (value) {
        value.listen((progress){
          LogMessage.d("BackupRestoreManager", "Download Progress: $progress");
          iCloudProgressController.add((progress).floor());
        }, onDone: () {
          _cloudBackUpDownloadPath = result ?? "";
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

  void startBackup({bool isServerUploadRequired = false}) {
    this.isServerUploadRequired = isServerUploadRequired;
    Mirrorfly.startBackup();
  }

  void restoreBackup({required String backupFilePath}) {
    LogMessage.d("BackupRestoreManager", 'Restoring Backup: $backupFilePath');
    Mirrorfly.restoreBackup(backupPath: backupFilePath);
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
    return '${backupDirectory.path}/Backup_${SessionManagement.getUsername()}.crypto7';
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
    final file = File("$downloadPath/$backupFileName.crypto7");

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
        response.stream.listen(
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

  void cancelDownload() {
    if (_downloadSubscription != null) {
      _downloadSubscription?.cancel();
      _downloadSubscription = null;
      debugPrint("Download canceled.");
    } else {
      debugPrint("No active download to cancel.");
    }
  }
}

Stream<List<int>> trackProgress(
    Stream<List<int>> stream, int totalBytes, Function(double) onProgress) {
  int uploadedBytes = 0;

  return stream.transform(
    StreamTransformer<List<int>, List<int>>.fromHandlers(
      handleData: (chunk, sink) {
        uploadedBytes += chunk.length;
        double progress = uploadedBytes / totalBytes;
        onProgress(progress); // Update progress
        sink.add(chunk); // Pass chunk to the next stream
      },
    ),
  );
}


class BackupFile {
  String? fileId;
  String? fileName;
  String? fileSize;
  String? fileCreatedDate;
  String? iCloudRelativePath;

  BackupFile({
    this.fileId,
    this.fileName,
    this.fileSize,
    this.fileCreatedDate,
    this.iCloudRelativePath,
  });

  Map<String, dynamic> toJson() => {
        "fileId": fileId,
        "fileName": fileName,
        "fileSize": fileSize,
        "fileDate": fileCreatedDate,
        "iCloudRelativePath": iCloudRelativePath,
      };
}
