import 'package:encryption/styling.dart';
import 'package:flutter/material.dart';
import 'customText.dart';

class CustomFlatButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback callback;
  final double height;
  final double width;
  final double radius;
  final Widget child;
  final double fontSize;

  const CustomFlatButton(
      {Key key,
      this.text,
      this.color,
      this.callback,
      this.textColor,
      this.height,
      this.width,
      this.radius,
      this.child,
      this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: height ?? 45,
      minWidth: width ?? 200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radius))),
      onPressed: callback,
      color: color ?? primaryColor,
      child: child ??
          CustomText(
            text: text ?? '',
            color: textColor,
            size: fontSize,
          ),
    );
  }
}
