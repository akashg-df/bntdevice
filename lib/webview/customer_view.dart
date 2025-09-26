import 'dart:async';
import 'package:dfdevicewebview/component/add_device_comp.dart';
import 'package:dfdevicewebview/constant.dart';
import 'package:dfdevicewebview/responsive.dart';
import 'package:dfdevicewebview/service/api_client.dart';
import 'package:dfdevicewebview/service/auth_service.dart';
import 'package:dfdevicewebview/typography.dart';
import 'package:dfdevicewebview/utli/auth_utils.dart';
import 'package:dfdevicewebview/utli/drawer_utils.dart';
import 'package:dfdevicewebview/utli/loader_utils.dart';
import 'package:dfdevicewebview/widget/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dfdevicewebview/model/device_data_manager.dart'; // <--- ADDED IMPORT

// New class to hold device data and its selection state
class DeviceSelection {
  final Map<String, dynamic> device;
  bool isSelected;

  DeviceSelection({required this.device, this.isSelected = false});
}

class CustomerView extends StatefulWidget {
  final String? userEmail;
  final String? userPass;
  const CustomerView({super.key, this.userEmail, this.userPass});


  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool loading = false;
  late List<bool> isExpandedList;

  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();
  List<DeviceSelection> homeData = [];
  List<Map<String, dynamic>> displayedDevices = [];

  Timer? _timer;


  @override
  void initState() {
    super.initState();
    _fetchData();
    _startPeriodicLogin();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _performLoginAndRefresh() async {
    // Always use hardcoded credentials
    const email = "testing23@mailinator.com";
    const password = "Qwerty@123";

    bool success = await _authService.loginUser(email, password);
    if (success) {
      print("✅ Login successful, fetching data...");
      await _fetchData();
    } else {
      print("❌ Login failed.");
    }
  }

  Future<void> _startPeriodicLogin() async {
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer t) async {
      await _performLoginAndRefresh();
    });
  }

  Future<void> _handleManualRefresh() async {
    _timer?.cancel();
    await _performLoginAndRefresh();
    _startPeriodicLogin();
  }


  Future<void> _fetchData() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      homeData = [];
      isExpandedList = [];
      displayedDevices = [];
    });

    final Set<String> processedDeviceIds = {};
    final List<DeviceSelection> fetchedHomeData = [];

    // 1. Load locally saved devices from AdminTwxDashboard
    try {
      final localDevices = await DeviceDataManager.loadDevices(); // <--- ADDED 'await'
      for (var device in localDevices) {
        // Assuming the Device model has a toJson() method or similar
        // to convert it to a Map<String, dynamic>.
        final Map<String, dynamic> deviceMap = device.toJson();

        // 💡 FIX APPLIED HERE: Added check for 'mac' key, which stores the device ID/MAC from AdminTwxDashboard.
        final deviceId = deviceMap['deviceId'] ?? deviceMap['deviceid'] ?? deviceMap['mac'] ?? 'unknown';

        if (deviceId != 'unknown' && processedDeviceIds.add(deviceId)) {
          print("💾 Adding local device: $deviceId");
          fetchedHomeData.add(DeviceSelection(device: {
            "devicename": deviceMap['deviceName'] ?? deviceMap['name'] ?? deviceId,
            "homeid": deviceMap['homeId'] ?? 'Local',
            "roomid": deviceMap['roomId']?.toString() ?? 'N/A',
            "deviceId": deviceId,
          }));
        }
      }
    } catch (e) {
      print("❌ Error loading local devices: $e");
    }

    try {
      print("🔄 Fetching homes...");
      final homesResponse = await _apiClient.get(
          'https://overtureiot.broan-nutone.com/overturev2/api/v1/ciaq/user/getallhomesandUserInfo');

      if (!mounted) return;

      if (homesResponse is List) {
        print("✅ Homes fetched: ${homesResponse.length}");
        for (var home in homesResponse) {
          final homeId = home['homeId'];
          print("➡️ Home ID: $homeId");

          final devicesResponse = await _apiClient.get(
              'https://overtureiot.broan-nutone.com/overturev2/api/v1/ciaq/user/allDevicesForMyHome',
              customHeaders: {'home_id': homeId});

          if (!mounted) return;

          if (devicesResponse is List) {
            print("   📦 Devices found: ${devicesResponse.length}");
            for (var device in devicesResponse) {
              final deviceId = device['deviceId'];

              // Check against processedDeviceIds to avoid duplicates from local storage
              if (processedDeviceIds.add(deviceId)) {
                print("   ➡️ Device ID: $deviceId (New/API)");
                fetchedHomeData.add(DeviceSelection(device: {
                  "devicename": deviceId,
                  "homeid": homeId,
                  "roomid": device['roomId'].toString(),
                  "deviceId": deviceId,
                }));
              } else {
                print("   ➡️ Device ID: $deviceId (Skipping, already added from local list)");
              }
            }
          }
        }
      }

      // Add hardcoded devices, also checking against the processed list
      for (var device in hardcodedDevices) {
        final deviceId = device["deviceid"]!;
        if (processedDeviceIds.add(deviceId)) {
          print("⭐ Adding hardcoded device: ${device["deviceid"]}");
          fetchedHomeData.add(DeviceSelection(device: {
            "devicename": device["name"],
            "homeid": "Manual",
            "roomid": "N/A",
            "deviceId": deviceId,
          }));
        }
      }

    } catch (e) {
      print("❌ Error fetching data: $e");
    } finally {
      if (mounted) {
        // Ensure isExpandedList is sized correctly for the new homeData
        setState(() {
          homeData = List.from(fetchedHomeData);
          isExpandedList = List.generate(homeData.length, (index) => false);
          loading = false;
        });
      }
      print("✅ Final homeData count: ${homeData.length}");
    }
  }

  Future<void> _onDeviceSelected(DeviceSelection selectedDevice, bool isSelected) async {
    setState(() {
      selectedDevice.isSelected = isSelected;
    });

    if (isSelected) {
      setState(() {
        loading = true;
      });

      final deviceId = selectedDevice.device['deviceId'];
      final homeId = selectedDevice.device['homeid'];
      // final isLocalDevice = homeId == 'Local'; // Not needed for the fix

      // ✅ FIX: ALWAYS set the home_id header. This resolves the 400 error.
      final Map<String, String>? headers = {'home_id': homeId};

      try {
        // Check if device is a locally added hardcoded device (homeid='Manual')
        final isManualHardcoded = homeId == 'Manual';

        // Mock data for hardcoded devices as API calls will fail for them
        Map<String, dynamic> sensorDataResponse;

        // ⚠️ WARNING: The 'if (isManualHardcoded)' mock data block has been removed.
        // This means an API call will be attempted for devices with homeId='Manual'.
        // This API call is expected to fail with a 404 or other error,
        // which will be caught in the 'catch' block.
        sensorDataResponse = await _apiClient.get(
            'https://overtureiot.broan-nutone.com/overturev2/api/v1/ciaq/thingworx/user/device/$deviceId',
            customHeaders: headers);

        if (!mounted) return;

        final deviceDetails = sensorDataResponse['deviceDetailsDTO'];
        final isConnected = deviceDetails['isConnected'];
        final deviceName = selectedDevice.device['devicename'];

        final updatedDevice = {
          "devicename": deviceName,
          "homeid": homeId,
          "roomid": selectedDevice.device['roomid'],
          "status": isConnected ? "All devices online" : "1 device online",
          "statusColor": isConnected ? Colors.green : Colors.orange,
          "iaqindex": deviceDetails['iaqindex']?.toString() ?? 'N/A',
          "temperature": deviceDetails['temperature']?.toString() ?? 'N/A',
          "co2": deviceDetails['co2']?.toString() ?? 'N/A',
          "tvoc": deviceDetails['tvoc']?.toString() ?? 'N/A',
          "pm2_5": deviceDetails['pm2_5']?.toString() ?? 'N/A',
          "humidity": deviceDetails['humidity']?.toString() ?? 'N/A',
          "deviceId": deviceId,
        };

        setState(() {
          displayedDevices.add(updatedDevice);
        });

      } catch (e) {
        // This catch block will now handle the API error for 'Manual' devices
        // as well as any legitimate network errors. The device will be marked as offline
        // or simply not displayed depending on how you handle this error state.
        print("❌ Error fetching sensor data for $deviceId: $e");
      } finally {
        setState(() {
          loading = false;
        });
      }
    } else {
      // Remove the device from the displayed list if it's deselected
      setState(() {
        displayedDevices.removeWhere((device) => device['deviceId'] == selectedDevice.device['deviceId']);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Responsive(
      mobile: mobileView(width, height),
      desktop: desktopView(width, height),
      tablet: tabletView(width, height),
    );
  }

  mobileView(width, height) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: priBg,
      drawer: DrawerUtils(scaffoldKey: _scaffoldKey),
      appBar: appBar(),
      body: loading
          ? LoaderUtils().circularLoader()
          : desktoptabViewbody(width, height),
    );
  }

  desktopView(width, height) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: priBg,
      drawer: DrawerUtils(scaffoldKey: _scaffoldKey),
      appBar: appBar(),
      body: loading
          ? LoaderUtils().circularLoader()
          : desktoptabViewbody(width, height),
    );
  }

  tabletView(width, height) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: priBg,
      drawer: DrawerUtils(scaffoldKey: _scaffoldKey),
      appBar: appBar(),
      body: loading
          ? LoaderUtils().circularLoader()
          : desktoptabViewbody(width, height),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: buttonNavyLight,
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        icon: Icon(
          Icons.menu_open,
          color: priBg,
          size: 28,
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      title: TextWidget(
        text: 'Air Quality Monitoring Dashboard',
        fontWeight: semiBold,
        fontsize: 18,
        color: priBg,
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _handleManualRefresh,
          tooltip: 'Refresh Data',
        ),
        popBttnActionBar(),
        const SizedBox(width: 10,)
      ],
    );
  }

  @override
  Widget desktoptabViewbody(width,height) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (width > 600)
          SizedBox(
            width: 250, // fixed width
            child: _buildDeviceSelector(),
          ),

        // Divider stays
        const VerticalDivider(thickness: .2, color: Colors.black),

        // Right side takes remaining space
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildMainContent(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMainContent() {
      if (displayedDevices.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end, // 👈 Push to bottom
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AddDeviceComp().emptyList(),
          const SizedBox(height: 30), // optional spacing from bottom
        ],
      );
    }
    return buildHomeCards();
  }

  Widget _buildDeviceSelector() {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    // The content of the device selector (the list)
    final deviceListContent = ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: homeData.length,
      itemBuilder: (context, index) {
        final deviceItem = homeData[index];
        final deviceName = deviceItem.device['devicename'] ?? "Unnamed Device";

        return CheckboxListTile(
          dense: isMobile, // compact on mobile
          title: Text(
            deviceName,
            style: TextStyle(fontSize: isMobile ? 14 : 16),
          ),
          value: deviceItem.isSelected,
          onChanged: (bool? newValue) {
            _onDeviceSelected(deviceItem, newValue ?? false);
          },
        );
      },
    );

    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(
          top: 20,
          left: isMobile ? 10 : 20,
          right: isMobile ? 10 : 0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
        ),
        // Use an ExpansionTile for the collapsible functionality
        child: Theme(
          // Optional: Remove the divider line above and below the tile
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true, // Start open, change to false if you want it closed initially
            tilePadding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20, vertical: 0),
            // Set the title directly without a Center widget to align it to the left
            title: Text(
              'Select Devices', // Your button/title text
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor, // Use your app's primary color
              ),
            ),
            children: <Widget>[
              const Divider(height: 1, thickness: 1, color: Colors.black12), // Visual separator
              // Wrap the list in a padding or container for the interior padding
              Padding(
                padding: const EdgeInsets.all(10), // The original padding you had
                child: deviceListContent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHomeCards() {
    if (displayedDevices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AddDeviceComp().emptyList(),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.start,
        children: displayedDevices.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return SizedBox(
            width: 350,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: priBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(text: item["devicename"], fontsize: titleMedium, fontWeight: FontWeight.bold),
                          //TextWidget(text: item["status"], color: item["statusColor"]),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: item["statusColor"],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(item["statusColor"] == Colors.green ? Icons.check : Icons.warning, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            TextWidget(text: item["status"] == "All devices online" ? "Online" : "Offline", color: Colors.white, fontsize: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  buildSensorRow(
                    'assets/indoor-air-quality.png', "IAQ Index", item["iaqindex"],
                    'assets/temperature.png', "Temperature", "${item["temperature"]} °C",
                  ),
                  const SizedBox(height: 25),
                  buildSensorRow(
                    'assets/co2.png', "CO2", "${item["co2"]} ppm",
                    'assets/tvoc.png', "TVOC", "${item["tvoc"]} µg/m³",
                  ),
                  const SizedBox(height: 25),
                  buildSensorRow(
                    'assets/pm2.5.png', "PM2.5", "${item["pm2_5"]} µg/m³",
                    'assets/humidity.png', "Humidity", "${item["humidity"]} %",
                  ),
                  const SizedBox(height: 15),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpandedList[index] = !isExpandedList[index];
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(text: "More Info", fontWeight: semiBold, fontsize: 14),
                        Icon(isExpandedList[index] ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 24, color: Colors.black54),
                      ],
                    ),
                  ),

                  if (isExpandedList[index])
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(text: "Summary: Device operating within normal parameters.", color: Colors.grey, fontsize: bodyMedium),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildSensorRow(
      String asset1, String label1, String value1,
      String asset2, String label2, String value2) {
    return Row(
      children: [
        Flexible(
          child: Row(
            children: [
              Image.asset(asset1, width: 35, height: 35),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(text: label1, fontsize: bodyLarge),
                    const SizedBox(height: 4),
                    TextWidget(
                      text: value1,
                      fontsize: bodyLarge,
                      oflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Flexible(
          child: Row(
            children: [
              Image.asset(asset2, width: 35, height: 35),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(text: label2, fontsize: bodyLarge),
                    const SizedBox(height: 4),
                    TextWidget(
                      text: value2,
                      fontsize: bodyLarge,
                      oflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget popBttnActionBar() {
    return PopupMenuButton<String>(
      color: priBg,
      elevation: 7,
      position: PopupMenuPosition.under,
      surfaceTintColor: Colors.white,
      child: CircleAvatar(
        radius: 14,
        backgroundColor: priBg,
        child: const Icon(Icons.person, color: Colors.black),
      ),
      onSelected: (String newValue) {},
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
          height: 20,
          textStyle: TextStyle(
            fontSize: bodyMedium,
            color: priText,
          ),
          value: 'Logout',
          onTap: () {
            AuthUtils.logout(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.logout_outlined, size: 18),
              const SizedBox(width: 10),
              const Text('Logout'),
            ],
          ),
        ),
      ],
    );
  }
}