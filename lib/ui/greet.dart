import 'dart:async';

import 'package:bill_splitter/ui/BillSplitter.dart';
import 'package:flutter/material.dart';

import '../util/hexcolor.dart';

class Greeting extends StatefulWidget {
  final String name;
  const Greeting({required this.name, Key? key}) : super(key: key);

  @override
  State<Greeting> createState() => _GreetingState();
}

class _GreetingState extends State<Greeting> {
  final Color _purple = HexColor("#6908D6");
  String getFirstName() {
    // Split the 'name' using the space character as the delimiter and return the first part (first name).
    return widget.name.split(" ")[0];
  }

  void initState() {
    super.initState();
    // Wait for 1 second using Timer and then navigate to the Bill Splitter screen
    Timer(Duration(seconds: 1, milliseconds: 900), () {
      navigateToBillSplitter();
    });
  }

  void navigateToBillSplitter() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BillSplitter(name: widget.name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: _purple.withOpacity(0.2),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                "Registering ${getFirstName()}",
                style: const TextStyle(fontSize: 35, fontWeight: FontWeight.w600),
              ),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
