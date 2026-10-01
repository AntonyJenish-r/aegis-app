import 'dart:math' as math;

/// Distress Detector — real DSP-based audio analysis.
/// Analyzes raw PCM audio samples and computes a distress probability (0-100).
class DistressDetector {
  final List<double> _history = [];
  static const int _smoothingWindow = 5;
  DateTime? _lastTrigger;

  /// Analyze a chunk of PCM 16-bit samples.
  /// Returns a score 0-100 (higher = more likely distress).
  double analyze(List<int> pcmSamples, int sampleRate) {
    if (pcmSamples.isEmpty) return 0;

    // Feature 1: RMS energy
    double sumSquares = 0;
    for (final s in pcmSamples) {
      final v = s / 32768.0;
      sumSquares += v * v;
    }
    final rms = math.sqrt(sumSquares / pcmSamples.length);
    final loudness = ((rms - 0.005) / 0.30).clamp(0.0, 1.0);

    // Feature 2: Zero-crossing rate
    int zc = 0;
    for (int i = 1; i < pcmSamples.length; i++) {
      if ((pcmSamples[i - 1] >= 0) != (pcmSamples[i] >= 0)) zc++;
    }
    final zcr = zc / pcmSamples.length;
    final hfContent = ((zcr - 0.05) / 0.35).clamp(0.0, 1.0);

    // Feature 3: Short-time energy variance
    final winSize = (pcmSamples.length / 4).floor();
    if (winSize < 10) return 0;

    final energies = <double>[];
    for (int w = 0; w < 4; w++) {
      double sum = 0;
      final start = w * winSize;
      final end = start + winSize;
      for (int i = start; i < end && i < pcmSamples.length; i++) {
        final v = pcmSamples[i] / 32768.0;
        sum += v * v;
      }
      energies.add(sum / winSize);
    }

    double flux = 0;
    for (int i = 1; i < energies.length; i++) {
      flux += (energies[i] - energies[i - 1]).abs();
    }
    final temporalDynamics = (flux * 5).clamp(0.0, 1.0);

    // Weighted combination — loudness capped at 40%
    final rawScore = 0.40 * loudness + 0.35 * hfContent + 0.25 * temporalDynamics;

    // Temporal smoothing
    _history.add(rawScore);
    if (_history.length > _smoothingWindow) _history.removeAt(0);
    final smoothed = _history.reduce((a, b) => a + b) / _history.length;

    return (smoothed * 100).clamp(0.0, 100.0);
  }

  /// Check if we should trigger an alert (score >= 75, 30 sec cooldown).
  bool shouldTrigger(double score) {
    if (score < 75) return false;
    final now = DateTime.now();
    if (_lastTrigger != null && now.difference(_lastTrigger!).inSeconds < 30) {
      return false;
    }
    _lastTrigger = now;
    return true;
  }

  void reset() {
    _history.clear();
    _lastTrigger = null;
  }
}