import UIKit
import Flutter
import flutter_local_notifications
import GoogleMaps
import Firebase
 
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      if FirebaseApp.app() == nil {
            print("Configuring Firebase")
            FirebaseApp.configure()
          } else {
             print("Firebase already configured")
          }
       
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
    GeneratedPluginRegistrant.register(with: registry)}

    GeneratedPluginRegistrant.register(with: self)
      GMSServices.provideAPIKey("AIzaSyCo1EQkS8hi8i84TwgksdXsWzM41MaYdXs")

      if #available(iOS 10.0, *) {
         UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      }
         application.registerForRemoteNotifications()
     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
     
}

