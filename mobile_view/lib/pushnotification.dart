import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future initialize() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
     });

    FirebaseMessaging.onBackgroundMessage(backgroundHandler);

    // Get the token
    await getToken();
  }

  Future<void> backgroundHandler(RemoteMessage message) async {
    print('Handling a background message ${message.messageId}');
  }

  Future<String?> getToken() async {
    String? token = await _fcm.getToken();
    print('Token: $token');
    return token;
  }
  Future<void> setupFirebaseMessaging() async {
    print('setupFirebaseMessaging call');
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Retrieve the APNS token
    // String? apnsToken = await messaging.getAPNSToken();
    // print('PUSH  APNS Token: $apnsToken');

    // Retrieve the FCM token
    print('PUSH FCM Token: ${messaging.getToken()}');
    String? fcmToken = await messaging.getToken();
    print('PUSH FCM Token: $fcmToken');
  }

}





