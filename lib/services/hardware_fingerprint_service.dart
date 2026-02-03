import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:platform_device_id/platform_device_id.dart';

/// Service for generating unique hardware fingerprints
/// Used to tie licenses to specific devices
class HardwareFingerprintService {
  static String? _cachedFingerprint;
  static Map<String, String>? _cachedDeviceInfo;

  /// Generate a unique hardware fingerprint for this device
  /// Combines device ID, MAC address, and system info into a SHA-256 hash
  static Future<String> generateFingerprint() async {
    if (_cachedFingerprint != null) {
      return _cachedFingerprint!;
    }

    try {
      final components = <String>[];

      // 1. Get platform device ID
      final deviceId = await PlatformDeviceId.getDeviceId;
      if (deviceId != null) {
        components.add('DEVICE_ID:$deviceId');
      }

      // 2. Get MAC address (if available)
      try {
        final networkInfo = NetworkInfo();
        final wifiMAC = await networkInfo.getWifiBSSID();
        if (wifiMAC != null && wifiMAC.isNotEmpty) {
          components.add('MAC:$wifiMAC');
        }
      } catch (e) {
        print('Could not get MAC address: $e');
      }

      // 3. Get device-specific information
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        components.add('COMPUTER:${windowsInfo.computerName}');
        components.add('MACHINE:${windowsInfo.numberOfCores}');
        // Use system GUID if available
        if (windowsInfo.systemMemoryInMegabytes > 0) {
          components.add('MEM:${windowsInfo.systemMemoryInMegabytes}');
        }
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        components.add('MACHINE:${linuxInfo.machineId}');
        components.add('NAME:${linuxInfo.name}');
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        components.add('MODEL:${macInfo.model}');
        components.add('SERIAL:${macInfo.systemGUID}');
      }

      // 4. Combine all components
      if (components.isEmpty) {
        throw Exception('Could not gather any device information');
      }

      final combined = components.join('|');
      
      // 5. Generate SHA-256 hash
      final bytes = utf8.encode(combined);
      final digest = sha256.convert(bytes);
      final fingerprint = digest.toString();

      _cachedFingerprint = fingerprint;
      print('✓ Hardware fingerprint generated: ${fingerprint.substring(0, 16)}...');
      
      return fingerprint;
    } catch (e) {
      print('Error generating hardware fingerprint: $e');
      rethrow;
    }
  }

  /// Get detailed device information for display/logging
  static Future<Map<String, String>> getDeviceInfo() async {
    if (_cachedDeviceInfo != null) {
      return _cachedDeviceInfo!;
    }

    try {
      final info = <String, String>{};
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        info['os'] = 'Windows';
        info['version'] = windowsInfo.displayVersion;
        info['computerName'] = windowsInfo.computerName;
        info['cores'] = windowsInfo.numberOfCores.toString();
        info['memory'] = '${windowsInfo.systemMemoryInMegabytes} MB';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        info['os'] = 'Linux';
        info['name'] = linuxInfo.name;
        info['version'] = linuxInfo.version ?? 'Unknown';
        info['machineId'] = linuxInfo.machineId ?? 'Unknown';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        info['os'] = 'macOS';
        info['model'] = macInfo.model;
        info['version'] = macInfo.osRelease;
        info['computerName'] = macInfo.computerName;
      }

      // Add device ID
      final deviceId = await PlatformDeviceId.getDeviceId;
      if (deviceId != null) {
        info['deviceId'] = deviceId;
      }

      _cachedDeviceInfo = info;
      return info;
    } catch (e) {
      print('Error getting device info: $e');
      return {'error': e.toString()};
    }
  }

  /// Check if hardware has changed significantly
  /// Returns true if the fingerprint matches the stored one
  static Future<bool> verifyFingerprint(String storedFingerprint) async {
    try {
      final currentFingerprint = await generateFingerprint();
      return currentFingerprint == storedFingerprint;
    } catch (e) {
      print('Error verifying fingerprint: $e');
      return false;
    }
  }

  /// Clear cached fingerprint (useful for testing)
  static void clearCache() {
    _cachedFingerprint = null;
    _cachedDeviceInfo = null;
  }

  /// Get a human-readable device name
  static Future<String> getDeviceName() async {
    try {
      final info = await getDeviceInfo();
      
      if (Platform.isWindows) {
        return info['computerName'] ?? 'Windows PC';
      } else if (Platform.isLinux) {
        return info['name'] ?? 'Linux Machine';
      } else if (Platform.isMacOS) {
        return info['computerName'] ?? 'Mac';
      }
      
      return 'Unknown Device';
    } catch (e) {
      return 'Unknown Device';
    }
  }
}
