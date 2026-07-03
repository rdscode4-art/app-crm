import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class CallLogService {
  /// Requests the necessary permissions to read call logs.
  /// Returns true if permission is granted, false otherwise.
  Future<bool> requestPermissions() async {
    // Call log permissions are only relevant on Android
    if (defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    PermissionStatus status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
    }
    
    // Request contacts just in case
    PermissionStatus contactsStatus = await Permission.contacts.status;
    if (!contactsStatus.isGranted) {
      await Permission.contacts.request();
    }

    return status.isGranted;
  }

  /// Fetches call logs from the device starting from [startDate].
  Future<Iterable<CallLogEntry>> getRecentCallLogs({DateTime? startDate}) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return [];
    }

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      return [];
    }

    try {
      if (startDate != null) {
        int dateFrom = startDate.millisecondsSinceEpoch;
        return await CallLog.query(dateFrom: dateFrom);
      } else {
        return await CallLog.get();
      }
    } catch (e) {
      debugPrint("Error fetching call logs: $e");
      return [];
    }
  }
}
