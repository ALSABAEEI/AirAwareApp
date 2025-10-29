import 'dart:convert';
import 'dart:typed_data';
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
  }

  Future<void> _loadOutputOrder() async {
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/model/airaware_output_order.json',
      );
      final list = json.decode(jsonStr) as List;
      _outputOrder = list.map((e) => e.toString()).toList();
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
        return denom == 0 ? 0.0 : (x[i] - _min[i]) / denom;
      });
    }
    // No normalization
    return x;
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
    final features = _normalize(rawFeatures);
    // TFLite expects float32 tensor [1, N]
    final input = Float32List.fromList(features).reshape([1, features.length]);
    final output = List.filled(6, 0.0).reshape([1, 6]);
    _interpreter!.run(input, output);
    final result = (output.first as List)
        .map((e) => (e as num).toDouble())
        .toList();
    return result; // scores 10..100, no softmax
  }

  // Expose mapping for consumers that want activity labels
  List<String> get outputOrder => _outputOrder;
}
