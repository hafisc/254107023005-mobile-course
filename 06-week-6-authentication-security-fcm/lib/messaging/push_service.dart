import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';


final _local = FlutterLocalNotificationsPlugin();
String? pendingDeepLink;

// Ekstrak parsing RemoteMessage -> route ke fungsi murni
String routeFromMessage(Map<String, dynamic> data) {
  final route = data['route'] as String? ?? '/';
  return route.startsWith('/') ? route : '/$route';
}

// Background handler top-level wajib
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Hanya logging, jangan akses BuildContext/Riverpod di sini.
  // Routing dilakukan di onMessageOpenedApp / getInitialMessage
  debugPrint('Handling a background message: ${message.messageId}');
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

class PushService {
  Future<bool> requestNotificationPermission() async {
    // Meminta izin untuk Android 13+ dan iOS. (Bagian yang BERBEDA untuk Android 13+ vs iOS)
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        pendingDeepLink = response.payload;
      },
    );
  }

  Future<void> initFcmToken({required Future<void> Function(String token) onToken}) async {
    // 1. Ambil token
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await onToken(token);
    
    // 2. Listen untuk token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen(onToken);
  }

  void listenForeground(void Function(String route) go) {
    // Foreground: sistem TIDAK menampilkan banner otomatis,
    // jadi tampilkan manual via local notification.
    FirebaseMessaging.onMessage.listen((message) async {
      final route = routeFromMessage(message.data);
      const androidDetails = AndroidNotificationDetails(
        'pengumuman',
        'Pengumuman Kampus',
        importance: Importance.high,
        priority: Priority.high,
      );
      await _local.show(
        id: message.hashCode,
        title: message.notification?.title ?? 'Pengumuman',
        body: message.notification?.body ?? '',
        notificationDetails: const NotificationDetails(android: androidDetails),
        payload: route,
      );
    });

    // Background -> diklik.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      go(routeFromMessage(message.data));
    });
  }

  Future<void> handleTerminated(void Function(String route) go) async {
    // Terminated -> dibuka dari notifikasi.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) go(routeFromMessage(initial.data));
    if (pendingDeepLink != null) {
      go(pendingDeepLink!);
      pendingDeepLink = null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}
