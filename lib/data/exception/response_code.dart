enum ErrorCode {
  deviceTimeout(10),
  notFoundBinaryFile(11),
  uploadFail(12),

  undefinedErrorCode(99, false);

  const ErrorCode(this.code, [this.isStandardModbusExceptionCode = true]);
  final int code;
  final bool isStandardModbusExceptionCode;

  factory ErrorCode.fromCode(int code) => values.singleWhere((e) => code == e.code, orElse: () => ErrorCode.undefinedErrorCode);
}