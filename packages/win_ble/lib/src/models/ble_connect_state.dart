
class BleConnectState {
  BleConnectState({
    required this.address,
    required this.state,
    required this.isForced
  });

  String address;
  bool state;
  bool isForced;
}
