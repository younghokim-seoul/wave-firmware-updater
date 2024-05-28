
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ota_data.freezed.dart';


@freezed
class OtaData with _$OtaData {
  const factory OtaData({
    required int totalDataLen,
    required int totalPageNum,
    required int pageNum,
    required int lastPageDataLen,
    required int sendCnt,
    required Uint8List totalBuff,
    required Uint8List pageBuff,
  }) = _OtaData;


  factory OtaData.blank() => OtaData(
    totalDataLen: 0,
    totalPageNum: 0,
    pageNum: 0,
    lastPageDataLen: 0,
    sendCnt: 0,
    totalBuff: Uint8List(0),
    pageBuff: Uint8List(0),
  );
}