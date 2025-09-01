class ApiException {
  final String message;
  final int statusCode;

  ApiException(String decodeBodyBytes, {required this.message, required this.statusCode});

}
