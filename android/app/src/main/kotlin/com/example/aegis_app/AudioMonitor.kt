package com.example.aegis_app

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.util.Log
import kotlin.math.abs
import kotlin.math.sqrt

class AudioMonitor(private val onScore: (Double) -> Unit) {

    companion object {
        private const val SAMPLE_RATE = 16000
        private const val CHUNK_SIZE = 16000
        private const val TAG = "AegisAudio"
    }

    private var recorder: AudioRecord? = null
    private var thread: Thread? = null

    @Volatile
    private var running = false

    private val history = ArrayDeque<Double>()

    val isRunning: Boolean
        get() = running

    fun start() {
        if (running) return

        val minBuffer = AudioRecord.getMinBufferSize(
            SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )

        if (minBuffer <= 0) {
            Log.e(TAG, "Invalid min buffer size")
            return
        }

        try {
            recorder = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                SAMPLE_RATE,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                minBuffer * 4
            )

            if (recorder?.state != AudioRecord.STATE_INITIALIZED) {
                Log.e(TAG, "AudioRecord not initialized")
                recorder?.release()
                recorder = null
                return
            }

            running = true
            recorder?.startRecording()

            thread = Thread {
                val buffer = ShortArray(CHUNK_SIZE)
                val accumulated = ArrayList<Short>(CHUNK_SIZE)

                while (running) {
                    val read = recorder?.read(buffer, 0, buffer.size) ?: 0
                    if (read > 0) {
                        for (i in 0 until read) {
                            accumulated.add(buffer[i])
                        }
                        if (accumulated.size >= CHUNK_SIZE) {
                            val chunk = accumulated.take(CHUNK_SIZE)
                            val score = analyze(chunk)
                            onScore(score)
                            accumulated.clear()
                        }
                    }
                }
            }.also { it.start() }

            Log.d(TAG, "Started")
        } catch (e: SecurityException) {
            Log.e(TAG, "Permission denied", e)
            running = false
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start: ${e.message}", e)
            running = false
        }
    }

    fun stop() {
        running = false
        try {
            recorder?.stop()
        } catch (_: Exception) {
        }
        try {
            recorder?.release()
        } catch (_: Exception) {
        }
        recorder = null
        thread?.join(500)
        thread = null
        history.clear()
        Log.d(TAG, "Stopped")
    }

    private fun analyze(samples: List<Short>): Double {
        if (samples.isEmpty()) return 0.0

        var sumSquares = 0.0
        for (s in samples) {
            val v = s / 32768.0
            sumSquares += v * v
        }
        val rms = sqrt(sumSquares / samples.size)
        val loudness = ((rms - 0.005) / 0.30).coerceIn(0.0, 1.0)

        var zc = 0
        for (i in 1 until samples.size) {
            if ((samples[i - 1] >= 0) != (samples[i] >= 0)) {
                zc++
            }
        }
        val zcr = zc.toDouble() / samples.size
        val hfContent = ((zcr - 0.05) / 0.35).coerceIn(0.0, 1.0)

        val winSize = samples.size / 4
        if (winSize < 10) return 0.0

        val energies = DoubleArray(4)
        for (w in 0 until 4) {
            var sum = 0.0
            val start = w * winSize
            val end = start + winSize
            for (i in start until end) {
                val v = samples[i] / 32768.0
                sum += v * v
            }
            energies[w] = sum / winSize
        }

        var flux = 0.0
        for (i in 1 until 4) {
            flux += abs(energies[i] - energies[i - 1])
        }
        val temporalDynamics = (flux * 5).coerceIn(0.0, 1.0)

        val rawScore = 0.40 * loudness + 0.35 * hfContent + 0.25 * temporalDynamics

        history.addLast(rawScore)
        while (history.size > 5) {
            history.removeFirst()
        }
        val smoothed = history.average()

        return (smoothed * 100).coerceIn(0.0, 100.0)
    }
}