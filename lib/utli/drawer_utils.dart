import 'dart:convert';

import 'package:dfdevicewebview/typography.dart';
import 'package:dfdevicewebview/webview/admin_twx_dashboard.dart';
import 'package:dfdevicewebview/webview/customer_view.dart';
import 'package:dfdevicewebview/widget/hover_menu_tile.dart';
import 'package:dfdevicewebview/widget/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class DrawerUtils extends StatefulWidget {
  var scaffoldKey;

  DrawerUtils({super.key, required this.scaffoldKey});

  @override
  State<DrawerUtils> createState() => _DrawerUtilsState();
}

class _DrawerUtilsState extends State<DrawerUtils> {
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: priBg,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 50),

                // For School image
                // Replace Network Image with Asset Image
                ClipOval(
                  child: Image.asset(
                    "assets/df.png", // <-- put your asset image path
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),

                // For User Name
                TextWidget(
                  text: "Better Air, Better life",
                  fontWeight: semiBold,
                  fontsize: bodyMedium,
                  oflow: TextOverflow.ellipsis,
                  color: secText,
                ),

                const SizedBox(height: 5),

                // For User Role
                TextWidget(
                  text: "",
                  fontWeight: medium,
                  fontsize: bodySmall,
                  oflow: TextOverflow.ellipsis,
                  color: secText,
                ),

                const Divider(
                  indent: 8.0,
                  endIndent: 8.0,
                ),


                HoverDrawerTile(
                  icon: CupertinoIcons.settings_solid, // Profile Settings
                  label: "Dashboard",
                  onTap: () {
                    widget.scaffoldKey.currentState!.closeDrawer();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const CustomerView(),
                      ),
                    );
                  },
                ),
                const Divider(indent: 8.0, endIndent: 8.0),
                const SizedBox(height: 10),

                HoverDrawerTile(
                  icon: CupertinoIcons.home, // Home
                  label: "Device Management",
                  onTap: () {
                    widget.scaffoldKey.currentState!.closeDrawer();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const AdminTwxDashboard(),
                      ),
                    );

                  },
                ),
                const Divider(indent: 8.0, endIndent: 8.0),
                const SizedBox(height: 10),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
