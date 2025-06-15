import 'dart:convert';

import 'package:flutter/material.dart';

class AuthModel extends ChangeNotifier {
  bool _isLogin = false;
  Map<String, dynamic> user = {}; //update user details when login
  Map<String, dynamic> appointment =
      {}; //update upcoming appointment when login
  final String _profileImagePath = 'assets/profile.jpg';

  List<Map<String, dynamic>> favDoc = []; //get latest favorite doctor
  List<dynamic> _fav = []; //get all fav doctor id in list
  List<Map<String, dynamic>> _favDocs = [];
  String get profileImage => _profileImagePath;

  // List<Map<String, dynamic>> get getFavDoc => _favDocs;

  void toggleFavDoctor(String docId) {
    final index = _favDocs.indexWhere((doc) => doc['doc_id'] == docId);
    if (index != -1) {
      _favDocs.removeAt(index);
    } else {
      // optional: تضيفه لو مش موجود
    }
    notifyListeners();
  }
  bool get isLogin {
    return _isLogin;
  }

  List<dynamic> get getFav {
    return _fav;
  }

  Map<String, dynamic> get getUser {
    return user;
  }

  Map<String, dynamic> get getAppointment {
    return appointment;
  }

//this is to update latest favorite list and notify all widgets
  void setFavList(List<dynamic> list) {
    _fav = list;
    notifyListeners();
  }

//and this is to return latest favorite doctor list
  List<Map<String, dynamic>> get getFavDoc {
    favDoc.clear(); //clear all previous record before get latest list

    //list out doctor list according to favorite list
    for (var num in _fav) {
      for (var doc in user['doctor']) {
        if (num == doc['doc_id']) {
          favDoc.add(doc);
        }
      }
    }
    return favDoc;
  }

//when login success, update the status
  void loginSuccess(
      Map<String, dynamic> userData, Map<String, dynamic> appointmentInfo) {
    _isLogin = true;

    //update all these data when login
    user = userData;
    appointment = appointmentInfo;
    if (user['details']['fav'] != null) {
      _fav = json.decode(user['details']['fav']);
    }
    print(_fav);
    print(user);
    notifyListeners();
  }
}
