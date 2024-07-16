enum ConnectionStatus {
  connecting,
  connected,
  disconnected,
}


extension FromDeviceExtension on Map {
  String? getAddressFromDevice() {
    String? address;
    forEach((key, value) {
      print("getAddressFromDevice key....  " + key);
      address = key;
    });
    return address;
  }
}
