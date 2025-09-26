
import 'package:dfdevicewebview/typography.dart';
import 'package:flutter/material.dart';

class LoaderUtils{

  Widget circularLoader(){
    return Center(
      child: CircularProgressIndicator(
        color: pri,
      ),
    );
  }

  Widget linearLoader(){
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50),
      child: Center(
        child: LinearProgressIndicator(
          color: pri,
        ),
      ),
    );
  }

}

class CircularLoaderUtils extends StatelessWidget {
  const CircularLoaderUtils({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: priBg,
      body: LoaderUtils().circularLoader());
  }
}