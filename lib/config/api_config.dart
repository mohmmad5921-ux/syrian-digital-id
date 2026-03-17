class ApiConfig {
  static const String baseUrl = 'https://digitalidsyria.com/api';
  static const Duration timeout = Duration(seconds: 30);

  // API Endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String user = '/user';
  static const String digitalId = '/digital-id';
  static const String walletPass = '/wallet/pass';
  static const String verify = '/verify';
}
