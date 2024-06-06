import 'dart:typed_data';

import 'package:control_protocol/src/models/range.dart';


const Range stxRange = Range(0, 2);
const Range mtRange = Range(2, 5);


abstract class BaseModel {
  late Uint8List rawBytes;

  BaseModel({required int length}) {
    rawBytes = Uint8List(length);
  }

  void setSTX(Uint8List stx) {
    rawBytes.setRange(stxRange.start, stxRange.end, stx);
  }

  void setMT(Uint8List mt,Range range) {
    rawBytes.setRange(range.start, range.end, mt);
  }

  void setETX(Uint8List etx) {
    rawBytes.setRange(rawBytes.length - 2, rawBytes.length, etx);
  }

  Uint8List getRawBytes() {
    return rawBytes;
  }

  Uint8List intToBytes(int value, int byteCount) {
    Uint8List bytes = Uint8List(byteCount); // 지정된 크기의 바이트 배열 생성
    for (int i = 0; i < byteCount; i++) {
      bytes[byteCount - i - 1] = (value >> (8 * i)) & 0xFF;
    }
    return bytes;
  }
}
