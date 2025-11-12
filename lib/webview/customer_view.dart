import 'dart:async';
import 'dart:convert';
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
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


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

  // NEW: State variable to store the token for dream-filler API
  String? _dreamFillerToken;


  @override
  void initState() {
    super.initState();
    // NEW: Get the dream-filler token immediately after the main login process
    _performLoginAndRefresh().then((_) async {
      await _getDreamFillerToken(); // Fetch dream-filler token
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
      body: desktoptabViewbody(width, height),
    );
  }

  desktopView(width, height) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: priBg,
      drawer: DrawerUtils(scaffoldKey: _scaffoldKey),
      appBar: appBar(),
      body:  desktoptabViewbody(width, height),
    );
  }

  tabletView(width, height) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: priBg,
      drawer: DrawerUtils(scaffoldKey: _scaffoldKey),
      appBar: appBar(),
      body: desktoptabViewbody(width, height),
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

    // Check if homeData is empty
    final deviceListContent = homeData.isEmpty
        ? Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Text(
          'No devices available. Please add a device.',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    )
        : ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: homeData.length,
      itemBuilder: (context, index) {
        final deviceItem = homeData[index];
        final deviceName =
            deviceItem.device['devicename'] ?? "Unnamed Device";

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
          //  border: Border.all(color: Colors.black12),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding:
            EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20, vertical: 0),
            title: Text(
              'Select Devices',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            children: [
              const Divider(height: 1, thickness: 1, color: Colors.black12),
              Padding(
                padding: const EdgeInsets.all(10),
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
  Future<bool> _performLoginAndRefresh() async {
    var headers = {
      'Authorization':
      'Basic YnJvYW4tY2lhcS1hcHAuY2xpZW50LmU0OGJmY2U5YjA0NzQ1OWE4OGVjYzQyZGFlZGQ1M2UzOjdlZTc1NmJjY2QzYWUwMzFlZjUzZDFhOTM4ZWJmMDdmOTA1Zjg4MTllNzdmNzliZjAyNTc5NDUxNTk0MWVjNzA=',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    var body = {
      "grant_type": "password",
      "username": "testing23@mailinator.com",
      "password": "Qwerty@123",
    };

    try {
      var response = await http.post(
        Uri.parse(
            "https://overtureiot.broan-nutone.com/overturev2/api/v1/ciaq/oauth/token"),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String accessToken = data['access_token'];
        await _fetchData();
        // Save token in local storage
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);

        return true;
      } else {
        debugPrint("Login failed: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

  // NEW: Function to get token for dream-filler API
    Future<void> _getDreamFillerToken() async {
    // ✅ Correct way: separate client_id and client_secret, then Base64 encode
    const String clientId = 'df-device-6e3d05c5-66ab-4eaf-b31c-5b398376c38f';
    const String clientSecret = 'fbc1d87e36f3abcef83d6a8aef26e0eba819d40adc06034acb1b315d77e73c6f';

    // Encode properly as "clientId:clientSecret"
    final String correctBase64Auth =
    base64Encode(utf8.encode('$clientId:$clientSecret'));

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Basic $correctBase64Auth',
    };

    // 💡 Encode body for x-www-form-urlencoded
    final Map<String, String> bodyMap = {
      'grant_type': 'password',
      'username': 'risb@gmail.com',
      'password': 'Qwerty@123',
    };

    final encodedBody = bodyMap.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    try {
      print("🌐 Requesting Dream-Filler token...");

      final response = await http.post(
        Uri.parse('https://iotdevice.dream-filler.com/api/auth/token'),
        headers: headers,
        body: encodedBody,
      );

      print("📥 Response status: ${response.statusCode}");
      print("📦 Raw response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _dreamFillerToken = data['accessToken'];
        print("✅ Dream-Filler Token obtained successfully.");
      } else {
        print("❌ Dream-Filler Token failed: ${response.statusCode}");
        print("Reason: ${response.reasonPhrase}");
        _dreamFillerToken = null;
      }
    } catch (e, stack) {
      print("⚠️ Error getting Dream-Filler Token: $e");
      print("📚 StackTrace: $stack");
      _dreamFillerToken = null;
    }
  }


  // NEW: Function to fetch data for a single device without triggering the main screen loader
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
    bool isDreamFillerDevice = false;

    if (anotherHardcodedDevices.any((d) => d['deviceid'] == deviceId)) {
      currentApiUrl = '$newApiUrl$deviceId';
      isDreamFillerDevice = true;
    } else {
      currentApiUrl = '$existingApiUrl$deviceId';
    }

    final Map<String, String>? headers = {'home_id': homeId};

    try {
      dynamic sensorDataResponse;
      if (isDreamFillerDevice) {
        // Use the new token and a dedicated GET function that accepts a token
        if (_dreamFillerToken == null) {
          print("⚠️ Dream-Filler Token is missing. Re-attempting fetch.");
          await _getDreamFillerToken();
          if (_dreamFillerToken == null) {
            throw Exception("Dream-Filler Token is still null after re-attempt.");
          }
        }
        sensorDataResponse = await _apiClient.getWithToken(
            currentApiUrl!,
            _dreamFillerToken!,
            customHeaders: headers);
      } else {
        // Use the existing client method which relies on the stored token (OvertureIOT)
        sensorDataResponse = await _apiClient.get(
            currentApiUrl!,
            customHeaders: headers);
      }


      if (!mounted) return;

      Map<String, dynamic> deviceDetails;
      bool isConnected = true; // Default assumption for connected state

      if (isDreamFillerDevice) {
        // --- DREAM-FILLER RESPONSE HANDLING ---
        // Response is a List: [ { ... sensor data ... } ]
        if (sensorDataResponse is List && sensorDataResponse.isNotEmpty) {
          final dataMap = sensorDataResponse[0];

          // Map Dream-Filler keys to the structure expected by the rest of the code
          deviceDetails = {
            // Assume connected if data successfully retrieved
            'isConnected': true,
            'iaqindex': dataMap['aqi'],
            'temperature': dataMap['temperature'],
            'co2': dataMap['co2'],
            'tvoc': dataMap['tvoc'],
            'pm2_5': dataMap['pm25'], // Key difference: 'pm25' in JSON, 'pm2_5' in display
            'humidity': dataMap['humidity'],
          };
          isConnected = deviceDetails['isConnected'];
        } else {
          // Handle case where list is empty or invalid
          throw Exception("Invalid or empty Dream-Filler sensor data response.");
        }
      } else {
        // --- OVERTUREIOT RESPONSE HANDLING ---
        // Response is a Map: { "deviceDetailsDTO": { ... } }
        deviceDetails = sensorDataResponse['deviceDetailsDTO'];
        isConnected = deviceDetails['isConnected'];
      }


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
            displayedDevices[index]['iaqindex'] = 'Error';
            displayedDevices[index]['temperature'] = 'Error';
            displayedDevices[index]['co2'] = 'Error';
            displayedDevices[index]['tvoc'] = 'Error';
            displayedDevices[index]['pm2_5'] = 'Error';
            displayedDevices[index]['humidity'] = 'Error';
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

    // Stop and clear all individual device timers for removed devices
    final existingDeviceIds = homeData.map((d) => d.device['deviceId'] ?? '').toSet();

    _deviceTimers.forEach((deviceId, timer) {
      if (!existingDeviceIds.contains(deviceId)) {
        timer.cancel();
        _deviceTimers.remove(deviceId);
        displayedDevices.removeWhere((d) => d['deviceId'] == deviceId);
      }
    });

    final Set<String> processedDeviceIds = {};
    final List<DeviceSelection> fetchedHomeData = [];

    // Map home names from hardcoded list
    for (var d in allAvailableDevices) {
      final homeId = d['homeid']!;
      final homeName = d['homename']!;
      homeNames[homeId] = homeName;
    }

    // Load locally saved devices
    try {
      final localDevices = await DeviceDataManager.loadDevices();

      for (var device in localDevices) {
        final Map<String, dynamic> deviceMap = device.toJson();
        final deviceId = deviceMap['mac'] ?? 'unknown';

        if (deviceId != 'unknown' && processedDeviceIds.add(deviceId)) {
          // Preserve previous selection state if exists
          final previous = homeData.firstWhere(
                  (d) => d.device['deviceId'] == deviceId,
              orElse: () => DeviceSelection(device: {}, isSelected: false));

          fetchedHomeData.add(DeviceSelection(
            device: {
              "devicename": deviceMap['name'] ?? deviceId,
              "homeid": deviceMap['homeId'] ?? 'Local',
              "roomid": deviceMap['roomId']?.toString() ?? 'N/A',
              "deviceId": deviceId,
            },
            isSelected: previous.isSelected, // Preserve checkbox state
          ));
        }
      }
    } catch (e) {
      print("❌ Error loading local devices: $e");
    }

    if (mounted) {
      setState(() {
        homeData = List.from(fetchedHomeData);
        isExpandedList = List.generate(homeData.length, (index) => false);
      });

      // Re-start timers for devices that are still selected
      for (var deviceSelection in homeData) {
        if (deviceSelection.isSelected) {
          final deviceId = deviceSelection.device['deviceId'];
          // Cancel existing timer if any
          _deviceTimers[deviceId]?.cancel();

          // Start a new 5-second timer
          _deviceTimers[deviceId] = Timer.periodic(const Duration(seconds: 5), (timer) {
            _fetchAndDisplayData(deviceSelection);
          });

          // Fetch immediately
          _fetchAndDisplayData(deviceSelection);
        }
      }
    }

    print("✅ Final homeData count: ${homeData.length}");
  }

  Future<void> _onDeviceSelected(DeviceSelection selectedDevice, bool isSelected) async {
    setState(() {
      selectedDevice.isSelected = isSelected;
    });

    final deviceId = selectedDevice.device['deviceId'];
    // Cancel any existing timer for this device
    _deviceTimers[deviceId]?.cancel();
    _deviceTimers.remove(deviceId);

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