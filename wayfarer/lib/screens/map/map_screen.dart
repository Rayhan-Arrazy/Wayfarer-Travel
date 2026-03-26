import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final _searchController = TextEditingController();
  final ApiService _api = ApiService();

  LatLng _center = const LatLng(35.6895, 139.6917); // Tokyo
  double _zoom = 15.0;
  List<Marker> _markers = [];
  String _selectedCategory = 'Restaurants';
  bool _isSearching = false;

  // Currently selected place for bottom sheet
  Map<String, dynamic>? _selectedPlace;
  bool _showBottomSheet = true;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.restaurant, 'label': 'Restaurants', 'osm': 'restaurant'},
    {'icon': Icons.hotel, 'label': 'Stays', 'osm': 'hotel'},
    {'icon': Icons.camera_alt, 'label': 'Sights', 'osm': 'tourism'},
  ];

  // Default featured place
  final Map<String, dynamic> _defaultPlace = {
    'name': 'Tonkotsu Ramen Shinjuku',
    'address': '2 Chome-1-1 Shinjuku, Tokyo 160-0022, Japan',
    'category': 'TOP RATED DINING',
    'rating': 5,
    'image': 'https://images.unsplash.com/photo-1557872943-16a5ac26437e?w=800&q=80',
    'hours': 'OPEN UNTIL\n11:45 PM',
    'price': 'MODERATE',
    'lat': 35.6938,
    'lng': 139.7034,
  };

  @override
  void initState() {
    super.initState();
    _selectedPlace = _defaultPlace;
    _addMarker(_center, _defaultPlace['name']);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addMarker(LatLng pos, String label) {
    setState(() {
      _markers = [
        Marker(
          point: pos,
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF97316),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: const Color(0xFFF97316).withValues(alpha: 0.4), blurRadius: 8)],
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 20),
          ),
        ),
      ];
    });
  }

  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);
    try {
      final response = await _api.searchPlaces(query);
      final results = response.data;
      if (results is List && results.isNotEmpty) {
        final first = results[0];
        final lat = (first['lat'] as num?)?.toDouble() ?? _center.latitude;
        final lng = (first['lng'] as num?)?.toDouble() ?? (first['lon'] as num?)?.toDouble() ?? _center.longitude;
        final newCenter = LatLng(lat, lng);

        setState(() {
          _center = newCenter;
          _selectedPlace = {
            'name': first['name'] ?? query,
            'address': first['display_name'] ?? first['address'] ?? '',
            'category': _selectedCategory.toUpperCase(),
            'rating': 4,
            'image': '',
            'hours': '',
            'price': '',
            'lat': lat,
            'lng': lng,
          };
          _showBottomSheet = true;
        });

        _addMarker(newCenter, first['name'] ?? query);
        _mapController.move(newCenter, 16);
      }
    } catch (e) {
      // Silently fail
    }
    setState(() => _isSearching = false);
  }

  Future<void> _searchNearby(String type) async {
    try {
      final response = await _api.getNearbyPlaces(_center.latitude, _center.longitude, type, radius: 2000);
      final dynamic data = response.data;
      List<dynamic> resultsList = [];
      
      if (data is List) {
        resultsList = data;
      } else if (data is Map) {
        // Handle Overpass elements OR our custom wrapper like { restaurants: [...] }
        resultsList = data['elements'] ?? data['restaurants'] ?? data['stops'] ?? data['accommodations'] ?? [];
      }

      if (resultsList.isNotEmpty) {
        List<Marker> newMarkers = [];
        for (var place in resultsList.take(15)) {
          final lat = (place['lat'] as num?)?.toDouble() ?? (place['center'] != null ? (place['center']['lat'] as num?)?.toDouble() : null);
          final lng = (place['lng'] as num?)?.toDouble() ?? (place['lon'] as num?)?.toDouble() ?? (place['center'] != null ? (place['center']['lon'] as num?)?.toDouble() : null);
          
          if (lat != null && lng != null) {
            final name = place['name'] ?? (place['tags'] != null ? place['tags']['name'] : null) ?? 'Nearby Spot';
            final address = place['address'] ?? (place['tags'] != null ? [place['tags']['addr:street'], place['tags']['addr:housenumber']].where((e) => e != null).join(' ') : null) ?? '';
            final category = type.toUpperCase();
            final image = place['imageUrl'] ?? '';

            newMarkers.add(
              Marker(
                point: LatLng(lat, lng),
                width: 40, height: 40,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPlace = {
                        'name': name,
                        'address': address.isEmpty ? 'Tap for more info' : address,
                        'category': category,
                        'rating': 4,
                        'image': image,
                        'hours': 'OPEN',
                        'price': 'MODERATE',
                        'lat': lat,
                        'lng': lng,
                      };
                      _showBottomSheet = true;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Icon(_getIconForType(type), color: Colors.white, size: 20),
                  ),
                ),
              ),
            );
          }
        }
        if (newMarkers.isNotEmpty) setState(() => _markers = newMarkers);
      }
    } catch (_) {}
  }

  Future<void> _handleMapTap(TapPosition tapPosition, LatLng point) async {
    setState(() {
      _isSearching = true;
      _showBottomSheet = false;
    });
    try {
      // Revert to backend proxy or direct to nominatim if proxy fails
      // We will just try using _api.reverseGeocode if exists, else direct parsing
      // For simplicity let's use the node backend proxy.
      final res = await _api.reverseGeocode(point.latitude, point.longitude);
      final data = res.data;
      String name = 'Marked Location';
      String address = '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
      
      if (data is Map) {
         name = data['name'] ?? data['address']?['suburb'] ?? data['address']?['city'] ?? data['display_name']?.toString().split(',')[0] ?? name;
         address = data['display_name'] ?? address;
      }
      
      setState(() {
          _selectedPlace = {
            'name': name,
            'address': address,
            'category': 'MARKED POINT',
            'rating': 4,
            'image': '',
            'hours': '',
            'price': '',
            'lat': point.latitude,
            'lng': point.longitude,
          };
          _showBottomSheet = true;
      });
      _addMarker(point, name);
    } catch (_) {
      setState(() {
          _selectedPlace = {
            'name': 'Marked Location',
            'address': '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
            'category': 'MARKED POINT',
            'rating': 4,
            'image': '',
            'hours': '',
            'price': '',
            'lat': point.latitude,
            'lng': point.longitude,
          };
          _showBottomSheet = true;
      });
      _addMarker(point, 'Marked Location');
    }
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: Stack(
        children: [
          // Full-screen map — using Google Maps tiles
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _zoom,
              onTap: _handleMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.wayfarer.app',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),

          // Top UI Layer — Search + Chips
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Search Bar — matches prototype
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.search, color: AppTheme.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Search places...',
                              hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
                              border: InputBorder.none,
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                            onSubmitted: _searchPlace,
                          ),
                        ),
                        if (_isSearching)
                          const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                        else
                          GestureDetector(
                            onTap: () => _searchPlace(_searchController.text),
                            child: Container(padding: const EdgeInsets.all(16), child: const Icon(Icons.tune, color: AppTheme.textSecondary)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category chips — matches prototype
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (ctx, i) {
                        final cat = _categories[i];
                        final isActive = _selectedCategory == cat['label'];
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedCategory = cat['label']);
                            _searchNearby(cat['osm']);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isActive ? AppTheme.primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Row(
                              children: [
                                Icon(cat['icon'], size: 16, color: isActive ? Colors.white : AppTheme.textPrimary),
                                const SizedBox(width: 8),
                                Text(cat['label'], style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: isActive ? Colors.white : AppTheme.textPrimary)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sheet — Place detail card like prototype
          if (_showBottomSheet && _selectedPlace != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(width: 48, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category + rating + favorite
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(_selectedPlace!['category'] ?? 'PLACE', style: GoogleFonts.inter(color: const Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
                                  const SizedBox(width: 8),
                                  Row(children: List.generate((_selectedPlace!['rating'] ?? 4) as int, (_) => const Icon(Icons.star, size: 12, color: Color(0xFFF97316)))),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                                child: const Icon(Icons.favorite, color: Color(0xFFF97316), size: 20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Name
                          Text(_selectedPlace!['name'] ?? '', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                          const SizedBox(height: 4),
                          // Address
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppTheme.textSecondary, size: 16),
                              const SizedBox(width: 4),
                              Expanded(child: Text(_selectedPlace!['address'] ?? '', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Image + info cards row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        height: 140, width: double.infinity,
                                        color: Colors.grey.shade200,
                                        child: _selectedPlace!['image'] != null && (_selectedPlace!['image'] as String).isNotEmpty
                                            ? CachedNetworkImage(imageUrl: _selectedPlace!['image'], fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.restaurant, size: 40, color: AppTheme.textMuted))
                                            : const Icon(Icons.restaurant, size: 40, color: AppTheme.textMuted),
                                      ),
                                    ),
                                     if (_selectedPlace!['rating'] != null && (_selectedPlace!['rating'] as num) >= 4)
                                      Positioned(
                                        bottom: 8, left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(4)),
                                          child: Text("TOP RATED", style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    Container(
                                      height: 66, width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(16)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.phone, size: 16, color: AppTheme.primaryColor),
                                          const SizedBox(height: 4),
                                          Text("OPENS UNTIL\n11:00 PM", textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 10, color: AppTheme.primaryColor, height: 1.2)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 66, width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text("¥", style: GoogleFonts.inter(fontSize: 18, color: AppTheme.textSecondary)),
                                          const Spacer(),
                                          Text("MODERATE", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 10, color: AppTheme.textSecondary)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.directions, color: Colors.white, size: 18),
                                  label: const Text("Get Directions"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 4,
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.menu_book, color: AppTheme.primaryColor, size: 18),
                                  label: const Text("Menu"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    foregroundColor: AppTheme.primaryColor,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    if (type.contains('restaurant')) return Icons.restaurant;
    if (type.contains('hotel')) return Icons.hotel;
    if (type.contains('tourism')) return Icons.camera_alt;
    return Icons.location_on;
  }
}
