import 'package:flutter_blue/flutter_blue.dart';

abstract class BTCom {
  static final String TAG_CONNECTED = "c onnected",
      TAG_CONNECTING = "connecting",
      TAG_DISCONNECTED = "disconnected",
      TAG_FAIL_CONNECTION = "fail_connection",
      TAG_LOST_CONNECTION = "lost_connection",
      TAG_A_PRINT_TEXT = "print";

  bool isNotFound = false;

  OnConnected onConnected;
  OnConnecting onConnecting;
  OnDisconnected onDisconnected;
  OnLostConnection onLostConnection;
  OnFailConnection onFailConnection;
  OnDataReceived onDataReceived;
  OnReadRSSI onReadRSSI;
  OnDataTransmited onDataTransmited;

  bool _disconnect = false;
  bool scanning = false;

  void connect(BluetoothDevice device);

  void connectByAddress(String address);

  void transmitData(String data);

  void disconnect();

  bool isConnected();
}

typedef OnConnected = void Function();
typedef OnConnecting = void Function();
typedef OnDisconnected = void Function();
typedef OnLostConnection = void Function();
typedef OnFailConnection = void Function();
typedef OnReadRSSI = void Function(String rssi);
typedef OnDataReceived = void Function(String data);
typedef OnDataTransmited = void Function(bool success);
