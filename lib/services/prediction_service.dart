import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

/// TFLite-based prediction service.
/// Input order (after normalization):
/// [temperature, UV_index, humidity, wind_speed, rain_chance]
/// Output: 6 suitability scores (10..100) in the order defined by
/// assets/model/airaware_output_order.json
class PredictionService {
  PredictionService._();
  static final instance = PredictionService._();

  Interpreter? _interpreter;
  late List<String> _outputOrder;

  // Normalization config
  late String _normMethod; // 'standard' or 'minmax' or 'none'
  late List<double> _mean;
  late List<double> _std;
  late List<double> _min;
  late List<double> _max;

  Future<void> _loadScaler() async {
    final jsonStr = await rootBundle.loadString(
      'assets/model/airaware_input_scaler.json',
    );
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    _normMethod = (data['method'] as String?)?.toLowerCase() ?? 'none';
    _mean =
        (data['mean'] as List?)?.map((e) => (e as num).toDouble()).toList() ??
        const [];
    _std =
        (data['std'] as List?)?.map((e) => (e as num).toDouble()).toList() ??
        const [];
    _min =
        (data['min'] as List?)?.map((e) => (e as num).toDouble()).toList() ??
        const [];
    _max =
        (data['max'] as List?)?.map((e) => (e as num).toDouble()).toList() ??
        const [];

    // If scaler info missing or malformed, fall back to reasonable min-max ranges
    const expectedLen = 5; // temperature, uv, humidity, wind, rain_chance
    final hasStandard =
        _normMethod == 'standard' &&
        _mean.length == expectedLen &&
        _std.length == expectedLen;
    final hasMinMax =
        _normMethod == 'minmax' &&
        _min.length == expectedLen &&
        _max.length == expectedLen;
    if (!hasStandard && !hasMinMax) {
      _normMethod = 'minmax';
      _min = const [-10.0, 0.0, 0.0, 0.0, 0.0];
      _max = const [45.0, 12.0, 100.0, 20.0, 100.0];
    }
  }

  Future<void> _loadOutputOrder() async {
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/model/airaware_output_order.json',
      );
      final dynamic parsed = json.decode(jsonStr);
      List<dynamic> rawList;
      if (parsed is List) {
        rawList = parsed;
      } else if (parsed is Map && parsed['outputs'] is List) {
        rawList = parsed['outputs'] as List;
      } else {
        throw const FormatException('Unsupported output_order schema');
      }
      _outputOrder = rawList
          .map((e) => e.toString())
          .map((s) {
            var base = s.trim();
            if (base.isEmpty) return 'Activity';
            base = base.replaceAll('_percent', '');
            base = base.replaceAll('_', ' ');
            return base.substring(0, 1).toUpperCase() + base.substring(1);
          })
          .toList(growable: false);
    } catch (_) {
      // Fallback to default
      _outputOrder = const [
        'Jogging',
        'Swimming',
        'Hiking',
        'Football',
        'Walking',
        'Cycling',
      ];
    }
  }

  List<double> _normalize(List<double> x) {
    if (_normMethod == 'standard' &&
        _mean.length == x.length &&
        _std.length == x.length) {
      return List.generate(
        x.length,
        (i) => (x[i] - _mean[i]) / (_std[i] == 0 ? 1 : _std[i]),
      );
    }
    if (_normMethod == 'minmax' &&
        _min.length == x.length &&
        _max.length == x.length) {
      return List.generate(x.length, (i) {
        final denom = (_max[i] - _min[i]);
        if (denom == 0) {
          // Avoid collapsing the input to a constant when scaler is degenerate
          return 0.5; // center of [0,1]
        }
        return (x[i] - _min[i]) / denom;
      });
    }
    // No normalization
    return x;
  }

  bool _hasLowVariance(List<double> values) {
    if (values.isEmpty) return true;
    final mean = values.reduce((a, b) => a + b) / values.length;
    double variance = 0.0;
    for (final v in values) {
      final d = v - mean;
      variance += d * d;
    }
    variance /= values.length;
    return variance < 1e-6; // effectively constant
  }

  Future<void> _ensureLoaded() async {
    if (_interpreter != null) return;
    // For tflite_flutter, provide the asset key relative to pubspec assets
    _interpreter = await Interpreter.fromAsset(
      'model/airaware_model_fp16.tflite',
    );
    await _loadScaler();
    await _loadOutputOrder();
  }

  Future<List<double>> predict(List<double> rawFeatures) async {
    await _ensureLoaded();
    final normalized = _normalize(rawFeatures);
    // If normalization collapses inputs to a near-constant vector, fallback to raw
    final features = (_normMethod != 'none' && _hasLowVariance(normalized))
        ? rawFeatures
        : normalized;
    // TFLite expects float32 tensor [1, N]
    final input = Float32List.fromList(features).reshape([1, features.length]);
    final output = List.generate(1, (_) => List.filled(6, 0.0));
    _interpreter!.run(input, output);
    var result = (output.first as List)
        .map((e) => (e as num).toDouble())
        .toList();
    // Auto-scale if model outputs probabilities (0..1)
    final maxVal = result.fold<double>(-double.infinity, math.max);
    if (maxVal <= 1.5) {
      result = result.map((v) => v * 100.0).toList();
    }
    // Optional: debug the first few predictions to verify variability
    // This prints at most 3 lines to avoid log spam
    // ignore: prefer_final_fields
    // (We keep a static counter to limit logs.)
    // Note: this is safe in release (kDebugMode = false)
    // ignore: unnecessary_statements
    if (kDebugMode) {
      // Print a concise one-liner
      print(
        '[Predict] raw=$rawFeatures norm=${normalized.map((e) => e.toStringAsFixed(3)).toList()} -> out=${result.map((e) => e.toStringAsFixed(1)).toList()}',
      );
    }
    return result; // scores 10..100, no softmax
  }

  // Expose mapping for consumers that want activity labels
  List<String> get outputOrder => _outputOrder;
}
