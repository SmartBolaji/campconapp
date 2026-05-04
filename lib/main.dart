import 'package:campcon/firebase_options.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/provider/animated_provider.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/event_create_provider.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:campcon/main/provider/feed_provider.dart';
import 'package:campcon/main/provider/follow_provider.dart';
import 'package:campcon/main/provider/friends_provider.dart';
import 'package:campcon/main/provider/market_provider.dart';
import 'package:campcon/main/provider/media_provider.dart';
import 'package:campcon/main/provider/message_provider.dart';
import 'package:campcon/main/provider/post_provider.dart';
import 'package:campcon/main/provider/market_post_provider.dart';
import 'package:campcon/main/provider/product_provider.dart';
import 'package:campcon/main/provider/resource_provider.dart';
import 'package:campcon/main/provider/resource_post_provider.dart';
import 'package:campcon/main/provider/notify_provider.dart';
import 'package:campcon/main/provider/theme_provider.dart';
import 'package:campcon/main/provider/admin_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/message_cache.dart';
import 'package:campcon/main/screens/onboarding/onboarding.dart';
import 'package:campcon/main/screens/main_screen.dart';
import 'package:campcon/main/services/push_notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'main/provider/chat_provider.dart';
import 'main/provider/profile_provider.dart';
import 'main/provider/sales_provider.dart';
import 'main/provider/buyer_orders_provider.dart';
import 'main/provider/pickup_provider.dart';
import 'package:campcon/main/provider/new_post_provider.dart';
import 'package:campcon/main/provider/poll_provider.dart';
import 'main/provider/search_provider.dart';
import 'main/provider/update_provider.dart';
import 'main/services/algorithm/shorebird.dart';
import 'package:campcon/main/widgets/shorebird_update_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization with timeout
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
  } catch (e) {
    debugPrint('❌ Firebase init error: $e');
  }

  // Push notifications with timeout
  try {
    await PushNotificationService.instance.initialize().timeout(
          const Duration(seconds: 5),
        );
  } catch (e) {
    debugPrint('❌ Push notification init error: $e');
  }

  // Firestore settings
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } catch (e) {
    debugPrint('❌ Firestore settings error: $e');
  }

  // Message cache with timeout
  try {
    await MessageCacheService.init().timeout(
      const Duration(seconds: 5),
    );
  } catch (e) {
    debugPrint('❌ Message cache init error: $e');
  }

  // Photo manager cleanup (non-blocking)
  try {
    PhotoManager.clearFileCache();
  } catch (e) {
    debugPrint('❌ Photo manager error: $e');
  }

  final shorebirdService = ShorebirdService();
  shorebirdService.checkForUpdate();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => FollowProvider()),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => MarketPostProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => FriendsTabProvider()),
        ChangeNotifierProvider(create: (_) => AnimatedProvider()),
        ChangeNotifierProvider(create: (_) => MediaSelectionProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => EventCreateProvider()),
        ChangeNotifierProvider(create: (_) => ResourceProvider()),
        ChangeNotifierProvider(create: (_) => ResourcePostProvider()),
        ChangeNotifierProvider(create: (_) => NotifyProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => BuyerOrdersProvider()),
        ChangeNotifierProvider(create: (_) => PickupProvider()),
        ChangeNotifierProvider(create: (_) => NewPostProvider()),
        ChangeNotifierProvider(create: (_) => PollProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => UpdateProvider()),
        ChangeNotifierProvider.value(value: shorebirdService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return ShorebirdUpdateNotifier(
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Campcon',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                home: const AuthenticationWrapper(),
                localizationsDelegates: const [
                  MonthYearPickerLocalizations.delegate
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize user auth state with timeout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false)
          .initializeUser()
          .timeout(const Duration(seconds: 8))
          .catchError((e) {
        debugPrint('❌ Auth initialization error or timeout: $e');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final brightness = Theme.of(context).brightness;
        final isDark = brightness == Brightness.dark;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
          child: Builder(
            builder: (context) {
              // Show loading while initializing
              if (!authProvider.isInitialized) {
                return Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/small_logo.png",
                          height: 60,
                          width: 60,
                        ),
                        SizedBox(height: 20.h),
                        CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Check authentication status
              if (authProvider.isAuthenticated &&
                  authProvider.currentUser != null) {
                return const MainScreen();
              }

              // Show onboarding for unauthenticated users
              return const Onboarding();
            },
          ),
        );
      },
    );
  }
}
