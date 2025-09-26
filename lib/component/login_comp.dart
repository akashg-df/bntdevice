
import 'package:dfdevicewebview/typography.dart';
import 'package:dfdevicewebview/widget/bttnicon_widget.dart';
import 'package:dfdevicewebview/widget/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginComp{

  Widget headingText(){
    return const Column(
      children: [
        TextWidget(
          text: "Login to your account",
          color: Colors.black54,
          fontsize: bodyMedium,
          fontWeight: medium,
          letterspacing: 1,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget buildConfirmBttn() {
    return Card(
      elevation: 5,
      child: BttnIconWidget(
        height: 35,
        width: 100,
        containerColor: sec,
        text: "Confirm",
        fontSize: bodyMedium,
        txtColor: priBg,
        icon: Icons.verified_outlined,
        iconColor: priBg,
        iconSize: 20,
      ),
    );
  }

  Widget buildSubmitBttn() {
    return Card(
      elevation: 5,
      child: BttnIconWidget(
        height: 35,
        width: 90,
        containerColor: buttonNavy,
        text: "Login",
        fontSize: bodyMedium,
        txtColor: priBg,
        icon: CupertinoIcons.arrow_right_circle_fill,
        iconColor: priBg,
        iconSize: 20,
      ),
    );
  }

  Widget buildResetBttn() {
    return Card(
      elevation: 5,
      child: BttnIconWidget(
        height: 35,
        width: 90,
        containerColor: accentRed,
        text: "Reset",
        fontSize: bodyMedium,
        txtColor: priBg,
        icon: CupertinoIcons.arrow_2_circlepath_circle,
        iconColor: priBg,
        iconSize: 20,
      ),
    );
  }

}
