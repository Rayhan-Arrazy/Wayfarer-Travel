import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/routes.dart';
import '../../services/api_service.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final ApiService _api = ApiService();
  Position? _currentPosition;
  Map<String, List<Map<String, dynamic>>> _categorizedItems = {};
  bool _isLoading = true;

  final List<Map<String, String>> _categoriesToFetch = [
    {'label': 'EMERGENCY', 'type': 'emergency'},
    {'label': 'FINANCIAL', 'type': 'financial'},
    {'label': 'TRANSPORT', 'type': 'station'},
    {'label': 'DINING', 'type': 'restaurant'},
  ];

  @override
  void initState() {
    super.initState();
    _loadNearbyData();
  }

  Future<void> _loadNearbyData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _currentPosition = pos);

      Map<String, List<Map<String, dynamic>>> newCategorizedItems = {};

      for (var cat in _categoriesToFetch) {
        try {
          final response = await _api.getNearbyPlaces(pos.latitude, pos.longitude, cat['type']!, radius: 2000);
          final List<dynamic> elements = response.data['elements'] ?? [];
          
          List<Map<String, dynamic>> items = [];
          for (var e in elements.take(2)) { // Take top 2 per category
            final tags = e['tags'] ?? {};
            items.add({
              'icon': _getIconForTags(tags),
              'title': tags['name'] ?? tags['amenity'] ?? tags['tourism'] ?? 'Point of Interest',
              'subtitle': _getSubtitleForTags(tags),
              'badge': _getBadgeForTags(tags, cat['label']!),
              'distance': _calculateDistanceString(e['lat'] ?? e['center']?['lat'], e['lon'] ?? e['center']?['lon']),
            });
          }
          if (items.isNotEmpty) {
            newCategorizedItems[cat['label']!] = items;
          }
        } catch (e) {
          debugPrint('Error fetching ${cat['label']}: $e');
        }
      }

      if (!mounted) return;
      setState(() {
        _categorizedItems = newCategorizedItems;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('ExploreTab Load Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _getIconForTags(Map tags) {
    if (tags['amenity'] == 'hospital' || tags['amenity'] == 'clinic' || tags['amenity'] == 'pharmacy') return Icons.medical_services;
    if (tags['amenity'] == 'atm' || tags['amenity'] == 'bank' || tags['amenity'] == 'bureau_de_change') return Icons.attach_money;
    if (tags['amenity'] == 'restaurant' || tags['amenity'] == 'cafe') return Icons.restaurant;
    if (tags['railway'] == 'station' || tags['amenity'] == 'bus_station') return Icons.train;
    return Icons.place;
  }

  String _getSubtitleForTags(Map tags) {
    final amenity = (tags['amenity'] ?? tags['tourism'] ?? 'Point of Interest').toString().replaceAll('_', ' ');
    final hours = tags['opening_hours'] != null ? ' • ${tags['opening_hours']}' : ' • Hours vary';
    return '${amenity.toUpperCase()}$hours';
  }

  String _getBadgeForTags(Map tags, String category) {
    if (category == 'EMERGENCY') return 'PRIORITY ASSISTANCE AVAILABLE';
    if (category == 'FINANCIAL') return 'GLOBAL WITHDRAWAL SUPPORTED';
    if (tags['cuisine'] != null) return 'CUISINE: ${tags['cuisine'].toString().toUpperCase()}';
    return 'HIGHLY RATED LOCALLY';
  }

  String _calculateDistanceString(dynamic lat, dynamic lon) {
    if (lat == null || lon == null || _currentPosition == null) return '0.5 KM';
    final distance = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, lat.toDouble(), lon.toDouble());
    if (distance < 1000) return '${distance.round()} M';
    return '${(distance/1000).toStringAsFixed(1)} KM';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu, color: Color(0xFF132F5C)),
        ),
        title: Text('Wayfarer', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1D4E89))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.person, color: Color(0xFF132F5C))),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNearbyData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Live Map Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  image: DecorationImage(
                    image: const NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&q=80'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.9), BlendMode.lighten),
                  ),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  children: [
                     Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                       child: const Icon(Icons.map, color: Color(0xFF132F5C), size: 32),
                     ),
                     const SizedBox(height: 24),
                     Text('View Live Map', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                     const SizedBox(height: 8),
                     Text('EXPLORE REAL-TIME DATA NEAR YOU', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.0)),
                     const SizedBox(height: 24),
                     SizedBox(
                       height: 56,
                       width: 180,
                       child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF132F5C),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Open Explorer', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
                       ),
                     ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('What matters\nnearby', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46), height: 1.1)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                        child: Text('LIVE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF166534))),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('CURRENT COORDINATES:', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1.0)),
                      Text(
                        _currentPosition != null 
                        ? '${_currentPosition!.latitude.toStringAsFixed(2)} N, ${_currentPosition!.longitude.toStringAsFixed(2)} E'
                        : 'Loading...', 
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(color: Color(0xFF132F5C)),
                ))
              else if (_categorizedItems.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text('No essential places found nearby.', style: GoogleFonts.inter(color: Colors.grey)),
                ))
              else
                ..._categorizedItems.entries.map((entry) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, top: 8),
                      child: Text(entry.key, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1.5)),
                    ),
                    ...entry.value.map((item) => _buildNearbyItem(
                      item['icon'], item['title'], item['subtitle'], item['badge'], item['distance']
                    )),
                    const SizedBox(height: 16),
                  ],
                )),

              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
                  child: Text('VIEW ALL ON MAP', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF64748B), letterSpacing: 1.0)),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyItem(IconData icon, String title, String subtitle, String badge, String distance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Container(
             padding: const EdgeInsets.all(10),
             decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
             child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Flexible(child: Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46)), overflow: TextOverflow.ellipsis)),
                     Text(distance, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                   ],
                 ),
                 Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
                 const SizedBox(height: 4),
                 Text(badge, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF1E40AF), letterSpacing: 0.5)),
               ],
             ),
           ),
        ],
      ),
    );
  }
}
