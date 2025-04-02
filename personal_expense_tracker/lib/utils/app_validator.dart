class AppValidator {
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter an email';
    RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) return 'Please enter a valid email';
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a username';
    if (value.length < 3) return 'Username must be at least 3 characters';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}