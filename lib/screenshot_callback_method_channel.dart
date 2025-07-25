import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'screenshot_callback_platform_interface.dart';

/// An implementation of [ScreenshotCallbackPlatform] that uses method channels.
class MethodChannelScreenshotCallback extends ScreenshotCallbackPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('screenshot_callback');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
