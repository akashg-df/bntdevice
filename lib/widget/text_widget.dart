import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  final String? text;
  final double? fontsize;
  final FontWeight? fontWeight;
  final double? letterspacing;
  final Color? color;
  final int? maxline;
  final TextOverflow? oflow;
  final bool? softwrap;
  final TextDecoration? textDecoration;
  final Color? decorationColor;
  final TextAlign? textAlign;
  final FontStyle? fontStyle;
  final String? fontFamily;
  final TextStyle? customStyle;

  const TextWidget({
    super.key,
    required this.text,
    this.fontsize,
    this.fontWeight,
    this.letterspacing,
    this.color,
    this.maxline,
    this.oflow,
    this.softwrap = true,
    this.textDecoration,
    this.decorationColor,
    this.textAlign,
    this.fontStyle,
    this.fontFamily,
    this.customStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? '',
      overflow: oflow,
      maxLines: maxline,
      softWrap: softwrap,
      textAlign: textAlign,
      style: customStyle ?? TextStyle(
        decoration: textDecoration,
        decorationColor: decorationColor,
        fontSize: fontsize,
        fontWeight: fontWeight,
        letterSpacing: letterspacing,
        color: color,
        fontStyle: fontStyle,
        fontFamily: fontFamily,
      ),
    );
  }
}
