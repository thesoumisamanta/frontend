class NetworkResponse<T> {
  const NetworkResponse({
    required this.data,
    required this.statusCode,
    this.message,
    this.raw,
  });

  final T? data;
  final int? statusCode;
  final String? message;
  final dynamic raw;

  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;
}
