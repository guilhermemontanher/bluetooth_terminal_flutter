import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class TerminalPage extends StatefulWidget {
  final BluetoothDevice device;
  final List<BluetoothService> services;

  const TerminalPage(this.device, this.services);

  @override
  _MyHomePageState createState() => _MyHomePageState(device, services);
}

class _MyHomePageState extends State<TerminalPage> {
  static Guid UUID_SERVICE = Guid("0000ABF0-0000-1000-8000-00805F9B34FB");
  static Guid UUID_CHARACTERIST_RX = Guid("0000ABF2-0000-1000-8000-00805F9B34FB");
  static Guid UUID_CHARACTERIST_TX = Guid("0000ABF1-0000-1000-8000-00805F9B34FB");
  static Guid UUID_CCC = Guid("00002902-0000-1000-8000-00805F9B34FB");

  BluetoothService gattService;

  List<String> listTerminal = List<String>();

  final BluetoothDevice device;
  final List<BluetoothService> services;
  BluetoothCharacteristic characteristicTransparentUARTTX;
  BluetoothCharacteristic characteristicTransparentUARTRX;

  ScrollController _scrollController = new ScrollController();
  TextEditingController _controllerSend = TextEditingController();



  _MyHomePageState(this.device, this.services){
    _getCharacteristics();
    FlutterBlue.instance.onStateChanged().listen((state) {
      switch(state){
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
    _onDataReceived();
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
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(50))),
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
    device.writeCharacteristic(services[2].characteristics[0], (_controllerSend.text + "\r\n").codeUnits);

    setState(() {
      listTerminal.add(_controllerSend.text);
      _controllerSend.text = "";
      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 100),
      );
    });
  }

  Widget _getListView() {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32),
      child: ListView.builder(
        controller: _scrollController ,
        reverse: true,
        itemCount: listTerminal.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return InkWell(
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            listTerminal[index],
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Text("- - -"),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _onDataReceived() {
    device.readCharacteristic(services[2].characteristics[1]).then((dataReceived){
      print(String.fromCharCodes(dataReceived));
      _onDataReceived();
    });
  }

  void _getCharacteristics() {
    for(BluetoothService service in services){
      if(service.uuid == UUID_SERVICE){
        gattService = service;
        for(BluetoothCharacteristic characteristic in service.characteristics){
          if(characteristic.uuid == UUID_CHARACTERIST_RX){
            characteristicTransparentUARTRX = characteristic;
            device.setNotifyValue(characteristic, true);
            device.onValueChanged(characteristic).listen((value){
              print(String.fromCharCodes(value));
              setState(() {

                listTerminal.add(String.fromCharCodes(value));
              });
            });

//            BluetoothDescriptor descriptor;
//            for(BluetoothDescriptor descrip in characteristic.descriptors){
//              if(descriptor.uuid == descrip.uuid){
//                descrip.value = BluetoothDescriptor.
//              }
//            }


          } else if (characteristic.uuid == UUID_CHARACTERIST_TX){
            characteristicTransparentUARTTX = characteristic;
          }
        }

      }
    }

  }
}
