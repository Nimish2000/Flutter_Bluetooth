import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dashboard_screen.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key? key}) : super(key: key);

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  List<BluetoothDevice> _devicesList = [];
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    enableBluetooth();
    getPairedDevices();
  }

  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return;
    } else {
      await getPairedDevices();
    }
    return;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text("Paired Devices"),
      ),
      body: ListView.builder(
          itemCount: _devicesList.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                onTap: () {
                  //Here we will navigate to the dashboard screen with the device value
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => DashboardScreen(
                            device: _devicesList[index],
                          )));
                  print("Button is pressed index : $index");
                },
                leading: Icon(Icons.indeterminate_check_box_rounded),
                subtitle: _devicesList[index].isConnected
                    ? Text("Connected")
                    : Text("Tap to connect"),
                title: Text(_devicesList[index].name.toString()),
                trailing: Icon(Icons.bluetooth),
              ),
            );
          }),
    );
  }
}
