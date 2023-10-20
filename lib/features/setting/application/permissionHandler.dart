import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static requestCameraPermission() async {
    await Permission.camera.request();
  }

  static requestStoragePermission() async {
    await Permission.storage.request();
  }

  static openSetting() async {
    await openAppSettings();
  }
}
