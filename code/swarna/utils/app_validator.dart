class AppValidator {
  /// Validates an email address.
  /// 
  /// Returns an error message if the email is empty or does not match 
  /// the standard email format.
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter an email';
    // Regular expression to check for a valid email format
    RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) return 'Please enter a valid email';
    return null;// No error, valid emai
  }
  /// Validates a username.
  /// 
  /// Ensures the username is not empty and has at least 3 characters.
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a username';
    if (value.length < 3) return 'Username must be at least 3 characters';
    return null;// No error, valid username
  }
  /// Validates a password.
  /// 
  /// Ensures the password is not empty and has at least 6 characters.
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;// No error, valid password
  }
}
