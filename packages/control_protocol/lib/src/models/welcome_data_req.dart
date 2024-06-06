import 'dart:typed_data';

import 'package:control_protocol/control_protocol.dart';


class WelcomeDataRequest extends BaseModel {
  WelcomeDataRequest() : super(length: 40) {
    setSTX(Uint8List.fromList(stx.codeUnits));
    setDate();
    setETX(Uint8List.fromList(etx.codeUnits));
  }

  setDate() {
    Uint8List data = Uint8List.fromList(welcome.codeUnits);
    Uint8List separator = Uint8List.fromList('%'.codeUnits);
    Uint8List buffer = Uint8List(data.length + separator.length);

    int offset = 0;
    buffer.setRange(offset, offset + data.length, data);
    offset += data.length;
    buffer.setRange(offset, offset + separator.length, separator);

    int dataStartIndex = 2;

    rawBytes.setRange(dataStartIndex, dataStartIndex + buffer.length, buffer);
  }
}
