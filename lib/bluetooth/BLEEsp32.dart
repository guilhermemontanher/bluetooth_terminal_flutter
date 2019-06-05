import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';

import 'BTCom.dart';

class BLEEsp32 extends BTCom {
  static Guid UUID_SERVICE = Guid("0000ABF0-0000-1000-8000-00805F9B34FB");
  static Guid UUID_CHARACTERIST_RX =
      Guid("0000ABF2-0000-1000-8000-00805F9B34FB");
  static Guid UUID_CHARACTERIST_TX =
      Guid("0000ABF1-0000-1000-8000-00805F9B34FB");

  static final String TAG = "BLEServiceESP32";
  static final int STATE_DISCONNECTED = 0;
  static final int STATE_CONNECTED = 2;
  static final int STATE_READY_TO_USE = 3;
  static final int TIMEOUT_CONNECTION = 10000;
  static final int MTU_SIZE_MAX = 255;
  static final int MTU_SIZE_DEFAULT = 20;

  BluetoothService gattService;

  BluetoothDevice device;
  List<BluetoothService> services;
  BluetoothCharacteristic characteristicTransparentUARTTX;
  BluetoothCharacteristic characteristicTransparentUARTRX;

  int connectionState = STATE_DISCONNECTED;

  var bluetoothStreamConnection;

//  final bluetoothStreamController = StreamController<BluetoothListener>();

  @override
  connect(BluetoothDevice device) {
    this.device = device;
    //CALLBACK BLUETOOTH STATE
    print("$TAG | CONNECTING");
    if (onConnecting != null) onConnecting();
    bluetoothStreamConnection =
        FlutterBlue.instance.connect(device,autoConnect: false).listen((s) {
      switch (s) {
        case BluetoothDeviceState.connecting:
          //print("$TAG | CONNECTING");
          //if (onConnecting != null) onConnecting();
          break;
        case BluetoothDeviceState.connected:
          print("$TAG | CONNECTED");
          _discoverServices(device);
          break;
        case BluetoothDeviceState.disconnecting:
          print("$TAG | DISCONNECTING");
          break;
        case BluetoothDeviceState.disconnected:
          print("$TAG | DISCONNECTED");
          connectionState = STATE_DISCONNECTED;
          if (onLostConnection != null) onLostConnection();
          break;
      }
    }, onError: (d) {
      print("onError " + d.toString());
      if (onFailConnection != null) onFailConnection();
    });
    return null;
  }

  @override
  void connectByAddress(String address) {
    List<ScanResult> devices = List<ScanResult>();
    bool found = false;
    FlutterBlue.instance
        .scan(scanMode: ScanMode.balanced, timeout: Duration(seconds: 10))
        .listen((scanResult) {
      scanning = true;
      if (scanResult.device.id.id == address) {
        found = true;
        connect(scanResult.device);
      }
    }, onError: (error) {
      print("$TAG | $error");
      scanning = false;
      if (onFailConnection != null) onFailConnection();
    }, onDone: () {
      scanning = false;
      if (!found) if (onFailConnection != null) onFailConnection();
    });
  }

  _discoverServices(BluetoothDevice device) async {
    services = await device.discoverServices();
    services.forEach((service) {
      print("$TAG | UUID - ${service.uuid}");
      print("$TAG | DeviceIdentifier - ${service.deviceId.id}");
      print("$TAG | Primary - ${service.isPrimary}");
      print("$TAG | Characteristics");
      service.characteristics.forEach((characteristic) {
        print("$TAG |     ${characteristic.uuid}");
        print("$TAG |     ${characteristic.uuid}");
        print("$TAG |     ${characteristic.uuid}");
      });

      print("IncludedServices - ${service.includedServices.toString()}");
    });

    _getCharacteristics();
  }

  _getCharacteristics() {
    for (BluetoothService service in services) {
      if (service.uuid == UUID_SERVICE) {
        gattService = service;
        //SEARCHING FOR TX/RX CHARACTERISTIC
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid == UUID_CHARACTERIST_RX) {
            characteristicTransparentUARTRX = characteristic;
            device.setNotifyValue(characteristic, true);
            //RECEPÇÃO DO BLUETOOTH
            device.onValueChanged(characteristic).listen((value) {
              String data = String.fromCharCodes(value);
              print("$TAG | $data");
              if (onDataReceived != null) onDataReceived(data);
            });
          } else if (characteristic.uuid == UUID_CHARACTERIST_TX) {
            characteristicTransparentUARTTX = characteristic;
          }
        }

        if (characteristicTransparentUARTRX == null &&
            characteristicTransparentUARTTX == null) {
          print("$TAG | No TX|RX characteristics found.");
          if (onFailConnection != null) onFailConnection();
        }

        //CONECTED
        connectionState = STATE_CONNECTED;
        if (onConnected != null) onConnected();
      }
    }
  }

  @override
  disconnect() {
    bluetoothStreamConnection.cancel();
//    MethodChannel('$NAMESPACE/methods')
//        .invokeMethod('disconnect', device.id.toString());
  }

  @override
  bool isConnected() {
    return connectionState == STATE_CONNECTED;
  }

  @override
  reset() {}

  @override
  transmitData(String data) {
    if (device != null)
      device.writeCharacteristic(characteristicTransparentUARTTX,
          (data.replaceAll("\r\n", "") + "\r\n").codeUnits);
  }
}
