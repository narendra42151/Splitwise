import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Testscreen extends StatefulWidget {
  Testscreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _TestScreen();
  }
}

class _TestScreen extends State<Testscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("Test Screen")],
        ),
      ),
    );
  }
}
