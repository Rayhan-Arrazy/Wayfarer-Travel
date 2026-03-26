import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../services/api_service.dart';
import '../guide/guide_list_screen.dart';
import '../map/map_screen.dart';
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

  // =============================================
  // DRAWER — Matches prototype exactly
  // =============================================
  Widget _buildDrawer() {
    final auth = context.watch<AuthProvider>();
    final userName = auth.user?.name ?? 'Traveler';

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(0))),
      child: Column(
        children: [
          // Header with app name + user info
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wayfarer', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: const Color(0xFFF97316))),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Avatar
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            border: Border.all(color: AppTheme.lightBorder, width: 2),
                          ),
                          child: Center(
                            child: Text(userName[0].toUpperCase(), style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                          ),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            width: 16, height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userName, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
                            Text(auth.isAuthenticated ? (auth.isAdmin ? 'ADMIN MEMBER' : 'PREMIUM MEMBER') : 'GUEST USER',
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 0.5)),
                          ],
                        ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Navigation items — matching prototype order
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerNavItem(Icons.home_rounded, 'Home', 0),
                _buildDrawerNavItem(Icons.luggage_rounded, 'Trip Planner', -1, route: AppRoutes.trips),
                _buildDrawerNavItem(Icons.menu_book_rounded, 'Destinations & Guides', -1, route: AppRoutes.guides),
                const Divider(height: 24, indent: 24, endIndent: 24),
                _buildDrawerNavItem(Icons.settings_rounded, 'Settings', -1, route: AppRoutes.settings),
                _buildDrawerNavItem(Icons.person_outline_rounded, 'My Profile', -1, route: AppRoutes.profile),
                _buildDrawerAuthItem(),
              ],
            ),
          ),

          // Version
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text('WAYFARER V${AppConstants.appVersion}', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted, letterSpacing: 1.0)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerNavItem(IconData icon, String label, int tabIndex, {String? route}) {
    final isActive = tabIndex >= 0 && _currentIndex == tabIndex;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFF1E6) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? const Color(0xFFF97316) : AppTheme.textSecondary, size: 22),
        title: Text(label, style: GoogleFonts.inter(fontSize: 15, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? const Color(0xFFF97316) : AppTheme.textPrimary)),
        onTap: () {
          Navigator.pop(context);
          if (route != null) {
            Navigator.pushNamed(context, route);
          } else if (tabIndex >= 0) {
            setState(() => _currentIndex = tabIndex);
          }
        },
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // emergency item removed

  Widget _buildDrawerAuthItem() {
    final auth = context.read<AuthProvider>();
    final isAuth = auth.isAuthenticated;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: ListTile(
        leading: Icon(isAuth ? Icons.logout_rounded : Icons.login_rounded, color: AppTheme.textSecondary, size: 22),
        title: Text(isAuth ? 'Logout' : 'Login / Register', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
        onTap: () {
          if (isAuth) {
            auth.logout();
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          } else {
            Navigator.pushNamed(context, AppRoutes.login);
          }
        },
        dense: true,
      ),
    );
  }

  // =============================================
  // BODY — Tab controller
  // =============================================
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildHomePage();
      case 1: return const TripListScreen();
      case 2: return const MapScreen();
      case 3: return _buildExplorePage();
      case 4: return JournalScreen(tripId: context.watch<TripProvider>().selectedTrip?.id);
      default: return _buildHomePage();
    }
  }

  // =============================================
  // HOME PAGE — Matches prototype
  // =============================================
  Widget _buildHomePage() {
    final auth = context.watch<AuthProvider>();
    final tripProvider = context.watch<TripProvider>();
    final upcomingTrip = tripProvider.selectedTrip; // Changed to selectedTrip
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
                        Text('Wayfarer', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                      child: Container(
                        width: 36, height: 36,
                        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient, shape: BoxShape.circle),
                        child: Center(child: Text(userName[0].toUpperCase(), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
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
                      'Ready for your next\njourney?',
                      style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.5, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Trip Selector Dropdown
              if (tripProvider.trips.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.lightBorder),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: tripProvider.selectedTrip?.id,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryColor),
                        items: tripProvider.trips.map((t) {
                          return DropdownMenuItem(
                            value: t.id,
                            child: Row(
                              children: [
                                const Icon(Icons.flight_takeoff, size: 16, color: AppTheme.primaryColor),
                                const SizedBox(width: 12),
                                Expanded(child: Text('${t.destination} (${DateFormat('MMM d').format(t.startDate)})', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600))),
                              ],
                            ),
                          );
                        }).toList(),
                         onChanged: (id) {
                          final selected = tripProvider.trips.firstWhere((t) => t.id == id);
                          tripProvider.setSelectedTrip(selected);
                        },
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Upcoming/Selected Trip Card
              if (tripProvider.selectedTrip != null)
                _buildUpcomingTripCard(tripProvider.selectedTrip!)
              else
                _buildNoTripCard(),

              const SizedBox(height: 16),

              // Removed Extra Features

              const SizedBox(height: 24),

              // Packing Checklist — MATCHES PROTOTYPE with interactive checkboxes
              if (upcomingTrip != null && upcomingTrip.checklist.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Packing Checklist', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                      Text('${upcomingTrip.checklist.where((c) => c.checked).length}/${upcomingTrip.checklist.length} COMPLETED',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFF97316))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...upcomingTrip.checklist.take(4).map((item) => _buildChecklistItem(item, upcomingTrip)),
              ],

              // Your Trips carousel
              _buildTripsCarousel(tripProvider.trips),

              const SizedBox(height: 32),

              // Quick Feature Grid (Restored)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Travel Toolkit', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(children: [
                      _buildQuickFeature(Icons.public, 'Guides', AppRoutes.guides, const Color(0xFF6366F1)),
                      const SizedBox(width: 12),
                      _buildQuickFeature(Icons.sunny, 'Weather', AppRoutes.weather, const Color(0xFF0EA5E9)),
                      const SizedBox(width: 12),
                      _buildQuickFeature(Icons.currency_exchange, 'FX', AppRoutes.currency, const Color(0xFF10B981)),
                      const SizedBox(width: 12),
                      _buildQuickFeature(Icons.favorite, 'Saved', AppRoutes.favorites, const Color(0xFFEC4899)),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // IMPROVISED: Itinerary & Budget
              if (tripProvider.selectedTrip != null) ...[
                _buildItinerarySection(tripProvider.selectedTrip!),
                const SizedBox(height: 32),
                _buildBudgetSection(tripProvider.selectedTrip!),
              ],
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================
  // Upcoming Trip Card — with map preview like prototype
  // =============================================
  Widget _buildUpcomingTripCard(TripModel trip) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () async {
          await Navigator.pushNamed(context, AppRoutes.tripDetail, arguments: trip.id);
          if (mounted) context.read<TripProvider>().fetchTrips();
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E2E46),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFF1E2E46).withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10))],
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
                    decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      trip.isActive ? 'ACTIVE NOW' : 'UPCOMING TRIP',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.luggage, color: Colors.white, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(trip.destination, style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                'Departure: ${DateFormat('MMM dd, yyyy').format(trip.startDate)}',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 16),

              // Map preview — static map image using Google Static Maps or placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: const Color(0xFF2D3748),
                  child: Stack(
                    children: [
                      // Use cover image as map preview placeholder
                      CachedNetworkImage(
                        imageUrl: trip.coverImage.isNotEmpty
                            ? '${trip.coverImage}?w=800&q=60'
                            : 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800&q=60',
                        height: 120, width: double.infinity, fit: BoxFit.cover,
                        color: const Color(0xFF1E2E46).withOpacity(0.5),
                        colorBlendMode: BlendMode.darken,
                        errorWidget: (_, __, ___) => Container(color: const Color(0xFF2D3748)),
                      ),
                      // Map pin overlay
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Color(0xFFF97316), shape: BoxShape.circle),
                          child: const Icon(Icons.location_on, color: Colors.white, size: 16),
                        ),
                      ),
                      // VIEW ITINERARY button
                      Positioned(
                        bottom: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                          child: Text('VIEW ITINERARY', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                        ),
                      ),
                      // City label
                      Positioned(
                        bottom: 8, right: 8,
                        child: Text(
                          trip.destination.split(',').first.toUpperCase(),
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white70),
                        ),
                      ),
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

  // =============================================
  // Checklist Item — interactive like prototype
  // =============================================
  Widget _buildChecklistItem(dynamic item, dynamic trip) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.lightBorder),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                final idx = trip.checklist.indexOf(item);
                if (idx >= 0) {
                  try {
                    await ApiService().toggleChecklistItem(trip.id, idx);
                    if (mounted) context.read<TripProvider>().fetchTrips();
                  } catch (_) {}
                }
              },
              child: Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: item.checked ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: item.checked ? AppTheme.primaryColor : AppTheme.textMuted, width: 2),
                ),
                child: item.checked ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.item,
                style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w500,
                  color: item.checked ? AppTheme.textMuted : AppTheme.textPrimary,
                  decoration: item.checked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsCarousel(List<TripModel> trips) {
    if (trips.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
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
            itemCount: trips.length.clamp(0, 5),
            itemBuilder: (ctx, i) {
              final trip = trips[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.tripDetail, arguments: trip.id),
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(image: CachedNetworkImageProvider('${trip.coverImage}?w=400&q=80'), fit: BoxFit.cover),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)]),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trip.destination, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1),
                        Text('${DateFormat('MMM dd').format(trip.startDate)} - ${DateFormat('MMM dd').format(trip.endDate)}', style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItinerarySection(TripModel trip) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adventure Timeline', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
          const SizedBox(height: 16),
          _buildItineraryItem('Day 1: Arrival & Check-in', 'Airport Pickup • Hotel Senso • Dinner', '09:00 AM', true),
          _buildItineraryItem('Day 2: Exploration', 'City Tour • Main Landmarks', '08:30 AM', false),
        ],
      ),
    );
  }

  Widget _buildItineraryItem(String title, String spots, String time, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: isDone ? const Color(0xFFF97316) : Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF97316), width: 2))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$time • $title', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                Text(spots, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBudgetSection(TripModel trip) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Budget Overview', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Budget', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF4338CA))),
                Text('\$${trip.budget}', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF4338CA))),
              ],
            ),
          ),
        ],
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

  // =============================================
  // EXPLORE PAGE
  // =============================================
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
                  _buildExploreSection('Safety & Personal'),
                  _buildExploreItem(Icons.favorite, 'Favorites', 'Your saved spots',
                      () => Navigator.pushNamed(context, AppRoutes.favorites), const Color(0xFFEC4899)),
                  _buildExploreItem(Icons.person, 'Profile', 'Manage account details',
                      () => Navigator.pushNamed(context, AppRoutes.profile), const Color(0xFF64748B)),
                  _buildExploreItem(Icons.settings, 'Settings', 'App preferences & account settings',
                      () => Navigator.pushNamed(context, AppRoutes.settings), const Color(0xFF6B7280)),

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

  // =============================================
  // BOTTOM NAV — Matches prototype with elevated map
  // =============================================
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, Icons.home_filled, 'HOME', 0),
              _buildNavItem(Icons.luggage_outlined, Icons.luggage, 'TRIPS', 1),
              // Elevated MAP button — like prototype
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 2),
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: _currentIndex == 2 ? AppTheme.primaryColor : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    boxShadow: _currentIndex == 2
                        ? [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Icon(Icons.map, size: 24, color: _currentIndex == 2 ? Colors.white : AppTheme.textSecondary),
                ),
              ),
              _buildNavItem(Icons.explore_outlined, Icons.explore, 'EXPLORE', 3),
              _buildNavItem(Icons.book_outlined, Icons.book, 'JOURNAL', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, size: 24, color: isActive ? AppTheme.primaryColor : const Color(0xFF94A3B8)),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: isActive ? FontWeight.bold : FontWeight.w600, color: isActive ? AppTheme.primaryColor : const Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }
}
