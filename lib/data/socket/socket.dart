library socket;

import 'dart:convert';

import 'package:wave_desktop_installer/data/socket/wave_socket.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';


part 'socket_notifier.dart';

extension FirstWhereExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
