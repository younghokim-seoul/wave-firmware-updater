// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wave_desktop_installer/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    String packet = '\$\$HB 2:9:11:2,100,0,54,15,1, 0,1,1,0% \#\#';
    String stx = '\$\$';
    String etx = '\#\#';
    if (packet.startsWith("\$\$") && packet.endsWith("\#\#")) {
      print("Packet is valid");
      int dataEndIndex = packet.indexOf("%");
      print(dataEndIndex);
      String hex = packet.substring(stx.length, dataEndIndex);
      hex = hex.replaceAllMapped(RegExp(r',\s'), (match) => ',');
      final values = hex.split(' ').skip(1).toList();
      print(values.length);
      print(values);
    }
  });

  String removeStxEtx(String packet, String stx, String etx) {
    if (packet.startsWith(stx) && packet.endsWith(etx)) {
      return packet.substring(stx.length, packet.length - etx.length);
    }
    return packet;
  }
}
