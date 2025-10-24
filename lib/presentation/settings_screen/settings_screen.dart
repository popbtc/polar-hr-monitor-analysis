import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/account_section_widget.dart';
import './widgets/setting_item_widget.dart';
import './widgets/settings_section_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Settings state
  bool _autoReconnect = true;
  int _connectionTimeout = 30;
  bool _batteryAlerts = true;
  String _heartRateUnits = 'BPM';
  String _colorTheme = 'Auto';
  bool _connectionAlerts = true;
  bool _lowBatteryWarnings = true;
  bool _thresholdNotifications = true;
  String _dataRetention = '30 days';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  bool _shouldShowItem(String title, String subtitle) {
    if (_searchQuery.isEmpty) return true;
    return title.toLowerCase().contains(_searchQuery) ||
        subtitle.toLowerCase().contains(_searchQuery);
  }

  void _handleAccountSignIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sign in functionality'),
        backgroundColor: AppTheme.accentHighlight,
      ),
    );
  }

  void _handleProfileManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile management'),
        backgroundColor: AppTheme.accentHighlight,
      ),
    );
  }

  void _handleConnectionTimeout() {
    _showTimeoutDialog();
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Connection Timeout',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select connection timeout duration',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              ...([15, 30, 60, 120].map((seconds) {
                return RadioListTile<int>(
                  title: Text('${seconds}s'),
                  value: seconds,
                  groupValue: _connectionTimeout,
                  onChanged: (value) {
                    setState(() {
                      _connectionTimeout = value!;
                    });
                    Navigator.of(context).pop();
                  },
                  activeColor: AppTheme.accentHighlight,
                );
              }).toList()),
            ],
          ),
        );
      },
    );
  }

  void _handleHeartRateUnits() {
    _showHeartRateUnitsDialog();
  }

  void _showHeartRateUnitsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Heart Rate Units',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('BPM (Beats per minute)'),
                value: 'BPM',
                groupValue: _heartRateUnits,
                onChanged: (value) {
                  setState(() {
                    _heartRateUnits = value!;
                  });
                  Navigator.of(context).pop();
                },
                activeColor: AppTheme.accentHighlight,
              ),
              RadioListTile<String>(
                title: Text('Percentage of max HR'),
                value: 'Percentage',
                groupValue: _heartRateUnits,
                onChanged: (value) {
                  setState(() {
                    _heartRateUnits = value!;
                  });
                  Navigator.of(context).pop();
                },
                activeColor: AppTheme.accentHighlight,
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleColorTheme() {
    _showColorThemeDialog();
  }

  void _showColorThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Color Theme',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...(['Auto', 'Light', 'Dark'].map((theme) {
                return RadioListTile<String>(
                  title: Text(theme),
                  value: theme,
                  groupValue: _colorTheme,
                  onChanged: (value) {
                    setState(() {
                      _colorTheme = value!;
                    });
                    Navigator.of(context).pop();
                  },
                  activeColor: AppTheme.accentHighlight,
                );
              }).toList()),
            ],
          ),
        );
      },
    );
  }

  void _handleDataRetention() {
    _showDataRetentionDialog();
  }

  void _showDataRetentionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Data Retention',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...(['7 days', '30 days', '90 days', '1 year', 'Forever']
                  .map((period) {
                return RadioListTile<String>(
                  title: Text(period),
                  value: period,
                  groupValue: _dataRetention,
                  onChanged: (value) {
                    setState(() {
                      _dataRetention = value!;
                    });
                    Navigator.of(context).pop();
                  },
                  activeColor: AppTheme.accentHighlight,
                );
              }).toList()),
            ],
          ),
        );
      },
    );
  }

  void _handleExportData() {
    _showExportDialog();
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Export Data',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Export your heart rate data and device history?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Data export started'),
                    backgroundColor: AppTheme.connectionSuccess,
                  ),
                );
              },
              child: Text('Export'),
            ),
          ],
        );
      },
    );
  }

  void _handleAccountDeletion() {
    _showAccountDeletionDialog();
  }

  void _showAccountDeletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Account',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.errorCritical,
            ),
          ),
          content: Text(
            'This action cannot be undone. All your data will be permanently deleted.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Account deletion cancelled'),
                    backgroundColor: AppTheme.warningState,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorCritical,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        foregroundColor: AppTheme.primaryLight,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search functionality
            Container(
              padding: EdgeInsets.all(4.w),
              child: TextField(
                controller: _searchController,
                onChanged: _handleSearch,
                decoration: InputDecoration(
                  hintText: 'Search settings...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.textMediumEmphasisLight,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: AppTheme.textMediumEmphasisLight,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _handleSearch('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Settings content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  children: [
                    // Account Section
                    if (_shouldShowItem(
                        'Account', 'Sign in and profile management'))
                      SettingsSectionWidget(
                        title: 'Account',
                        children: [
                          AccountSectionWidget(
                            onSignIn: _handleAccountSignIn,
                            onProfileManagement: _handleProfileManagement,
                          ),
                        ],
                      ),

                    SizedBox(height: 3.h),

                    // Device Preferences Section
                    if (_shouldShowItem('Device Preferences',
                        'Auto-reconnect and connection settings'))
                      SettingsSectionWidget(
                        title: 'Device Preferences',
                        children: [
                          SettingItemWidget(
                            icon: 'autorenew',
                            title: 'Auto-reconnect',
                            subtitle: 'Automatically reconnect to devices',
                            trailing: Switch(
                              value: _autoReconnect,
                              onChanged: (value) {
                                setState(() {
                                  _autoReconnect = value;
                                });
                              },
                            ),
                          ),
                          SettingItemWidget(
                            icon: 'schedule',
                            title: 'Connection Timeout',
                            subtitle: '${_connectionTimeout} seconds',
                            onTap: _handleConnectionTimeout,
                            showArrow: true,
                          ),
                          SettingItemWidget(
                            icon: 'battery_alert',
                            title: 'Battery Alerts',
                            subtitle: 'Warn when device battery is low',
                            trailing: Switch(
                              value: _batteryAlerts,
                              onChanged: (value) {
                                setState(() {
                                  _batteryAlerts = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 3.h),

                    // Display Options Section
                    if (_shouldShowItem(
                        'Display Options', 'Heart rate units and themes'))
                      SettingsSectionWidget(
                        title: 'Display Options',
                        children: [
                          SettingItemWidget(
                            icon: 'favorite',
                            title: 'Heart Rate Units',
                            subtitle: _heartRateUnits,
                            onTap: _handleHeartRateUnits,
                            showArrow: true,
                          ),
                          SettingItemWidget(
                            icon: 'palette',
                            title: 'Color Theme',
                            subtitle: _colorTheme,
                            onTap: _handleColorTheme,
                            showArrow: true,
                          ),
                          SettingItemWidget(
                            icon: 'tune',
                            title: 'Zone Customization',
                            subtitle: 'Customize heart rate zones',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Zone customization'),
                                  backgroundColor: AppTheme.accentHighlight,
                                ),
                              );
                            },
                            showArrow: true,
                          ),
                        ],
                      ),

                    SizedBox(height: 3.h),

                    // Notifications Section
                    if (_shouldShowItem('Notifications', 'Alerts and warnings'))
                      SettingsSectionWidget(
                        title: 'Notifications',
                        children: [
                          SettingItemWidget(
                            icon: 'notifications_active',
                            title: 'Connection Status Alerts',
                            subtitle:
                                'Device connection/disconnection notifications',
                            trailing: Switch(
                              value: _connectionAlerts,
                              onChanged: (value) {
                                setState(() {
                                  _connectionAlerts = value;
                                });
                              },
                            ),
                          ),
                          SettingItemWidget(
                            icon: 'battery_std',
                            title: 'Low Battery Warnings',
                            subtitle: 'Alert when device battery is low',
                            trailing: Switch(
                              value: _lowBatteryWarnings,
                              onChanged: (value) {
                                setState(() {
                                  _lowBatteryWarnings = value;
                                });
                              },
                            ),
                          ),
                          SettingItemWidget(
                            icon: 'warning',
                            title: 'Heart Rate Threshold',
                            subtitle: 'Notifications for high/low heart rate',
                            trailing: Switch(
                              value: _thresholdNotifications,
                              onChanged: (value) {
                                setState(() {
                                  _thresholdNotifications = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 3.h),

                    // Data & Privacy Section
                    if (_shouldShowItem(
                        'Data & Privacy', 'Export and retention settings'))
                      SettingsSectionWidget(
                        title: 'Data & Privacy',
                        children: [
                          SettingItemWidget(
                            icon: 'file_download',
                            title: 'Export Data',
                            subtitle: 'Download your heart rate data',
                            onTap: _handleExportData,
                            showArrow: true,
                          ),
                          SettingItemWidget(
                            icon: 'history',
                            title: 'Data Retention',
                            subtitle: _dataRetention,
                            onTap: _handleDataRetention,
                            showArrow: true,
                          ),
                          SettingItemWidget(
                            icon: 'privacy_tip',
                            title: 'Privacy Controls',
                            subtitle: 'Manage data sharing preferences',
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/permission-request-screen');
                            },
                            showArrow: true,
                          ),
                        ],
                      ),

                    SizedBox(height: 3.h),

                    // About Section
                    if (_shouldShowItem('About', 'App information and support'))
                      SettingsSectionWidget(
                        title: 'About',
                        children: [
                          SettingItemWidget(
                            icon: 'info',
                            title: 'App Version',
                            subtitle: 'v1.0.0 (Build 1)',
                            onTap: () {},
                          ),
                          SettingItemWidget(
                            icon: 'support',
                            title: 'Support Contact',
                            subtitle: 'Get help with PolarSync',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Support contact'),
                                  backgroundColor: AppTheme.accentHighlight,
                                ),
                              );
                            },
                            showArrow: true,
                          ),
                          SettingItemWidget(
                            icon: 'gavel',
                            title: 'Legal Information',
                            subtitle: 'Terms of use and privacy policy',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Legal information'),
                                  backgroundColor: AppTheme.accentHighlight,
                                ),
                              );
                            },
                            showArrow: true,
                          ),
                        ],
                      ),

                    SizedBox(height: 3.h),

                    // Danger Zone
                    if (_shouldShowItem(
                        'Delete Account', 'Permanently delete account'))
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 2.h),
                        child: OutlinedButton(
                          onPressed: _handleAccountDeletion,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.errorCritical),
                            foregroundColor: AppTheme.errorCritical,
                          ),
                          child: Text('Delete Account'),
                        ),
                      ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
