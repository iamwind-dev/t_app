import 'package:equatable/equatable.dart';

class ModerationLayerResult extends Equatable {
  const ModerationLayerResult({
    required this.layer,
    required this.task,
    required this.model,
    required this.inputText,
    required this.predId,
    required this.label,
    required this.confidence,
    required this.probabilities,
    required this.isWarning,
  });

  /// Parses one backend moderation layer and falls back safely on partial data.
  factory ModerationLayerResult.fromJson(Map<String, dynamic> json) {
    return ModerationLayerResult(
      layer: json['layer'] as String? ?? '',
      task: json['task'] as String? ?? '',
      model: json['model'] as String? ?? '',
      inputText: json['input_text'] as String? ?? '',
      predId: _readInt(json['pred_id']),
      label: json['label'] as String? ?? 'clean',
      confidence: _readDouble(json['confidence']),
      probabilities: _readProbabilities(json['probabilities']),
      isWarning: json['is_warning'] as bool? ?? false,
    );
  }

  final String layer;
  final String task;
  final String model;
  final String inputText;
  final int predId;
  final String label;
  final double confidence;
  final Map<String, double> probabilities;
  final bool isWarning;

  /// Serializes the moderation layer back to the backend snake_case contract.
  Map<String, dynamic> toJson() {
    return {
      'layer': layer,
      'task': task,
      'model': model,
      'input_text': inputText,
      'pred_id': predId,
      'label': label,
      'confidence': confidence,
      'probabilities': probabilities,
      'is_warning': isWarning,
    };
  }

  @override
  List<Object?> get props => [
    layer,
    task,
    model,
    inputText,
    predId,
    label,
    confidence,
    probabilities,
    isWarning,
  ];
}

class ModerationResult extends Equatable {
  const ModerationResult({
    required this.text,
    required this.finalLabel,
    required this.finalConfidence,
    required this.isWarning,
    required this.action,
    required this.layers,
    required this.status,
    required this.model,
  });

  /// Parses the merged moderation result returned by the NestJS wrapper.
  factory ModerationResult.fromJson(Map<String, dynamic> json) {
    return ModerationResult(
      text: json['text'] as String? ?? '',
      finalLabel: json['final_label'] as String? ?? 'clean',
      finalConfidence: _readDouble(json['final_confidence']),
      isWarning: json['is_warning'] as bool? ?? false,
      action: json['action'] as String? ?? 'ALLOW',
      layers: _readLayers(json['layers']),
      status: json['status'] as String? ?? 'APPROVED',
      model: json['model'] as String? ?? '',
    );
  }

  final String text;
  final String finalLabel;
  final double finalConfidence;
  final bool isWarning;
  final String action;
  final List<ModerationLayerResult> layers;
  final String status;
  final String model;

  /// Serializes the moderation result back to the backend snake_case contract.
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'final_label': finalLabel,
      'final_confidence': finalConfidence,
      'is_warning': isWarning,
      'action': action,
      'layers': layers.map((layer) => layer.toJson()).toList(growable: false),
      'status': status,
      'model': model,
    };
  }

  @override
  List<Object?> get props => [
    text,
    finalLabel,
    finalConfidence,
    isWarning,
    action,
    layers,
    status,
    model,
  ];
}

/// Normalizes backend numeric values without relying on `dynamic`.
double _readDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  return 0;
}

/// Normalizes backend integer values without throwing on missing fields.
int _readInt(Object? value) {
  if (value is num) {
    return value.toInt();
  }

  return 0;
}

/// Parses layer probability maps while dropping invalid entries safely.
Map<String, double> _readProbabilities(Object? value) {
  if (value is! Map) {
    return const <String, double>{};
  }

  final probabilities = <String, double>{};
  for (final entry in value.entries) {
    final key = entry.key;
    final probability = entry.value;
    if (key is String && probability is num) {
      probabilities[key] = probability.toDouble();
    }
  }

  return probabilities;
}

/// Parses the backend layers array into immutable moderation layer objects.
List<ModerationLayerResult> _readLayers(Object? value) {
  if (value is! List) {
    return const <ModerationLayerResult>[];
  }

  return value
      .whereType<Map<String, dynamic>>()
      .map(ModerationLayerResult.fromJson)
      .toList(growable: false);
}
