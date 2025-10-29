import 'dart:io';
import 'package:huawei_push/huawei_push.dart' as hms;
import 'package:permission_handler/permission_handler.dart';

class HmsPushService {
  HmsPushService._();
  static final HmsPushService instance = HmsPushService._();

  bool _initialized = false;

  Future<void> initAndRegister() async {
    if (!Platform.isAndroid) return;
    if (_initialized) return;

    // Ensure Huawei Mobile Services is present
    final bool isHmsAvailable = await hms.Push.isHuaweiMobileServicesAvailable;
    if (!isHmsAvailable) {
      _initialized = true;
      return;
    }

    // Android 13+ requires runtime notification permission
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }

    // Enable auto init for token generation
    await hms.Push.setAutoInitEnabled(true);

    String? token;
    try {
      token = await hms.Push.getToken("");
    } catch (_) {
      // Ignore; token may arrive via onTokenRefresh
    }

    // Listen for token refresh
    hms.Push.onTokenRefreshStream.listen((String newToken) {
      // TODO: send token to your backend for daily broadcasts
    });

    // Subscribe to a common topic for daily reminders
    try {
      await hms.Push.subscribe("daily");
    } catch (_) {}

    // Optional foreground message listener
    hms.Push.onMessageReceivedStream.listen((hms.RemoteMessage msg) {
      // Background notifications with notification payload will be shown by HMS.
    });

    if (token != null && token.isNotEmpty) {
      // TODO: send token to your backend for daily broadcasts
    }

    _initialized = true;
  }
}


