
import 'package:flutter/material.dart';

@immutable
class BleForceConnectState {
  const BleForceConnectState({
    required this.address,
    required this.state,
    required this.serviceUuidList
  });

  final String address;
  final bool state;
  final List<String> serviceUuidList;
}
