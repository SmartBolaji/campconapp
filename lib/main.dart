import 'package:campcon/firebase_options.dart';
import 'package:campcon/mainscreen.dart';
import 'package:campcon/model/theme.dart';
import 'package:campcon/services/timeago.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:campcon/onboarding/onboarding.dart';
import 'package:campcon/services/task_data.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.grey.shade100, // Set the status bar color
    statusBarIconBrightness:
        Brightness.dark, // For light text on dark background
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  timeago.setLocaleMessages('short', ShortTimeAgo());
  await dotenv.load(fileName: ".env");
  PhotoManager.clearFileCache();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Campcon',
        theme: AppStyles.themeData,
        home: const KeyboardVisibilityProvider(child: AuthCheck()),
        localizationsDelegates: const [MonthYearPickerLocalizations.delegate],
      ),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool userAvailable = false;
  bool isLoading = true; // Loading state for improved UI feedback
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUser();
    });
  }

  Future<void> _initializeUser() async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
      final taskData = Provider.of<TaskData>(context, listen: false);

      final uid = sharedPreferences.getString('uid');
      if (uid != null) {
        await taskData.loadLogs();
        await taskData.loadSnap(newTags: taskData.tags, limit: 10);

        setState(() {
          userAvailable = true;
        });
      } else {
        setState(() {
          userAvailable = false;
        });
      }
    } catch (e) {
      debugPrint("Error initializing user: $e");
      setState(() {
        userAvailable = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider
    final taskData = Provider.of<TaskData>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.grey.shade800,
              ),
            )
          : userAvailable && taskData.snapWithAuthors.isNotEmpty
              ? const MainScreen()
              : OnboardingScreen(),
    );
  }
}
