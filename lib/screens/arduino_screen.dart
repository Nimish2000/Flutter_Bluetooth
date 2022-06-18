import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class arduinoScreen extends StatefulWidget {
  final BluetoothDevice? device;
  arduinoScreen({this.device});

  @override
  State<arduinoScreen> createState() => _arduinoScreenState();
}

class _arduinoScreenState extends State<arduinoScreen> {
  bool isConnecting = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  BluetoothConnection? connection;
  bool get isConnected => connection != null && connection!.isConnected;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BluetoothConnection.toAddress(widget.device!.address).then((_connection) {
      print('Connected to the device');
      show("Connected to " + widget.device!.name.toString());
      connection = _connection;
      setState(() {
        isConnecting = false;
      });
      connection!.input!.listen(null).onDone(() {
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      setState(() {
        isConnecting = false;
      });
      print('Cannot connect, exception occured');
    });
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState!.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }

  Widget ledButtons({required String? name, required bool status}) {
    return Row(
      children: [
        Text(
          name.toString(),
        ),
        Switch(
          value: status,
          onChanged: (val) {
            print(val);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "LED Controller",
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ledButtons(name: "LED 1 :", status: true),
          Switch(value: isConnecting, onChanged: (_){
            setState(() {
              isConnecting=!isConnecting;
            });
          })
        ],
      )),
    );
  }
}
