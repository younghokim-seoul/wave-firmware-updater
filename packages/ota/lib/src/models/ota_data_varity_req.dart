import 'dart:typed_data';

import 'package:ota/ota.dart';

class OtaDataVarityRequest extends BaseModel {
  OtaDataVarityRequest() : super(length: 256) {
    setSTX(Uint8List.fromList(stx.codeUnits));
    setETX(Uint8List.fromList(etx.codeUnits));
  }

  setDate() {
    Uint8List dataVarity = Uint8List.fromList(varity.codeUnits);
    Uint8List separator = Uint8List.fromList('%'.codeUnits);
    Uint8List buffer = Uint8List(dataVarity.length + separator.length);

    int offset = 0;
    buffer.setRange(offset, offset + dataVarity.length, dataVarity);
    offset += dataVarity.length;
    buffer.setRange(offset, offset + separator.length, separator);

    int dataStartIndex = 2;

    rawBytes.setRange(dataStartIndex, dataStartIndex + buffer.length, buffer);
  }
}
