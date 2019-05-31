
import 'BTCom.dart';

class BLEEsp32 implements BTComService{
  @override
  connectPeripheral(String address) {
    // TODO: implement connectPeripheral
    return null;
  }

  @override
  disconnect() {
    // TODO: implement disconnect
    return null;
  }

  @override
  List<int> hexStringToByteArray(String s) {
    // TODO: implement hexStringToByteArray
    return null;
  }

  @override
  bool isconnected() {
    // TODO: implement isconnected
    return null;
  }

  @override
  reset() {
    // TODO: implement reset
    return null;
  }

  @override
  transmitData(String data) {
    // TODO: implement transmitData
    return null;
  }

  @override
  bool isNotFound;

  @override
  OnConnectedListener onConnectedListener;

  @override
  OnConnectingListener onConnectingListener;

  @override
  OnDataReceived onDataReceived;

  @override
  OnDataTransmitedListener onDataTransmitedListener;

  @override
  OnDisconnectedListener onDisconnectedListener;

  @override
  OnFailConnectionListener onFailConnectionListener;

  @override
  OnLostConnectionListener onLostConnectionListener;

  @override
  OnReadRSSIListener onReadRSSIListener;

}