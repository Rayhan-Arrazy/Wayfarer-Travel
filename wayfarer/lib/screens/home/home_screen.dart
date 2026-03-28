import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../guide/guide_list_screen.dart';
import '../trip_planner/trip_list_screen.dart';
import '../journal/journal_screen.dart';
import '../../models/trip_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().init();
      context.read<TripProvider>().fetchTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.createTrip),
              backgroundColor: const Color(0xFFF97316),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildDashboard();
      case 1: return const TripListScreen();
      case 2: return const GuideListScreen();
      case 3: return JournalScreen(tripId: context.watch<TripProvider>().selectedTrip?.id);
      default: return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    final auth = context.watch<AuthProvider>();
    final tripProvider = context.watch<TripProvider>();
    final upcomingTrip = tripProvider.selectedTrip;
    final userName = auth.user?.name.split(' ').first ?? 'Traveler';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: const Icon(Icons.menu, color: AppTheme.primaryColor),
                ),
                Text('Wayfarer', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                const CircleAvatar(radius: 18, backgroundColor: Color(0xFFFFB703), child: Icon(Icons.person, size: 20, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 24),
            Text('Hello, $userName!', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            Text('Where is your next adventure?', style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textSecondary)),
            const SizedBox(height: 32),

            // STEP 1: PREPARATION
            _buildStepHeader('STEP 1: PREPARATION', 'Plan your route & essentials'),
            if (upcomingTrip != null)
              _buildTripStatusCard(upcomingTrip)
            else
              _buildActionCard(Icons.edit_calendar, 'Start Planning', 'Create your itinerary and packing list', () => setState(() => _currentIndex = 1)),

            const SizedBox(height: 32),

            // STEP 2: AT DESTINATION
            _buildStepHeader('STEP 2: AT DESTINATION', 'Explore & Stay Safe'),
            _buildActionCard(Icons.explore_off_outlined, 'Explore Nearby', 'Discover POIs and emergency services', () => setState(() => _currentIndex = 2)),
            const SizedBox(height: 32),

            // STEP 3: BACK HOME
            _buildStepHeader('STEP 3: POST-TRIP', 'Preserve your memories'),
            _buildActionCard(Icons.book_outlined, 'Write Journal', 'Document your journey for the future', () => setState(() => _currentIndex = 3)),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFFF97316), letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text(subtitle, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.lightBorder),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFFB703).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFFFFB703)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildTripStatusCard(TripModel trip) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2E46),
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(trip.coverImage.isNotEmpty ? trip.coverImage : 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(const Color(0xFF1E2E46).withOpacity(0.8), BlendMode.multiply),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(8)),
                child: Text('ACTIVE JOURNEY', style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.flight_takeoff, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text(trip.destination, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('${DateFormat('MMM dd').format(trip.startDate)} - ${DateFormat('MMM dd').format(trip.endDate)}', style: GoogleFonts.inter(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFF97316),
      unselectedItemColor: AppTheme.textMuted,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.edit_calendar), label: 'Prep'),
        BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: 'Journal'),
      ],
    );
  }

  Widget _buildDrawer() {
    final auth = context.watch<AuthProvider>();
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1E2E46)),
            accountName: Text(auth.user?.name ?? 'Traveler'),
            accountEmail: Text(auth.user?.email ?? 'guest@wayfarer.com'),
            currentAccountPicture: const CircleAvatar(backgroundColor: Color(0xFFFFB703), child: Icon(Icons.person, color: Colors.white)),
          ),
          ListTile(leading: const Icon(Icons.home), title: const Text('Dashboard'), onTap: () => setState(() => _currentIndex = 0)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () { auth.logout(); Navigator.pushReplacementNamed(context, AppRoutes.login); },
          ),
        ],
      ),
    );
  }
}
