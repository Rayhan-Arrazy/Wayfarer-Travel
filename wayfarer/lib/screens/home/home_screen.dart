import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../guide/guide_list_screen.dart';
import '../map/map_screen.dart';
import '../trip_planner/trip_list_screen.dart';
import '../journal/journal_screen.dart';

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
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.pushNamed(context, AppRoutes.createTrip);
                if (mounted) context.read<TripProvider>().fetchTrips();
              },
              backgroundColor: const Color(0xFFF97316),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
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
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (auth.user?.name ?? 'U')[0].toUpperCase(),
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(auth.user?.name ?? 'Traveler',
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(auth.user?.email ?? '',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                if (auth.isAdmin) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text('Admin', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildDrawerItem(Icons.person_outline, 'Profile', () {
            Navigator.pop(context);
            Navigator.pushNamed(context, AppRoutes.profile);
          }),
          _buildDrawerItem(Icons.favorite_border, 'Favorites', () {
            Navigator.pop(context);
          }),
          _buildDrawerItem(Icons.settings_outlined, 'Settings', () {
            Navigator.pop(context);
          }),
          const Divider(height: 32),
          _buildDrawerItem(Icons.logout, 'Sign Out', () {
            auth.logout();
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }, color: AppTheme.errorColor),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.textPrimary, size: 22),
      title: Text(label, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: color ?? AppTheme.textPrimary)),
      onTap: onTap,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const TripListScreen();
      case 2:
        return const MapScreen();
      case 3:
        return const JournalScreen();
      case 4:
        return _buildExplorePage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    final auth = context.watch<AuthProvider>();
    final tripProvider = context.watch<TripProvider>();
    final upcomingTrip = tripProvider.upcomingTrip;
    final userName = auth.user?.name.split(' ').first ?? 'Traveler';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await context.read<TripProvider>().fetchTrips();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _scaffoldKey.currentState?.openDrawer(),
                          child: const Icon(Icons.menu, color: AppTheme.primaryColor, size: 26),
                        ),
                        const SizedBox(width: 16),
                        Text('Wayfarer',
                          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            userName[0].toUpperCase(),
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Welcome Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WELCOME BACK', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: const Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    Text(
                      'Hey $userName! 👋\nReady for adventure?',
                      style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.5, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Upcoming Trip Card
              if (upcomingTrip != null)
                _buildUpcomingTripCard(upcomingTrip)
              else
                _buildNoTripCard(),

              const SizedBox(height: 16),

              // Quick Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.currency),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.sync_alt, color: Color(0xFF3B82F6), size: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('EXCHANGE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text('1 ${auth.user?.homeCurrency ?? "USD"}', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text('Tap to convert', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.emergency),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: const Color(0xFFE11D48), borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.local_hospital, color: Colors.white, size: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('EMERGENCY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text('Safety Hub', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text('SOS & Help', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Trip Summary
              if (tripProvider.trips.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your Trips', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                      GestureDetector(
                        onTap: () => setState(() => _currentIndex = 1),
                        child: Text('See All', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFF97316))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    clipBehavior: Clip.none,
                    itemCount: tripProvider.trips.length.clamp(0, 5),
                    itemBuilder: (ctx, i) {
                      final trip = tripProvider.trips[i];
                      final coverImg = trip.coverImage.isNotEmpty
                          ? trip.coverImage
                          : 'https://images.unsplash.com/photo-1488646953014-85cb44e25828';
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(context, AppRoutes.tripDetail, arguments: trip.id);
                          if (mounted) context.read<TripProvider>().fetchTrips();
                        },
                        child: Container(
                          width: 180,
                          margin: const EdgeInsets.only(right: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider('$coverImg?w=400&q=80'),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                              ),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: trip.isActive
                                        ? AppTheme.successColor
                                        : trip.isCompleted
                                            ? Colors.white24
                                            : const Color(0xFFF97316),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    trip.status.toUpperCase(),
                                    style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(trip.destination, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(
                                  '${DateFormat('MMM dd').format(trip.startDate)} - ${DateFormat('MMM dd').format(trip.endDate)}',
                                  style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Quick Feature Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Quick Access', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildQuickFeature(Icons.restaurant, 'Food', AppRoutes.food, const Color(0xFF9333EA)),
                    const SizedBox(width: 12),
                    _buildQuickFeature(Icons.cloud, 'Weather', AppRoutes.weather, const Color(0xFF0EA5E9)),
                    const SizedBox(width: 12),
                    _buildQuickFeature(Icons.hotel, 'Stay', AppRoutes.accommodation, const Color(0xFFD97706)),
                    const SizedBox(width: 12),
                    _buildQuickFeature(Icons.directions_car, 'Transport', AppRoutes.transport, const Color(0xFF16A34A)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingTripCard(dynamic trip) {
    final coverImg = trip.coverImage.isNotEmpty
        ? trip.coverImage
        : 'https://images.unsplash.com/photo-1488646953014-85cb44e25828';
    final daysUntil = trip.startDate.difference(DateTime.now()).inDays;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () async {
          await Navigator.pushNamed(context, AppRoutes.tripDetail, arguments: trip.id);
          if (mounted) context.read<TripProvider>().fetchTrips();
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF233C5B),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFF233C5B).withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: trip.isActive ? AppTheme.successColor : const Color(0xFFF97316),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trip.isActive ? 'ACTIVE NOW' : (daysUntil > 0 ? '$daysUntil DAYS LEFT' : 'UPCOMING'),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          children: [
                            const Icon(Icons.people, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text('${trip.partySize}', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(trip.destination, style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                '${DateFormat('MMM dd').format(trip.startDate)} - ${DateFormat('MMM dd, yyyy').format(trip.endDate)}',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 16),

              // Cover image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: '$coverImg?w=800&q=80',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(height: 150, color: Colors.grey.shade800),
                  errorWidget: (_, __, ___) => Container(height: 150, color: Colors.grey.shade800, child: const Icon(Icons.image, color: Colors.white24, size: 40)),
                ),
              ),
              const SizedBox(height: 14),

              // Checklist progress
              if (trip.checklist.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Checklist', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
                    Text('${trip.checklistProgress}%', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFF97316), fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: trip.checklistProgress / 100,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    color: const Color(0xFFF97316),
                    minHeight: 5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoTripCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.createTrip),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            children: [
              const Icon(Icons.flight_takeoff, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text('Plan Your First Trip', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Tap here to start planning your next adventure', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70, height: 1.4), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Text('Get Started', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFeature(IconData icon, String label, String route, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6)],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplorePage() {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Explore', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                  const SizedBox(height: 4),
                  Text('Discover tools for your journey', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildExploreSection('Travel Planning'),
                  _buildExploreItem(Icons.public, 'Country Guides', 'Comprehensive handbook for every nation',
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideListScreen())), Colors.indigo),
                  _buildExploreItem(Icons.luggage, 'Trip Planner', 'Plan itineraries & manage checklists',
                      () => setState(() => _currentIndex = 1), const Color(0xFFF97316)),
                  _buildExploreItem(Icons.map, 'Interactive Map', 'Explore nearby places & points of interest',
                      () => setState(() => _currentIndex = 2), const Color(0xFF0EA5E9)),

                  const SizedBox(height: 20),
                  _buildExploreSection('Services'),
                  _buildExploreItem(Icons.currency_exchange, 'Currency & Finance', 'Live exchange rates & budget tools',
                      () => Navigator.pushNamed(context, AppRoutes.currency), const Color(0xFF16A34A)),
                  _buildExploreItem(Icons.cloud, 'Weather', 'Live forecast, UV index & air quality',
                      () => Navigator.pushNamed(context, AppRoutes.weather), const Color(0xFF0284C7)),
                  _buildExploreItem(Icons.restaurant, 'Food & Dining', 'Find restaurants & local cuisine',
                      () => Navigator.pushNamed(context, AppRoutes.food), const Color(0xFF9333EA)),
                  _buildExploreItem(Icons.hotel, 'Accommodation', 'Hotels, hostels & apartments',
                      () => Navigator.pushNamed(context, AppRoutes.accommodation), const Color(0xFFD97706)),
                  _buildExploreItem(Icons.directions_car, 'Transport', 'Routes, flights & transit stops',
                      () => Navigator.pushNamed(context, AppRoutes.transport), const Color(0xFF059669)),

                  const SizedBox(height: 20),
                  _buildExploreSection('Safety & Personal'),
                  _buildExploreItem(Icons.sos, 'Emergency Services', 'SOS, hospitals & emergency numbers',
                      () => Navigator.pushNamed(context, AppRoutes.emergency), const Color(0xFFDC2626)),
                  _buildExploreItem(Icons.edit_note, 'Travel Journal', 'Document your journey memories',
                      () => setState(() => _currentIndex = 3), const Color(0xFF7C3AED)),
                  _buildExploreItem(Icons.person, 'Profile', 'Manage account & emergency contacts',
                      () => Navigator.pushNamed(context, AppRoutes.profile), const Color(0xFF64748B)),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1.0)),
    );
  }

  Widget _buildExploreItem(IconData icon, String title, String subtitle, VoidCallback onTap, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primaryColor)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.luggage_outlined), activeIcon: Icon(Icons.luggage), label: 'Trips'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Map'),
            BottomNavigationBarItem(icon: Icon(Icons.edit_note_outlined), activeIcon: Icon(Icons.edit_note), label: 'Journal'),
            BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Explore'),
          ],
        ),
      ),
    );
  }
}
