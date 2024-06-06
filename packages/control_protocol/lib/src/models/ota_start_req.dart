import 'dart:typed_data';

import 'package:control_protocol/control_protocol.dart';


class OtaStartRequest extends BaseModel {
  OtaStartRequest() : super(length: 40) {
    setSTX(Uint8List.fromList(stx.codeUnits));
    setMT(Uint8List.fromList(set.codeUnits), const Range(2, 14));
    setETX(Uint8List.fromList(etx.codeUnits));
  }

  setDate(int fileSize) {
    Uint8List file = Uint8List.fromList(fileSize.toString().codeUnits);
    Uint8List separator = Uint8List.fromList('%'.codeUnits);
    Uint8List buffer = Uint8List(file.length + separator.length);

    int offset = 0;
    buffer.setRange(offset, offset + file.length, file);
    offset += file.length;
    buffer.setRange(offset, offset + separator.length, separator);

    int dataStartIndex = 14;

    rawBytes.setRange(dataStartIndex, dataStartIndex + buffer.length, buffer);
  }
}
