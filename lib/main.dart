import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'TerminalPage.dart';
import 'bluetooth/BLEEsp32.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        accentColor: Colors.blueAccent,
        accentColorBrightness: Brightness.light,
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

  var _scanning = false;
  var _connecting = false;
  var _msgStatus = "";

  BLEEsp32 bluetoothManager = BLEEsp32();

  @override
  void initState() {
    _scanBLEDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _scanBLEDevices,
          ),
        ],
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
        if (scanResult.advertisementData.connectable) devices.add(scanResult);
      }

      devices.sort((a, b) => b.rssi.compareTo(a.rssi));

      setState(() {
        _scanning = true;
      });
    }, onDone: () {
      setState(() {
        _scanning = false;
      });
    });
  }

  _listDeviceBluetooth() {
    return Column(
      children: <Widget>[
        Opacity(
          opacity: _scanning ? 1.0 : 0.0,
          child: LinearProgressIndicator(),
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
    return ListView.separated(
      itemCount: devices.length,
      separatorBuilder: (context, index) => Divider(
            color: Colors.black87,
          ),
      itemBuilder: (BuildContext ctxt, int index) {
        return InkWell(
          onTap: () => _connectBLE(devices[index].device),
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
        );
      },
    );
  }

  _connectBLE(BluetoothDevice device) {
    try {
      bluetoothManager.onConnected = () {
        print("Connectado a ${device.name}");
        setState(() {
          _msgStatus = "Conectado à ${device.name}";
        });
        _discoverServices(device);
      };

      bluetoothManager.onConnecting = () {
        setState(() {
          _connecting = true;
          _msgStatus = "Conectando...";
        });
      };
      bluetoothManager.onFailConnection = () {
        setState(() {
          _connecting = false;
        });
      };

      //bluetoothManager.connect(device);
      bluetoothManager.connectByAddress(device.id.id);
    } catch (error) {
      print("ERRO: " + error.toString());
      setState(() {
        _connecting = false;
      });
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
      MaterialPageRoute(builder: (context) => TerminalPage(bluetoothManager)),
    );

    setState(() {
      _connecting = false;
    });
  }
}
