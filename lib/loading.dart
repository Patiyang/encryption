import 'package:encryption/styling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'customText.dart';

class Loading extends StatefulWidget {
  final String text;
  final Color color;
  final double loadingSize;
  final double fontSize;
  const Loading({Key key, this.text, this.color, this.fontSize, this.loadingSize}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool lightTheme = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: lightTheme == true ? grey[100] : grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: SpinKitFadingGrid(color: lightTheme == true ? black : white, size: 20)),
          SizedBox(height: 10),
          CustomText(text: widget.text ?? '', letterSpacing: .3, fontWeight: FontWeight.w500, size: widget.fontSize ?? 15)
        ],
      ),
    );
  }
}

class LoadingImages extends StatefulWidget {
  final String text;
  final Color spinkitColor;
  final Color containerColor;
  final double size;
  const LoadingImages({Key key, this.text, this.size, this.containerColor, this.spinkitColor}) : super(key: key);

  @override
  _LoadingImagesState createState() => _LoadingImagesState();
}

class _LoadingImagesState extends State<LoadingImages> {
  bool lightTheme = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: lightTheme == true ? grey[100] : grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SpinKitCubeGrid(color: lightTheme == true ? black : white, size: widget.size ?? 25),
          ),
          SizedBox(height: 10),
          CustomText(text: widget.text ?? '', letterSpacing: .3, fontWeight: FontWeight.w500, size: 15)
        ],
      ),
    );
  }
}
