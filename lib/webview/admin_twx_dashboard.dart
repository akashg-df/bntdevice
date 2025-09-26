import 'package:dfdevicewebview/component/add_device_comp.dart';
import 'package:dfdevicewebview/constant.dart';
import 'package:dfdevicewebview/model/device_data_manager.dart';
import 'package:dfdevicewebview/responsive.dart';
import 'package:dfdevicewebview/typography.dart';
import 'package:dfdevicewebview/utli/drawer_utils.dart';
import 'package:dfdevicewebview/utli/loader_utils.dart';
import 'package:dfdevicewebview/widget/fieldheading_widget.dart';
import 'package:dfdevicewebview/widget/text_widget.dart';
import 'package:flutter/material.dart';

class AdminTwxDashboard extends StatefulWidget {
  const AdminTwxDashboard({super.key});

  @override
  _AdminTwxDashboardState createState() => _AdminTwxDashboardState();
}

class _AdminTwxDashboardState extends State<AdminTwxDashboard> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool loading = false;

  List<Device> devices = [];

  // Controllers for new device
  TextEditingController deviceNameCtrl = TextEditingController();
  TextEditingController deviceCategoryCtrl = TextEditingController();
  TextEditingController deviceMacCtrl = TextEditingController();
  TextEditingController devicefilter = TextEditingController();

  // To hold the selected device from the dropdown
  String? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      loading = true;
    });
    final loadedDevices = await DeviceDataManager.loadDevices();
    setState(() {
      devices = loadedDevices;
      loading = false;
    });
  }

  Future<void> _addDevice() async {
    // Ensure a device is selected from the dropdown
    if (_selectedDevice == null || _selectedDevice!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a device.')),
      );
      return;
    }

    // 💡 FIX: Use hardcodedDevicesPart1 to find the correct device details
    final deviceDetails = hardcodedDevicesPart1.firstWhere(
            (d) => d['deviceid'] == _selectedDevice,
        orElse: () => {});

    if (deviceDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected device not found in list.')),
      );
      return;
    }

    // Correctly create the Device model with all required fields
    final newDevice = Device(
      name: deviceDetails['name']!,
      category: deviceDetails['devicetype']!,
      mac: deviceDetails['deviceid']!,
      homeId: deviceDetails['homeid']!,
      roomId: deviceDetails['roomid']!,
    );

    setState(() {
      devices.add(newDevice);
      deviceNameCtrl.clear();
      deviceCategoryCtrl.clear();
      deviceMacCtrl.clear();
      _selectedDevice = null; // Reset the dropdown selection
    });

    await DeviceDataManager.saveDevices(devices);
    Navigator.pop(context); // Close the dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device added successfully!')),
    );
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Responsive(
      mobile: mobileView(width, height),
      tablet: tabView(width, height),
      desktop: desktopView(width, height),
    );
  }

  mobileView(width, height) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: priBg, // Light gray background
      drawer: DrawerUtils(scaffoldKey: _scaffoldKey),
      appBar: appBar(),
      body: loading
          ? LoaderUtils().circularLoader()
          : desktoptabViewbody(width, height),
      floatingActionButton: addDeviceFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  tabView(width, height) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: priBg, // Light gray background
      drawer: DrawerUtils(scaffoldKey: _scaffoldKey),
      appBar: appBar(),
      body: loading
          ? LoaderUtils().circularLoader()
          : desktoptabViewbody(width, height),
      floatingActionButton: addDeviceFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  desktopView(width, height) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: priBg, // Light gray background
      drawer: DrawerUtils(scaffoldKey: _scaffoldKey),
      appBar: appBar(),
      body: loading
          ? LoaderUtils().circularLoader()
          : desktoptabViewbody(width, height),
      floatingActionButton: addDeviceFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
          size: 28, // <-- set size here
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      title: InkWell(
        onTap: (){
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (BuildContext context) => const CustomerView(),
          //   ),
          // );
        },
        child: TextWidget(
          text: 'DF- Admin',
          fontWeight: semiBold,
          fontsize: titleLarge,
          color: priBg,
        ),
      ),
    );
  }

  // Body
  Widget desktoptabViewbody(width, height) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: 'Device Management',
                              fontWeight: semiBold,
                              fontsize: 24,
                              color: Colors.black87,
                            ),
                            const SizedBox(height: 4),
                            TextWidget(
                              text: 'View, sort, and manage your devices.',
                              fontsize: 16,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE0E0E0)),
                  Expanded(
                    child: deviceList(width),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // UPDATED: This widget is now a dropdown menu
  Widget deviceNameField() {
    return DropdownButtonFormField<String>(
      value: _selectedDevice,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        hintText: 'Select a device',
        hintStyle: TextStyle(fontSize: bodyMedium, fontWeight: normal),
      ),
      items: hardcodedDevicesPart1.map((device) {
        return DropdownMenuItem<String>(
          value: device['deviceid'],
          child: Text(
            device['name']!,
            style: const TextStyle(fontSize: bodyMedium, fontWeight: normal),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedDevice = newValue;
          final deviceDetails = hardcodedDevicesPart1.firstWhere(
                  (d) => d['deviceid'] == newValue,
              orElse: () => {});
          if (deviceDetails.isNotEmpty) {
            deviceNameCtrl.text = deviceDetails['name']!;
            deviceCategoryCtrl.text = deviceDetails['devicetype']!;
            deviceMacCtrl.text = deviceDetails['deviceid']!;
          }
        });
      },
      validator: (value) => value == null ? 'Please select a device' : null,
    );
  }


  Widget deviceCategoryField() {
    return TextFormField(
      controller: deviceCategoryCtrl,
      readOnly: true, // Make it read-only
      textAlignVertical: TextAlignVertical.center,
      style: const TextStyle(fontSize: bodyMedium, fontWeight: normal),
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        hintText: 'Device category will be auto-filled',
        hintStyle: TextStyle(fontSize: bodyMedium, fontWeight: normal),
      ),
    );
  }

  Widget deviceMacField() {
    return TextFormField(
      controller: deviceMacCtrl,
      readOnly: true, // Make it read-only
      textAlignVertical: TextAlignVertical.center,
      style: const TextStyle(fontSize: bodyMedium, fontWeight: normal),
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        hintText: 'Device MAC will be auto-filled',
        hintStyle: TextStyle(fontSize: bodyMedium, fontWeight: normal),
      ),
    );
  }

  // Device List
  Widget deviceList(width) {
    // Convert hardcodedDevices (Map) -> Device objects
    final hardcodedAsDevices = hardcodedDevices.map((d) => Device(
      name: d['name'] ?? '',
      category: d['devicetype'] ?? '',
      mac: d['deviceid'] ?? '',
      homeId: d['homeid'] ?? '',
      roomId: d['roomid'] ?? '',
    )).toList();

    // Merge with saved devices
    final combinedDevices = [...hardcodedAsDevices, ...devices];

    if (combinedDevices.isEmpty) {
      return Center(
        child: TextWidget(
          text: "No devices added yet.",
          color: Colors.grey,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: width,
          child: DataTable(
            showCheckboxColumn: false,
            headingRowColor: MaterialStateProperty.all(Colors.transparent),
            dataRowColor: MaterialStateProperty.all(Colors.transparent),
            columnSpacing: 40,
            horizontalMargin: 20,
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
            dataTextStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: Colors.black87,
            ),
            columns: const [
              DataColumn(label: Text('S.No.')),
              DataColumn(label: Text('Device Name')),
              DataColumn(label: Text('Device Type')),
            ],
            rows: List.generate(combinedDevices.length, (index) {
              final device = combinedDevices[index];

              // Check if this device came from hardcoded list
              final hardcoded = hardcodedDevices.firstWhere(
                    (d) => d['deviceid'] == device.mac,
                orElse: () => {},
              );

              return DataRow(
                cells: [
                  DataCell(Text("${index + 1}")),
                  DataCell(Text(device.name)),
                  DataCell(Text(device.category)),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // Floating Button
  Widget addDeviceFab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: FloatingActionButton.extended(
        backgroundColor: buttonNavyLight,
        onPressed: () => showAddDeviceDialog(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Device",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Dialog for Adding Device
  void showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            double dialogHeight = 500; // adjust as needed
            double dialogWidth = 550;

            return Dialog(
              backgroundColor: Colors.transparent, // allow AnimatedContainer bg to show
              insetPadding: const EdgeInsets.all(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: dialogHeight,
                width: dialogWidth,
                decoration: BoxDecoration(
                  color: priBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    backgroundColor: buttonNavy,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: priBg),
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    title: TextWidget(
                      text: 'Add New Device',
                      fontWeight: semiBold,
                      fontsize: titleMedium,
                      color: terText,
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Device Name Field
                          const Headingtextwidget(text1: "Device Name"),
                          const SizedBox(height: 10),
                          deviceNameField(), // This will now show the dropdown

                          const SizedBox(height: 20),

                          // Device Category Field
                          const Headingtextwidget(text1: "Device Category"),
                          const SizedBox(height: 10),
                          deviceCategoryField(),


                          const SizedBox(height: 30),

                          // Action Buttons
                          Center(
                            child: InkWell(
                              onTap: _addDevice,
                              child: AddDeviceComp().buildAddBttn(),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}