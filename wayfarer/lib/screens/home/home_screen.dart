import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildExplorePage();
      case 2:
        return _buildTripsPage();
      case 3:
        return _buildProfilePage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${user?.name.split(' ').first ?? 'Traveler'} 👋',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Where will you go next?',
                          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Emergency Button
                        _buildIconButton(Icons.sos, AppTheme.errorColor, () {
                          Navigator.pushNamed(context, AppRoutes.emergency);
                        }),
                        const SizedBox(width: 8),
                        if (auth.isAdmin)
                          _buildIconButton(Icons.admin_panel_settings, AppTheme.warningColor, () {
                            Navigator.pushNamed(context, AppRoutes.admin);
                          }),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Next Adventure Banner (Added to prevent empty look)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Next Adventure', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    Text('5 days to go', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?q=80&w=1000&auto=format&fit=crop'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('UPCOMING TRIP', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white70, letterSpacing: 1.5)),
                        const SizedBox(height: 4),
                        Text('Tokyo, Japan', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                                const SizedBox(width: 6),
                                Text('Oct 12 - 20', style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
                                const SizedBox(width: 16),
                                const Icon(Icons.wb_sunny, color: Colors.white70, size: 14),
                                const SizedBox(width: 6),
                                Text('22°C', style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.trips),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('Details', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Quick Actions Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Text('Quick Tools',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  _buildQuickAction(Icons.flight_takeoff, 'Trip\nPlanner', AppRoutes.trips, const Color(0xFF4D94FF)),
                  _buildQuickAction(Icons.map, 'Live\nMap', AppRoutes.map, const Color(0xFF00D4AA)),
                  _buildQuickAction(Icons.currency_exchange, 'Currency', AppRoutes.currency, const Color(0xFFFFB74D)),
                  _buildQuickAction(Icons.cloud, 'Weather', AppRoutes.weather, const Color(0xFF64B5F6)),
                  _buildQuickAction(Icons.restaurant, 'Food &\nDining', AppRoutes.food, const Color(0xFFFF8A65)),
                  _buildQuickAction(Icons.hotel, 'Hotels', AppRoutes.accommodation, const Color(0xFFBA68C8)),
                  _buildQuickAction(Icons.directions_bus, 'Transport', AppRoutes.transport, const Color(0xFF4DB6AC)),
                  _buildQuickAction(Icons.book, 'Journal', AppRoutes.journal, const Color(0xFFE57373)),
                ],
              ),
            ),

            // Feature Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Text('Features',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  children: [
                    _buildFeatureCard(
                      'Trip Planner',
                      'Plan your dream trip with auto-generated checklists',
                      Icons.flight_takeoff,
                      const [Color(0xFF0066FF), Color(0xFF00D4AA)],
                      () => Navigator.pushNamed(context, AppRoutes.trips),
                    ),
                    _buildFeatureCard(
                      'Live Map',
                      'Navigate with nearby restaurants, hotels & more',
                      Icons.map,
                      const [Color(0xFF00D4AA), Color(0xFF00A884)],
                      () => Navigator.pushNamed(context, AppRoutes.map),
                    ),
                    _buildFeatureCard(
                      'Currency Converter',
                      'Real-time exchange rates & cost of living',
                      Icons.currency_exchange,
                      const [Color(0xFFFF9100), Color(0xFFFF6D00)],
                      () => Navigator.pushNamed(context, AppRoutes.currency),
                    ),
                    _buildFeatureCard(
                      'Emergency SOS',
                      'Quick access to emergency services & contacts',
                      Icons.sos,
                      const [Color(0xFFFF1744), Color(0xFFD50000)],
                      () => Navigator.pushNamed(context, AppRoutes.emergency),
                    ),
                    _buildFeatureCard(
                      'Travel Journal',
                      'Capture your memories with photos & notes',
                      Icons.book,
                      const [Color(0xFFE91E63), Color(0xFF9C27B0)],
                      () => Navigator.pushNamed(context, AppRoutes.journal),
                    ),
                  ],
                ),
              ),
            ),

            // Safety Tip
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.accentColor.withValues(alpha: 0.15), AppTheme.primaryColor.withValues(alpha: 0.08)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.tips_and_updates, color: AppTheme.accentColor, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Travel Tip',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.accentColor)),
                            const SizedBox(height: 4),
                            Text('Always keep digital copies of your passport and travel documents accessible offline.',
                              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplorePage() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Explore', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Text('Discover features for your journey', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildExploreItem(Icons.map, 'Live Map & Navigation', 'Find nearby places and navigate', AppRoutes.map, AppTheme.accentColor),
                    _buildExploreItem(Icons.restaurant, 'Food & Dining', 'Discover local cuisine and restaurants', AppRoutes.food, const Color(0xFFFF8A65)),
                    _buildExploreItem(Icons.hotel, 'Accommodation', 'Search hotels, hostels & apartments', AppRoutes.accommodation, const Color(0xFFBA68C8)),
                    _buildExploreItem(Icons.directions_bus, 'Transport', 'Flights, trains, buses & more', AppRoutes.transport, const Color(0xFF4DB6AC)),
                    _buildExploreItem(Icons.currency_exchange, 'Currency & Finance', 'Exchange rates & cost of living', AppRoutes.currency, const Color(0xFFFFB74D)),
                    _buildExploreItem(Icons.cloud, 'Weather & Climate', 'Forecasts, UV, air quality', AppRoutes.weather, const Color(0xFF64B5F6)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExploreItem(IconData icon, String title, String subtitle, String route, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.lightBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripsPage() {
    final auth = context.watch<AuthProvider>();
    
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Trips', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  if (auth.isAuthenticated)
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.createTrip),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flight_takeoff, size: 64, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      if (auth.isAuthenticated) ...[
                        Text('No trips yet', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                        const SizedBox(height: 8),
                        Text('Start planning your next adventure!', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.createTrip),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Trip'),
                        ),
                      ] else ...[
                        Text('Sign in to view trips', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                        const SizedBox(height: 8),
                        Text('Save and manage your adventures securely.', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                          icon: const Icon(Icons.login),
                          label: const Text('Sign In'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: Center(
                  child: Text(
                    (user?.name ?? 'U')[0].toUpperCase(),
                    style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              if (user != null) ...[
                Text(user.name, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                Text(user.email, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                if (user.isAdmin)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
                    ),
                    child: Text('Admin', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.warningColor)),
                  ),
                const SizedBox(height: 32),
                
                _buildProfileItem(Icons.person_outline, 'Edit Profile', () => Navigator.pushNamed(context, AppRoutes.profile)),
                _buildProfileItem(Icons.book_outlined, 'Travel Journal', () => Navigator.pushNamed(context, AppRoutes.journal)),
                _buildProfileItem(Icons.sos, 'Emergency Info', () => Navigator.pushNamed(context, AppRoutes.emergency)),
                if (auth.isAdmin)
                  _buildProfileItem(Icons.admin_panel_settings, 'Admin Panel', () => Navigator.pushNamed(context, AppRoutes.admin)),
                const Divider(height: 32),
                _buildProfileItem(Icons.logout, 'Logout', () async {
                  await auth.logout();
                  if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
                }, color: AppTheme.errorColor),
              ] else ...[
                Text('Guest Traveler', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                Text('Login to save your trips & journals', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                const SizedBox(height: 32),
                
                _buildProfileItem(Icons.sos, 'Emergency Info', () => Navigator.pushNamed(context, AppRoutes.emergency)),
                const Divider(height: 32),
                _buildProfileItem(Icons.login, 'Sign In / Sign Up', () {
                  Navigator.pushNamed(context, AppRoutes.login);
                }, color: AppTheme.primaryColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: AppTheme.lightCard,
          leading: Icon(icon, color: color ?? AppTheme.textSecondary),
          title: Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: color ?? AppTheme.textPrimary)),
          trailing: Icon(Icons.chevron_right, color: color ?? AppTheme.textMuted),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, String route, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.lightBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondary, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String desc, IconData icon, List<Color> colors, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: colors[0].withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(desc, style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.8)), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        border: Border(top: BorderSide(color: AppTheme.lightBorder.withValues(alpha: 0.5))),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.flight_takeoff_rounded), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
