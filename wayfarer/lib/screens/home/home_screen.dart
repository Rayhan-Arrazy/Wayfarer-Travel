import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';

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
      context.read<TripProvider>().fetchTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      body: tripProvider.isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDrawer() {
    final auth = context.watch<AuthProvider>();
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(32))),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
            color: AppTheme.primaryColor,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                Text(auth.user?.name ?? 'Alex Rivera', 
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(auth.user?.email ?? 'alex@example.com', 
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDrawerItem(Icons.home_outlined, 'Home', () => Navigator.pop(context)),
          _buildDrawerItem(Icons.map_outlined, 'Navigation', () => Navigator.pushNamed(context, AppRoutes.map)),
          _buildDrawerItem(Icons.restaurant_outlined, 'Dining & Food', () => Navigator.pushNamed(context, AppRoutes.food)),
          _buildDrawerItem(Icons.hotel_outlined, 'Accommodation', () => Navigator.pushNamed(context, AppRoutes.accommodation)),
          _buildDrawerItem(Icons.currency_exchange_outlined, 'Currency Converter', () => Navigator.pushNamed(context, AppRoutes.currency)),
          _buildDrawerItem(Icons.cloud_outlined, 'Weather Forecast', () => Navigator.pushNamed(context, AppRoutes.weather)),
          _buildDrawerItem(Icons.book_outlined, 'Travel Journal', () => Navigator.pushNamed(context, AppRoutes.journal)),
          const Divider(indent: 24, endIndent: 24, height: 40),
          _buildDrawerItem(Icons.emergency_outlined, 'Emergency SOS', () => Navigator.pushNamed(context, AppRoutes.emergency), color: AppTheme.errorColor),
          _buildDrawerItem(Icons.logout, 'Sign Out', () => auth.logout(), color: AppTheme.textMuted),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Wayfarer v1.0.0', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.textPrimary, size: 22),
      title: Text(label, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: color ?? AppTheme.textPrimary)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
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
    final tripProvider = context.watch<TripProvider>();
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Premium Top Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: const Icon(Icons.menu, color: AppTheme.textPrimary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Text('Wayfarer',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=user123'),
                  ),
                ],
              ),
            ),
          ),

          // Welcome Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WELCOME BACK!', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppTheme.textMuted)),
                  const SizedBox(height: 4),
                  Text(
                    'Ready for your next\njourney?',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -0.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Journey Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: tripProvider.upcomingTrip == null 
                ? _buildNoTripCard() 
                : Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 15))
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(6)),
                              child: const Text('UPCOMING TRIP', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 16),
                            Text(tripProvider.upcomingTrip!.destination, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                              '${tripProvider.upcomingTrip!.startDate.toString().substring(0, 10)} - ${tripProvider.upcomingTrip!.endDate.toString().substring(0, 10)}', 
                              style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 20,
                        top: 20,
                        bottom: 20,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: tripProvider.upcomingTrip!.coverImage.isNotEmpty 
                                ? tripProvider.upcomingTrip!.coverImage 
                                : 'https://images.unsplash.com/photo-1493976040372-50b510520638?q=80&w=400',
                            width: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ),
          ),

          // SOS and Exchange Rates
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatButton(
                    icon: Icons.currency_exchange,
                    label: 'EXCHANGE RATE',
                    value: '145.20 JPY',
                    color: const Color(0xFFF1F5F9),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.currency),
                  ),
                  const SizedBox(width: 12),
                  _buildStatButton(
                    icon: Icons.emergency_outlined,
                    label: 'EMERGENCY',
                    value: 'Dial 119',
                    color: const Color(0xFFFEF2F2),
                    textColor: AppTheme.errorColor,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.emergency),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // Items to Pack Section
          _buildHorizontalSectionHeader('Items to Pack', '1/12 COMPLETED'),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  _buildChecklistCard('Passport & Visa', Icons.badge_outlined, true),
                  _buildChecklistCard('Power Adapter', Icons.power_outlined, false),
                  _buildChecklistCard('Cash (JPY)', Icons.payments_outlined, false),
                  _buildChecklistCard('Winter Coat', Icons.checkroom_outlined, false),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Check for Departure Section
          _buildHorizontalSectionHeader('Check for Departure', '0/4 DONE'),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  _buildChecklistCard('Vaccination', Icons.vaccines_outlined, false, category: 'HEALTH'),
                  _buildChecklistCard('Insurance', Icons.verified_user_outlined, false, category: 'ADMIN'),
                  _buildChecklistCard('Flight Checkin', Icons.flight_land, false, category: 'TRANSPORT'),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // Health Essentials
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Health Essentials', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  _buildHealthCard(Icons.wb_sunny_outlined, 'UV INDEX', 'Moderate'),
                  _buildHealthCard(Icons.air, 'AIR QUALITY', 'Good (42)'),
                  _buildHealthCard(Icons.health_and_safety_outlined, 'VACCINE', 'Required'),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHorizontalSectionHeader(String title, String status) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(status, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primaryColor, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistCard(String title, IconData icon, bool isChecked, {String? category}) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isChecked ? AppTheme.primaryColor.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isChecked ? AppTheme.primaryColor.withValues(alpha: 0.2) : const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: isChecked ? AppTheme.primaryColor : AppTheme.textSecondary),
              if (isChecked) const Icon(Icons.check_circle, size: 16, color: AppTheme.successColor),
            ],
          ),
          const Spacer(),
          if (category != null) 
            Text(category, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, height: 1.2)),
        ],
      ),
    );
  }

  Widget _buildStatButton({required IconData icon, required String label, required String value, required Color color, Color? textColor, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: textColor ?? AppTheme.textSecondary),
              const SizedBox(height: 8),
              Text(label, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: textColor ?? AppTheme.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthCard(IconData icon, String label, String value) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: AppTheme.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
                Text(value, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplorePage() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Explore', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Text('Discover everything for your trip', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildExploreItem(Icons.map_outlined, 'Navigation', 'Live maps & directions', AppRoutes.map, Colors.blue),
                    _buildExploreItem(Icons.restaurant_outlined, 'Dining', 'Best local eateries', AppRoutes.food, Colors.orange),
                    _buildExploreItem(Icons.hotel_outlined, 'Stays', 'Hotels & apartments', AppRoutes.accommodation, Colors.purple),
                    _buildExploreItem(Icons.currency_exchange_outlined, 'Finance', 'Rates & Budget', AppRoutes.currency, Colors.green),
                    _buildExploreItem(Icons.cloud_outlined, 'Weather', 'Live forecast & Air', AppRoutes.weather, Colors.lightBlue),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, route),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
      ),
    );
  }

  Widget _buildTripsPage() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Trips', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.createTrip),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('New'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTripListCard('Kyoto Adventure', 'Oct 12 - 20, 2024', 'Japan', 'https://images.unsplash.com/photo-1493976040372-50b510520638?q=80&w=400'),
              _buildTripListCard('Paris Escape', 'Dec 15 - 22, 2023', 'France', 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=400'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripListCard(String title, String date, String country, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            child: CachedNetworkImage(imageUrl: imageUrl, width: 120, height: 120, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(country.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.accentColor, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
                  Text(date, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    final auth = context.watch<AuthProvider>();
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const CircleAvatar(radius: 50, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=user123')),
              const SizedBox(height: 16),
              Text(auth.user?.name ?? 'Alex Rivera', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800)),
              Text(auth.user?.email ?? 'alex.rivera@example.com', style: GoogleFonts.inter(color: AppTheme.textMuted)),
              const SizedBox(height: 32),
              _buildProfileOption(Icons.person_outline, 'Personal Info'),
              _buildProfileOption(Icons.history, 'Trip History'),
              _buildProfileOption(Icons.favorite_border, 'Favorites'),
              _buildProfileOption(Icons.settings_outlined, 'Settings'),
              const Divider(height: 40),
              _buildProfileOption(Icons.logout, 'Sign Out', color: AppTheme.errorColor, onTap: () => auth.logout()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? AppTheme.textPrimary),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: color ?? AppTheme.textPrimary)),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF1F5F9)))),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textMuted,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_filled), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'EXPLORE'),
          BottomNavigationBarItem(icon: Icon(Icons.flight_outlined), activeIcon: Icon(Icons.flight), label: 'TRIPS'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'PROFILE'),
        ],
      ),
    );
  }

  Widget _buildNoTripCard() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flight_takeoff, color: AppTheme.textMuted, size: 40),
          const SizedBox(height: 12),
          Text('No upcoming trips', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('Plan your next adventure now', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.createTrip),
            child: const Text('Create Trip'),
          ),
        ],
      ),
    );
  }
}
