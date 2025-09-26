import 'package:dfdevicewebview/typography.dart';
import 'package:dfdevicewebview/widget/bttnicon_widget.dart';
import 'package:dfdevicewebview/widget/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class AddDeviceComp{

  Widget emptyList(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 80,
            color: accentAmber,
          ),
          const SizedBox(
            height: 10,
          ),
          TextWidget(
            text: 'Please Selected the device',
            fontWeight: semiBold,
            fontsize: titleMedium,
            color: priText,
          ),
        ],
      ),
    );
  }

  // Add Student --------------
  Widget createHeading(){
    return TextWidget(
      text: 'Add Student',
      fontWeight: semiBold,
      fontsize: titleMedium,
      color: secText,
    );
  }

  Widget updateHeading(){
    return TextWidget(
      text: 'Update Student',
      fontWeight: semiBold,
      fontsize: titleMedium,
      color: secText,
    );
  }

  Widget readHeading(){
    return TextWidget(
      text: 'Read Only',
      fontWeight: semiBold,
      fontsize: titleMedium,
      color: secText,
    );
  }

  Widget buildSearchBttn() {
    return Card(
      elevation: 5,
      child: BttnIconWidget(
        height: 35,
        width: 80,
        containerColor: alt,
        text: "Search",
        fontSize: bodySmall,
        txtColor: priBg,
        icon: CupertinoIcons.search_circle_fill,
        iconColor: priBg,
        iconSize: 20,
      ),
    );
  }

  Widget buildupdateBttn() {
    return Card(
      elevation: 5,
      child: BttnIconWidget(
        height: 35,
        width: 140,
        containerColor: buttonNavy,
        text: "Update",
        fontSize: bodySmall,
        txtColor: priBg,
        icon: CupertinoIcons.arrow_2_circlepath_circle,
        iconColor: priBg,
        iconSize: 20,
      ),
    );
  }

  Widget buildcancelBttn() {
    return Card(
      elevation: 5,
      child: BttnIconWidget(
        height: 35,
        width: 80,
        containerColor: priText,
        text: "Cancel",
        fontSize: bodySmall,
        txtColor: priBg,
        icon: CupertinoIcons.arrow_2_circlepath_circle,
        iconColor: priBg,
        iconSize: 20,
      ),
    );
  }


  Widget buildlistAddBttn() {
    return Card(
      elevation: 5,
      child: BttnIconWidget(
        height: 45,
        width: 250,
        containerColor: buttonNavy,
        text: "Add New Device",
        fontSize: bodyMedium,
        txtColor: priBg,
        icon: CupertinoIcons.add_circled,
        iconColor: priBg,
        iconSize: 20,
      ),
    );
  }

  Widget buildAddBttn() {
    return Card(
      elevation: 5,
      child: BttnIconWidget(
        height: 40,
        width: 200,
        containerColor: buttonNavy,
        text: "Add Device",
        fontSize: bodyMedium,
        txtColor: priBg,
        icon: CupertinoIcons.add_circled,
        iconColor: priBg,
        iconSize: 20,
      ),
    );
  }



}
