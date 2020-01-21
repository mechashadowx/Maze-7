import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maze/helper.dart';
import 'home/HomePage.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: black,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maze',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Quicksand',
      ),
      home: HomePage(),
    );
  }
}
