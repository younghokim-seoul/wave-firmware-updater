import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class OTAServer {

  static Future<Uint8List> archiveInputStream({String? fileName}) async {
    String bleServerExe = 'packages/win_ble/assets/patch.zip';
    File file = await _getFilePath(bleServerExe, fileName);
    return await file.readAsBytes();
  }

  static Future<File> _getFilePath(String path, String? fileName) async {
    final byteData = await rootBundle.load(path);
    final buffer = byteData.buffer;
    String tempPath = (await getTemporaryDirectory()).path;
    var initPath = '$tempPath/${fileName ?? 'patch'}.zip';
    var filePath = initPath;

    for (int i = 1; i < 10; i++) {
      var file = File(filePath);
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (e) {
          filePath = "$initPath$i";
          continue;
        }
        break;
      } else {
        break;
      }
    }

    return File(filePath).writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }
}
