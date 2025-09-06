/// UWH Portal Clubs Flutter Mockup
/// 
/// A modular Flutter application following uwhportal architecture patterns
/// for seamless integration with the main monorepo.
library;

import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/navigation_service.dart';
import 'core/utils/back_navigation_handler.dart';
import 'features/clubs/clubs_list_screen.dart';
import 'features/home/home_screen.dart';
import 'features/events/events_screen.dart';
import 'features/programs/programs_screen.dart';
import 'features/notifications/notifications_placeholder_screen.dart';
import 'features/learn/learn_placeholder_screen.dart';
import 'features/about/about_placeholder_screen.dart';
import 'features/faq/faq_placeholder_screen.dart';
import 'features/contact/contact_us_placeholder_screen.dart';
import 'base/widgets/app_drawer_main.dart' as drawer;
import 'base/widgets/right_drawer.dart';
import 'base/widgets/phone_frame.dart';
import 'core/utils/user_role_manager.dart';

void main() {
  runApp(const ClubsMockupApp());
}

/// Root application widget with uwhportal theming
class ClubsMockupApp extends StatelessWidget {
  const ClubsMockupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
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
      ),
      home: PhoneFrameWrapper(
        child: MainNavigationScreen(
          onBackPressed: () => BackNavigationHandler.instance.handleBack(),
        ),
        onBackPressed: () => BackNavigationHandler.instance.handleBack(),
      ),
    );
  }
}

/// Main navigation screen with drawer and bottom navigation
class MainNavigationScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  
  const MainNavigationScreen({
    super.key,
    this.onBackPressed,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final List<int> _navigationHistory = [0]; // Track navigation history
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const HomeScreen(),                      // 0
    const EventsScreen(),                    // 1
    const ProgramsScreen(),                  // 2
    const ClubsListScreen(),                 // 3
    const ProfilePlaceholderScreen(),        // 4
    const NotificationsPlaceholderScreen(),  // 5
    const LearnPlaceholderScreen(),          // 6
    const AboutPlaceholderScreen(),          // 7
    const FAQPlaceholderScreen(),            // 8
    const ContactUsPlaceholderScreen(),      // 9
  ];

  void _onItemTapped(int index) {
    setState(() {
      // Add to history if it's a different tab
      if (index != _selectedIndex) {
        _navigationHistory.add(index);
        // Keep history manageable
        if (_navigationHistory.length > 10) {
          _navigationHistory.removeAt(0);
        }
      }
      _selectedIndex = index;
    });
  }

  void _handleBackNavigation() {
    // Handle drawer first - check if either left or right drawer is open
    final scaffoldState = _scaffoldKey.currentState;
    if (scaffoldState != null) {
      if (scaffoldState.isDrawerOpen) {
        scaffoldState.closeDrawer();
        return;
      }
      if (scaffoldState.isEndDrawerOpen) {
        scaffoldState.closeEndDrawer();
        return;
      }
    }

    // Handle tab history
    if (_navigationHistory.length > 1) {
      setState(() {
        _navigationHistory.removeLast(); // Remove current
        _selectedIndex = _navigationHistory.last; // Go to previous
      });
    } else {
      // If no history, go to home tab
      if (_selectedIndex != 0) {
        setState(() {
          _selectedIndex = 0;
          _navigationHistory.clear();
          _navigationHistory.add(0);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Register the back handler with the parent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onBackPressed != null) {
        // Store reference for back navigation
        BackNavigationHandler.instance.setHandler(_handleBackNavigation);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const drawer.AppDrawer(),
      endDrawer: RightDrawer(onNavigateToTab: _onItemTapped),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _selectedIndex < 5 ? BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[100],
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
            icon: _ThreePersonNavIcon(),
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
      ) : null,
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
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black87,
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

/// Placeholder screen for Profile feature
class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              size: 28.8, // 20% larger than default 24
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.menu,
              size: 28.8, // 20% larger than default 24
            ),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.person,
                    size: 64,
                    color: AppColors.textDisabled,
                  ),
                  SizedBox(height: AppSpacing.medium),
                  Text(
                    'Profile Feature',
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
            const SizedBox(height: 40),
            // Role Selection Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListenableBuilder(
                      listenable: UserRoleManager.instance,
                      builder: (context, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Role:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: UserRoleManager.instance.allRoles
                                    .map((role) => CheckboxListTile(
                                          title: Text(role.displayName),
                                          value: UserRoleManager.instance.currentRole == role,
                                          onChanged: (bool? selected) {
                                            if (selected == true) {
                                              UserRoleManager.instance.setRole(role);
                                            }
                                          },
                                          controlAffinity: ListTileControlAffinity.trailing,
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreePersonNavIcon extends StatelessWidget {
  const _ThreePersonNavIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 24,
      child: Stack(
        children: [
          // Left person
          Positioned(
            left: 0,
            top: 4,
            child: Icon(
              Icons.person,
              size: 16,
              color: Colors.grey[600],
            ),
          ),
          // Center person (slightly higher)
          Positioned(
            left: 7,
            top: 0,
            child: Icon(
              Icons.person,
              size: 20,
              color: Colors.grey[600],
            ),
          ),
          // Right person
          Positioned(
            left: 16,
            top: 4,
            child: Icon(
              Icons.person,
              size: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
