import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'model/Command.dart';

class TerminalPage extends StatefulWidget {
  final BluetoothDevice device;
  final List<BluetoothService> services;

  const TerminalPage(this.device, this.services);

  @override
  _MyHomePageState createState() => _MyHomePageState(device, services);
}

class _MyHomePageState extends State<TerminalPage> {
  static Guid UUID_SERVICE = Guid("0000ABF0-0000-1000-8000-00805F9B34FB");
  static Guid UUID_CHARACTERIST_RX =
      Guid("0000ABF2-0000-1000-8000-00805F9B34FB");
  static Guid UUID_CHARACTERIST_TX =
      Guid("0000ABF1-0000-1000-8000-00805F9B34FB");
  static Guid UUID_CCC = Guid("00002902-0000-1000-8000-00805F9B34FB");

  List<int> bufferBT = List<int>();

  BluetoothService gattService;

  List<Command> listTerminal = List<Command>();

  final BluetoothDevice device;
  final List<BluetoothService> services;
  BluetoothCharacteristic characteristicTransparentUARTTX;
  BluetoothCharacteristic characteristicTransparentUARTRX;

  ScrollController _scrollController = new ScrollController();
  TextEditingController _controllerSend = TextEditingController();

  _MyHomePageState(this.device, this.services) {
    _getCharacteristics();
    FlutterBlue.instance.onStateChanged().listen((state) {
      switch (state) {
        case BluetoothState.off:
          print("Bluetooth OFF");
          break;
        case BluetoothState.unknown:
          print("Bluetooth unknown");
          break;
        case BluetoothState.unavailable:
          print("Bluetooth unavailable");
          break;
        case BluetoothState.unauthorized:
          print("Bluetooth unauthorized");
          break;
        case BluetoothState.turningOn:
          print("Bluetooth turningOn");
          break;
        case BluetoothState.on:
          print("Bluetooth on");
          break;
        case BluetoothState.turningOff:
          print("Bluetooth turningOff");
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${device.name} - ${device.id.id}"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _getListView(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 75, bottom: 14),
            child: TextField(
              controller: _controllerSend,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50))),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _sendCommandBt,
        tooltip: 'Send',
        child: Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _sendCommandBt() {
    bufferBT.clear();
    device.writeCharacteristic(characteristicTransparentUARTTX,
        (_controllerSend.text.replaceAll("\r\n", "") + "\r\n").codeUnits);

    setState(() {
      listTerminal
          .add(Command(_controllerSend.text.replaceAll("\r\n", "") + "\r\n", CommandType.Send));
      _controllerSend.text = "";
    });

    _scrollToBottom();
  }

  Widget _getListView() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: listTerminal.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return InkWell(
            onTap: () {
              String text = listTerminal[index].command;
              _controllerSend.text = text;
            },
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Row(
                children: <Widget>[
                  _spaceBefore(index),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text(
                      listTerminal[index].command.replaceAll("\r\n", ""),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _getCharacteristics() {
    for (BluetoothService service in services) {
      if (service.uuid == UUID_SERVICE) {
        gattService = service;
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid == UUID_CHARACTERIST_RX) {
            characteristicTransparentUARTRX = characteristic;
            device.setNotifyValue(characteristic, true);
            device.onValueChanged(characteristic).listen((value) {
              String dataStr = String.fromCharCodes(value);
              print(dataStr);
              for(int x in value){
                bufferBT.add(x);
              }

              if (dataStr.contains("\r\n")) {
                setState(() {
                  listTerminal.add(Command(
                      String.fromCharCodes(bufferBT), CommandType.Receive));
                });
                _scrollToBottom();
              }
            });
          } else if (characteristic.uuid == UUID_CHARACTERIST_TX) {
            characteristicTransparentUARTTX = characteristic;
          }
        }
      }
    }
  }

  _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 100),
    );
  }

  _spaceBefore(int index) {
    if(listTerminal[index].type == CommandType.Send){
      return Expanded(child: Container(),);
    } else {
      return Container();
    }
  }
}
