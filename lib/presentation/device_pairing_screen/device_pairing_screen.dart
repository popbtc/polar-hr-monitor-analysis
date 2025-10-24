import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart'; // ✅ เพิ่มบรรทัดนี้
import 'package:sizer/sizer.dart';
import '../../core/permissions.dart';


class DevicePairingScreen extends StatefulWidget {
  const DevicePairingScreen({Key? key}) : super(key: key);

  @override
  State<DevicePairingScreen> createState() => _DevicePairingScreenState();
}

class _DevicePairingScreenState extends State<DevicePairingScreen>
    with WidgetsBindingObserver {
  final _ble = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? _scanSub;

  List<DiscoveredDevice> _devices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPermissionsAndScan();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopScan();
    super.dispose();
  }

  // ✅ ตรวจสอบอีกครั้งเมื่อผู้ใช้กลับมาจาก Settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recheckPermissionsAndScan();
    }
  }

  Future<void> _initPermissionsAndScan() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final hasBluetooth = await Permissions.requestBluetooth();
    final hasLocation = await Permissions.requestLocation(context);

    if (!hasBluetooth || !hasLocation) return;

    await Future.delayed(const Duration(milliseconds: 300));
    _startScan();
  }

  Future<void> _recheckPermissionsAndScan() async {
    final locationOk = await Permission.locationWhenInUse.isGranted;
    final nearbyOk = await Permission.bluetoothScan.isGranted;

    if (locationOk && nearbyOk && !_isScanning) {
      _startScan();
    }
  }

  void _startScan() {
    _devices.clear();
    _scanSub?.cancel();

    setState(() => _isScanning = true);

    _scanSub = _ble
        .scanForDevices(withServices: [], scanMode: ScanMode.lowLatency)
        .listen((device) {
      if (device.name.isNotEmpty &&
          !_devices.any((d) => d.id == device.id)) {
        setState(() => _devices.add(device));
      }
    }, onError: (e) {
      debugPrint("❌ Scan error: $e");
      setState(() => _isScanning = false);
    });
  }

  void _stopScan() {
    _scanSub?.cancel();
    _scanSub = null;
    setState(() => _isScanning = false);
  }

  void _selectDevice(DiscoveredDevice device) {
    _stopScan();
    Navigator.pop(context, {'id': device.id, 'name': device.name});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Polar Device'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
            onPressed: _isScanning ? _stopScan : _startScan,
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(3.w),
        child: _isScanning && _devices.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _devices.isEmpty
            ? const Center(
          child: Text(
            "No devices found.\nMake sure Polar is on and nearby.",
            textAlign: TextAlign.center,
          ),
        )
            : ListView.builder(
          itemCount: _devices.length,
          itemBuilder: (context, index) {
            final d = _devices[index];
            return Card(
              child: ListTile(
                leading:
                const Icon(Icons.watch, color: Colors.blue),
                title: Text(d.name.isEmpty ? "Unknown" : d.name),
                subtitle: Text(d.id),
                onTap: () => _selectDevice(d),
              ),
            );
          },
        ),
      ),
    );
  }
}
