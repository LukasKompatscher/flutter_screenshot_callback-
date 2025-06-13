package com.flutter.moum.screenshot_callback

import android.content.Context
import android.content.ContentResolver
import android.database.ContentObserver
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * ScreenshotCallbackPlugin implements a Flutter plugin to detect screenshots
 */
class ScreenshotCallbackPlugin: FlutterPlugin, MethodChannel.MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var appContext: Context
  private var handler: Handler? = null
  private var detector: ScreenshotDetector? = null
  private var lastScreenshotName: String? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    appContext = binding.applicationContext
    channel = MethodChannel(binding.binaryMessenger, "flutter.moum/screenshot_callback")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "initialize" -> {
        handler = Handler(Looper.getMainLooper())
        detector = ScreenshotDetector(appContext) { name ->
          if (name != lastScreenshotName) {
            lastScreenshotName = name
            handler?.post {
              channel.invokeMethod("onCallback", null)
            }
          }
        }
        detector?.start()
        result.success("initialize")
      }
      "dispose" -> {
        detector?.stop()
        detector = null
        lastScreenshotName = null
        result.success("dispose")
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}

private class ScreenshotDetector(
  private val context: Context,
  private val callback: (String) -> Unit
) {
  private var observer: ContentObserver? = null

  fun start() {
    if (observer == null) {
      observer = registerObserver()
    }
  }

  fun stop() {
    observer?.let {
      context.contentResolver.unregisterContentObserver(it)
      observer = null
    }
  }

  private fun registerObserver(): ContentObserver {
    val observer = object : ContentObserver(Handler(Looper.getMainLooper())) {
      override fun onChange(selfChange: Boolean, uri: Uri?) {
        super.onChange(selfChange, uri)
        uri?.let { reportUpdate(it) }
      }
    }
    context.contentResolver.registerContentObserver(
      MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
      true,
      observer
    )
    return observer
  }

  private fun reportUpdate(uri: Uri) {
    queryScreenshots(uri).lastOrNull()?.let { callback(it) }
  }

  private fun queryScreenshots(uri: Uri): List<String> = try {
    val resolver = context.contentResolver
    val (projection, extractor) =
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        arrayOf(MediaStore.Images.Media.DISPLAY_NAME, MediaStore.Images.Media.RELATIVE_PATH) to
                { cursor: android.database.Cursor ->
                  val name = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DISPLAY_NAME))
                  val path = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.RELATIVE_PATH))
                  if (name.contains("screenshot", true) || path.contains("screenshot", true)) name else null
                }
      } else {
        arrayOf(MediaStore.Images.Media.DATA) to
                { cursor: android.database.Cursor ->
                  val path = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DATA))
                  if (path.contains("screenshot", true)) path else null
                }
      }

    resolver.query(uri, projection, null, null, null)?.use { cursor ->
      val list = mutableListOf<String>()
      while (cursor.moveToNext()) {
        extractor(cursor)?.let { list.add(it) }
      }
      list
    } ?: emptyList()
  } catch (e: Exception) {
    emptyList()
  }
}
