import 'dart:convert';

/// Encodes [value] as canonical JSON: the top-level keys are sorted, so equal
/// logical maps always produce byte-identical output.
///
/// Both the audit hash chain and licence signatures depend on this stability.
/// Nested maps are **not** re-sorted, so keep payloads flat.
String encodeCanonicalJson(Map<String, Object?> value) {
  final List<MapEntry<String, Object?>> entries = value.entries.toList()
    ..sort(
      (MapEntry<String, Object?> a, MapEntry<String, Object?> b) =>
          a.key.compareTo(b.key),
    );
  return jsonEncode(Map<String, Object?>.fromEntries(entries));
}
