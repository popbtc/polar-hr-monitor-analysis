import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DiscoveredDeviceItemWidget extends StatelessWidget {
  final Map<String, dynamic> device;
  final bool isConnecting;
  final VoidCallback onConnect;

  const DiscoveredDeviceItemWidget({
    Key? key,
    required this.device,
    required this.isConnecting,
    required this.onConnect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isConnected = device["isConnected"] ?? false;
    final int signal = device["signalStrength"] ?? 0;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ข้อมูลอุปกรณ์
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device["name"] ?? "Unknown Device",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device["macAddress"] ?? "",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isConnecting ? "Connecting..." : "Tap to connect",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // ปุ่ม Connect
            ElevatedButton(
              onPressed: isConnecting || isConnected ? null : onConnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected ? Colors.green : Colors.blue,
                disabledBackgroundColor:
                    isConnecting ? Colors.grey.shade400 : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
              ),
              child: Text(
                isConnecting
                    ? "Connecting..."
                    : isConnected
                        ? "Connected"
                        : "Connect",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
