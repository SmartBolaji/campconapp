import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

final UniqueId idG = UniqueId();

class TaskData extends ChangeNotifier {
  // Info
  IconData _qicon = Icons.format_quote_outlined;
  IconData _aicon = Icons.notifications_outlined;
  IconData _todoicon = Icons.view_agenda_outlined;

  // Menu conditionals
  bool _showAd = true;
  bool _normal = true;
  bool _darkMode = false;
  // int _snapSize = 0;
  String _name = '';
  int _id = 0;
  double _points = 0.0;
  int _mpin = 0;
  String _month1 = DateFormat('MMMM').format(DateTime.now());
  String _month2 = DateFormat('MMMM').format(DateTime.now());
  String _month3 = DateFormat('MMMM').format(DateTime.now());
  String _month4 = DateFormat('MMMM').format(DateTime.now());
  String _month5 = DateFormat('MMMM').format(DateTime.now());

  // Provider config
  IconData get qicon => _qicon;
  set qicon(IconData value) {
    _qicon = value;
    notifyListeners();
  }

  IconData get aicon => _aicon;
  set aicon(IconData value) {
    _aicon = value;
    notifyListeners();
  }

  IconData get todoicon => _todoicon;
  set todoicon(IconData value) {
    _todoicon = value;
    notifyListeners();
  }

  bool get showAd => _showAd;
  set showAd(bool value) {
    _showAd = value;
    notifyListeners();
  }

  // int get snapSize => _snapSize;
  // set snapSize(int value) {
  //   _snapSize = value;
  //   notifyListeners();
  // }

  String get name => _name;
  set name(String value) {
    _name = value;
    notifyListeners();
  }

  int get id => _id;
  set id(int value) {
    _id = value;
    notifyListeners();
  }

  double get points => _points;
  set points(double value) {
    _points = value;
    notifyListeners();
  }

  int get mpin => _mpin;
  set mpin(int value) {
    _mpin = value;
    notifyListeners();
  }

  String get month1 => _month1;
  set month1(String value) {
    _month1 = value;
    notifyListeners();
  }

  String get month2 => _month2;
  set month2(String value) {
    _month2 = value;
    notifyListeners();
  }

  String get month3 => _month3;
  set month3(String value) {
    _month3 = value;
    notifyListeners();
  }

  String get month4 => _month4;
  set month4(String value) {
    _month4 = value;
    notifyListeners();
  }

  String get month5 => _month5;
  set month5(String value) {
    _month5 = value;
    notifyListeners();
  }

  bool get normal => _normal;
  set normal(bool value) {
    _normal = value;
    notifyListeners();
  }

  bool get darkMode => _darkMode;
  set darkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  // Functions

  // load darkmode value from shared preferences
  void loadShowDark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? darkModeValue = prefs.getBool('darkMode');
    if (darkModeValue != null) {
      darkMode = darkModeValue;
    } else {
      darkMode = false; // or whatever default value you want
    }
    notifyListeners();
  }

  // save darkmode value to shared preferences
  void saveShowDark(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    darkMode = value;
    prefs.setBool('darkMode', value);
    notifyListeners();
  }

  // load show ads value from shared preferences
  void loadShowAds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? showAdValue = prefs.getBool('showAd');
    if (showAdValue != null) {
      showAd = showAdValue;
    } else {
      showAd = true; // or whatever default value you want
    }
    notifyListeners();
  }

  // save show ads value to shared preferences
  void saveShowAds(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showAd = value;
    prefs.setBool('showAd', value);
    notifyListeners();
  }

  void updateM1(context, String month) {
    _month1 = month;
    notifyListeners();
  }

  void updateM2(context, String month) {
    _month2 = month;
    notifyListeners();
  }

  void updateM3(context, String month) {
    _month3 = month;
    notifyListeners();
  }

  void updateM4(context, String month) {
    _month4 = month;
    notifyListeners();
  }

  void updateM5(context, String month) {
    _month5 = month;
    notifyListeners();
  }

  // void updateSnap1(context, int size) {
  //   _snapSize = size;
  //   notifyListeners();
  // }

  // save logs to shared preferences
  void saveLogsOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    notifyListeners();
  }

  // save logs to shared preferences
  void saveLogs(int newId, String newName, double newPts, int newMpin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = newId;
    name = newName;
    points = newPts;
    mpin = newMpin;
    prefs.setInt('id', newId);
    prefs.setString('name', newName);
    prefs.setDouble('points', newPts);
    prefs.setInt('mpin', newMpin);
    notifyListeners();
  }


   // save pts to shared preferences
  void savePts(double newPts) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    points = newPts;
    prefs.setDouble('points', newPts);
    notifyListeners();
  }

  // load logs value from shared preferences
  void loadLogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getInt('id')!;
    name = prefs.getString('name')!;
    points = prefs.getDouble('points')!;
    mpin = prefs.getInt('mpin')!;
    notifyListeners();
  }

  // // Save user's details to storage
  // void storeLogData() async {
  //   const storage = FlutterSecureStorage();
  //   User? user = FirebaseAuth.instance.currentUser;
  //   await storage.write(key: 'uid', value: user!.uid);
  //   await storage.write(key: 'email', value: user.email);
  //   notifyListeners();
  // }

  // // Save user's information to storage
  // void storeLogInfo(
  //     String newName, String newBio, String newLocale, String newLink, String? newWallet) async {
  //   const storage = FlutterSecureStorage();
  //   await storage.write(key: 'name', value: newName);
  //   await storage.write(key: 'bio', value: newBio);
  //   await storage.write(key: 'locale', value: newLocale);
  //   await storage.write(key: 'link', value: newLink);
  //   await storage.write(key: 'wallet', value: newWallet);
  //   notifyListeners();
  // }

  // // Save user's name only to storage
  // void storeLogNameOnly(String newName) async {
  //   const storage = FlutterSecureStorage();
  //   await storage.write(key: 'name', value: newName);
  //   notifyListeners();
  // }

  // // Save user's bio and link only to storage
  // void storeLogBioandLinkOnly(
  //     String newBio, String newLocale, String newLink, String newWallet) async {
  //   const storage = FlutterSecureStorage();
  //   await storage.write(key: 'bio', value: newBio);
  //   await storage.write(key: 'locale', value: newLocale);
  //   await storage.write(key: 'link', value: newLink);
  //   await storage.write(key: 'wallet', value: newWallet);
  //   notifyListeners();
  // }

  // void checkLogin() async {
  //   AuthClass authClass = AuthClass();
  //   token = await authClass.getToken();
  //   email = await authClass.getEmail();
  //   uid = await authClass.getUid();
  //   name = await authClass.getName();
  //   bio = await authClass.getBio();
  //   locale = await authClass.getLocale();
  //   link = await authClass.getLink();
  //   wallet = await authClass.getWallet();
  //   notifyListeners();
  // }
}

class UniqueId {
  final Set<int> _usedIds = <int>{};
  final Random _random = Random();

  int generate() {
    int newId;

    do {
      newId = _random.nextInt(1000000);
    } while (_usedIds.contains(newId));

    _usedIds.add(newId);

    return newId;
  }
}
