import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:screenshot_callback/screenshot_callback_platform_interface.dart';
import 'package:screenshot_callback/screenshot_callback_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockScreenshotCallbackPlatform
    with MockPlatformInterfaceMixin
    implements ScreenshotCallbackPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ScreenshotCallbackPlatform initialPlatform = ScreenshotCallbackPlatform.instance;

  test('$MethodChannelScreenshotCallback is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelScreenshotCallback>());
  });

  test('getPlatformVersion', () async {
    ScreenshotCallback screenshotCallbackPlugin = ScreenshotCallback();
    MockScreenshotCallbackPlatform fakePlatform = MockScreenshotCallbackPlatform();
    ScreenshotCallbackPlatform.instance = fakePlatform;

    expect(await screenshotCallbackPlugin.getPlatformVersion(), '42');
  });
}
