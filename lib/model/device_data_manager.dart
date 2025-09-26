import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Defines the structure of a single device.
class Device {
  final String name;
  final String category;
  final String mac;
  final String homeId;
  final String roomId;

  Device({
    required this.name,
    required this.category,
    required this.mac,
    required this.homeId,
    required this.roomId,
  });

  /// Converts a Device object into a Map so it can be saved as JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'mac': mac,
    'homeId': homeId,
    'roomId': roomId,
  };

  /// Creates a Device object from a Map (retrieved from JSON).
  factory Device.fromJson(Map<String, dynamic> json) => Device(
    name: json['name'],
    category: json['category'],
    mac: json['mac'],
    // 💡 ADDED FIXES BELOW:
    // Provide a default value for homeId and roomId to prevent the error
    // from older saved data that doesn't have these fields.
    homeId: json['homeId'] ?? 'Local',
    roomId: json['roomId'] ?? 'N/A',
  );
}


// Manages saving and loading the list of devices from persistent storage.
class DeviceDataManager {
  // A unique key to identify our device list in the browser's storage.
  static const _devicesKey = 'devices_list';

  /// Saves the entire list of devices to local storage.
  static Future<void> saveDevices(List<Device> devices) async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Convert the list of Device objects to a list of Maps.
    List<Map<String, dynamic>> devicesJson = devices.map((device) => device.toJson()).toList();
    // 2. Convert the list of Maps into a single JSON string.
    String devicesString = jsonEncode(devicesJson);
    // 3. Save the string to storage.
    await prefs.setString(_devicesKey, devicesString);
  }

  /// Loads the list of devices from local storage.
  static Future<List<Device>> loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Get the saved JSON string from storage.
    final String? devicesString = prefs.getString(_devicesKey);

    if (devicesString != null && devicesString.isNotEmpty) {
      // 2. Decode the string back into a List of Maps.
      List<dynamic> devicesJson = jsonDecode(devicesString);
      // 3. Convert the list of Maps back into a list of Device objects.
      return devicesJson.map((json) => Device.fromJson(json)).toList();
    } else {
      // If no devices are saved yet, return an empty list.
      return [];
    }
  }
}