class SessionExpiredException implements Exception {
  final String message;

  SessionExpiredException(this.message);
}
