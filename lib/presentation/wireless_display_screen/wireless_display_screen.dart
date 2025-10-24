import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';


import '../../core/app_export.dart';
import './widgets/casting_device_card.dart';
import './widgets/casting_preview_widget.dart';
import './widgets/connection_status_widget.dart';
import './widgets/display_options_widget.dart';
import './widgets/troubleshooting_widget.dart';

class WirelessDisplayScreen extends StatefulWidget {
  const WirelessDisplayScreen({Key? key}) : super(key: key);

  @override
  State<WirelessDisplayScreen> createState() => _WirelessDisplayScreenState();
}

class _WirelessDisplayScreenState extends State<WirelessDisplayScreen> {
  String _connectionStatus = 'searching';
  String? _connectedDeviceName;
  String? _connectingDeviceName;
  String _selectedLayout = 'grid';
  bool _showDeviceNames = true;
  bool _useHeartRateColors = true;
  bool _isNetworkAvailable = true;

  // Mock casting devices data
  final List<Map<String, dynamic>> _availableDevices = [
    {
      'id': '1',
      'name': 'Living Room TV',
      'type': 'Chromecast',
      'signalStrength': 85,
      'isConnected': false,
    },
    {
      'id': '2',
      'name': 'Apple TV 4K',
      'type': 'Apple TV',
      'signalStrength': 92,
      'isConnected': false,
    },
    {
      'id': '3',
      'name': 'Samsung Smart TV',
      'type': 'Miracast',
      'signalStrength': 78,
      'isConnected': false,
    },
    {
      'id': '4',
      'name': 'Bedroom Chromecast',
      'type': 'Chromecast',
      'signalStrength': 65,
      'isConnected': false,
    },
  ];

  // Mock heart rate data for preview
  final List<Map<String, dynamic>> _heartRateData = [
    {
      'deviceId': 'polar_001',
      'deviceName': 'Polar H10 - John',
      'heartRate': 142,
      'isConnected': true,
      'lastUpdate': DateTime.now(),
    },
    {
      'deviceId': 'polar_002',
      'deviceName': 'Polar H10 - Sarah',
      'heartRate': 128,
      'isConnected': true,
      'lastUpdate': DateTime.now(),
    },
    {
      'deviceId': 'polar_003',
      'deviceName': 'Polar H10 - Mike',
      'heartRate': 165,
      'isConnected': true,
      'lastUpdate': DateTime.now(),
    },
    {
      'deviceId': 'polar_004',
      'deviceName': 'Polar H10 - Lisa',
      'heartRate': 98,
      'isConnected': true,
      'lastUpdate': DateTime.now(),
    },
  ];

  @override
  void initState() {
    super.initState();

    // ✅ บังคับให้หน้าจอเป็นแนวนอนตอนเข้า
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _checkNetworkAvailability();
    _startDeviceDiscovery();
  }

  @override
  void dispose() {
    // ✅ คืนค่าหน้าจอกลับเป็นแนวตั้งตอนออก
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void _checkNetworkAvailability() {
    // Simulate network check
    setState(() {
      _isNetworkAvailable = true;
    });
  }

  void _startDeviceDiscovery() {
    setState(() {
      _connectionStatus = 'searching';
    });

    // Simulate device discovery
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _connectionStatus = 'idle';
        });
      }
    });
  }

  void _connectToDevice(Map<String, dynamic> device) {
    setState(() {
      _connectionStatus = 'connecting';
      _connectingDeviceName = device['name'] as String;
    });

    // Simulate connection process
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Simulate connection success/failure (80% success rate)
        final isSuccess = DateTime.now().millisecond % 10 < 8;

        setState(() {
          if (isSuccess) {
            _connectionStatus = 'connected';
            _connectedDeviceName = device['name'] as String;
            _connectingDeviceName = null;

            // Update device connection status
            final deviceIndex = _availableDevices.indexWhere(
                  (d) => d['id'] == device['id'],
            );
            if (deviceIndex != -1) {
              _availableDevices[deviceIndex]['isConnected'] = true;
            }
          } else {
            _connectionStatus = 'failed';
            _connectingDeviceName = null;
          }
        });

        // Auto-hide failed status after 5 seconds
        if (!isSuccess) {
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted && _connectionStatus == 'failed') {
              setState(() {
                _connectionStatus = 'idle';
              });
            }
          });
        }
      }
    });
  }

  void _stopCasting() {
    setState(() {
      _connectionStatus = 'idle';
      _connectedDeviceName = null;

      // Reset all device connection status
      for (var device in _availableDevices) {
        device['isConnected'] = false;
      }
    });
  }

  void _retryConnection() {
    _startDeviceDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Wireless Display',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _startDeviceDiscovery,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: AppTheme.accentHighlight,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: !_isNetworkAvailable
            ? _buildNetworkUnavailableView()
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),

              // Connection status
              ConnectionStatusWidget(
                status: _connectionStatus,
                connectedDeviceName:
                _connectedDeviceName ?? _connectingDeviceName,
                onStopCasting: _connectionStatus == 'connected'
                    ? _stopCasting
                    : null,
              ),

              SizedBox(height: 2.h),

              // Available devices section
              if (_connectionStatus != 'connected') ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    'Available Devices',
                    style: AppTheme.lightTheme.textTheme.titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                if (_connectionStatus == 'searching')
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.all(8.w),
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 12.w,
                            height: 12.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.accentHighlight,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Scanning for devices...',
                            style: AppTheme
                                .lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _availableDevices.length,
                    itemBuilder: (context, index) {
                      final device = _availableDevices[index];
                      return CastingDeviceCard(
                        device: device,
                        onTap: () => _connectToDevice(device),
                        isConnecting: _connectionStatus == 'connecting' &&
                            _connectingDeviceName == device['name'],
                      );
                    },
                  ),
                SizedBox(height: 3.h),
              ],

              // Display options (only show when connected)
              if (_connectionStatus == 'connected') ...[
                DisplayOptionsWidget(
                  selectedLayout: _selectedLayout,
                  showDeviceNames: _showDeviceNames,
                  useHeartRateColors: _useHeartRateColors,
                  onLayoutChanged: (layout) {
                    setState(() {
                      _selectedLayout = layout;
                    });
                  },
                  onDeviceNamesToggled: (value) {
                    setState(() {
                      _showDeviceNames = value;
                    });
                  },
                  onHeartRateColorsToggled: (value) {
                    setState(() {
                      _useHeartRateColors = value;
                    });
                  },
                ),

                SizedBox(height: 3.h),

                // Preview section
                CastingPreviewWidget(
                  layout: _selectedLayout,
                  showDeviceNames: _showDeviceNames,
                  useHeartRateColors: _useHeartRateColors,
                  heartRateData: _heartRateData,
                ),

                SizedBox(height: 3.h),
              ],

              // Troubleshooting section
              const TroubleshootingWidget(),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkUnavailableView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'wifi_off',
              color: AppTheme.errorCritical,
              size: 20.w,
            ),
            SizedBox(height: 4.h),
            Text(
              'No Network Connection',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.errorCritical,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Wireless display requires a WiFi connection. Please connect to a network and try again.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: _checkNetworkAvailability,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentHighlight,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'refresh',
                    color: Colors.white,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Check Connection',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
