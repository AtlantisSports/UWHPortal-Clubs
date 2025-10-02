/// UWH Portal - Clubs Flutter Mockup
///
/// A modular Flutter application following uwhportal architecture patterns
/// for seamless integration with the main monorepo.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'features/clubs/clubs_list_screen.dart';
import 'features/home/home_screen.dart';
import 'features/events/events_screen.dart';
import 'features/programs/programs_screen.dart';
import 'features/profile/profile_screen_new.dart';
import 'core/utils/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Root application widget with uwhportal theming
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.background,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
            ),
            textTheme: const TextTheme(
              headlineLarge: AppTextStyles.headline1,
              headlineMedium: AppTextStyles.headline2,
              headlineSmall: AppTextStyles.headline3,
              bodyLarge: AppTextStyles.bodyLarge,
              bodyMedium: AppTextStyles.bodyMedium,
              bodySmall: AppTextStyles.bodySmall,
              labelLarge: AppTextStyles.button,
            ),
            // Use default page transitions for snappy navigation
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: ZoomPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.linux: ZoomPageTransitionsBuilder(),
                TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.windows: ZoomPageTransitionsBuilder(),
              },
            ),
          ),
          home: const MainNavigationScreen(),
          // Use default route generation for snappy navigation
          onGenerateRoute: null,
        ),
    );
  }
}

/// Main navigation screen with bottom navigation
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 3; // Start with Clubs tab

  final List<Widget> _screens = [
    const HomeScreen(),
    const EventsScreen(),
    const ProgramsScreen(),
    const ClubsListScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // This allows more than 3 items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Programs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Clubs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// Placeholder screen for Events feature
class EventsPlaceholderScreen extends StatelessWidget {
  const EventsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event,
              size: 64,
              color: AppColors.textDisabled,
            ),
            SizedBox(height: AppSpacing.medium),
            Text(
              'Events Feature',
              style: AppTextStyles.headline2,
            ),
            SizedBox(height: AppSpacing.small),
            Text(
              'Coming Soon',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}