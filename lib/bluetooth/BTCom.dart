import 'package:flutter_blue/flutter_blue.dart';

abstract class BTComService {
  static final String TAG_CONNECTED = "c onnected",
      TAG_CONNECTING = "connecting",
      TAG_DISCONNECTED = "disconnected",
      TAG_FAIL_CONNECTION = "fail_connection",
      TAG_LOST_CONNECTION = "lost_connection",
      TAG_A_PRINT_TEXT = "print";

  bool isNotFound = false;

  OnConnectedListener onConnectedListener;
  OnConnectingListener onConnectingListener;
  OnDisconnectedListener onDisconnectedListener;
  OnLostConnectionListener onLostConnectionListener;
  OnFailConnectionListener onFailConnectionListener;
  OnDataTransmitedListener onDataTransmitedListener;
  OnDataReceived onDataReceived;
  OnReadRSSIListener onReadRSSIListener;
  bool _disconnect = false;

  void connect(BluetoothDevice device);
  void transmitData(String data);
  void disconnect();
  bool isConnected();
  void reset();

  List<int> hexStringToByteArray(String s){
//    var len = s. length;
//
//    List<int> data = List<int>();
//
//    for(int i = 0; i < len; i+=2){
//      data[i/2 as int] =
//    }
//
//    return data;
  }

}

abstract class OnConnectedListener {
  void onConnected();
}

class OnConnectingListener {
  void onConnecting(){}
}

abstract class OnDisconnectedListener {
  void onDisconnected();
}

abstract class OnLostConnectionListener {
  void onLostConnection();
}

abstract class OnFailConnectionListener {
  void onFailConnection();
}

abstract class OnReadRSSIListener {
  void onReadRSSI(String rssi);
}

abstract class OnDataReceived {
  void onDataReceived(String data);
}

abstract class OnDataTransmitedListener {
  void onDataTransmitedSucess();

  void onDataTransmitedError();
}
