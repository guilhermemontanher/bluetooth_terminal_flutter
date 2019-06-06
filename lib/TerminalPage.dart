import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'bluetooth/BLEEsp32.dart';
import 'model/Command.dart';

class TerminalPage extends StatefulWidget {
  final BLEEsp32 bluetoothManager;

  const TerminalPage(this.bluetoothManager);

  @override
  _TerminalPageState createState() => _TerminalPageState(bluetoothManager);
}

class _TerminalPageState extends State<TerminalPage> {
  StringBuffer bufferBT = StringBuffer();

  List<Command> listTerminal = List<Command>();

  final BLEEsp32 bluetoothManager;

  ScrollController _scrollController = new ScrollController();
  TextEditingController _controllerSend = TextEditingController();

  _TerminalPageState(this.bluetoothManager) {
    bluetoothManager.onDataReceived = (data) {
      bufferBT.write(data);

      if (data.contains("\r\n")) {
        setState(() {
          listTerminal.add(Command(bufferBT.toString(), CommandType.Receive));
        });
        _scrollToBottom();
      }
    };

    bluetoothManager.onLostConnection = (){
      Fluttertoast.showToast(
          msg: "Lost Connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
      _closeTerminal();
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${bluetoothManager.device.name} - ${bluetoothManager.device.id.id}"),
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

    bluetoothManager
        .transmitData(_controllerSend.text.replaceAll("\r\n", "") + "\r\n");

    setState(() {
      listTerminal.add(Command(
          _controllerSend.text.replaceAll("\r\n", "") + "\r\n",
          CommandType.Send));
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
                mainAxisAlignment: listTerminal[index].type == CommandType.Send
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 250,
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

  _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 80,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 100),
    );
  }

  bool pop(BuildContext context) => Navigator.pop(context);

  _closeTerminal(){
    pop(context);
  }
}
