import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/connection_history_widget.dart';
import './widgets/device_card_widget.dart';
import './widgets/empty_state_widget.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  bool _isMultiSelectMode = false;
  Set<String> _selectedDevices = {};
  String _expandedDeviceId = '';
  bool _isRefreshing = false;
  String _searchQuery = '';

  // Mock data for devices
  final List<Map<String, dynamic>> _mockDevices = [
    {
      "id": "device_001",
      "name": "Polar H10 - John",
      "status": "connected",
      "heartRate": 78,
      "battery": 85,
      "lastSeen": "Just now",
      "macAddress": "AA:BB:CC:DD:EE:01",
      "firmware": "v2.1.3",
      "connectionDuration": "45 min",
      "signalStrength": 92,
      "autoReconnect": true,
      "notifications": true,
    },
    {
      "id": "device_002",
      "name": "Polar H10 - Sarah",
      "status": "connecting",
      "heartRate": 0,
      "battery": 67,
      "lastSeen": "2 min ago",
      "macAddress": "AA:BB:CC:DD:EE:02",
      "firmware": "v2.1.2",
      "connectionDuration": "0 min",
      "signalStrength": 78,
      "autoReconnect": true,
      "notifications": false,
    },
    {
      "id": "device_003",
      "name": "Polar H10 - Mike",
      "status": "disconnected",
      "heartRate": 0,
      "battery": 23,
      "lastSeen": "15 min ago",
      "macAddress": "AA:BB:CC:DD:EE:03",
      "firmware": "v2.0.8",
      "connectionDuration": "0 min",
      "signalStrength": 45,
      "autoReconnect": false,
      "notifications": true,
    },
    {
      "id": "device_004",
      "name": "Polar H10 - Emma",
      "status": "error",
      "heartRate": 0,
      "battery": 91,
      "lastSeen": "5 min ago",
      "macAddress": "AA:BB:CC:DD:EE:04",
      "firmware": "v2.1.3",
      "connectionDuration": "0 min",
      "signalStrength": 12,
      "autoReconnect": true,
      "notifications": true,
    },
  ];

  // Mock connection history data
  final List<Map<String, dynamic>> _mockHistory = [
    {
      "event": "connected",
      "timestamp": "2:45 PM",
      "deviceName": "Polar H10 - John",
      "duration": null,
      "reason": null,
    },
    {
      "event": "disconnected",
      "timestamp": "2:30 PM",
      "deviceName": "Polar H10 - Sarah",
      "duration": "1h 15m",
      "reason": "Low battery warning",
    },
    {
      "event": "reconnected",
      "timestamp": "2:15 PM",
      "deviceName": "Polar H10 - Mike",
      "duration": null,
      "reason": null,
    },
    {
      "event": "error",
      "timestamp": "2:00 PM",
      "deviceName": "Polar H10 - Emma",
      "duration": null,
      "reason": "Signal interference detected",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredDevices {
    if (_searchQuery.isEmpty) return _mockDevices;

    return _mockDevices.where((device) {
      final name = (device['name'] ?? '').toLowerCase();
      final macAddress = (device['macAddress'] ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();

      return name.contains(query) || macAddress.contains(query);
    }).toList();
  }

  int get _connectedDevicesCount {
    return _mockDevices
        .where((device) => device['status'] == 'connected')
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDevicesTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton:
          _tabController.index == 0 ? _buildFloatingActionButton() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.textHighEmphasisLight,
          size: 6.w,
        ),
      ),
      title: _isMultiSelectMode
          ? Text(
              '\${_selectedDevices.length} selected',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device Management',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$_connectedDevicesCount of 8 devices connected',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMediumEmphasisLight,
                  ),
                ),
              ],
            ),
      actions: _isMultiSelectMode
          ? _buildMultiSelectActions()
          : _buildNormalActions(),
    );
  }

  List<Widget> _buildNormalActions() {
    return [
      if (_mockDevices.isNotEmpty)
        TextButton(
          onPressed: _disconnectAllDevices,
          child: Text(
            'Disconnect All',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.errorCritical,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      PopupMenuButton<String>(
        icon: CustomIconWidget(
          iconName: 'more_vert',
          color: AppTheme.textHighEmphasisLight,
          size: 6.w,
        ),
        onSelected: _handleMenuAction,
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'multi_select',
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'checklist',
                  color: AppTheme.textMediumEmphasisLight,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Text('Multi-select'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'refresh',
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'refresh',
                  color: AppTheme.textMediumEmphasisLight,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Text('Refresh All'),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildMultiSelectActions() {
    return [
      IconButton(
        onPressed: _selectedDevices.isNotEmpty ? _deleteSelectedDevices : null,
        icon: CustomIconWidget(
          iconName: 'delete',
          color: _selectedDevices.isNotEmpty
              ? AppTheme.errorCritical
              : AppTheme.inactiveDevice,
          size: 6.w,
        ),
      ),
      IconButton(
        onPressed: () => setState(() {
          _isMultiSelectMode = false;
          _selectedDevices.clear();
        }),
        icon: CustomIconWidget(
          iconName: 'close',
          color: AppTheme.textHighEmphasisLight,
          size: 6.w,
        ),
      ),
    ];
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'devices',
                  color: _tabController.index == 0
                      ? AppTheme.accentHighlight
                      : AppTheme.textMediumEmphasisLight,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text('Devices'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'history',
                  color: _tabController.index == 1
                      ? AppTheme.accentHighlight
                      : AppTheme.textMediumEmphasisLight,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text('History'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesTab() {
    return Column(
      children: [
        if (_mockDevices.isNotEmpty) _buildSearchBar(),
        Expanded(
          child: _filteredDevices.isEmpty
              ? EmptyStateWidget(
                  onPairDevice: () =>
                      Navigator.pushNamed(context, '/device-pairing-screen'),
                )
              : RefreshIndicator(
                  onRefresh: _refreshDevices,
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 10.h),
                    itemCount: _filteredDevices.length,
                    itemBuilder: (context, index) {
                      final device = _filteredDevices[index];
                      final deviceId = device['id'] as String;

                      return DeviceCardWidget(
                        device: device,
                        isExpanded: _expandedDeviceId == deviceId,
                        onTap: () => _handleDeviceCardTap(deviceId),
                        onRename: () => _renameDevice(deviceId),
                        onViewHistory: () => _viewDeviceHistory(deviceId),
                        onDelete: () => _deleteDevice(deviceId),
                        onToggleAutoReconnect: () =>
                            _toggleAutoReconnect(deviceId),
                        onToggleNotifications: () =>
                            _toggleNotifications(deviceId),
                        onResetConnection: () => _resetConnection(deviceId),
                        onExportData: () => _exportDeviceData(deviceId),
                        onDeviceInfo: () => _showDeviceInfo(deviceId),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(4.w),
      color: AppTheme.lightTheme.colorScheme.surface,
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search devices by name or MAC address...',
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.textMediumEmphasisLight,
              size: 5.w,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: CustomIconWidget(
                    iconName: 'clear',
                    color: AppTheme.textMediumEmphasisLight,
                    size: 5.w,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppTheme.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppTheme.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppTheme.accentHighlight, width: 2),
          ),
          filled: true,
          fillColor: AppTheme.lightTheme.colorScheme.surface,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          ConnectionHistoryWidget(historyData: _mockHistory),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.pushNamed(context, '/device-pairing-screen'),
      backgroundColor: AppTheme.accentHighlight,
      foregroundColor: AppTheme.lightTheme.colorScheme.surface,
      icon: CustomIconWidget(
        iconName: 'add',
        color: AppTheme.lightTheme.colorScheme.surface,
        size: 6.w,
      ),
      label: Text(
        'Pair Device',
        style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          color: AppTheme.lightTheme.colorScheme.surface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleDeviceCardTap(String deviceId) {
    if (_isMultiSelectMode) {
      setState(() {
        if (_selectedDevices.contains(deviceId)) {
          _selectedDevices.remove(deviceId);
        } else {
          _selectedDevices.add(deviceId);
        }
      });
    } else {
      setState(() {
        _expandedDeviceId = _expandedDeviceId == deviceId ? '' : deviceId;
      });
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'multi_select':
        setState(() => _isMultiSelectMode = true);
        break;
      case 'refresh':
        _refreshDevices();
        break;
    }
  }

  Future<void> _refreshDevices() async {
    setState(() => _isRefreshing = true);

    // Simulate refresh delay
    await Future.delayed(Duration(seconds: 2));

    setState(() => _isRefreshing = false);

    Fluttertoast.showToast(
      msg: "Device status updated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _disconnectAllDevices() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Disconnect All Devices'),
        content:
            Text('Are you sure you want to disconnect all connected devices?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "All devices disconnected",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text(
              'Disconnect',
              style: TextStyle(color: AppTheme.errorCritical),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedDevices() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Selected Devices'),
        content: Text(
            'Are you sure you want to delete \${_selectedDevices.length} selected devices?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedDevices.clear();
                _isMultiSelectMode = false;
              });
              Fluttertoast.showToast(
                msg: "Selected devices deleted",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorCritical),
            ),
          ),
        ],
      ),
    );
  }

  void _renameDevice(String deviceId) {
    final TextEditingController nameController = TextEditingController();
    final device = _mockDevices.firstWhere((d) => d['id'] == deviceId);
    nameController.text = device['name'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Device'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Device Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Device renamed successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _viewDeviceHistory(String deviceId) {
    Navigator.pushNamed(context, '/device-dashboard');
  }

  void _deleteDevice(String deviceId) {
    final device = _mockDevices.firstWhere((d) => d['id'] == deviceId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Device'),
        content: Text(
            'Are you sure you want to delete "${device['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Device deleted successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorCritical),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleAutoReconnect(String deviceId) {
    Fluttertoast.showToast(
      msg: "Auto-reconnect setting updated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _toggleNotifications(String deviceId) {
    Fluttertoast.showToast(
      msg: "Notification setting updated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _resetConnection(String deviceId) {
    final device = _mockDevices.firstWhere((d) => d['id'] == deviceId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Connection'),
        content: Text(
            'Reset the connection for "${device['name']}"? The device will be disconnected and reconnected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Connection reset initiated",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _exportDeviceData(String deviceId) {
    final device = _mockDevices.firstWhere((d) => d['id'] == deviceId);

    Fluttertoast.showToast(
      msg: "Exporting data for ${device['name']}...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showDeviceInfo(String deviceId) {
    final device = _mockDevices.firstWhere((d) => d['id'] == deviceId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Device Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Name', device['name'] ?? 'Unknown'),
              _buildInfoRow('MAC Address', device['macAddress'] ?? 'Unknown'),
              _buildInfoRow('Firmware', device['firmware'] ?? 'Unknown'),
              _buildInfoRow('Status', device['status'] ?? 'Unknown'),
              _buildInfoRow('Battery', '${device['battery'] ?? 0}%'),
              _buildInfoRow(
                  'Signal Strength', '${device['signalStrength'] ?? 0}%'),
              _buildInfoRow('Last Seen', device['lastSeen'] ?? 'Never'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.textMediumEmphasisLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
