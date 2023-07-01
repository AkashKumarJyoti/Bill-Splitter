import 'package:bill_splitter/first%20page/splash_services.dart';
import 'package:bill_splitter/util/hexcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Color _purple = HexColor("#6908D6");
  SplashServices splashScreen = SplashServices();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    splashScreen.Welcome(context);
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async
      {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        // backgroundColor: _purple.withOpacity(0.1),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _purple.withOpacity(0.2),
                _purple.withOpacity(0.4),
                _purple.withOpacity(0.6),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset("images/icon.png"),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Text("Bill Splitter", style: TextStyle(
                    color: _purple.withOpacity(0.8),
                    fontSize: 35,
                    fontWeight: FontWeight.w600,
                  )),
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}



