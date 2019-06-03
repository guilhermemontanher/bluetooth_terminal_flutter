import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'TerminalPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: MyHomePage(
        title: 'BLE Terminal Flutter',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ScanResult> devices = List<ScanResult>();
  var scanSubscription;

  var _connecting = false;
  var _msgStatus = "";

  @override
  void initState() {
    _scanBLEDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: !_connecting ? _listDeviceBluetooth() : _viewConnecting(),
    );
  }

  void _scanBLEDevices() {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    scanSubscription = flutterBlue
        .scan(scanMode: ScanMode.balanced, timeout: Duration(seconds: 10))
        .listen((scanResult) {
      bool achou = false;
      var i;
      for (i = 0; i < devices.length; i++) {
        if (devices[i].device.id.id == scanResult.device.id.id) {
          /* print("device: " +
              devices[i].device.name +
              ":" +
              devices[i].device.id.id);*/
          achou = true;
          break; // 83246F61-BB41-3E47-15BE-1B5184C7AFB8
        }
      }

      if (achou) {
        devices[i] = scanResult;
      } else {
        devices.add(scanResult);
      }

      devices.sort((a, b) => b.rssi.compareTo(a.rssi));

      setState(() {});
    });
  }

  _listDeviceBluetooth() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Selecione o dispositivo",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: getListView(),
        ),
      ],
    );
  }

  _viewConnecting() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
          Text(
            _msgStatus,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget getListView() {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32),
      child: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return InkWell(
            onTap: () => _connectBLE(devices[index].device),
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.bluetooth),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            devices[index].device.name != ""
                                ? devices[index].device.name
                                : "Unknown",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            devices[index].device.id.id,
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Text("RSSI ${devices[index].rssi}"),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _connectBLE(BluetoothDevice device) {
    print("**********************");
    setState(() {
      _connecting = true;
      _msgStatus = "Conectando...";
    });
    //scanSubscription.cancel();
    try {
      FlutterBlue.instance.connect(device).listen((s) {
        if (s == BluetoothDeviceState.connected) {
          print("Connectado a ${device.name}");
          setState(() {
            _msgStatus = "Conectado à ${device.name}";
          });
          _discoverServices(device);
        }

        print("Matheus:  $s");
      }, onDone: () {
        print("onDone");
      }, onError: (d) {
        print("onError " + d.toString());
      });
    } catch (error) {
      print("MATHEUS: ERRO: " + error.toString());
    }
  }

  _discoverServices(BluetoothDevice device) async {
    setState(() {
      _msgStatus = "Obtendo serviço...";
    });
    await Future.delayed(Duration(seconds: 1));

    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) {
      print("UUID - ${service.uuid}");
      print("DeviceIdentifier - ${service.deviceId.id}");
      print("Primary - ${service.isPrimary}");
      print("Characteristics");
      service.characteristics.forEach((characteristic) {
        print("    ${characteristic.uuid}");
        print("    ${characteristic.uuid}");
        print("    ${characteristic.uuid}");
      });

      print("IncludedServices - ${service.includedServices.toString()}");
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TerminalPage(device, services)),
    );

    setState(() {
      _connecting = false;
    });
  }
}
