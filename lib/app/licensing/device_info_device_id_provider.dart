import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flow/core/licensing/device_id_provider.dart';

/// [DeviceIdProvider] backed by the `device_info_plus` plugin.
///
/// Each platform exposes a different "machine id" field; on platforms without
/// a strong one we fall back to a weaker `os:hostname` value. Pass a different
/// [DeviceIdProvider] if you need something stronger there.
class DeviceInfoDeviceIdProvider implements DeviceIdProvider {
  /// Creates the provider; [plugin] is injectable for tests.
  DeviceInfoDeviceIdProvider({DeviceInfoPlugin? plugin})
    : _plugin = plugin ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _plugin;

  @override
  Future<String> readRawDeviceId() async {
    if (Platform.isWindows) {
      return (await _plugin.windowsInfo).deviceId;
    }
    if (Platform.isAndroid) {
      return (await _plugin.androidInfo).id;
    }
    if (Platform.isIOS) {
      return (await _plugin.iosInfo).identifierForVendor ?? _fallback();
    }
    if (Platform.isLinux) {
      return (await _plugin.linuxInfo).machineId ?? _fallback();
    }
    if (Platform.isMacOS) {
      return (await _plugin.macOsInfo).systemGUID ?? _fallback();
    }
    return _fallback();
  }

  /// Weak but stable-ish value used when the platform has no machine id.
  String _fallback() => '${Platform.operatingSystem}:${Platform.localHostname}';
}
