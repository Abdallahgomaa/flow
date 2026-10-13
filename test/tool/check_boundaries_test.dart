// Regression tests for `tool/check_boundaries.dart`.
//
// Each test materialises a tiny synthetic source tree inside a temporary
// directory (the temporary directory acts as the `lib/` root), runs the
// checker against it and asserts on the exit code / diagnostics.
//
// Keeping these tests fast and hermetic means the boundary rules stay honest
// as the real codebase grows.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_boundaries.dart';

/// Writes [files] (root-relative path → source) into [root].
void _writeTree(Directory root, Map<String, String> files) {
  for (final MapEntry<String, String> entry in files.entries) {
    final File file = File('${root.path}/${entry.key}');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(entry.value);
  }
}

/// Seeds [root] with [files] and then runs the boundary check.
({int code, String output}) _run(Directory root, Map<String, String> files) {
  _writeTree(root, files);
  final StringBuffer buffer = StringBuffer();
  final int code = run(root.path, out: buffer);
  return (code: code, output: buffer.toString());
}

void main() {
  late Directory temp;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('flow_boundaries_');
  });

  tearDown(() {
    if (temp.existsSync()) {
      temp.deleteSync(recursive: true);
    }
  });

  test('accepts a tree that respects every boundary', () {
    final ({int code, String output}) result = _run(temp, <String, String>{
      'core/result/result.dart': "import 'dart:async';\n",
      'core/result/failure.dart': "import 'result.dart';\n",
      'shared/design/app_colors.dart':
          "import 'package:flutter/material.dart';\n",
      'shared/design/design.dart': "export 'app_colors.dart';\n",
      'shared/widgets/button.dart': "import '../design/app_colors.dart';\n",
      'features/catalog/domain/product.dart':
          "import 'package:meta/meta.dart';\n",
      'features/catalog/data/repository.dart':
          "import '../domain/product.dart';\n",
      'features/catalog/presentation/page.dart':
          "import '../data/repository.dart';\n",
      'features/catalog/catalog.dart': "export 'domain/product.dart';\n",
      'features/pos/presentation/checkout.dart':
          "import 'package:flow/features/catalog/catalog.dart';\n",
      'app/app.dart': "import 'package:flow/features/catalog/catalog.dart';\n",
    });

    expect(result.code, 0, reason: result.output);
    expect(result.output, contains('passed'));
  });

  test('rejects cross-feature data imports', () {
    final ({int code, String output}) result = _run(temp, <String, String>{
      'features/pos/presentation/checkout.dart':
          "import 'package:flow/features/catalog/data/repository.dart';\n",
    });

    expect(result.code, 1);
    expect(result.output, contains('cross-feature'));
  });

  test('rejects cross-feature presentation imports', () {
    final ({int code, String output}) result = _run(temp, <String, String>{
      'features/pos/presentation/checkout.dart':
          "import 'package:flow/features/catalog/presentation/page.dart';\n",
    });

    expect(result.code, 1);
    expect(result.output, contains('cross-feature'));
  });

  test('rejects core depending on shared', () {
    final ({int code, String output}) result = _run(temp, <String, String>{
      'core/result/result.dart':
          "import 'package:flow/shared/widgets/button.dart';\n",
    });

    expect(result.code, 1);
    expect(result.output, contains('core must not depend'));
  });

  test('rejects shared depending on app', () {
    final ({int code, String output}) result = _run(temp, <String, String>{
      'shared/widgets/button.dart': "import 'package:flow/app/app.dart';\n",
    });

    expect(result.code, 1);
    expect(result.output, contains('shared must not depend'));
  });

  test('rejects Flutter imports inside a domain layer', () {
    final ({int code, String output}) result = _run(temp, <String, String>{
      'features/catalog/domain/product.dart':
          "import 'package:flutter/material.dart';\n",
    });

    expect(result.code, 1);
    expect(result.output, contains('pure Dart'));
  });

  test('rejects domain depending on data', () {
    final ({int code, String output}) result = _run(temp, <String, String>{
      'features/catalog/domain/product.dart':
          "import '../data/repository.dart';\n",
    });

    expect(result.code, 1);
    expect(result.output, contains('domain must not depend'));
  });

  test('rejects data depending on presentation', () {
    final ({int code, String output}) result = _run(temp, <String, String>{
      'features/catalog/data/repository.dart':
          "import '../presentation/page.dart';\n",
    });

    expect(result.code, 1);
    expect(result.output, contains('data must not depend on presentation'));
  });

  test('rejects features depending on app', () {
    final ({int code, String output}) result = _run(temp, <String, String>{
      'features/catalog/presentation/page.dart':
          "import 'package:flow/app/app.dart';\n",
    });

    expect(result.code, 1);
    expect(result.output, contains('features must not depend on app'));
  });

  test('fails when the scanned root does not exist', () {
    final StringBuffer buffer = StringBuffer();
    final int code = run('${temp.path}/missing', out: buffer);

    expect(code, 1);
    expect(buffer.toString(), contains('does not exist'));
  });
}
