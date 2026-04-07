import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/wayfarer_drawer.dart';
import '../dashboard/dashboard_tab.dart';
import '../plan/plan_tab.dart';
import '../guide/guide_tab.dart';
import '../tools/tools_tab_screen.dart';
import '../map/explore_tab.dart';
import '../journal/journal_screen.dart';
import '../../config/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _tabs = [
    const DashboardTab(),
    const PlanTab(),
    const GuideTab(),
    const JournalScreen(),
    const ToolsTabScreen(),
    const ExploreTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final currentIndex = nav.currentIndex;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: WayfarerDrawer(
        currentIndex: currentIndex, 
        onTabSelected: (index) => nav.setIndex(index),
      ),
      body: _tabs[currentIndex],
      floatingActionButton: currentIndex == 3 ? FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.journalAdd),
        backgroundColor: const Color(0xFF1E40AF),
        child: const Icon(Icons.add, color: Colors.white),
      ) : (currentIndex == 1 ? FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createTrip),
        backgroundColor: const Color(0xFF1E40AF),
        child: const Icon(Icons.add, color: Colors.white),
      ) : null),
      bottomNavigationBar: _buildBottomNav(currentIndex, nav),
    );
  }

  Widget _buildBottomNav(int currentIndex, NavigationProvider nav) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, Icons.home, 'HOME', 0, currentIndex, nav),
            _buildNavItem(Icons.calendar_today_outlined, Icons.calendar_today, 'PLAN', 1, currentIndex, nav),
            _buildNavItem(Icons.explore_outlined, Icons.explore, 'GUIDE', 2, currentIndex, nav),
            _buildNavItem(Icons.book_outlined, Icons.book, 'JOURNAL', 3, currentIndex, nav),
            _buildNavItem(Icons.build_outlined, Icons.build, 'TOOLS', 4, currentIndex, nav),
            _buildNavItem(Icons.search_outlined, Icons.search, 'EXPLORE', 5, currentIndex, nav),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index, int currentIndex, NavigationProvider nav) {
    final bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => nav.setIndex(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, color: isActive ? const Color(0xFF1E40AF) : const Color(0xFF64748B), size: 24),
            const SizedBox(height: 6),
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: isActive ? FontWeight.w900 : FontWeight.bold, color: isActive ? const Color(0xFF1E40AF) : const Color(0xFF64748B), letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}
