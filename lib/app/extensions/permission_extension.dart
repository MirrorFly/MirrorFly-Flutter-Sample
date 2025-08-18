part of "extensions.dart";

/// this an extension of List of [Permission]
extension PermissionExtension on List<Permission> {
  /// This [status] is used to Check and returns Map of [PermissionStatus].
  Future<Map<String, PermissionStatus>> status() async {
    var permissionStatusList = <String, PermissionStatus>{};
    await Future.forEach(this, (Permission permission) async {
      var status = await permission.status;
      permissionStatusList.putIfAbsent(permission.toString(), () => status);
    });
    return permissionStatusList;
  }

  /// This [permanentlyDeniedPermissions] is used to Check and returns Map of [PermissionStatus.permanentlyDenied].
  Future<Map<String, PermissionStatus>> permanentlyDeniedPermissions() async {
    var permissionStatusList = <String, PermissionStatus>{};
    await Future.forEach(this, (Permission permission) async {
      var status = await permission.status;
      if (status == PermissionStatus.permanentlyDenied) {
        permissionStatusList.putIfAbsent(permission.toString(), () => status);
      }
    });
    return permissionStatusList;
  }

  /// This [deniedPermissions] is used to Check and returns Map of [PermissionStatus.denied].
  Future<Map<String, PermissionStatus>> deniedPermissions() async {
    var permissionStatusList = <String, PermissionStatus>{};
    await Future.forEach(this, (Permission permission) async {
      var status = await permission.status;
      if (status == PermissionStatus.denied) {
        permissionStatusList.putIfAbsent(permission.toString(), () => status);
      }
    });
    return permissionStatusList;
  }

  /// This [grantedPermissions] is used to Check and returns Map of [PermissionStatus.granted].
  Future<Map<String, PermissionStatus>> grantedPermissions() async {
    var permissionStatusList = <String, PermissionStatus>{};
    await Future.forEach(this, (Permission permission) async {
      var status = await permission.status;
      if (status == PermissionStatus.granted) {
        permissionStatusList.putIfAbsent(permission.toString(), () => status);
      }
    });
    return permissionStatusList;
  }

  /// This [shouldShowRationale] is used to Check available rationale and returns List of [bool].
  Future<List<bool>> shouldShowRationale() async {
    var permissionStatusList = <bool>[];
    await Future.forEach(this, (Permission permission) async {
      var show = await permission.shouldShowRequestRationale;
      LogMessage.d("shouldShowRationale", "${permission.toString()} : $show");
      permissionStatusList.add(show);
    });
    return permissionStatusList;
  }
}
