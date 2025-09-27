// Updated lib/src/repository/remote/api_gateway.dart
class ApiGateway {
  // Auth endpoints
  static const String LOGIN = 'api/auth/login';
  static const String REGISTER = 'api/auth/register';
  static const String LOGOUT = 'api/auth/logout';
  static const String REFRESH = 'api/auth/refresh';
  static const String PROFILE = 'api/auth/profile';

  // Meeting endpoints
  static const String MEETINGS = 'api/meetings';
  static const String CREATE_MEETING = 'api/meetings';
  static const String JOIN_MEETING = 'api/meetings/join';
  static const String END_MEETING = 'api/meetings/end';

  // User endpoints
  static const String USERS = 'api/users';
  static const String UPDATE_PROFILE = 'api/users/profile';
}
