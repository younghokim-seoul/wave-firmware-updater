class Range {
  final int start;
  final int end;

  const Range(this.start, this.end);
}

const int otaDataLength = 240;
const String stx ='\$\$';
const String fwd ='FWD';
const String set ='SET FW DOWN,';
const String etx ='\#\#';
const tail = '%';
const heartBeatPrefix = 'HB';
const swVer = 'SWVER';
const String varity ='GET FDATAVERI';
const String welcome ='WELCOME';


String byteArrayToHexString(List<int> byteArray) {
  return byteArray.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}