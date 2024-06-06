import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:control_protocol/control_protocol.dart';
import 'package:flutter/material.dart';

import 'package:wave_desktop_installer/domain/ota_data.dart';
import 'package:wave_desktop_installer/utils/extension.dart';
import 'package:win_ble/ota_file.dart';
import 'package:win_ble/win_ble.dart';

const String waveServiceUuid = "dec7cf01-c159-43c4-9fee-0efde1a0f54b";
const String waveWriteUuid = "dec7cf03-c159-43c4-9fee-0efde1a0f54b";
const String waveNotifyUuid = "dec7cf04-c159-43c4-9fee-0efde1a0f54b";

class DeviceInfo extends StatefulWidget {
  final BleDevice device;

  const DeviceInfo({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceInfo> createState() => _DeviceInfoState();
}

class _DeviceInfoState extends State<DeviceInfo> {
  late BleDevice device;
  String? serviceId;
  TextEditingController serviceTxt = TextEditingController();
  TextEditingController characteristicTxt = TextEditingController();
  TextEditingController uint8DataTxt = TextEditingController();
  bool connected = false;
  List<String> services = [];
  List<BleCharacteristic> characteristics = [];
  String result = "";
  String error = "none";

  OtaData otaData = OtaData.blank();

  final _snackbarDuration = const Duration(milliseconds: 700);

  void showSuccess(String value) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(value), backgroundColor: Colors.green, duration: _snackbarDuration));

  void showError(String value) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(value), backgroundColor: Colors.red, duration: _snackbarDuration));

  void showNotification(String value) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(value), backgroundColor: Colors.blue, duration: _snackbarDuration));

  connect(String address) async {
    try {
      final result = await WinBle.connect(address);

      print("Connect Result : $result");

      if (result) {
        final serviceUUID = await WinBle.discoverServices(address);
        final waveUUID = serviceUUID.where((uuid) => uuid == waveServiceUuid).firstOrNull;

        if (waveUUID == null) return;

        serviceId = waveUUID;
        print('waveUUID => $waveUUID');
        await WinBle.discoverCharacteristics(address: address, serviceId: waveUUID);

        await setNotificationEnable(address, waveUUID, waveNotifyUuid);
        _putCharacteristicValue(address, waveUUID, waveNotifyUuid);
      }
    } catch (e) {
      disconnect(address);
      setState(() {
        error = e.toString();
      });
    }
  }

  void _putCharacteristicValue(
    String address,
    String serviceId,
    String characteristicId,
  ) {
    if (!characteristicValueChangeMap.containsKey(address)) {
      characteristicValueChangeMap[address] = WinBle.characteristicValueStreamOf(
        address: address,
        serviceId: serviceId,
        characteristicId: characteristicId,
      ).listen(
        (data) {
          try {
            if (data != null) {
              final packet = data.whereType<int>().toList();
              final msgType = packet.sublist(2, 5);
              String hex = utf8.decode(packet);
              String event = utf8.decode(msgType);
              print("[RECEIVE PACKET] hex : " + hex.toString() + " envet : " + event.toString());
              switch (event) {
                case "SET":
                  print("SET");
                  final status = hex.extractDataBootloaderData();
                  print("status " + status);

                  if (status == "OK") {
                    // transferData(address, serviceId, waveWriteUuid);
                  } else {
                    print("OTA Fail");
                  }
                  break;
                case "FWD":
                  print("FWD");
                  final response = hex.extractDataFirmwareDownData().split(",");

                  if (response.length < 3) {
                    print("FW DOWN Data Varity");
                    final status = response[1];

                    if (status == "COM") {
                      print("펌웨어 파일 유효성 체크 성공");
                    } else {
                      print("펌웨어 파일 유효성 체크 실패 파일 깨짐.");
                    }
                  } else {
                    final status = response[1];
                    final pageNum = int.parse(response[2]);

                    print("curPage " + otaData.pageNum.toString());
                    print("status : $status pageNum : $pageNum totalPageNum : ${otaData.totalPageNum}");

                    //만약 3번 패킷이 NG 발생했어...
                    //그럼 다시 3번을 보내야하잖아..

                    if (status == "OK") {
                      otaData = otaData.copyWith(pageNum: pageNum, retryCnt: 0);
                    } else {
                      otaData = otaData.copyWith(retryCnt: otaData.retryCnt + 1);
                    }

                    if (pageNum < otaData.totalPageNum) {
                      transferData(address, serviceId, characteristicId);
                    } else {
                      print("WOW OTA COMPLETE........");
                      otaData = OtaData.blank();

                      OtaDataVarityRequest otaDataVarityRequest = OtaDataVarityRequest();
                      otaDataVarityRequest.setDate();

                      writeCharacteristic(address, serviceId, waveWriteUuid, otaDataVarityRequest.getRawBytes(), true);
                    }
                  }

                  break;
              }
            }
          } catch (e) {
            print("characteristicValueChangeMap error : $e");
          }
        },
      );
    }
  }

  void transferData(String address, String serviceId, String characteristicId) async {
    if (otaData == OtaData.blank()) {
      print('ota data blank..!!!!! error');
      return;
    }
    print("[${otaData.pageNum + 1} / ${otaData.totalPageNum}]");

    try {
      int sendPage = otaData.pageNum;
      final srcPos = sendPage * 240;
      final endPos = min(srcPos + otaDataLength, otaData.totalDataLen);

      print('startPos: $srcPos' ' endPos: $endPos');

      Uint8List pageBuff = otaData.totalBuff.sublist(srcPos, endPos);

      // 패킷의 크기가 240 바이트보다 작으면, 패킷의 뒷부분을 0으로 채웁니다.

      if ((otaData.pageNum + 1) == otaData.totalPageNum) {
        var paddedPacket = Uint8List(240);
        paddedPacket.setRange(0, pageBuff.length, pageBuff);
        pageBuff = paddedPacket;
      }

      otaData = otaData.copyWith(pageBuff: pageBuff);

      final OtaDataRequest otaDataRequest = OtaDataRequest();

      sendPage = sendPage + 1;
      print('Page => $sendPage');

      otaDataRequest.setDate(pageBuff);
      otaDataRequest.setHeader(page: sendPage);

      // int chunkSize = (otaDataRequest.getRawBytes().length / 3).ceil(); // 데이터를 3등분하기 위한 청크 크기 계산

      // for (int i = 0; i < 3; i++) {
      //   // 각 청크의 시작과 끝 인덱스 계산
      //   int start = i * chunkSize;
      //   int end = min(start + chunkSize, otaDataRequest.getRawBytes().length);
      //
      //   // 청크 데이터 추출
      //   Uint8List chunkData = otaDataRequest.getRawBytes().sublist(start, end);
      //
      //   // 2초 간격으로 청크 데이터 전송
      //   await Future.delayed(Duration(seconds: 2), () async {
      //     await writeCharacteristic(address, "dec7cf01-c159-43c4-9fee-0efde1a0f54b", "dec7cf03-c159-43c4-9fee-0efde1a0f54b", chunkData, true);
      //   });
      // }

      print("send--->>>> ${otaDataRequest.getRawBytes()}");
      await writeCharacteristic(address, "dec7cf01-c159-43c4-9fee-0efde1a0f54b", "dec7cf03-c159-43c4-9fee-0efde1a0f54b",
          otaDataRequest.getRawBytes(), true);
    } catch (e) {
      showError("writeCharError : $e");
      setState(() {
        error = e.toString();
      });
    }
  }

  Future<void> setNotificationEnable(
    String address,
    String serviceId,
    String characteristicId,
  ) async {
    try {
      await WinBle.unSubscribeFromCharacteristic(
          address: address, serviceId: serviceId, characteristicId: characteristicId);
      await WinBle.subscribeToCharacteristic(
          address: address, serviceId: serviceId, characteristicId: characteristicId);
      print("SubscribeToCharacteristic Success");
    } catch (e) {
      print("unSubscribeToCharacteristic Error: $e");
      for (int i = 0; i < 3; i++) {
        try {
          await WinBle.subscribeToCharacteristic(
              address: address, serviceId: serviceId, characteristicId: characteristicId);
          print("subscribeToCharacteristic Success  Retry Count: $i");
          break;
        } catch (e) {
          print("subscribeToCharacteristic Error : $e, Retry Count: $i");

          if (i == 2) {
            print("Failed to subscribe to characteristic after 3 attempts");
            rethrow;
          }
        }
      }
    }
  }

  disconnect(address) async {
    try {
      await WinBle.disconnect(address);
      showSuccess("Disconnected");
      disconnectAndClearAllDevices();
    } catch (e) {
      if (!mounted) return;
      showError(e.toString());
    }
  }

  startOTA(address) async {
    try {
      print("Starting OTA..." + address);
      final otaStartRequest = OtaStartRequest();
      final content = await OTAServer.archiveInputStream();
      final totalSize = content.length;

      otaData = otaData.copyWith(
        totalDataLen: totalSize,
        totalPageNum: (totalSize / 240).ceil(),
        lastPageDataLen: totalSize % 240,
        totalBuff: content,
      );

      otaStartRequest.setDate(otaData.totalPageNum);

      final send = otaStartRequest.getRawBytes();

      await writeCharacteristic(address, serviceId!, waveWriteUuid, send, true);
    } catch (e) {
      showError("DiscoverServiceError : $e");
      setState(() {
        error = e.toString();
      });
    }
  }

  void disconnectAndClearAllDevices() {
    if (characteristicValueChangeMap.isNotEmpty) {
      characteristicValueChangeMap.forEach((key, value) {
        value.cancel();
      });
      characteristicValueChangeMap.clear();
    }

    serviceId = null;
  }

  discoverCharacteristic(address, serviceID) async {
    try {
      List<BleCharacteristic> bleChar = await WinBle.discoverCharacteristics(address: address, serviceId: serviceID);
      print(bleChar.map((e) => e.toJson()));
      setState(() {
        characteristics = bleChar;
      });
    } catch (e) {
      showError("DiscoverCharError : $e");
      setState(() {
        error = e.toString();
      });
    }
  }

  readCharacteristic(address, serviceID, charID) async {
    try {
      List<int> data = await WinBle.read(address: address, serviceId: serviceID, characteristicId: charID);
      print(String.fromCharCodes(data));
      setState(() {
        result =
            "Read => List<int> : $data    ,    ToString :  ${String.fromCharCodes(data)}   , Time : ${DateTime.now()}";
      });
    } catch (e) {
      showError("ReadCharError : $e");
      setState(() {
        error = e.toString();
      });
    }
  }

  writeCharacteristic(String address, String serviceID, String charID, Uint8List data, bool writeWithResponse) async {
    try {
      await WinBle.write(
          address: address, service: serviceID, characteristic: charID, data: data, writeWithResponse: true);
    } catch (e) {
      showError("writeCharError : $e");
      setState(() {
        error = e.toString();
      });
    }
  }

  subsCribeToCharacteristic(address, serviceID, charID) async {
    try {
      await WinBle.subscribeToCharacteristic(address: address, serviceId: serviceID, characteristicId: charID);
      showSuccess("Subscribe Successfully");
    } catch (e) {
      showError("SubscribeCharError : $e");
      setState(() {
        error = e.toString() + " Date ${DateTime.now()}";
      });
    }
  }

  unSubscribeToCharacteristic(address, serviceID, charID) async {
    try {
      await WinBle.unSubscribeFromCharacteristic(address: address, serviceId: serviceID, characteristicId: charID);
      showSuccess("Unsubscribed Successfully");
    } catch (e) {
      showError("UnSubscribeError : $e");
      setState(() {
        error = e.toString() + " Date ${DateTime.now()}";
      });
    }
  }

  StreamSubscription? _connectionStream;
  StreamSubscription? _characteristicValueStream;
  final characteristicValueChangeMap = <String, StreamSubscription>{};

  @override
  void initState() {
    device = widget.device;
    // subscribe to connection events
    _connectionStream = WinBle.connectionStreamOf(device.address).listen((event) {
      if (event == false) {
        disconnectAndClearAllDevices();
        // connect(device.address);
      }
      setState(() {
        connected = event;
      });
      showSuccess("Connected : $event");
    });
    super.initState();
  }

  @override
  void dispose() {
    _connectionStream?.cancel();
    _characteristicValueStream?.cancel();
    disconnect(device.address);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        centerTitle: true,
        actions: [
          Row(
            children: [
              Text(connected ? "Connected" : "Disconnected"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.circle,
                  color: connected ? Colors.green : Colors.red,
                ),
              )
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Buttons
            const SizedBox(
              height: 10,
            ),
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                kButton("Connect", () {
                  connect(device.address);
                }),
                kButton("Disconnect", () {
                  disconnect(device.address);
                }),
                kButton("Start OTA", () {
                  startOTA(device.address);
                }, enabled: connected),
                kButton("Get MaxMtuSize", () {
                  WinBle.getMaxMtuSize(device.address).then((value) {
                    showNotification("MaxMtuSize : $value");
                  });
                }, enabled: connected),
              ],
            ),
            const Divider(),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                kButton("canPair", () async {
                  transferData(widget.device.address, serviceId!, waveWriteUuid);
                }, enabled: connected),
                kButton("isPaired", () async {
                  OtaDataVarityRequest otaDataVarityRequest = OtaDataVarityRequest();
                  otaDataVarityRequest.setDate();

                  writeCharacteristic(
                      widget.device.address, serviceId!, waveWriteUuid, otaDataVarityRequest.getRawBytes(), true);
                }, enabled: connected),
                kButton("Pair", () {}, enabled: connected),
                kButton("UnPair", () {}, enabled: connected),
              ],
            ),
            // Service List
            kHeadingText("Services List"),
            ListView.builder(
              itemCount: services.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    serviceTxt.text = services[index];
                    discoverCharacteristic(device.address, services[index]);
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(services[index]),
                    ),
                  ),
                );
              },
            ),

            kHeadingText("Characteristics List"),
            ListView.builder(
              itemCount: characteristics.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                BleCharacteristic characteristic = characteristics[index];
                return InkWell(
                  onTap: () {
                    characteristicTxt.text = characteristics[index].uuid;
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(characteristic.uuid),
                      subtitle: Text("Properties : ${characteristic.properties.toJson()}"),
                    ),
                  ),
                );
              },
            ),

            kTextForm(
              "Enter Characteristic",
              characteristicTxt,
            ),

            kTextForm(
              "Enter List<int> Data",
              uint8DataTxt,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                kButton("Read Characteristics", () {
                  readCharacteristic(device.address, serviceTxt.text, characteristicTxt.text);
                }, enabled: connected),
                kButton("Write Characteristics", () {
                  if (uint8DataTxt.text == "") {
                    setState(() {
                      error = "Please Enter Data , Time : ${DateTime.now()}";
                    });
                    return;
                  }
                  Uint8List data = Uint8List.fromList(uint8DataTxt.text
                      .replaceAll("[", "")
                      .replaceAll("]", "")
                      .split(",")
                      .map((e) => int.parse(e.trim()))
                      .toList());
                  writeCharacteristic(device.address, serviceTxt.text, characteristicTxt.text, data, true);
                }, enabled: connected),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                kButton("Subscribe Characteristics", () {
                  subsCribeToCharacteristic(device.address, serviceTxt.text, characteristicTxt.text);
                }, enabled: connected),
                kButton("UnSubscribe Characteristics", () {
                  unSubscribeToCharacteristic(device.address, serviceTxt.text, characteristicTxt.text);
                }, enabled: connected),
              ],
            ),

            const SizedBox(height: 10),

            kHeadingText(result, shiftLeft: true),

            const SizedBox(height: 10),
            kHeadingText("Error : " + error, shiftLeft: true),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  kTextForm(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hint,
        ),
      ),
    );
  }

  kButton(String txt, onTap, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        child: Text(
          txt,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  kHeadingText(String title, {bool shiftLeft = false}) {
    return Column(
      crossAxisAlignment: shiftLeft ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Text(title),
        ),
        const Divider(),
      ],
    );
  }
}
