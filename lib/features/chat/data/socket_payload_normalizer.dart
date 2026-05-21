import 'dart:convert';

Map<String, dynamic>? coerceSocketPayloadMap(Object? value) {
  final normalized = normalizeSocketPayloadValue(value);
  if (normalized is Map) {
    return Map<String, dynamic>.from(normalized);
  }
  if (normalized is List && normalized.length == 1 && normalized.first is Map) {
    return Map<String, dynamic>.from(normalized.first as Map);
  }
  return null;
}

Object? normalizeSocketPayloadValue(Object? value) {
  if (value is Map) {
    return value.map<String, dynamic>(
      (key, nestedValue) =>
          MapEntry(key.toString(), normalizeSocketPayloadValue(nestedValue)),
    );
  }

  if (value is List) {
    if (value.length == 1) {
      return normalizeSocketPayloadValue(value.first);
    }
    return value
        .map(normalizeSocketPayloadValue)
        .toList(growable: false);
  }

  if (value == null || value is num || value is bool || value is String) {
    return value;
  }

  try {
    return normalizeSocketPayloadValue(jsonDecode(jsonEncode(value)));
  } catch (_) {
    return value;
  }
}
