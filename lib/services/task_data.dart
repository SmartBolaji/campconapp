import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

final UniqueId idG = UniqueId();

class TaskData extends ChangeNotifier {
  // Store connection state for each user ID
  final Map<String, bool> _connections = {};
  // This function isConnected is meant to determine whether a specific user (identified by uid)
  // is currently in the _connections map with a true value, indicating a "connected" status.
  bool isConnected(String uid) => _connections[uid] ?? false;

  // Menu conditionals
  bool _showAd = true;
  bool _normal = true;
  bool _darkMode = false;
  // int _snapSize = 0;
  // snapshot
  QuerySnapshot? _snapShot;
  int _snapSize = 0;
  late List<Map<String, dynamic>> _snapWithAuthors;
  // profile
  String _uid = '';
  String _name = '';
  String _email = '';
  String _userid = '';
  String _pass = '';
  List<String> _tags = [];
  // role
  String _role = 'Student';
  // school
  String _sch = '';
  String _level = '';
  String _dept = '';
  String _faculty = '';
  String _loc = '';
  // more
  int _id = 0;
  double _points = 0.0;
  int _mpin = 0;
  // loading
  bool _circular = false;
  bool _isLoading = true;
  String _month1 = DateFormat('MMMM').format(DateTime.now());
  String _month2 = DateFormat('MMMM').format(DateTime.now());
  String _month3 = DateFormat('MMMM').format(DateTime.now());
  String _month4 = DateFormat('MMMM').format(DateTime.now());
  String _month5 = DateFormat('MMMM').format(DateTime.now());

  // Provider config
  // IconData get qicon => _qicon;
  // set qicon(IconData value) {
  //   _qicon = value;
  //   notifyListeners();
  // }

  // IconData get aicon => _aicon;
  // set aicon(IconData value) {
  //   _aicon = value;
  //   notifyListeners();
  // }

  // IconData get todoicon => _todoicon;
  // set todoicon(IconData value) {
  //   _todoicon = value;
  //   notifyListeners();
  // }

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

  // profile
  String get uid => _uid;
  set uid(String value) {
    _uid = value;
    notifyListeners();
  }

  String get name => _name;
  set name(String value) {
    _name = value;
    notifyListeners();
  }

  String get userid => _userid;
  set userid(String value) {
    _userid = value;
    notifyListeners();
  }

  String get email => _email;
  set email(String value) {
    _email = value;
    notifyListeners();
  }

  String get pass => _pass;
  set pass(String value) {
    _pass = value;
    notifyListeners();
  }

  List<String> get tags => _tags;
  set tags(List<String> value) {
    _tags = value;
    notifyListeners();
  }

  // school
  String get sch => _sch;
  set sch(String value) {
    _sch = value;
    notifyListeners();
  }

  String get level => _level;
  set level(String value) {
    _level = value;
    notifyListeners();
  }

  String get dept => _dept;
  set dept(String value) {
    _dept = value;
    notifyListeners();
  }

  String get faculty => _faculty;
  set faculty(String value) {
    _faculty = value;
    notifyListeners();
  }

  String get loc => _loc;
  set loc(String value) {
    _loc = value;
    notifyListeners();
  }

  int get id => _id;
  set id(int value) {
    _id = value;
    notifyListeners();
  }

  // loading
  bool get circular => _circular;
  set circular(bool value) {
    _circular = value;
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

  // role
  String get role => _role;
  set role(String value) {
    _role = value;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // snap
  QuerySnapshot? get snapShot => _snapShot;
  set snapShot(QuerySnapshot? value) {
    _snapShot = value;
    notifyListeners();
  }

  List<Map<String, dynamic>> get snapWithAuthors => _snapWithAuthors;
  set snapWithAuthors(List<Map<String, dynamic>> value) {
    _snapWithAuthors = value;
    notifyListeners();
  }

  // others

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

  // Method to fetch posts along with author data
  Future<void> loadSnap(
      {required List<dynamic> newTags, required int limit}) async {
    try {
      // Fetch posts matching the criteria
      final snap = await FirebaseFirestore.instance
          .collection('posts')
          .where('postTags', arrayContainsAny: newTags)
          .orderBy('addedDate', descending: true)
          .limit(limit)
          .get();

      // Fallback to cache if no documents are found
      if (snap.docs.isEmpty) {
        _snapShot = await FirebaseFirestore.instance
            .collection('posts')
            .where('postTags', arrayContainsAny: newTags)
            .orderBy('addedDate', descending: true)
            .limit(limit)
            .get(const GetOptions(source: Source.cache));
      } else {
        _snapShot = snap;
      }

      // Fetch author data and like/dislike status in parallel
      final List<Future<Map<String, dynamic>>> authorFetchTasks =
          _snapShot!.docs.map((postDoc) async {
        final authorRef = postDoc['author'] as DocumentReference;
        final authorSnapshot = await authorRef.get();

        final postId = postDoc.id;
        final userId = _uid; // Replace with the actual current user ID

        // Check if the user has liked or disliked the post
        final likeDoc = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('likes')
            .doc(userId)
            .get();
        final isLiked = likeDoc.exists;

        final dislikeDoc = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('dislikes')
            .doc(userId)
            .get();
        final isDisliked = dislikeDoc.exists;

        return {
          'post': postDoc.data(),
          'author': authorSnapshot.exists ? authorSnapshot.data() : null,
          'isLiked': isLiked,
          'isDisliked': isDisliked,
        };
      }).toList();

      // Combine posts with their authors and like/dislike status
      _snapWithAuthors = await Future.wait(authorFetchTasks);

      // Limit the snap size to a maximum of 30
      _snapSize = (_snapWithAuthors?.length ?? 0) > 30
          ? 30
          : _snapWithAuthors?.length ?? 0;
    } catch (e) {
      print('Error loading snap: $e');
    } finally {
      isLoading = false; // Data loading is complete
    }

    notifyListeners();
  }

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

  // sign up
  Future<void> updateSign(context, String uid, String name, String userid,
      String email, String pass) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _uid = uid;
    _name = name;
    _userid = userid;
    _email = email;
    _pass = pass;
    prefs.setString('uid', uid);
    prefs.setString('name', name);
    prefs.setString('userid', userid);
    prefs.setString('email', email);
    notifyListeners();
  }

  // log in
  Future<void> updateLogin(
      context, String uid, String name, String userid, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _uid = uid;
    _name = name;
    _userid = userid;
    _email = email;
    prefs.setString('uid', uid);
    prefs.setString('name', name);
    prefs.setString('userid', userid);
    prefs.setString('email', email);
    notifyListeners();
  }

  // tags
  Future<void> updateTags(BuildContext context, List<dynamic> newTags) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Add each new tag to the list if it doesn't already exist
    for (var tag in newTags) {
      if (!_tags.contains(tag)) {
        _tags.add(tag!);
      }
    }
    prefs.setStringList('tags', _tags);
    notifyListeners();
  }

  // school
  Future<void> updateSchool(context, String? sch, String? level, String? dept,
      String? faculty, String? loc) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _sch = sch!;
    _level = level!;
    _dept = dept!;
    _faculty = faculty!;
    _loc = loc!;
    prefs.setString('sch', sch);
    prefs.setString('level', level);
    prefs.setString('dept', dept);
    prefs.setString('faculty', faculty);
    prefs.setString('loc', loc);
    notifyListeners();
  }

  // load logs value from shared preferences
  Future<void> loadLogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid')!;
    name = prefs.getString('name')!;
    userid = prefs.getString('userid')!;
    email = prefs.getString('email')!;
    sch = prefs.getString('sch')!;
    level = prefs.getString('level')!;
    dept = prefs.getString('dept')!;
    faculty = prefs.getString('faculty')!;
    loc = prefs.getString('loc')!;
    tags = prefs.getStringList('tags')!;
    notifyListeners();
  }

  // role
  void updateRole(context, String newRole) {
    _role = newRole;
    notifyListeners();
  }

  // loading
  void updateCircle(context, bool roll) {
    _circular = roll;
    notifyListeners();
  }

  void updateLoading(context, bool load) {
    _isLoading = load;
    notifyListeners();
  }

  // Connect to a user and update Firestore
  Future<void> connectToUser(String uid, String cUid) async {
    if (!_connections.containsKey(uid) || !_connections[uid]!) {
      try {
        // Step 1: Add current user to the target user's 'following' subcollection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('following')
            .doc(cUid) // The current user
            .set({
          'uid': cUid,
          'userRef': FirebaseFirestore.instance
              .collection('users')
              .doc(cUid), // Reference to the user's document
          'addedDate': FieldValue.serverTimestamp(),
        });

        // Step 2: Add target user to the current user's 'followers' subcollection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(cUid)
            .collection('followers')
            .doc(uid) // The current user
            .set({
          'uid': uid,
          'userRef': FirebaseFirestore.instance.collection('users').doc(uid),
          'addedDate': FieldValue.serverTimestamp(),
        });

        // Step 3: Update the 'following' field in the targets user's document
        // Incrementing the 'following' count by 1
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'following':
              FieldValue.increment(1), // Increment the connecting count
        });

        // Step 4: Update the 'followers' field in the current user's document
        // Incrementing the 'followers' count by 1
        await FirebaseFirestore.instance.collection('users').doc(cUid).update({
          'followers': FieldValue.increment(1), // Increment the followers count
        });

        _connections[uid] = true;
        notifyListeners(); // Notify listeners about the update
      } catch (e) {
        print("Error connecting to user: $e");
      }
    }
  }

  // Disconnect from a user
  Future<void> disconnectFromUser(String uid, String cUid) async {
    try {
      // Step 1: Remove current user from the target user's 'connecting' subcollection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid) // The target user
          .collection('connecting')
          .doc(cUid) // The current user
          .delete();

      // Step 2: Remove target user from the current user's 'connects' subcollection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cUid) // The current user
          .collection('connects')
          .doc(uid) // The target user
          .delete();

      // Step 3: Decrement the 'connecting' count in the target user's document
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'connecting':
            FieldValue.increment(-1), // Decrement the connecting count
      });

      // Step 4: Decrement the 'connects' count in the current user's document
      await FirebaseFirestore.instance.collection('users').doc(cUid).update({
        'followers': FieldValue.increment(-1), // Decrement the followers count
      });

      _connections[uid] = false;
      notifyListeners(); // Notify listeners about the update
    } catch (e) {
      print("Error disconnecting from user: $e");
    }
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

  int generate(int lenght) {
    int newId;

    do {
      newId = _random.nextInt(lenght);
    } while (_usedIds.contains(newId));

    _usedIds.add(newId);

    return newId;
  }
}
