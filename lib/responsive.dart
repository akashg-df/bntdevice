import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  const Responsive({
    super.key ,
    this.mobile,
    this. tablet,
    this.desktop
  });

  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;

  static bool isTab(BuildContext context) => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    if(isMobile(context)){
      return mobile!;
    }
    else if (isDesktop(context)) {
      return desktop!;
    } else {
      return tablet!;
    }
  }
}