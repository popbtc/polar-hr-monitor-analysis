import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_google_cast/flutter_google_cast.dart';

import '../../core/app_export.dart';
import './widgets/device_card_widget.dart';
import './widgets/connection_status_widget.dart';
import './widgets/device_context_menu_widget.dart';
import './widgets/empty_state_widget.dart';
import '../wireless_display_screen/wireless_display_screen.dart';



class DeviceDashboard extends StatefulWidget {
  const DeviceDashboard({Key? key}) : super(key: key);

  @override
  State<DeviceDashboard> createState() => _DeviceDashboardState();
}

class _DeviceDashboardState extends State<DeviceDashboard>
    with TickerProviderStateMixin {
  final _ble = FlutterReactiveBle();
  late TabController _tabController;

  bool _isRefreshing = false;
  bool _isScanning = false;
  String? _selectedDeviceId;
  bool _showContextMenu = false;

  final List<Map<String, dynamic>> _connectedDevices = <Map<String, dynamic>>[];
  final _hrServiceUuid = Uuid.parse("0000180D-0000-1000-8000-00805F9B34FB");
  final _hrCharUuid = Uuid.parse("00002A37-0000-1000-8000-00805F9B34FB");

  final Map<String, StreamSubscription<ConnectionStateUpdate>> _connSubs = {};
  final Map<String, StreamSubscription<List<int>>> _hrSubs = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _restoreAndReconnectDevices();
  }

  Future<void> _restoreAndReconnectDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('connected_devices');
    if (saved == null) {
      debugPrint("⚠️ No saved devices found.");
      return;
    }

    final List<dynamic> list = jsonDecode(saved);
    setState(() {
      _connectedDevices.clear();
      _connectedDevices.addAll(List<Map<String, dynamic>>.from(list));
    });

    debugPrint("📦 Loaded ${_connectedDevices.length} devices from storage");
    debugPrint("🔄 Attempting auto-reconnect...");

    for (final dev in _connectedDevices) {
      final id = dev['id'] as String;
      final name = dev['name'] as String;

      // 🩵 Reset HR ก่อนเริ่ม reconnect เพื่อให้ UI แสดง "รอข้อมูล"
      _updateDevice(id, {
        "heartRate": null,
        "isConnected": false,
        "lastUpdate": "waiting..."
      });

      debugPrint("🧭 Found known device: $name ($id)");
      _connectDevice(id, name, forceReconnect: true);
    }
  }



  @override
  void dispose() {
    for (var sub in _connSubs.values) {
      sub.cancel();
    }
    for (var sub in _hrSubs.values) {
      sub.cancel();
    }
    _tabController.dispose();
    super.dispose();
  }

  // 🩵 เพิ่มอุปกรณ์ใหม่
  Future<void> _addNewDevice() async {
    final result = await Navigator.pushNamed(context, '/device_pairing');
    if (result is Map<String, dynamic>) {
      final id = result['id'] as String;
      final name = result['name'] as String;
      _connectDevice(id, name);
      _saveDevices();
    }
  }
  void _handleWirelessDisplay() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WirelessDisplayScreen(),
      ),
    );
  }



  void _connectDevice(String id, String name, {bool forceReconnect = false}) {
    // ถ้าไม่ force และมีอยู่แล้ว → ข้าม
    if (!forceReconnect && _connSubs.containsKey(id)) {
      debugPrint("⚠️ Connection already exists for $name ($id)");
      return;
    }

    // ✅ ถ้า restore กลับมา จะไม่ข้ามบล็อกนี้
    if (!forceReconnect && _connectedDevices.any((d) => d['id'] == id)) {
      return;
    }

    // เพิ่มเข้า list ถ้ายังไม่มี
    if (!_connectedDevices.any((d) => d['id'] == id)) {
      final device = {
        "id": id,
        "name": name,
        "heartRate": 0,
        "isConnected": false,
        "batteryLevel": 100,
        "deviceType": "Polar",
        "lastUpdate": "—",
      };
      setState(() => _connectedDevices.add(device));
      _saveDevices();
    }

    final connSub = _ble.connectToDevice(id: id).listen((update) async {
      debugPrint("📡 $name connection: ${update.connectionState}");
      if (update.connectionState == DeviceConnectionState.connected) {
        _updateDevice(id, {"isConnected": true});
        await _subscribeHR(id);
      } else if (update.connectionState == DeviceConnectionState.disconnected) {
        _updateDevice(id, {"isConnected": false, "heartRate": 0});
        _reconnectDevice(id, name);
      }
    });

    _connSubs[id] = connSub;
  }


  // 🔁 Reconnect อัตโนมัติเมื่อหลุด
  void _reconnectDevice(String id, String name) async {
    Future.delayed(const Duration(seconds: 5), () async {
      final devIndex = _connectedDevices.indexWhere((d) => d['id'] == id);
      if (devIndex == -1) return;

      final dev = _connectedDevices[devIndex];
      final isConnected = dev['isConnected'] as bool;

      if (!isConnected) {
        debugPrint("🔁 Reconnecting to $name ($id)...");

        try {
          await _connSubs[id]?.cancel();
          _connSubs.remove(id);
          await _hrSubs[id]?.cancel();
          _hrSubs.remove(id);
        } catch (e) {
          debugPrint("⚠️ Cleanup before reconnect: $e");
        }

        _ble.deinitialize();
        await Future.delayed(const Duration(milliseconds: 200));
        final newBle = FlutterReactiveBle();
        debugPrint("🆕 BLE reinitialized for $name ($id)");

        _connSubs[id] = newBle
            .connectToDevice(id: id, connectionTimeout: const Duration(seconds: 8))
            .listen((update) async {
          debugPrint("📡 $name connection: ${update.connectionState}");
          if (update.connectionState == DeviceConnectionState.connected) {
            _updateDevice(id, {"isConnected": true});
            await _subscribeHRWithInstance(newBle, id);
          } else if (update.connectionState ==
              DeviceConnectionState.disconnected) {
            _updateDevice(id, {"isConnected": false, "heartRate": 0});
            _reconnectDevice(id, name);
          }
        }, onError: (e) {
          debugPrint("❌ Reconnect error for $name: $e");
          _reconnectDevice(id, name);
        });
      }
    });
  }

  // ❤️ Subscribe HR
  Future<void> _subscribeHR(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final hrStream = _ble.subscribeToCharacteristic(
        QualifiedCharacteristic(
          serviceId: _hrServiceUuid,
          characteristicId: _hrCharUuid,
          deviceId: id,
        ),
      );

      _hrSubs[id]?.cancel();
      _hrSubs[id] = hrStream.listen(
            (data) {
          if (data.isNotEmpty) {
            final hr = data[1];
            _updateDevice(id, {
              "heartRate": hr,
              "lastUpdate": "${DateTime.now().second % 10}s ago"
            });
            debugPrint("💓 HR for $id = $hr bpm");
          }
        },
        onError: (e) async {
          debugPrint("⚠️ HR stream error for $id: $e → resubscribing...");
          await Future.delayed(const Duration(seconds: 2));
          _subscribeHR(id);
        },
        onDone: () async {
          debugPrint("⚠️ HR stream closed for $id → resubscribing...");
          await Future.delayed(const Duration(seconds: 2));
          _subscribeHR(id);
        },
      );
    } catch (e) {
      debugPrint("⚠️ HR subscribe error: $e");
    }
  }

  Future<void> _subscribeHRWithInstance(
      FlutterReactiveBle instance, String id) async {
    try {
      await _hrSubs[id]?.cancel();
      await Future.delayed(const Duration(seconds: 1));

      final char = QualifiedCharacteristic(
        serviceId: _hrServiceUuid,
        characteristicId: _hrCharUuid,
        deviceId: id,
      );

      _hrSubs[id] = instance.subscribeToCharacteristic(char).listen(
            (data) {
          if (data.isNotEmpty) {
            final hr = data[1];
            _updateDevice(id, {
              "heartRate": hr,
              "lastUpdate": "${DateTime.now().second % 10}s ago"
            });
            debugPrint("💓 HR update ($id) = $hr");
          }
        },
        onError: (e) async {
          debugPrint("⚠️ HR stream error (reconnect) for $id: $e → re-subscribing...");
          await Future.delayed(const Duration(seconds: 2));
          _subscribeHRWithInstance(instance, id);
        },
        onDone: () async {
          debugPrint("⚠️ HR stream closed (reconnect) for $id → re-subscribing...");
          await Future.delayed(const Duration(seconds: 2));
          _subscribeHRWithInstance(instance, id);
        },
      );

      debugPrint("✅ HR re-subscribed after reconnect for $id");
    } catch (e) {
      debugPrint("⚠️ SubscribeHRWithInstance error: $e");
    }
  }

  // 💾 Save devices
  Future<void> _saveDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = jsonEncode(_connectedDevices);
    await prefs.setString('connected_devices', jsonList);
    debugPrint("💾 Saved devices: ${_connectedDevices.length}");
  }


  // 📦 Load devices from local storage
  Future<void> _loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('connected_devices');
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      setState(() {
        _connectedDevices.clear();
        _connectedDevices.addAll(decoded.map((e) {
          final d = Map<String, dynamic>.from(e);
          d["heartRate"] = 0;
          d["isConnected"] = false;
          return d;
        }));
      });
      debugPrint("📦 Loaded ${_connectedDevices.length} devices from storage");
    }
  }

  Future<void> _restoreConnections() async {
    debugPrint("🔄 Restoring previous BLE connections...");
    await Future.delayed(const Duration(seconds: 1));

    // 🔍 เริ่มสแกนหาอุปกรณ์รอบตัว
    final seen = <String>{};
    final scanSub = _ble.scanForDevices(withServices: []).listen((device) {
      final id = device.id;
      if (seen.contains(id)) return; // กันซ้ำ
      seen.add(id);

      // ตรวจว่ามีอยู่ใน list เดิมไหม
      final match = _connectedDevices.firstWhere(
            (d) => d['id'] == id,
        orElse: () => {},
      );

      if (match.isNotEmpty) {
        final name = match['name'];
        debugPrint("🧭 Found previously known device nearby: $name ($id)");
        _connectDevice(id, name);
      }
    });

    // 🔚 หยุดสแกนหลัง 10 วินาที
    await Future.delayed(const Duration(seconds: 10));
    await scanSub.cancel();
    debugPrint("🛑 BLE restore scan finished");
  }


  void _updateDevice(String id, Map<String, dynamic> updates) {
    final index = _connectedDevices.indexWhere((d) => d['id'] == id);
    if (index != -1) {
      if (!mounted) return;
      setState(() {
        final updated = Map<String, dynamic>.from(_connectedDevices[index]);
        updated.addAll(updates);
        _connectedDevices[index] = updated;
      });
      _saveDevices();
    }
  }
// 🗑 ลบอุปกรณ์ออกจากรายการ
  Future<void> _handleRemoveDevice(String id) async {
    debugPrint("🗑 Removing device $id ...");

    try {
      await _connSubs[id]?.cancel();
      _connSubs.remove(id);
      await _hrSubs[id]?.cancel();
      _hrSubs.remove(id);
    } catch (e) {
      debugPrint("⚠️ Error removing BLE subs: $e");
    }

    setState(() {
      _connectedDevices.removeWhere((d) => d['id'] == id);
    });

    await _saveDevices();
    debugPrint("✅ Device $id removed successfully.");

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device removed')),
      );
    }
  }

  int get _connectedDevicesCount =>
      _connectedDevices.where((d) => d['isConnected'] as bool).length;

  // 🧭 UI SECTION
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    children: [
                      // Connection summary
                      Expanded(
                        child: ConnectionStatusWidget(
                          connectedDevices: _connectedDevicesCount,
                          totalDevices: _connectedDevices.length,
                          isScanning: _isScanning,
                        ),
                      ),

                      SizedBox(width: 3.w),

                      // 🟢 ปุ่ม Wireless Display (Cast)
                      GestureDetector(
                        onTap: _handleWirelessDisplay,
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.shadowColor,
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: CustomIconWidget(
                            iconName: 'cast',
                            color: _connectedDevicesCount > 0
                                ? AppTheme.accentHighlight
                                : AppTheme.inactiveDevice,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Dashboard'),
                      Tab(text: 'Devices'),
                      Tab(text: 'Settings'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDashboardTab(),
                      _buildDevicesTab(),
                      _buildSettingsTab(),
                    ],
                  ),
                ),
              ],
            ),

            // ✅ ย้าย if มาตรงนี้!
            if (_showContextMenu && _selectedDeviceId != null)
              DeviceContextMenuWidget(
                deviceName: _connectedDevices.firstWhere(
                        (d) => d['id'] == _selectedDeviceId)['name'] as String,
                onRename: () async {
                  final id = _selectedDeviceId!;
                  final currentName = _connectedDevices.firstWhere((d) => d['id'] == id)['name'];
                  final controller = TextEditingController(text: currentName);

                  final newName = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Rename Device'),
                        content: StatefulBuilder(
                          builder: (context, setState) {
                            return TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'New device name',
                                border: OutlineInputBorder(),
                              ),
                              autofocus: true,
                              onTap: () {
                                // 🔹 select ชื่อทั้งหมดทันทีเมื่อโฟกัส
                                controller.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: controller.text.length,
                                );
                              },
                            );
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, controller.text.trim()),
                            child: const Text('Save'),
                          ),
                        ],
                      );
                    },
                  );

                  if (newName == null || newName.isEmpty) {
                    setState(() => _showContextMenu = false);
                    return;
                  }

                  if (newName == currentName) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name unchanged')),
                    );
                    setState(() => _showContextMenu = false);
                    return;
                  }

                  final isDuplicate = _connectedDevices.any((d) =>
                  d['id'] != id &&
                      (d['name'] as String).toLowerCase() == newName.toLowerCase());

                  if (isDuplicate) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Name "$newName" is already used by another device.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    setState(() => _showContextMenu = false);
                    return;
                  }

                  _updateDevice(id, {"name": newName});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Renamed to "$newName"')),
                  );

                  setState(() => _showContextMenu = false);
                },

                onRemove: () async {
                  final id = _selectedDeviceId!;
                  final name = _connectedDevices.firstWhere((d) => d['id'] == id)['name'];
                  setState(() => _showContextMenu = false);

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Remove Device'),
                      content: Text('Are you sure you want to remove "$name"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Remove',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await _handleRemoveDevice(id);
                  }
                },

                onViewHistory: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('History not implemented yet')),
                  );
                },
                onDismiss: () => setState(() => _showContextMenu = false),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewDevice,
        icon: const Icon(Icons.add),
        label: const Text("Add Device"),
      ),
    );
  }

  Widget _buildDashboardTab() {
    if (_connectedDevices.isEmpty) {
      return EmptyStateWidget(onAddDevice: _addNewDevice);
    }

    return RefreshIndicator(
      onRefresh: () async {},
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(4.w),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 2.w,
                mainAxisSpacing: 2.h,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final device = _connectedDevices[index];
                  return DeviceCardWidget(
                    deviceData: device,
                    onLongPress: () {
                      setState(() {
                        _selectedDeviceId = device['id'];
                        _showContextMenu = true;
                      });
                    },
                    onTap: () {},
                  );
                },
                childCount: _connectedDevices.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesTab() =>
      const Center(child: Text("Device management"));
  Widget _buildSettingsTab() =>
      const Center(child: Text("Settings coming soon"));
}
