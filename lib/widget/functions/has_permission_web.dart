import 'dart:developer' as developer;

Future<bool> hasPermissionIoWeb() async {
  developer.log('✅  Permission access granted (Web)', name: 'Cached Media package');
  return true;
}
