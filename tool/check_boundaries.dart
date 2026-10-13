// Flow static architecture checker.
//
// Scans a Flutter/Dart source root (default: `lib`) and verifies that every
// `import`/`export` honours the project's Clean Architecture boundaries. The
// analyzer cannot express these rules as lints, so we enforce them here and in
// CI (`P0-03`).
//
// Usage:
//   dart run tool/check_boundaries.dart [rootDir]
//
// Exit codes: 0 = ok, 1 = violation(s).
//
// Enforced rules:
//   * `domain/` layers stay pure Dart (no Flutter / Drift / Riverpod imports).
//   * a feature never reaches into another feature's `data/` or
//     `presentation/` (use the feature barrel or the other feature's
//     `domain/`).
//   * `core/` must not depend on `shared/`, `features/` or `app/`.
//   * `shared/` must not depend on `app/` or `features/`.
//   * `features/` must not depend on `app/`.
//   * within a feature, `domain/` must not depend on `data/`/`presentation/`
//     and `data/` must not depend on `presentation/`.

import 'dart:io';

/// Package name used to resolve `package:flow/...` URIs.
const String _packageName = 'flow';

/// Exit code returned when the tree is clean.
const int _success = 0;

/// Exit code returned when at least one boundary is violated.
const int _failure = 1;

/// External packages that must never appear inside a pure `domain/` layer.
const Set<String> _impurePackages = <String>{
  'flutter',
  'flutter_riverpod',
  'flutter_riverpod_annotation',
  'riverpod',
  'riverpod_annotation',
  'flutter_test',
  'flutter_localizations',
  'drift',
  'drift_flutter',
  'sqlite3',
  'sqlite3_flutter_libs',
};

/// Layer directory names recognised inside a feature.
const Set<String> _layers = <String>{'domain', 'data', 'presentation'};

/// Top-level packages that only `app/` (or the root entry points) may own.
const Set<String> _appLevel = <String>{'shared', 'features', 'app'};

final RegExp _directivePattern = RegExp(
  '^\\s*(?:import|export)\\s+[\'"]([^\'"]+)[\'"]',
);

/// Entry point: runs the check and sets the process exit code on failure.
void main(List<String> args) {
  final String root = args.isNotEmpty ? args.first : 'lib';
  final int code = run(root);
  if (code != _success) {
    exitCode = code;
  }
}

/// Runs the boundary check against [rootPath] and returns an exit code.
///
/// When [out] is provided, diagnostics are written there instead of stdout,
/// which keeps the function easy to test.
int run(String rootPath, {StringSink? out}) {
  final StringSink sink = out ?? stdout;
  final Directory root = Directory(rootPath);
  if (!root.existsSync()) {
    sink.writeln('Boundary check FAILED: "$rootPath" does not exist.');
    return _failure;
  }

  final List<File> files =
      root
          .listSync(recursive: true)
          .whereType<File>()
          .where((File file) => file.path.endsWith('.dart'))
          .toList()
        ..sort((File a, File b) => a.path.compareTo(b.path));

  final List<String> violations = <String>[];
  for (final File file in files) {
    final String relative = _relative(root, file);
    final List<_Directive> directives = _parseDirectives(
      file.readAsStringSync(),
    );
    for (final _Directive directive in directives) {
      final _Target? target = _resolve(relative, directive.uri);
      if (target == null) {
        continue;
      }
      final String? violation = _check(relative, target, directive.uri);
      if (violation != null) {
        violations.add('${file.path}:${directive.line}: $violation');
      }
    }
  }

  if (violations.isEmpty) {
    sink.writeln('Boundary check passed.');
    return _success;
  }
  sink.writeln('Boundary check FAILED (${violations.length} violation(s)):');
  for (final String violation in violations) {
    sink.writeln('  $violation');
  }
  return _failure;
}

// ── Parsing helpers ─────────────────────────────────────────────────────────

/// A single `import`/`export` directive with its 1-based line number.
final class _Directive {
  const _Directive(this.uri, this.line);

  final String uri;
  final int line;
}

/// The destination of a directive: either a path inside the scanned root, or
/// an external package name.
final class _Target {
  const _Target.lib(this.path) : package = null;
  const _Target.external(this.package) : path = null;

  final String? path;
  final String? package;
}

List<_Directive> _parseDirectives(String source) {
  final List<_Directive> result = <_Directive>[];
  final List<String> lines = source.split('\n');
  for (int i = 0; i < lines.length; i++) {
    final RegExpMatch? match = _directivePattern.firstMatch(lines[i]);
    if (match != null) {
      result.add(_Directive(match.group(1)!, i + 1));
    }
  }
  return result;
}

/// Resolves [uri] relative to the importing file [importerRel].
///
/// Returns `null` for `dart:` libraries (always allowed).
_Target? _resolve(String importerRel, String uri) {
  if (uri.startsWith('dart:')) {
    return null;
  }
  const String packagePrefix = 'package:';
  if (uri.startsWith(packagePrefix)) {
    final String body = uri.substring(packagePrefix.length);
    final int slash = body.indexOf('/');
    final String package = slash == -1 ? body : body.substring(0, slash);
    if (package != _packageName) {
      return _Target.external(package);
    }
    final String path = slash == -1 ? '' : body.substring(slash + 1);
    return _Target.lib(_normalize(path));
  }
  return _Target.lib(_join(importerRel, uri));
}

String _join(String importerRel, String uri) {
  final List<String> segments = importerRel.split('/')..removeLast();
  for (final String part in uri.split('/')) {
    if (part == '.' || part.isEmpty) {
      continue;
    }
    if (part == '..') {
      if (segments.isNotEmpty) {
        segments.removeLast();
      }
    } else {
      segments.add(part);
    }
  }
  return segments.join('/');
}

String _normalize(String path) => path.replaceAll('\\', '/');

String _relative(Directory root, File file) {
  final String rootPath = _normalize(root.absolute.path);
  final String filePath = _normalize(file.absolute.path);
  if (filePath.startsWith('$rootPath/')) {
    return filePath.substring(rootPath.length + 1);
  }
  return filePath;
}

/// Classifies a root-relative path into its feature and layer, when relevant.
({String? feature, String? layer}) _classify(String rel) {
  final List<String> segments = rel.split('/');
  if (segments.isNotEmpty &&
      segments.first == 'features' &&
      segments.length >= 2) {
    final String feature = segments[1];
    String? layer;
    if (segments.length >= 3 && _layers.contains(segments[2])) {
      layer = segments[2];
    }
    return (feature: feature, layer: layer);
  }
  return (feature: null, layer: null);
}

// ── Rule engine ─────────────────────────────────────────────────────────────

String? _check(String importer, _Target target, String uri) {
  final ({String? feature, String? layer}) from = _classify(importer);
  final String importerTop = importer.split('/').first;

  final String? targetPackage = target.package;
  if (targetPackage != null) {
    if (from.layer == 'domain' && _impurePackages.contains(targetPackage)) {
      return 'domain must stay pure Dart (found "$targetPackage"): $uri';
    }
    return null;
  }

  final String toPath = target.path!;
  final ({String? feature, String? layer}) to = _classify(toPath);
  final String targetTop = toPath.split('/').first;

  // Layer independence from the application shell / sibling layers.
  if (importerTop == 'core' && _appLevel.contains(targetTop)) {
    return 'core must not depend on "$targetTop": $uri';
  }
  if (importerTop == 'shared' &&
      (targetTop == 'app' || targetTop == 'features')) {
    return 'shared must not depend on "$targetTop": $uri';
  }
  if (importerTop == 'features' && targetTop == 'app') {
    return 'features must not depend on app: $uri';
  }

  if (from.feature != null && to.feature != null) {
    if (from.feature == to.feature) {
      if (from.layer == 'domain' &&
          (to.layer == 'data' || to.layer == 'presentation')) {
        return 'domain must not depend on ${to.layer}: $uri';
      }
      if (from.layer == 'data' && to.layer == 'presentation') {
        return 'data must not depend on presentation: $uri';
      }
      return null;
    }

    // Cross-feature: only the barrel or the other feature's domain is public.
    final bool isBarrel = toPath == 'features/${to.feature}/${to.feature}.dart';
    if (to.layer == 'domain' || isBarrel) {
      return null;
    }
    return 'cross-feature imports must use the barrel or domain layer: $uri';
  }

  return null;
}
