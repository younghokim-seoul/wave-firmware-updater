enum ConnectionStatus {
  connecting,
  connected,
  disconnected,
}


extension FromDeviceExtension on Map {
  String? getAddressFromDevice() {
    String? address;
    forEach((key, value) {
      address = key;
    });
    return address;
  }
}
