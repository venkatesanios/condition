import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/login_screenOTP/login_screenotp.dart';
import 'package:mobile_view/screens/customer/Dashboard/Mobile%20Dashboard/login_screenOTP/otp_verification.dart';
import 'package:mobile_view/screens/customer/Dashboard/map/maplatlong_provider.dart';
import 'package:mobile_view/screens/customer/SentAndReceived/sent_and_received.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/customer/Dashboard/Mobile Dashboard/home_screen.dart';
import 'screens/splash_screen.dart';
import 'state_management/FertilizerSetProvider.dart';
import 'state_management/GlobalFertLimitProvider.dart';
import 'state_management/MqttPayloadProvider.dart';
import 'state_management/SelectedGroupProvider.dart';
import 'state_management/condition_provider.dart';
import 'state_management/constant_provider.dart';
import 'state_management/irrigation_program_main_provider.dart';
import 'state_management/overall_use.dart';
import 'state_management/preference_provider.dart';
import 'state_management/schedule_view_provider.dart';
import 'state_management/system_definition_provider.dart';
import 'login_page.dart';
import 'constants/notifi_service.dart';
import 'firebase_options.dart';
import 'package:upgrader/upgrader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // print('Handling a background message: ${message.messageId}');
  // You can show notifications or handle data messages here if necessary
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // WidgetsFlutterBinding.ensureInitialized();
  await Upgrader.clearSavedSettings();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  ScheduleViewProvider mySchedule = ScheduleViewProvider();
  MqttPayloadProvider myMqtt = MqttPayloadProvider();
  myMqtt.editMySchedule(mySchedule);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FertilizerSetProvider()),
        ChangeNotifierProvider(create: (context) => OverAllUse()),
        ChangeNotifierProvider(create: (context) => IrrigationProgramMainProvider()),
        ChangeNotifierProvider(create: (context) => SystemDefinitionProvider()),
        ChangeNotifierProvider(create: (context) => GlobalFertLimitProvider()),
        ChangeNotifierProvider(create: (context) => SelectedGroupProvider()),
        ChangeNotifierProvider(create: (context) => PreferenceProvider()),
        ChangeNotifierProvider(create: (context) => ConstantProvider()),
        ChangeNotifierProvider(create: (context) => mySchedule),
        ChangeNotifierProvider(create: (context) => myMqtt),
        ChangeNotifierProvider(create: (context) => MapLatlong()),
        ChangeNotifierProvider(create: (context) => ConditionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  @override
  void initState()
  {
    super.initState();
    // _getToken();
    if (Platform.isAndroid) {
      requestNotificationPermissions();
    }


    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // print('Message received: ${message.messageId}');
      if (message.notification != null) {
        NotificationService().showNotification(
          title: message.notification!.title,
          body: message.notification!.body,
        );
        print('Notification title: ${message.notification!.title}');
        print('Notification body: ${message.notification!.body}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // print('Message received onMessageOpenedApp: ${message.messageId}');
      if (message.notification != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return SentAndReceived();
        }));
        // print('Notification title open: ${message.notification!.title}');
        // print('Notification body onMessageOpenedApp: ${message.notification!.body}');
      }
    });


    // Request permission for iOS
    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get the token
    _firebaseMessaging.getToken().then((String? token) async{
      // print("FCM Token: $token");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('deviceToken', token ?? '' );
    });

    // if(Platform.isIOS)
    // {
    _firebaseMessaging.getAPNSToken().then((String? token) {
      print("APN Token: $token");
    });
    // }


  }

  Future<void> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit(
        designSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                primary: const Color(0xff1D808E),
                secondary: const Color(0xffFDC748),
                seedColor: const Color(0xff1D808E),
              ),
              useMaterial3: true,
            ),
            debugShowCheckedModeBanner: false,
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginForm(),
              '/loginOTP': (context) => LoginScreen(),
              '/dashboard': (context) => HomeScreen(userId: 0, fromDealer: false,),
              '/OtpScreen': (context) => OtpScreen(),
            },
          ),
        ),
      ),
    );
  }
}


