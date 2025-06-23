import Flutter
import UIKit

public class ScreenshotCallbackPlugin: NSObject, FlutterPlugin {
  private static var channel: FlutterMethodChannel?
  private static var observer: NSObjectProtocol?

  public static func register(with registrar: FlutterPluginRegistrar) {
    // match the name your Dart side expects
    let channel = FlutterMethodChannel(
      name: "flutter.moum/screenshot_callback",
      binaryMessenger: registrar.messenger()
    )
    // save for later invokes
    ScreenshotCallbackPlugin.channel = channel

    // route incoming calls to our handler
    registrar.addMethodCallDelegate(ScreenshotCallbackPlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "initialize":
        // remove any existing observer
        if let obs = ScreenshotCallbackPlugin.observer {
          NotificationCenter.default.removeObserver(obs)
          ScreenshotCallbackPlugin.observer = nil
        }
        // attach new observer
        ScreenshotCallbackPlugin.observer = NotificationCenter.default.addObserver(
          forName: UIApplication.userDidTakeScreenshotNotification,
          object: nil,
          queue: .main
        ) { _ in
          ScreenshotCallbackPlugin.channel?.invokeMethod("onCallback", arguments: nil)
        }
        result("initialize")

      case "dispose":
        if let obs = ScreenshotCallbackPlugin.observer {
          NotificationCenter.default.removeObserver(obs)
          ScreenshotCallbackPlugin.observer = nil
        }
        result("dispose")

      default:
        result(FlutterMethodNotImplemented)
    }
  }

  deinit {
    if let obs = ScreenshotCallbackPlugin.observer {
      NotificationCenter.default.removeObserver(obs)
    }
  }
}
