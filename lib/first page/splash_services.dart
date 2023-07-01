import 'dart:async';
import 'package:bill_splitter/ui/BillSplitter.dart';
import 'package:bill_splitter/ui/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SplashServices {
  Future<void> Welcome(BuildContext context) async {
    String? name = await getUserData();

    bool ans = await isFirestoreEmpty();

    Timer(const Duration(seconds: 1, milliseconds: 500), () {
      if (ans) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomePage()));
      } else {
        if (name != null) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BillSplitter(name: name)));
        } else {
          print("Error: 'name' is null");
        }
      }
    });
  }

  Future<String?> getUserData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').limit(1).get();

      if (snapshot.size > 0) {
        final document = snapshot.docs[0];
        if (document.exists) {
          if (document.data()!.containsKey('Name')) {
            return document.get('Name');
          } else {
            return null;
          }
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting user data: $e");
      throw e;
    }
  }


  Future<bool> isFirestoreEmpty() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').limit(1).get();
      return snapshot.size == 0;
    } catch (e) {
      print("Error checking Firestore database: $e");
      throw e;
    }
  }
}
