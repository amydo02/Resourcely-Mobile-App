class AppConstants {
  // App Information
  static const String appName = 'RESOURCELY';
  static const String tagline = 'Discover. Apply. Achieve.';
  
  // Navigation Labels
  static const String homeLabel = 'Home';
  static const String scholarshipsLabel = 'Scholarships';
  static const String transitLabel = 'Transit';
  static const String calendarLabel = 'Calendar';
  static const String profileLabel = 'Profile';
  
  // API Endpoints (for future use)
  static const String baseUrl = 'https://api.resourcely.app';
  static const String scholarshipsEndpoint = '/scholarships';
  static const String transitEndpoint = '/transit';
  static const String eventsEndpoint = '/events';
  static const String userEndpoint = '/user';
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String generalError = 'Something went wrong. Please try again.';
  static const String authError = 'Authentication failed. Please check your credentials.';
  
  // Success Messages
  static const String loginSuccess = 'Welcome back!';
  static const String signupSuccess = 'Account created successfully!';
  static const String updateSuccess = 'Profile updated successfully!';
  
  // Validation Messages
  static const String emailRequired = 'Email is required';
  //static const String passwordRequired = 'Password is required';
  static const String invalidEmail = 'Please enter a valid email';
  //static const String passwordTooShort = 'Password must be at least 6 characters';
}