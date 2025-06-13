import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'screenshot_callback_method_channel.dart';

abstract class ScreenshotCallbackPlatform extends PlatformInterface {
  /// Constructs a ScreenshotCallbackPlatform.
  ScreenshotCallbackPlatform() : super(token: _token);

  static final Object _token = Object();

  static ScreenshotCallbackPlatform _instance =
      MethodChannelScreenshotCallback();

  /// The default instance of [ScreenshotCallbackPlatform] to use.
  ///
  /// Defaults to [MethodChannelScreenshotCallback].
  static ScreenshotCallbackPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ScreenshotCallbackPlatform] when
  /// they register themselves.
  static set instance(ScreenshotCallbackPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
