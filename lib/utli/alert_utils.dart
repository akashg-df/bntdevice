

import 'package:dfdevicewebview/typography.dart';
import 'package:dfdevicewebview/widget/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AlertUtils {
  confirmAlert(context, text, confirmTap) {
    QuickAlert.show(
        context: context,
        width: 350,
        type: QuickAlertType.confirm,
        backgroundColor: priBg,
        disableBackBtn: true,
        barrierDismissible: true,
        text: text,
        // title: "Are you Sure ?",
        confirmBtnText: 'Yes',
        cancelBtnText: 'No',
        confirmBtnColor: pri,
        confirmBtnTextStyle: TextStyle(
          color: priBg,
          fontWeight: semiBold,
          fontSize: bodyLarge,
        ),
        cancelBtnTextStyle: TextStyle(
          color: secText,
          fontWeight: semiBold,
          fontSize: bodyLarge,
        ),
        onConfirmBtnTap: confirmTap,
        onCancelBtnTap: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
  }

  errorAlert(context, text) {
    QuickAlert.show(
      context: context,
      width: 350,
      showCancelBtn: false,
      type: QuickAlertType.error,
      backgroundColor: priBg,
      disableBackBtn: true,
      barrierDismissible: true,
      text: text,
      confirmBtnText: 'Okay',
      confirmBtnColor: sec,
      confirmBtnTextStyle: TextStyle(
        color: priBg,
        fontWeight: semiBold,
        fontSize: bodyMedium,
      ),
      onConfirmBtnTap: () {
        Navigator.pop(context);
      },
    );
  }

  infoAlert(
    context,
    text,
    onConfirmBtnTap,
  ) {
    return QuickAlert.show(
      width: 350,
      barrierDismissible: false,
      context: context,
      type: QuickAlertType.info,
      title: "Info",
      text: text.toString(),
      titleColor: Colors.lightGreen,
      confirmBtnText: "Okay!",
      confirmBtnColor: sec,
      onConfirmBtnTap: onConfirmBtnTap,
      confirmBtnTextStyle: const TextStyle(
        fontSize: bodyMedium,
        color: Colors.white,
      ),
    );
  }

  wifiAlert(context) {
    QuickAlert.show(
      context: context,
      width: 350,
      showCancelBtn: false,
      type: QuickAlertType.info,
      backgroundColor: priBg,
      disableBackBtn: true,
      barrierDismissible: true,
      text: "You are not connected to Wifi. Please use organization Wifi.",
      confirmBtnText: 'Okay',
      confirmBtnColor: sec,
      confirmBtnTextStyle: TextStyle(
        color: priBg,
        fontWeight: semiBold,
        fontSize: bodyMedium,
      ),
      onConfirmBtnTap: () {
        Navigator.pop(context);
      },
    );
  }

  permissionAlert(context) {
    QuickAlert.show(
      context: context,
      width: 350,
      showCancelBtn: false,
      type: QuickAlertType.info,
      backgroundColor: priBg,
      disableBackBtn: true,
      barrierDismissible: true,
      text: "Please, Allow the location permission.",
      confirmBtnText: 'Okay',
      confirmBtnColor: sec,
      confirmBtnTextStyle: TextStyle(
        color: priBg,
        fontWeight: semiBold,
        fontSize: bodyMedium,
      ),
      onConfirmBtnTap: () {
        Navigator.pop(context);
      },
    );
  }


  // Wrong Client Id Alert
  errorClientAlert(context, text, onTap) {
    QuickAlert.show(
      context: context,
      width: 350,
      showCancelBtn: false,
      type: QuickAlertType.error,
      backgroundColor: priBg,
      disableBackBtn: true,
      barrierDismissible: true,
      text: text,
      confirmBtnText: 'Okay',
      confirmBtnColor: sec,
      confirmBtnTextStyle: TextStyle(
        color: priBg,
        fontWeight: semiBold,
        fontSize: bodyMedium,
      ),
      onConfirmBtnTap: onTap,
    );
  }

  sessionTimeOutAlertBox(context, onTap) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextWidget(
            text: "Session Expired",
            fontsize: bodyLarge,
            fontWeight: semiBold,
            color: priText,
          ),
          content: const TextWidget(
            text: "Please Login Again",
            fontsize: bodyMedium,
            fontWeight: medium,
          ),
          actions: [
            TextButton(
              onPressed: onTap,
              child: TextWidget(
                text: "Okay",
                color: priText,
                fontWeight: semiBold,
                fontsize: bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }

  authorizedAlert(context, onTap) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextWidget(
            text: "Session Timeout",
            fontsize: bodyMedium + 3,
            fontWeight: FontWeight.w600,
            color: sec,
          ),
          content: const TextWidget(
              text: "Login again.",
              fontsize: bodyMedium,
              fontWeight: FontWeight.w500),
          actions: [
            TextButton(
              onPressed: onTap,
              child: TextWidget(
                text: "Okay",
                color: sec,
                fontWeight: FontWeight.w500,
                fontsize: bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }
}
