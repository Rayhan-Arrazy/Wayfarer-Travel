import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/routes.dart';

class WayfarerDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const WayfarerDrawer({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.user?.name ?? 'Alex Rivers';

    return Drawer(
      child: Container(
        color: const Color(0xFFF8FAFC),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Fixed Header
            const SizedBox(height: 60),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: Color(0xFF0B1B32), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    userName, 
                    style: GoogleFonts.outfit(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      color: const Color(0xFF0B1B32)
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Scrollable Menu Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDrawerSection('PLANNING'),
                    _buildDrawerItem(context, Icons.home_outlined, Icons.home, 'Home', 0),
                    _buildDrawerItem(context, Icons.calendar_today_outlined, Icons.calendar_today, 'Plan', 1),
                    
                    const SizedBox(height: 32),
                    _buildDrawerSection('DISCOVER'),
                    _buildDrawerItem(context, Icons.explore_outlined, Icons.explore, 'Travel Guide', 2),
                    _buildDrawerItem(context, Icons.location_on_outlined, Icons.location_on, 'Explore', 5),

                    const SizedBox(height: 32),
                    _buildDrawerSection('UTILITIES'),
                    _buildDrawerItem(context, Icons.build_outlined, Icons.build, 'Tools', 4),

                    const SizedBox(height: 32),
                    _buildDrawerSection('MEMORIES'),
                    _buildDrawerItem(context, Icons.menu_book_outlined, Icons.menu_book, 'Journal', 3),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Fixed Footer
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, color: Color(0xFF991B1B)),
              title: Text('Logout', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF991B1B))),
              onTap: () { 
                auth.logout(); 
                Navigator.pushReplacementNamed(context, AppRoutes.login); 
              },
            ),
            const SizedBox(height: 30),
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

  Widget _buildDrawerItem(BuildContext context, IconData icon, IconData activeIcon, String label, int index) {
    final bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () {
        onTabSelected(index);
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
            Icon(isActive ? activeIcon : icon, color: isActive ? const Color(0xFF0B1B32) : const Color(0xFF64748B), size: 22),
            const SizedBox(width: 16),
            Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: isActive ? FontWeight.bold : FontWeight.w600, color: isActive ? const Color(0xFF0B1B32) : const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}
