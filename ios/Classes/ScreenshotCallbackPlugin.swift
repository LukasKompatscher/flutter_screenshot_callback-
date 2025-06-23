import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var screenshotObserver: NSObjectProtocol?
  private var screenshotChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Grab your Flutter view controller
    let controller = window?.rootViewController as! FlutterViewController

    // Create a MethodChannel matching your Dart side
    screenshotChannel = FlutterMethodChannel(
      name: "flutter.moum/screenshot_callback",
      binaryMessenger: controller.binaryMessenger
    )

    // Handle "initialize" and "dispose" calls from Dart
    screenshotChannel?.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "initialize":
        self?.startObservingScreenshots()
        result("initialize")
      case "dispose":
        self?.stopObservingScreenshots()
        result("dispose")
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // Usual plugin registration
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func startObservingScreenshots() {
    // If already observing, remove first
    stopObservingScreenshots()
    screenshotObserver = NotificationCenter.default.addObserver(
      forName: UIApplication.userDidTakeScreenshotNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.screenshotChannel?.invokeMethod("onCallback", arguments: nil)
    }
  }

  private func stopObservingScreenshots() {
    if let obs = screenshotObserver {
      NotificationCenter.default.removeObserver(obs)
      screenshotObserver = nil
    }
  }

  deinit {
    stopObservingScreenshots()
  }
}
