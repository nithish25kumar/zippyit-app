import 'package:flutter/material.dart';

class Uihelper {
  static Widget CustomImage(
      {required String img, double? height, double? width}) {
    return Image.asset(
      "assets/images/$img",
      height: height,
      width: width,
      fit: BoxFit.contain,
    );
  }

  static CustomText(
      {required String text,
      required Color color,
      required FontWeight fontweight,
      String? fontfamily,
      required double fontsize}) {
    return Text(text,
        style: TextStyle(
            fontSize: fontsize,
            fontFamily: fontfamily ?? "regular",
            fontWeight: fontweight,
            color: color));
  }

  static Widget CustomTextField({
    required TextEditingController controller,
  }) {
    return Container(
      height: 40,
      width: 360,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: Border.all(color: Color(0XFFC5C5C5)),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 14),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          hintText: "Talk. Tap. Discoverd",
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  static CustomButton(VoidCallback callback) {
    return Container(
      height: 18,
      width: 30,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0XFF27AF34)),
          borderRadius: BorderRadius.circular(4)),
      child: Center(
        child: Text(
          "Add",
          style: TextStyle(fontSize: 8, color: Color(0XFF27AF34)),
        ),
      ),
    );
  }
}
