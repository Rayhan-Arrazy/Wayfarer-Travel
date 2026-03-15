import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final ApiService _api = ApiService();
  final _searchController = TextEditingController();
  
  LatLng _center = const LatLng(-6.2088, 106.8456); // Default: Jakarta
  final double _zoom = 13.0;
  List<Marker> _markers = [];
  String _selectedCategory = 'restaurant';
  bool _isLoading = false;
  List<dynamic> _searchResults = [];

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.restaurant, 'label': 'Restaurant', 'value': 'restaurant', 'color': const Color(0xFFFF8A65)},
    {'icon': Icons.hotel, 'label': 'Hotel', 'value': 'hotel', 'color': const Color(0xFFBA68C8)},
    {'icon': Icons.local_atm, 'label': 'ATM', 'value': 'atm', 'color': const Color(0xFFFFB74D)},
    {'icon': Icons.local_hospital, 'label': 'Hospital', 'value': 'hospital', 'color': const Color(0xFFE57373)},
    {'icon': Icons.local_pharmacy, 'label': 'Pharmacy', 'value': 'pharmacy', 'color': const Color(0xFF4DB6AC)},
    {'icon': Icons.camera_alt, 'label': 'Tourism', 'value': 'tourism', 'color': const Color(0xFF64B5F6)},
  ];

  @override
  void initState() {
    super.initState();
    _loadNearbyPlaces();
  }

  Future<void> _loadNearbyPlaces() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.getNearbyPlaces(_center.latitude, _center.longitude, _selectedCategory, radius: 2000);
      final elements = response.data['elements'] as List? ?? [];
      
      setState(() {
        _markers = elements.where((e) => e['lat'] != null).map<Marker>((e) {
          final name = e['tags']?['name'] ?? _selectedCategory;
          final catData = _categories.firstWhere((c) => c['value'] == _selectedCategory);
          return Marker(
            point: LatLng((e['lat'] as num).toDouble(), (e['lon'] as num).toDouble()),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showPlaceInfo(name, e),
              child: Container(
                decoration: BoxDecoration(
                  color: (catData['color'] as Color),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: (catData['color'] as Color).withValues(alpha: 0.4), blurRadius: 6)],
                ),
                child: Icon(catData['icon'] as IconData, color: Colors.white, size: 20),
              ),
            ),
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return;
    try {
      final response = await _api.searchPlaces(query);
      final List results = response.data;
      if (results.isNotEmpty) {
        final place = results[0];
        final lat = double.parse(place['lat'].toString());
        final lon = double.parse(place['lon'].toString());
        setState(() {
          _center = LatLng(lat, lon);
          _searchResults = results.take(5).toList();
        });
        _mapController.move(_center, 14);
        _loadNearbyPlaces();
      }
    } catch (e) {
      // Handle error
    }
  }

  void _showPlaceInfo(String name, Map<String, dynamic> element) {
    final tags = element['tags'] as Map<String, dynamic>? ?? {};
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.lightBorder, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text(name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            if (tags['cuisine'] != null) ...[
              const SizedBox(height: 6),
              Text('Cuisine: ${tags['cuisine']}', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
            ],
            if (tags['opening_hours'] != null) ...[
              const SizedBox(height: 4),
              Text('Hours: ${tags['opening_hours']}', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
            ],
            if (tags['phone'] != null) ...[
              const SizedBox(height: 4),
              Text('📞 ${tags['phone']}', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.primaryColor)),
            ],
            if (tags['website'] != null) ...[
              const SizedBox(height: 4),
              Text('🌐 ${tags['website']}', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.primaryColor)),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _zoom,
              onTap: (tapPosition, point) => setState(() => _searchResults = []),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.wayfarer.app',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          
          // Offline Map Button
          Positioned(
            right: 16,
            top: 100,
            child: FloatingActionButton.small(
              heroTag: 'offline_map',
              backgroundColor: AppTheme.lightCard,
              child: const Icon(Icons.download_for_offline, color: AppTheme.primaryColor),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading region for offline use... (Simulated)')),
                );
              },
            ),
          ),

          // Search Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.lightCard,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8)],
                          ),
                          child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 22),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Search field
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.lightCard,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8)],
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search location...',
                              hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
                              prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onSubmitted: _searchPlace,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Search results dropdown
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4, left: 44),
                      decoration: BoxDecoration(
                        color: AppTheme.lightCard,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)],
                      ),
                      child: Column(
                        children: _searchResults.map<Widget>((r) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 18),
                            title: Text(r['display_name']?.toString().split(',').take(3).join(',') ?? '',
                              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textPrimary),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                            onTap: () {
                              final lat = double.parse(r['lat'].toString());
                              final lon = double.parse(r['lon'].toString());
                              setState(() {
                                _center = LatLng(lat, lon);
                                _searchResults = [];
                              });
                              _mapController.move(_center, 15);
                              _loadNearbyPlaces();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Category chips at bottom
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final isActive = _selectedCategory == cat['value'];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat['value'] as String);
                      _loadNearbyPlaces();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive ? (cat['color'] as Color) : AppTheme.lightCard,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6)],
                      ),
                      child: Row(
                        children: [
                          Icon(cat['icon'] as IconData, size: 18, color: isActive ? Colors.white : AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Text(cat['label'] as String, style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w500,
                            color: isActive ? Colors.white : AppTheme.textSecondary,
                          )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.lightCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor)),
                      const SizedBox(width: 8),
                      Text('Loading places...', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
