import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart';

/// Loads the ONNX model and runs inference.
/// Input:  [temperature, UV_index, humidity, wind_speed, rain_chance]
/// Output: [jogging, swimming, hiking, football, walking, cycling] percentages (0..100)
class PredictionService {
  PredictionService._();
  static final instance = PredictionService._();

  OrtSession? _session;

  static const String _inputName = 'dense_input';
  // Single output in this model; names not required when using positional run

  Future<void> _ensureLoaded() async {
    if (_session != null) return;
    final modelBytes = await rootBundle.load(
      'assets/models/activity_suitability_model.onnx',
    );
    _session = OrtSession.fromBuffer(
      modelBytes.buffer.asUint8List(),
      OrtSessionOptions(),
    );
  }

  Future<List<double>> predict(List<double> features) async {
    await _ensureLoaded();
    final input = OrtValueTensor.createTensorWithDataList(
      Float32List.fromList(features),
      [1, features.length],
    );
    final outputs = _session!.run(OrtRunOptions(), {_inputName: input});
    final outTensor = outputs.isNotEmpty ? outputs.first : null;
    final obj = outTensor?.value;
    final out = obj is List
        ? obj.map((e) => (e as num).toDouble()).toList(growable: false)
        : <double>[];
    input.release();
    outTensor?.release();
    return out; // 0..100
  }
}
