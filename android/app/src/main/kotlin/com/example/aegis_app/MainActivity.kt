package com.example.aegis_app

import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val methodChannelName = "com.aegis.safety/audio_monitor"
    private val eventChannelName = "com.aegis.safety/audio_scores"

    private var audioMonitor: AudioMonitor? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        val granted = ContextCompat.checkSelfPermission(
                            this, Manifest.permission.RECORD_AUDIO
                        ) == PackageManager.PERMISSION_GRANTED

                        if (!granted) {
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.RECORD_AUDIO),
                                1001
                            )
                            result.error("PERMISSION_DENIED", "Microphone permission required", null)
                            return@setMethodCallHandler
                        }
                        startMonitoring()
                        result.success(audioMonitor?.isRunning == true)
                    }
                    "stop" -> {
                        stopMonitoring()
                        result.success(true)
                    }
                    "isRunning" -> result.success(audioMonitor?.isRunning ?: false)
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
    }

    private fun startMonitoring() {
        if (audioMonitor?.isRunning == true) return
        audioMonitor = AudioMonitor { score ->
            runOnUiThread {
                eventSink?.success(score)
            }
        }
        audioMonitor?.start()
    }

    private fun stopMonitoring() {
        audioMonitor?.stop()
        audioMonitor = null
    }

    override fun onDestroy() {
        stopMonitoring()
        super.onDestroy()
    }
}