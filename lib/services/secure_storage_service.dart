import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Service for securely storing sensitive data
/// Uses platform-specific secure storage (Windows Credential Manager, etc.)
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Storage keys
  static const _keyLicenseKey = 'license_key';
  static const _keyLicenseToken = 'license_token';
  static const _keyLastValidation = 'last_validation';
  static const _keyHardwareFingerprint = 'hardware_fingerprint';
  static const _keyDeviceId = 'device_id';

  /// Store license key
  static Future<void> storeLicenseKey(String licenseKey) async {
    await _storage.write(key: _keyLicenseKey, value: licenseKey);
  }

  /// Get stored license key
  static Future<String?> getLicenseKey() async {
    return await _storage.read(key: _keyLicenseKey);
  }

  /// Store license validation token
  static Future<void> storeLicenseToken(String token) async {
    await _storage.write(key: _keyLicenseToken, value: token);
  }

  /// Get license validation token
  static Future<String?> getLicenseToken() async {
    return await _storage.read(key: _keyLicenseToken);
  }

  /// Store last validation timestamp
  static Future<void> storeLastValidation(DateTime timestamp) async {
    await _storage.write(
      key: _keyLastValidation,
      value: timestamp.toIso8601String(),
    );
  }

  /// Get last validation timestamp
  static Future<DateTime?> getLastValidation() async {
    final value = await _storage.read(key: _keyLastValidation);
    if (value == null) return null;
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }

  /// Store hardware fingerprint
  static Future<void> storeHardwareFingerprint(String fingerprint) async {
    await _storage.write(key: _keyHardwareFingerprint, value: fingerprint);
  }

  /// Get stored hardware fingerprint
  static Future<String?> getHardwareFingerprint() async {
    return await _storage.read(key: _keyHardwareFingerprint);
  }

  /// Store device ID
  static Future<void> storeDeviceId(String deviceId) async {
    await _storage.write(key: _keyDeviceId, value: deviceId);
  }

  /// Get stored device ID
  static Future<String?> getDeviceId() async {
    return await _storage.read(key: _keyDeviceId);
  }

  /// Check if within grace period (4 days)
  static Future<bool> isWithinGracePeriod() async {
    final lastValidation = await getLastValidation();
    if (lastValidation == null) return false;

    final now = DateTime.now();
    final difference = now.difference(lastValidation);
    
    return difference.inDays < 4;
  }

  /// Get remaining grace period hours
  static Future<int> getRemainingGraceHours() async {
    final lastValidation = await getLastValidation();
    if (lastValidation == null) return 0;

    final now = DateTime.now();
    final gracePeriodEnd = lastValidation.add(const Duration(days: 4));
    final remaining = gracePeriodEnd.difference(now);

    return remaining.inHours.clamp(0, 96); // Max 96 hours (4 days)
  }

  /// Clear all license data (for logout/deactivation)
  static Future<void> clearLicenseData() async {
    await _storage.delete(key: _keyLicenseKey);
    await _storage.delete(key: _keyLicenseToken);
    await _storage.delete(key: _keyLastValidation);
    // Keep hardware fingerprint and device ID for reactivation
  }

  /// Clear all data (complete reset)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Store arbitrary encrypted data
  static Future<void> storeEncrypted(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read arbitrary encrypted data
  static Future<String?> readEncrypted(String key) async {
    return await _storage.read(key: key);
  }

  /// Check if license is stored
  static Future<bool> hasLicense() async {
    final licenseKey = await getLicenseKey();
    return licenseKey != null && licenseKey.isNotEmpty;
  }
}
