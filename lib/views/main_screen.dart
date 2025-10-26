import 'package:flutter/material.dart';
import '../utils/brand_colors.dart';
import '../utils/constants.dart';
import 'home/home_screen.dart';
import 'scholarships/scholarships_screen.dart';
import 'transit/transit_screen.dart';
import 'calendar/calendar_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Create screens with navigation callback
  List<Widget> get _screens => [
    HomeScreen(
      onNavigate: _onTabTapped, // Pass the callback here
    ),
    const ScholarshipsScreen(),
    const TransitScreen(),
    const CalendarScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: BrandColors.slateGray.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: BrandColors.royalBlue,
          unselectedItemColor: BrandColors.slateGray,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            fontFamily: 'Poppins',
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: AppConstants.homeLabel,
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              label: AppConstants.scholarshipsLabel,
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus),
              label: AppConstants.transitLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.event),
              label: AppConstants.calendarLabel,
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: AppConstants.profileLabel,
            ),
          ],
        ),
      ),
    );
  }
}