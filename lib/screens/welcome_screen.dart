import "package:flutter/material.dart";
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:demoapp/main.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

class welcomeScreen extends StatefulWidget {
  final BluetoothDevice? device;
  welcomeScreen({
    required this.device,
  });

  @override
  State<welcomeScreen> createState() => _welcomeScreenState();
}

class _welcomeScreenState extends State<welcomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isBrightMode = true;
  BluetoothConnection? connection;
  bool get isConnected => connection != null && connection!.isConnected;
  bool isConnecting = true;

  @override
  void initState() {
    super.initState();
    print(widget.device!.name);
    print(widget.device!.address);
    BluetoothConnection.toAddress(widget.device!.address).then((_connection) {
      print('Connected to the device');
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

  void _connect() async {
    setState(() {
      isConnecting = true;
    });
    await BluetoothConnection.toAddress(widget.device!.address)
        .then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
      });
      show('Connected to ' + widget.device!.name.toString());
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
      show('Cannot Connect Try again');
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

  Widget squareBox({required Color c, required Widget I}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        height: 40.0,
        width: 40.0,
        color: c,
        child: I,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isBrightMode ? Colors.white : Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            isConnecting
                ? LinearProgressIndicator(
                    backgroundColor: Colors.yellow,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  )
                : Container(
                    height: 0.0,
                  ),
            Container(
              height: MediaQuery.of(context).size.height * 0.18,
              child: Padding(
                padding: EdgeInsets.only(
                  top: height * 0.12,
                  left: width * 0.1,
                  right: width * 0.1,
                  bottom: 1.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          squareBox(
                            c: Colors.red,
                            I: IconButton(
                              onPressed: () {
                                //Here we will do bluetooth settings
                                //Connect the bluetooth
                                _connect();
                                print("Blutooth Icon is pressed");
                              },
                              icon: Icon(
                                Icons.bluetooth,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: width * 0.03,
                          ),
                          squareBox(
                              c: isBrightMode ? Colors.black : Colors.white,
                              I: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isBrightMode = !isBrightMode;
                                  });
                                },
                                icon: Transform.scale(
                                  scaleX: -1,
                                  child: Icon(
                                    Icons.brightness_2,
                                    color: isBrightMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        //Here we will do open Setting stuff
                        FlutterBluetoothSerial.instance.openSettings();

                        print('Setting Icon button is pressed');
                      },
                      icon: Icon(
                        Icons.settings_sharp,
                        color: Colors.red,
                        size: 45.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 1.0,
              color: Colors.red,
            ),
            Container(
              height: height * 0.15,
              child: Center(
                child: Text(
                  "Company_Name",
                  style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: isBrightMode ? Colors.black : Colors.white),
                ),
              ),
            ),
            Divider(
              thickness: 1.0,
              color: Colors.red,
            ),
            SizedBox(
              height: height * 0.10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50.0, right: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  controllerWidget(
                      messageUp: '@1234#0001%', messageDown: '@1234#0010%'),
                  SizedBox(
                    width: 50.0,
                  ),
                  controllerWidget(
                      messageUp: '@1234#0100%', messageDown: '@1234#1000%'),
                ],
              ),
            ),
            SizedBox(
              height: height * 0.05,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50.0, right: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  bottomController(
                    icon: Icons.arrow_forward_ios,
                    isUp: true,
                  ),
                  SizedBox(
                    width: 50.0,
                  ),
                  bottomController(
                    icon: Icons.arrow_back_ios,
                    isUp: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget controllerWidget({String? messageUp, String? messageDown}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(
            color: isBrightMode ? Colors.black : Colors.white, width: 5.25),
      ),
      height: 180.0,
      width: 90.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(100.0),
            onTap: () {
              _sendMessageToBluetooth("@1234#0000%");
              print("Button is released");
            },
            onTapDown: (_) {
              _sendMessageToBluetooth(messageUp.toString());
              print("button pressed");
            },
            child: Transform.rotate(
              angle: 187.0,
              child: Icon(
                Icons.arrow_forward_ios,
                color: isBrightMode ? Colors.red : Colors.white,
                size: 55.0,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(100.0),
            onTap: () {
              _sendMessageToBluetooth("@1234#0000%");
              print("Button is released");
            },
            onTapDown: (_) {
              _sendMessageToBluetooth(messageDown.toString());
              print("button pressed");
            },
            child: Transform.rotate(
              angle: 45.56,
              child: Icon(
                Icons.arrow_forward_ios,
                color: isBrightMode ? Colors.red : Colors.white,
                size: 55.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomController({icon, required bool isUp}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
        border: Border.all(
            color: isBrightMode ? Colors.black : Colors.white, width: 5.25),
      ),
      height: 100.0,
      width: 90.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(100.0),
        onTapDown: (_) {
          if (isUp) {
            _sendMessageToBluetooth("@1234#0001%");
            _sendMessageToBluetooth("@1234#0010%");
            _sendMessageToBluetooth("@1234#0100%");
            _sendMessageToBluetooth("@1234#1000%");
          } else {
            _sendMessageToBluetooth("@1234#0000%");
            _sendMessageToBluetooth("@1234#0000%");
            _sendMessageToBluetooth("@1234#0000%");
            _sendMessageToBluetooth("@1234#0000%");
          }
        },
        child: Transform.rotate(
          angle: 187.0,
          child: Icon(
            icon,
            color: isBrightMode ? Colors.red : Colors.white,
            size: 50.0,
          ),
        ),
      ),
    );
  }

  void _sendMessageToBluetooth(String message) async {
    message = message.trim();
    connection!.output.add(utf8.encode(message + "\r\n") as Uint8List);
    await connection!.output.allSent;
  }
}
