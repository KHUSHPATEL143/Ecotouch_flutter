class Validators {
  /// Validate required field
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  /// Validate number (must be valid double)
  static String? number(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }
  
  /// Validate positive number
  static String? positiveNumber(String? value, {String fieldName = 'This field'}) {
    final numberError = number(value, fieldName: fieldName);
    if (numberError != null) return numberError;
    
    final num = double.parse(value!);
    if (num <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }
  
  /// Validate non-negative number
  static String? nonNegativeNumber(String? value, {String fieldName = 'This field'}) {
    final numberError = number(value, fieldName: fieldName);
    if (numberError != null) return numberError;
    
    final num = double.parse(value!);
    if (num < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }
  
  /// Validate integer
  static String? integer(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (int.tryParse(value) == null) {
      return '$fieldName must be a whole number';
    }
    return null;
  }
  
  /// Validate positive integer
  static String? positiveInteger(String? value, {String fieldName = 'This field'}) {
    final intError = integer(value, fieldName: fieldName);
    if (intError != null) return intError;
    
    final num = int.parse(value!);
    if (num <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }
  
  /// Validate phone number (basic validation)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces, dashes, parentheses
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check if it contains only digits and optional + at start
    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
  
  /// Validate email (basic validation)
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  /// Validate password strength
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  /// Validate date is not in future
  static String? notFutureDate(DateTime? date) {
    if (date == null) {
      return 'Date is required';
    }
    
    final today = DateTime.now();
    if (date.isAfter(DateTime(today.year, today.month, today.day))) {
      return 'Date cannot be in the future';
    }
    
    return null;
  }
  
  /// Validate minimum length
  static String? minLength(String? value, int min, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    
    return null;
  }
  
  /// Validate maximum length
  static String? maxLength(String? value, int max, {String fieldName = 'This field'}) {
    if (value != null && value.length > max) {
      return '$fieldName must be at most $max characters';
    }
    
    return null;
  }
  
  /// Combine multiple validators
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
