enum ErrorCode {
  deviceTimeout(10),
  notFoundBinaryFile(11),
  uploadFail(12),
  serverConnectFail(13),
  notFoundNearDevice(14),

  undefinedErrorCode(99, false);

  const ErrorCode(this.code, [this.isStandardModbusExceptionCode = true]);
  final int code;
  final bool isStandardModbusExceptionCode;

  factory ErrorCode.fromCode(int code) => values.singleWhere((e) => code == e.code, orElse: () => ErrorCode.undefinedErrorCode);
}

class FwupdException implements Exception {
  const FwupdException(this.error, this.code);

  final Object error;
  final int code;
}