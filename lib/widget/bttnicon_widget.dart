
import 'package:dfdevicewebview/typography.dart';
import 'package:dfdevicewebview/widget/text_widget.dart';
import 'package:flutter/material.dart';


class BttnIconWidget extends StatelessWidget {
  final double? height, width, fontSize;
  final Color? containerColor, txtColor, iconColor;
  final String? text;
  final IconData? icon;
  final double? iconSize;

  const BttnIconWidget({
    super.key,
    required this.height,
    required this.width,
    required this.containerColor,
    this.txtColor,
    this.fontSize,
    this.text,
    this.icon,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: containerColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWidget(
            text: text,
            fontWeight: semiBold,
            color: txtColor,
            fontsize: fontSize,
          ),
          const SizedBox(width: 5,),
          Icon(
            icon,
            size: iconSize,
            color: iconColor,
          )
        ],
      ),
    );
  }
}

class IconWidget extends StatelessWidget {
  final double? height, width;
  final Color? containerColor, txtColor, iconColor;
  final IconData? icon;
  final double? iconSize;

  const IconWidget({
    super.key,
    required this.height,
    required this.width,
    required this.containerColor,
    this.txtColor,
    this.icon,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: containerColor,
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor,
      ),
    );
  }
}

