import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/license_service_mock.dart'; // Using mock service (Firebase disabled)
import '../../services/secure_storage_service.dart';
import '../main/main_layout.dart';

/// License activation screen
/// Shown when user needs to activate their license
class LicenseActivationScreen extends StatefulWidget {
  const LicenseActivationScreen({super.key});

  @override
  State<LicenseActivationScreen> createState() => _LicenseActivationScreenState();
}

class _LicenseActivationScreenState extends State<LicenseActivationScreen> {
  final _licenseController = TextEditingController();
  bool _isActivating = false;
  String? _errorMessage;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final online = await LicenseService.checkConnectivity();
    setState(() {
      _isOnline = online;
    });
  }

  Future<void> _activateLicense() async {
    setState(() {
      _isActivating = true;
      _errorMessage = null;
    });

    final licenseKey = _licenseController.text.trim().toUpperCase();
    
    final result = await LicenseService.activateLicense(licenseKey);

    if (mounted) {
      setState(() {
        _isActivating = false;
      });

      if (result['success'] == true) {
        // Activation successful - navigate to main app
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainLayout()),
          );
        }
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Activation failed';
        });
      }
    }
  }

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Title
                  Icon(
                    Icons.verified_user,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Activate Ecotouch',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Enter your license key to continue',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Online/Offline indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isOnline 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isOnline ? Icons.wifi : Icons.wifi_off,
                          size: 16,
                          color: _isOnline ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isOnline ? 'Online' : 'Offline - Internet required for activation',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isOnline ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // License key input
                  TextField(
                    controller: _licenseController,
                    decoration: InputDecoration(
                      labelText: 'License Key',
                      hintText: 'ECOT-XXXX-XXXX-XXXX',
                      prefixIcon: const Icon(Icons.key),
                      border: const OutlineInputBorder(),
                      errorText: _errorMessage,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9-]')),
                      LengthLimitingTextInputFormatter(19), // ECOT-XXXX-XXXX-XXXX
                    ],
                    onChanged: (value) {
                      // Auto-format with dashes
                      if (value.length == 4 && !value.endsWith('-')) {
                        _licenseController.text = '$value-';
                        _licenseController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _licenseController.text.length),
                        );
                      } else if (value.length == 9 && !value.endsWith('-')) {
                        _licenseController.text = '$value-';
                        _licenseController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _licenseController.text.length),
                        );
                      } else if (value.length == 14 && !value.endsWith('-')) {
                        _licenseController.text = '$value-';
                        _licenseController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _licenseController.text.length),
                        );
                      }
                      
                      // Clear error when user types
                      if (_errorMessage != null) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }
                    },
                    onSubmitted: (_) => _isOnline && !_isActivating ? _activateLicense() : null,
                  ),
                  const SizedBox(height: 24),

                  // Activate button
                  ElevatedButton(
                    onPressed: _isOnline && !_isActivating ? _activateLicense : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isActivating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Activate License',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Support contact
                  Text(
                    'Need help? Contact support',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
