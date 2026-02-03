import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'hardware_fingerprint_service.dart';
import 'secure_storage_service.dart';

/// MOCK License validation service for testing WITHOUT Firebase
/// This simulates Firebase behavior locally for development
/// Replace with real license_service.dart when Firebase is enabled
class LicenseService {
  static Timer? _heartbeatTimer;
  static String? _currentSessionId;
  static bool _isOnline = false;

  // Mock license database (in production, this is in Firebase)
  static final Map<String, Map<String, dynamic>> _mockLicenses = {
    'ECOT-TEST-1234-ABCD': {
      'key': 'ECOT-TEST-1234-ABCD',
      'clientName': 'Test Client',
      'isActive': true,
      'expiresAt': null, // perpetual
      'maxActivations': 4,
      'maxConcurrent': 1,
      'activations': <String, Map<String, dynamic>>{},
      'sessions': <String, Map<String, dynamic>>{},
    },
  };

  // Constants
  static const int maxActivations = 4;
  static const int maxConcurrent = 1;
  static const Duration heartbeatInterval = Duration(minutes: 2);
  static const Duration sessionTimeout = Duration(minutes: 5);
  static const Duration gracePeriodDays = Duration(days: 4);

  /// Check if device is online
  static Future<bool> checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _isOnline = connectivityResult.first != ConnectivityResult.none;
      return _isOnline;
    } catch (e) {
      _isOnline = false;
      return false;
    }
  }

  /// Validate license key format (ECOT-XXXX-XXXX-XXXX)
  static bool isValidLicenseFormat(String licenseKey) {
    final regex = RegExp(r'^ECOT-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
    return regex.hasMatch(licenseKey.toUpperCase());
  }

  /// Activate license on this device (MOCK VERSION)
  static Future<Map<String, dynamic>> activateLicense(String licenseKey) async {
    try {
      print('🧪 MOCK: Activating license (Firebase disabled)');
      
      // Validate format
      if (!isValidLicenseFormat(licenseKey)) {
        return {
          'success': false,
          'error': 'Invalid license key format. Expected: ECOT-XXXX-XXXX-XXXX',
        };
      }

      // Check if license exists in mock database
      final normalizedKey = licenseKey.toUpperCase();
      if (!_mockLicenses.containsKey(normalizedKey)) {
        return {
          'success': false,
          'error': 'License key not found. (Mock mode - only ECOT-TEST-1234-ABCD works)',
        };
      }

      final license = _mockLicenses[normalizedKey]!;

      // Check if active
      if (license['isActive'] != true) {
        return {
          'success': false,
          'error': 'This license has been deactivated.',
        };
      }

      // Get hardware fingerprint
      final fingerprint = await HardwareFingerprintService.generateFingerprint();
      final deviceName = await HardwareFingerprintService.getDeviceName();
      final deviceId = DateTime.now().millisecondsSinceEpoch.toString();

      // Store activation in mock database
      license['activations'][deviceId] = {
        'hardwareFingerprint': fingerprint,
        'deviceName': deviceName,
        'activatedAt': DateTime.now(),
        'lastValidated': DateTime.now(),
      };

      // Store license locally
      await SecureStorageService.storeLicenseKey(normalizedKey);
      await SecureStorageService.storeHardwareFingerprint(fingerprint);
      await SecureStorageService.storeDeviceId(deviceId);
      await SecureStorageService.storeLastValidation(DateTime.now());

      print('✓ MOCK: License activated successfully');
      return {
        'success': true,
        'message': 'License activated successfully! (Mock mode)',
        'deviceId': deviceId,
      };
    } catch (e) {
      print('Error activating license: $e');
      return {
        'success': false,
        'error': 'Activation failed: ${e.toString()}',
      };
    }
  }

  /// Validate license (MOCK VERSION)
  static Future<Map<String, dynamic>> validateLicense() async {
    try {
      print('🧪 MOCK: Validating license (Firebase disabled)');
      
      // Check if license is stored locally
      final licenseKey = await SecureStorageService.getLicenseKey();
      if (licenseKey == null) {
        return {
          'success': false,
          'error': 'No license found. Please activate a license.',
          'requiresActivation': true,
        };
      }

      // In mock mode, always validate successfully if license is stored
      await SecureStorageService.storeLastValidation(DateTime.now());

      print('✓ MOCK: License validated successfully');
      return {
        'success': true,
        'message': 'License validated successfully (Mock mode)',
        'online': false,
        'mockMode': true,
      };
    } catch (e) {
      print('Error validating license: $e');
      return {
        'success': false,
        'error': 'Validation failed: ${e.toString()}',
      };
    }
  }

  /// Create session (MOCK VERSION)
  static Future<bool> createSession() async {
    try {
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _currentSessionId = sessionId;
      print('✓ MOCK: Session created: $sessionId');
      return true;
    } catch (e) {
      print('Error creating session: $e');
      return false;
    }
  }

  /// End session (MOCK VERSION)
  static Future<void> endSession() async {
    try {
      _heartbeatTimer?.cancel();
      if (_currentSessionId != null) {
        print('✓ MOCK: Session ended: $_currentSessionId');
        _currentSessionId = null;
      }
    } catch (e) {
      print('Error ending session: $e');
    }
  }

  /// Deactivate this device (MOCK VERSION)
  static Future<Map<String, dynamic>> deactivateDevice() async {
    try {
      await endSession();
      await SecureStorageService.clearLicenseData();
      
      print('✓ MOCK: Device deactivated');
      return {
        'success': true,
        'message': 'Device deactivated successfully (Mock mode)',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Deactivation failed: ${e.toString()}',
      };
    }
  }
}
