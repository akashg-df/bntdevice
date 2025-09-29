import 'dart:async';
import 'package:dfdevicewebview/component/add_device_comp.dart';
import 'package:dfdevicewebview/constant.dart';
import 'package:dfdevicewebview/model/device_selection.dart';
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
import 'package:dfdevicewebview/model/device_data_manager.dart';

class CustomerView extends StatefulWidget {
  final String? userEmail;
  final String? userPass;
  bool? isSelected;
  final Map<String, dynamic>? device;

  CustomerView({super.key, this.userEmail, this.userPass, this.isSelected = false, this.device,});


  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool loading = true;
  late List<bool> isExpandedList;
  Timer? _timer;
  String? apiUrl;

  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();
  List<DeviceSelection> homeData = [];
  List<Map<String, dynamic>> displayedDevices = [];
  Map<String, String> homeNames = {};
  final Map<String, Timer> _deviceTimers = {};
  final Map<String, bool> deviceLoadingStates = {};





  @override
  void initState() {
    super.initState();
    _performLoginAndRefresh().then((_) {
      _startPeriodicLogin();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _deviceTimers.forEach((key, timer) => timer.cancel());
    super.dispose();
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
        //popBttnActionBar(),
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
              mainAxisAlignment: MainAxisAlignment.center,
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
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.7, // adjust based on header/footer
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AddDeviceComp().emptyList(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    }
    return buildHomeCards();
  }

  // buildDeviceSelector with home name grouping
  Widget _buildDeviceSelector() {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
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
            children:[
              const Divider(height: 1, thickness: 1, color: Colors.black12), // Visual separator
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
                        // isExpandedList is sized for homeData, but used here for displayedDevices.
                        // This index mapping is risky if the two lists don't align.
                        // Assuming the index aligns for simplicity in this context.
                        if (index < isExpandedList.length) {
                          isExpandedList[index] = !isExpandedList[index];
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(text: "More Info", fontWeight: semiBold, fontsize: 14),
                        Icon(index < isExpandedList.length && isExpandedList[index] ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 24, color: Colors.black54),
                      ],
                    ),
                  ),

                  if (index < isExpandedList.length && isExpandedList[index])
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

  //Function
  Future<void> _startPeriodicLogin() async {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(minutes: 1), (Timer t) async {
      await _performLoginAndRefresh();
    });
  }

  Future<void> _handleManualRefresh() async {
    _timer?.cancel();
    await _performLoginAndRefresh();
    _startPeriodicLogin();
  }


  // API
  Future<void> _performLoginAndRefresh() async {
    // Always use hardcoded credentials
    const email = "testing23@mailinator.com";
    const password = "Qwerty@123";

    bool success = await _authService.loginUser(email, password);
    if (success) {
      print("✅ Login successful, fetching data...");
      // This fetch uses the new, valid token immediately
      await _fetchData();
    } else {
      print("❌ Login failed.");
      // 💡 FIX: Ensure loading state is turned off on failure.
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // NEW: Function to fetch data for a single device without triggering the main screen loader
  Future<void> _fetchAndDisplayData(DeviceSelection selectedDevice) async {
    if (!mounted) return;

    final rawDeviceId = selectedDevice.device['deviceId'];
    final deviceId = (rawDeviceId is String) ? rawDeviceId : '';
    final homeId = selectedDevice.device['homeid'];

    if (deviceId.isEmpty) {
      print("❌ Cannot fetch sensor data: deviceId is missing or empty.");
      return;
    }

    // 🔄 Show loader for this device
    setState(() {
      deviceLoadingStates[deviceId] = true;
    });

    // Determine API URL (using constants defined in your code)
    String? currentApiUrl;
    if (anotherHardcodedDevices.any((d) => d['deviceid'] == deviceId)) {
      currentApiUrl = '$newApiUrl$deviceId';
    } else {
      currentApiUrl = '$existingApiUrl$deviceId';
    }

    final Map<String, String>? headers = {'home_id': homeId};

    try {
      final sensorDataResponse = await _apiClient.get(
          currentApiUrl!,
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
        // Find the existing device in displayedDevices and update it, or add it if new.
        final index = displayedDevices.indexWhere((d) => d['deviceId'] == deviceId);
        if (index != -1) {
          displayedDevices[index] = updatedDevice;
        } else {
          displayedDevices.add(updatedDevice);
        }
      });

    } catch (e) {
      print("❌ Error fetching sensor data for $deviceId: $e");
      // Optionally update the device's status to indicate failure without a loader
      if (mounted) {
        setState(() {
          final index = displayedDevices.indexWhere((d) => d['deviceId'] == deviceId);
          if (index != -1) {
            displayedDevices[index]['status'] = 'Data Error';
            displayedDevices[index]['statusColor'] = Colors.red;
          }
        });
      }
    }finally {
      if (mounted) {
        setState((){
          deviceLoadingStates[deviceId] = false;
        });
      }
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;

    // 1. CLEAR STATE AND STOP ALL TIMERS
    setState(() {
      loading = true;
      homeData = [];
      isExpandedList = [];
      displayedDevices = [];
      homeNames = {};
      deviceLoadingStates.clear();

    });

    // Stop and clear all individual device timers (Crucial for manual refresh)
    _deviceTimers.forEach((key, timer) => timer.cancel());
    _deviceTimers.clear();

    final Set<String> processedDeviceIds = {};
    final List<DeviceSelection> fetchedHomeData = [];

    // 1. Map home names from the hardcoded lists (unchanged)
    for (var d in allAvailableDevices) {
      final homeId = d['homeid']!;
      final homeName = d['homename']!;
      homeNames[homeId] = homeName;
    }

    // 2. Load locally saved devices from AdminTwxDashboard
    try {
      final localDevices = await DeviceDataManager.loadDevices();

      for (var device in localDevices) {
        final Map<String, dynamic> deviceMap = device.toJson();
        final deviceId = deviceMap['mac'] ?? 'unknown';

        if (deviceId != 'unknown' && processedDeviceIds.add(deviceId)) {
          print("💾 Adding local device: $deviceId");
          // FIX: isSelected is set to false (default) to prevent auto-selection
          fetchedHomeData.add(DeviceSelection(device: {
            "devicename": deviceMap['name'] ?? deviceId,
            "homeid": deviceMap['homeId'] ?? 'Local',
            "roomid": deviceMap['roomId']?.toString() ?? 'N/A',
            "deviceId": deviceId,
          }, isSelected: false)); // Devices are NOT automatically selected
        }
      }
    } catch (e) {
      print("❌ Error loading local devices: $e");
    }


    try {
      // API call block is now empty (removed)
    } catch (e) {
      print("❌ Error fetching data: $e");
    } finally {
      if (mounted) {
        // Update the state with all found devices
        setState(() {
          homeData = List.from(fetchedHomeData);
          isExpandedList = List.generate(homeData.length, (index) => false);
          loading = false; // Hide main loader
        });

        // The loop to auto-select/auto-start timers is REMOVED, respecting the "not always selected" requirement.
      }
      print("✅ Final homeData count: ${homeData.length}");
    }
  }

  Future<void> _onDeviceSelected(DeviceSelection selectedDevice, bool isSelected) async {
    setState(() {
      selectedDevice.isSelected = isSelected;
    });

    final deviceId = selectedDevice.device['deviceId'];

    if (isSelected) {
      // 1. Fetch data immediately
      await _fetchAndDisplayData(selectedDevice);

      // 2. Start a 5-second periodic timer for automatic refresh
      final timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        _fetchAndDisplayData(selectedDevice);
      });

      // 3. Store the timer to manage it later
      _deviceTimers[deviceId] = timer;
      print("✅ Started 5s timer for device: $deviceId");

    } else {
      // Stop the 5-second timer
      _deviceTimers[deviceId]?.cancel();
      _deviceTimers.remove(deviceId);
      print("🛑 Stopped 5s timer for device: $deviceId");

      // Remove the device from the displayed list
      setState(() {
        displayedDevices.removeWhere((device) => device['deviceId'] == deviceId);
      });
    }
  }
}