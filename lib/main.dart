/// UWH Portal - Clubs Flutter Mockup
/// 
/// A modular Flutter application following uwhportal architecture patterns
/// for seamless integration with the main monorepo.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/di/service_locator.dart';
import 'core/providers/navigation_provider.dart';
import 'core/providers/participation_provider.dart';
import 'core/providers/practice_filter_provider.dart';
import 'core/providers/user_provider.dart';
import 'features/clubs/clubs_list_screen.dart';
import 'features/clubs/clubs_provider.dart';
import 'features/home/home_screen.dart';
import 'features/events/events_screen.dart';
import 'features/programs/programs_screen.dart';
import 'features/profile/profile_screen_new.dart';
import 'base/widgets/phone_frame.dart';
import 'base/widgets/right_drawer.dart';
import 'core/utils/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await setupServiceLocator();
  
  runApp(const MyApp());
}

/// Root application widget with uwhportal theming
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ParticipationProvider()),
        ChangeNotifierProvider(create: (_) => PracticeFilterProvider()),
        ChangeNotifierProxyProvider<ParticipationProvider, ClubsProvider>(
          create: (context) => ClubsProvider(participationProvider: context.read<ParticipationProvider>()),
          update: (context, participationProvider, clubsProvider) =>
              clubsProvider ?? ClubsProvider(participationProvider: participationProvider),
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        // Add more providers as features grow
      ],
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
        home: Consumer<NavigationProvider>(
          builder: (context, navigationProvider, child) {
            return PhoneFrameWrapper(
              onBackPressed: () {
                debugPrint('📱 Back button pressed');
                
                // First check if drawer is open
                if (navigationProvider.isDrawerOpen) {
                  debugPrint('📱 Drawer is open, closing it');
                  final navContext = NavigationService.context;
                  if (navContext != null) {
                    Navigator.of(navContext).pop();
                    return;
                  }
                }
                
                // Try tab navigation history
                if (navigationProvider.handlePhoneBackNavigation()) {
                  debugPrint('📱 Phone back navigation succeeded');
                  return;
                }
                
                // Fallback to regular navigation
                final navContext = NavigationService.context;
                if (navContext != null && Navigator.of(navContext).canPop()) {
                  debugPrint('📱 Using regular navigation pop');
                  Navigator.of(navContext).pop();
                } else {
                  debugPrint('📱 Cannot pop navigation stack');
                }
              },
              child: const MainNavigationScreen(),
            );
          },
        ),
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
  final List<Widget> _screens = [
    const HomeScreen(),
    const EventsScreen(),
    const ProgramsScreen(),
    const ClubsListScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    navigationProvider.selectTab(index);
  }

  void _onDrawerNavigate(int index) {
    debugPrint('DEBUG: Drawer navigate to index: $index');
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    
    // Handle navigation from drawer
    if (index >= 0 && index < _screens.length) {
      // Navigate to main tabs (Home, Events, Programs, Clubs, Profile)
      navigationProvider.selectTab(index);
    } else {
      // Handle navigation to additional screens (Notifications, Learn, About, etc.)
      // For now, we'll show a placeholder message since these screens aren't in main navigation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigation to additional screen at index $index - Coming Soon'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: navigationProvider.selectedIndex,
            children: _screens,
          ),
          endDrawer: RightDrawer(
            onNavigateToTab: _onDrawerNavigate,
          ),
          onEndDrawerChanged: (isOpened) {
            // Update navigation provider drawer state
            navigationProvider.setDrawerState(isOpened);
          },
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
            currentIndex: navigationProvider.selectedIndex,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
          ),
        );
      },
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


