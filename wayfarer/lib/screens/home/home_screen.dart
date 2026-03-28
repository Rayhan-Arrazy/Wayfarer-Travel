import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';
import '../dashboard/dashboard_tab.dart';
import '../plan/plan_tab.dart';
import '../guide/guide_tab.dart';
import '../tools/tools_tab_screen.dart';
import '../map/explore_tab.dart';
import '../journal/journal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: _buildDrawer(),
      body: _tabs[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDrawer() {
    final auth = context.watch<AuthProvider>();
    final userName = auth.user?.name ?? 'Alex Rivers';

    return Drawer(
      child: Container(
        color: const Color(0xFFF8FAFC),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: Color(0xFF1E40AF), size: 28),
                ),
                const SizedBox(width: 16),
                Text(userName, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF132F5C))),
              ],
            ),
            
            const SizedBox(height: 48),
            _buildDrawerSection('PLANNING'),
            _buildDrawerItem(Icons.home_outlined, Icons.home, 'Home', 0),
            _buildDrawerItem(Icons.calendar_today_outlined, Icons.calendar_today, 'Plan', 1),
            
            const SizedBox(height: 32),
            _buildDrawerSection('DISCOVER'),
            _buildDrawerItem(Icons.explore_outlined, Icons.explore, 'Travel Guide', 2),
            _buildDrawerItem(Icons.location_on_outlined, Icons.location_on, 'Explore', 5),

            const SizedBox(height: 32),
            _buildDrawerSection('UTILITIES'),
            _buildDrawerItem(Icons.build_outlined, Icons.build, 'Tools', 4),

            const SizedBox(height: 32),
            _buildDrawerSection('MEMORIES'),
            _buildDrawerItem(Icons.menu_book_outlined, Icons.menu_book, 'Journal', 3),

            const Spacer(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, color: Color(0xFF991B1B)),
              title: Text('Logout', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF991B1B))),
              onTap: () { 
                auth.logout(); 
                Navigator.pushReplacementNamed(context, AppRoutes.login); 
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(title, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1.0)),
    );
  }

  Widget _buildDrawerItem(IconData icon, IconData activeIcon, String label, int index) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          children: [
            Icon(isActive ? activeIcon : icon, color: isActive ? const Color(0xFF1E40AF) : const Color(0xFF64748B), size: 22),
            const SizedBox(width: 16),
            Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: isActive ? FontWeight.bold : FontWeight.w600, color: isActive ? const Color(0xFF1E40AF) : const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
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
            _buildNavItem(Icons.home_outlined, Icons.home, 'HOME', 0),
            _buildNavItem(Icons.calendar_today_outlined, Icons.calendar_today, 'PLAN', 1),
            _buildNavItem(Icons.explore_outlined, Icons.explore, 'GUIDE', 2),
            _buildNavItem(Icons.book_outlined, Icons.book, 'JOURNAL', 3),
            _buildNavItem(Icons.build_outlined, Icons.build, 'TOOLS', 4),
            _buildNavItem(Icons.search_outlined, Icons.search, 'EXPLORE', 5),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
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
