import 'package:encryption/styling.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double size;
  final double letterSpacing;
  final Color color;
  final FontWeight fontWeight;
  final TextOverflow overflow;
  final int maxLines;
  final TextAlign textAlign;

  const CustomText({
    Key key,
    @required this.text,
    this.size,
    this.color,
    this.fontWeight,
    this.letterSpacing,
    this.overflow,
    this.maxLines,
    this.textAlign,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines ?? 700,
      overflow: overflow ?? TextOverflow.fade,
      style: TextStyle(
          // fontFamily: 'Helvetica',
          fontSize: size,
          color: color ?? black,
          fontWeight: fontWeight ?? FontWeight.normal,
          letterSpacing: letterSpacing ?? 0),
    );
  }
}

class CustomRichText extends StatelessWidget {
  final String lightFont;
  final String boldFont;
  final double lightFontSize;
  final double boldFontSize;
  final double letterSpacing;
  final VoidCallback lightCallback;
  final VoidCallback boldCallback;
  final Color lightColor;
  final Color boldColor;

  const CustomRichText(
      {Key key,
      this.lightFont,
      this.boldFont,
      this.lightFontSize,
      this.boldFontSize,
      this.letterSpacing,
      this.lightCallback,
      this.boldCallback,
      this.lightColor,
      this.boldColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: lightCallback,
      child: RichText(textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(children: [
          TextSpan(
              text: lightFont,
              style: TextStyle(
                  color: lightColor ?? black.withOpacity(.6),
                  fontSize: lightFontSize ?? 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Helvetica')),
          TextSpan(
              text: boldFont,
              style: TextStyle(
                  color: boldColor ?? black,
                  fontSize: boldFontSize ?? 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: letterSpacing,
                  fontFamily: 'Helvetica')),
        ]),
      ),
    );
  }
}
