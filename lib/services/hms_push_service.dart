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

    print('🚀 [HMS PUSH] Starting initialization...');

    // Android 13+ requires runtime notification permission
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      print('🔐 [HMS PUSH] Requesting notification permission...');
      await Permission.notification.request();
    } else {
      print('✅ [HMS PUSH] Notification permission granted');
    }

    // Enable auto init for token generation
    hms.Push.setAutoInitEnabled(true);
    print('✅ [HMS PUSH] Auto-init enabled');

    String? token;
    try {
      hms.Push.getToken("");
      print('✅ [HMS PUSH] Token request sent');
    } catch (e) {
      print('⚠️ [HMS PUSH] Failed to request token: $e');
    }

    // Listen for token
    hms.Push.getTokenStream.listen((String newToken) {
      print('🎫 [HMS PUSH] Token received: ${newToken.substring(0, 20)}...');
      print('📱 [HMS PUSH] FULL TOKEN: $newToken');
      token = newToken;
    }, onError: (err) {
      print('⚠️ [HMS PUSH] Token error: $err');
    });

    // Subscribe to a common topic for daily reminders
    try {
      hms.Push.subscribe("daily");
      print('✅ [HMS PUSH] Subscribed to "daily" topic');
    } catch (e) {
      print('⚠️ [HMS PUSH] Failed to subscribe: $e');
    }

    // Optional foreground message listener
    hms.Push.onMessageReceivedStream.listen((hms.RemoteMessage msg) {
      print('📩 [HMS PUSH] Message received!');
      print('   Data: ${msg.data}');
      if (msg.notification != null) {
        print('   Title: ${msg.notification!.title}');
        print('   Body: ${msg.notification!.body}');
      }
    });

    _initialized = true;
    print('✅ [HMS PUSH] Initialization complete!');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}


