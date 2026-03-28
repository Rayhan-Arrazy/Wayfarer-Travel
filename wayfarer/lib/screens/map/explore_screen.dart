import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/api_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ApiService _api = ApiService();
  Position? _currentPosition;
  bool _isLoadingNearby = false;
  List<Map<String, dynamic>> _nearbyPlaces = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = position;
      });
      _fetchNearbyData();
    }
  }

  Future<void> _fetchNearbyData() async {
    if (_currentPosition == null) return;
    setState(() => _isLoadingNearby = true);
    
    try {
      final List<Map<String, dynamic>> results = [];
      
      // Fetch ATM
      try {
        final res = await _api.getNearbyPlaces(_currentPosition!.latitude, _currentPosition!.longitude, 'atm', radius: 1000);
        final list = res.data is List ? res.data : (res.data['elements'] ?? []);
        if (list.isNotEmpty) {
          final p = list[0];
          results.add({
            'icon': Icons.attach_money,
            'title': 'ATM',
            'subtitle': p['name'] ?? 'Nearby Bank',
            'highlight': 'OPEN 24H',
            'distance': '0.2 MI',
          });
        }
      } catch (_) {}

      // Fetch Food
      try {
        final res = await _api.getNearbyPlaces(_currentPosition!.latitude, _currentPosition!.longitude, 'restaurant', radius: 1000);
        final list = res.data is List ? res.data : (res.data['elements'] ?? []);
        if (list.isNotEmpty) {
          final p = list[0];
          results.add({
            'icon': Icons.restaurant,
            'title': 'Quick Bite',
            'subtitle': p['name'] ?? 'Local Eatery',
            'highlight': 'HIGHLY RATED',
            'distance': '0.5 MI',
          });
        }
      } catch (_) {}

      // Fetch Transit
      try {
        final res = await _api.getTransitStops(_currentPosition!.latitude, _currentPosition!.longitude, radius: 1000);
        final list = res.data is List ? res.data : (res.data['elements'] ?? res.data['stops'] ?? []);
        if (list.isNotEmpty) {
          final p = list[0];
          results.add({
            'icon': Icons.train,
            'title': 'Transit',
            'subtitle': p['name'] ?? 'Bus/Train Station',
            'highlight': 'ON TIME',
            'distance': '0.1 MI',
          });
        }
      } catch (_) {}

      if (results.isEmpty) {
        // Fallback to mocks if API fails or returns nothing
        results.addAll([
          {'icon': Icons.attach_money, 'title': 'ATM', 'subtitle': 'Global Bank ATM', 'highlight': 'FEE-FREE', 'distance': '0.2 MI'},
          {'icon': Icons.restaurant, 'title': 'Quick Bite', 'subtitle': 'Local Snack Bar', 'highlight': 'TOP RATED', 'distance': '0.5 MI'},
          {'icon': Icons.local_pharmacy, 'title': 'Pharmacy', 'subtitle': 'Health Plus', 'highlight': 'OPEN NOW', 'distance': '0.8 MI'},
        ]);
      }

      if (mounted) {
        setState(() {
          _nearbyPlaces = results;
          _isLoadingNearby = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingNearby = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const Icon(Icons.menu, color: AppTheme.primaryColor),
        title: Text('Wayfarer', 
          style: GoogleFonts.outfit(
            color: AppTheme.primaryColor, 
            fontWeight: FontWeight.w800,
            fontSize: 22,
          )),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=wayfarer'),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // View Live Map Card
            _buildLiveMapCard(),
            
            const SizedBox(height: 48),
            
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What matters', 
                      style: GoogleFonts.outfit(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        color: AppTheme.textPrimary,
                        height: 1.1,
                      )),
                    Text('nearby', 
                      style: GoogleFonts.outfit(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        color: AppTheme.textPrimary,
                        height: 1.1,
                      )),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    _currentPosition != null 
                      ? 'CURRENT COORDINATES:\n${_currentPosition!.latitude.toStringAsFixed(2)} N, ${_currentPosition!.longitude.toStringAsFixed(2)} E'
                      : 'FETCHING LOCATION...',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 9, 
                      fontWeight: FontWeight.w800, 
                      color: const Color(0xFF94A3B8), 
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Nearby Items
            if (_isLoadingNearby)
              const Center(child: Padding(padding: EdgeInsets.all(48.0), child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF334155))))
            else if (_nearbyPlaces.isEmpty)
              Center(child: Text('No places found nearby', style: GoogleFonts.inter(color: AppTheme.textMuted)))
            else
              ..._nearbyPlaces.map((p) => _buildNearbyItem(
                icon: p['icon'],
                title: p['title'],
                subtitle: p['subtitle'],
                highlight: p['highlight'],
                distance: p['distance'],
              )),
            
            const SizedBox(height: 40),
            
            Center(
              child: Text(
                'VIEW ALL CATEGORIES (12)',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMapCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://www.transparenttextures.com/patterns/gray-gears.png'),
          opacity: 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.map, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            'View Live Map',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'EXPLORE REAL-TIME DATA NEAR YOU',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF334155),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Open Explorer',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String highlight,
    required String distance,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  highlight,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            distance,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
