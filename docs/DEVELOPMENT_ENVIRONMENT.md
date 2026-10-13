# Development environment notes

## Flutter SDK path contains a space (Windows)

The SDK is installed at `D:\flow business\flutter\flutter`. Flutter's
native-assets hook runner invokes `dart compile kernel` with that path
**unquoted**, so `cmd` splits it at the space and the build fails for any
program whose asset graph includes a hook-based package (`sqlite3`,
`objective_c`, …).

Disabling native assets is **not** possible: `sqlite3` 3.x requires the
`dart assets` feature.

### Workaround (per terminal session)

```powershell
subst Z: "D:\flow business\flutter\flutter"
```

Then run the hook-sensitive commands through the space-free drive:

| Gate | Command |
|---|---|
| Tests | `Z:\bin\flutter.bat test` |
| Boundary check | `Z:\bin\flutter.bat pub run tool/check_boundaries.dart` |

Hook-free commands work with the normal SDK path: `dart format`,
`flutter analyze`, `flutter pub get`, `dart run build_runner build`.

A bare `dart run <script>` **fails** here, because the Dart process resolves
its own executable back to the real (space-containing) path; the Flutter
wrapper (`flutter pub run` / `flutter test`) is required.

**Durable fix:** install/move the Flutter SDK to a path without spaces (for
example `D:\flutter`) and update `PATH`.
