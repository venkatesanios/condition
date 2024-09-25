import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  static Future<bool> request(Permission permission) async {
    var status = await permission.request();
    return status.isGranted;
  }

  static Future<Map<Permission, PermissionStatus>> requestAll() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.location,
      Permission.locationWhenInUse,
      Permission.locationAlways,
      Permission.storage,
      Permission.photos,
      Permission.contacts,
      Permission.phone,
      Permission.notification,
      // Add other permissions as needed
    ].request();

    return statuses;
  }

  static Future<bool> isGranted(Permission permission) async {
    PermissionStatus status = await permission.status;
    return status.isGranted;
  }
}
