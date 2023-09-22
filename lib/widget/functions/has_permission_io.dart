import 'dart:developer' as developer;
import 'package:permission_handler/permission_handler.dart';

Future<bool> hasPermissionIoWeb() async {
  var permissionStatus = await Permission.storage.status;
  developer.log('ℹ️  Permission status: $permissionStatus', name: 'Cached Media package');
  if (permissionStatus != PermissionStatus.granted) {
    developer.log('❌  Permission access was not granted', name: 'Cached Media package');
    PermissionStatus permissionStatus1 = await Permission.storage.request();
    developer.log('🕵️‍♂️  Permission requested', name: 'Cached Media package');
    permissionStatus = permissionStatus1;
    if (permissionStatus != PermissionStatus.granted) {
      developer.log('❌  Permission denied', name: 'Cached Media package');
      return false;
    } else {
      developer.log('✅  Permission access granted', name: 'Cached Media package');
      return true;
    }
  } else {
    developer.log('✅  Permission access granted', name: 'Cached Media package');
    return true;
  }
}
