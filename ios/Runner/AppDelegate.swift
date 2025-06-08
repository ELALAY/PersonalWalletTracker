import Flutter
import UIKit

import local_flutter_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // my
    FlutterLocalNotificationsPlugin.setPluginRegistratCallback{(registry) in
    GeneratedPluginRegistrant.register(with: registry)}
    // ----
    GeneratedPluginRegistrant.register(with: self)
    // my
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenter
    }
    // ----
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
