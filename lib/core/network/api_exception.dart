class ApiException implements Exception {
  const ApiException({required this.message, this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() {
    final codeLabel = code == null ? '' : ' [$code]';
    return 'ApiException$codeLabel: $message';
  }
}
