import 'dart:typed_data';

import 'package:ota/ota.dart';

const Range pageRange = Range(5, 13);
const Range dataRange = Range(13, 253);

class OtaDataRequest extends BaseModel {
  OtaDataRequest() : super(length: 256) {
    setSTX(Uint8List.fromList(stx.codeUnits));
    setMT(Uint8List.fromList(fwd.codeUnits),mtRange);
    setETX(Uint8List.fromList(etx.codeUnits));
  }

  setDate(Uint8List data) {
    print("data size : ${data.length}");
    rawBytes.setRange(dataRange.start, dataRange.end, data);
    rawBytes[dataRange.end] ='%'.codeUnits[0];
  }

  setHeader({required int page}) {
    Uint8List separator = Uint8List.fromList(','.codeUnits);

    print('page  : $page | page length : ${_calculateChecksum()}');
    final pageBuffer = intToBytes(page, 3);
    final checkSumBuffer = intToBytes(_calculateChecksum(), 2);

    // 구분자와 변환된 정수값들을 모두 포함할 수 있는 크기의 `Uint8List` 버퍼를 생성
    Uint8List buffer = Uint8List(separator.length * 3 + pageBuffer.length + checkSumBuffer.length);

    int offset = 0;
    buffer.setRange(offset, offset + separator.length, separator); //첫번째 구분자 복사
    offset += separator.length;
    buffer.setRange(offset, offset + pageBuffer.length, pageBuffer); // 페이지값 복사
    offset += pageBuffer.length;
    buffer.setRange(offset, offset + separator.length, separator); // 두번째 구분자 복사
    offset += separator.length;
    buffer.setRange(offset, offset + checkSumBuffer.length, checkSumBuffer); // 체크섬 값 복사
    offset += checkSumBuffer.length;
    buffer.setRange(offset, offset + separator.length, separator); // 세번째 구분자 복사

    print('Header buffer : $buffer');

    rawBytes.setRange(pageRange.start, pageRange.end, buffer);
  }

  int _calculateChecksum() {
    int checksum = 0;
    for (int i = dataRange.start; i < dataRange.end; i++) {
      checksum += rawBytes[i];
    }
    return checksum;
  }
}
