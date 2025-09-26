


import 'package:dfdevicewebview/typography.dart';
import 'package:dfdevicewebview/widget/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Headingtextwidget extends StatelessWidget {
  final String? text1;
  final String? text2;
  final String? text3;

  const Headingtextwidget({super.key, this.text1, this.text2,this.text3});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextWidget(
          text: text1,
          fontWeight: semiBold,
          fontsize: titleSmall,
        ),
        const SizedBox(
          width: 4,
        ),
        TextWidget(
          text: text3,
          fontWeight: semiBold,
          fontsize: titleSmall,
          color: Colors.red,
        ),
        const SizedBox(
          width: 8,
        ),
        if(text2 != null)
          Tooltip(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black),
          excludeFromSemantics: true,
          margin: const EdgeInsets.all(10),
          preferBelow: false,
          verticalOffset: 0,
          textAlign: TextAlign.justify,
          message: '''$text2''',
          child: const Icon(
            CupertinoIcons.question_circle,
          ),
        ),
      ],
    );
  }
}
