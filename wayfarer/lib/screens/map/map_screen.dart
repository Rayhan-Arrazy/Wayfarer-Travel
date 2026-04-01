import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
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

  LatLng _currentLocation = const LatLng(-6.2000, 106.8166); // Default Jakarta context
  double _zoom = 15.0;
  List<Marker> _markers = [];
  String _selectedCategory = 'All';
  String _selectedType = 'all';
  int _selectedRadius = 2000;
  bool _isLoading = false;
  Map<String, dynamic>? _selectedPlace;
  String _currentLocationName = 'Discovering location...';

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.stars, 'label': 'All', 'type': 'all'},
    {'icon': Icons.medical_services, 'label': 'Emergency', 'type': 'emergency'},
    {'icon': Icons.attach_money, 'label': 'Financial', 'type': 'financial'},
    {'icon': Icons.restaurant, 'label': 'Dining', 'type': 'restaurant'},
    {'icon': Icons.train, 'label': 'Transport', 'type': 'station'},
    {'icon': Icons.hotel, 'label': 'Hotels', 'type': 'hotel'},
    {'icon': Icons.camera_alt, 'label': 'Attractions', 'type': 'tourism'},
    {'icon': Icons.shopping_bag, 'label': 'Shopping', 'type': 'mall'},
  ];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentLocation, _zoom);
      await _reverseGeocode(_currentLocation);
      await _fetchNearbyPlaces();
    } catch (e) {
      debugPrint('Location Error: $e');
      await _reverseGeocode(_currentLocation);
      await _fetchNearbyPlaces();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _reverseGeocode(LatLng point) async {
    try {
      final response = await _api.reverseGeocode(point.latitude, point.longitude);
      if (response.data != null) {
        final address = response.data['address'];
        if (address != null) {
          setState(() {
            _currentLocationName = address['city'] ?? 
                                 address['town'] ?? 
                                 address['suburb'] ?? 
                                 address['road'] ?? 'Current Area';
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchNearbyPlaces() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.getNearbyPlaces(
        _currentLocation.latitude, 
        _currentLocation.longitude, 
        _selectedType,
        radius: _selectedRadius,
      );
      
      final List<dynamic> elements = response.data['elements'] ?? [];
      
      setState(() {
        _markers = elements.map((e) {
          final lat = (e['lat'] ?? e['center']?['lat']).toDouble();
          final lon = (e['lon'] ?? e['center']?['lon']).toDouble();
          final tags = e['tags'] ?? {};
          final name = tags['name'] ?? tags['amenity'] ?? tags['tourism'] ?? 'Point of Interest';
          final typeLabel = _getTypeLabel(tags);
          final icon = _getIconForTags(tags);
          
          return _buildCustomMarker(lat, lon, typeLabel, icon, name, tags);
        }).toList();
      });
    } catch (e) {
      debugPrint('Nearby Fetch Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getTypeLabel(Map tags) {
    if (tags['amenity'] != null) return (tags['amenity'] as String).toUpperCase();
    if (tags['tourism'] != null) return (tags['tourism'] as String).toUpperCase();
    if (tags['railway'] != null) return 'STATION';
    return 'PLACE';
  }

  IconData _getIconForTags(Map tags) {
    if (tags['amenity'] == 'restaurant' || tags['amenity'] == 'cafe') return Icons.restaurant;
    if (tags['amenity'] == 'atm' || tags['amenity'] == 'bank') return Icons.attach_money;
    if (tags['railway'] == 'station' || tags['amenity'] == 'bus_station') return Icons.train;
    if (tags['tourism'] == 'hotel' || tags['tourism'] == 'hostel') return Icons.hotel;
    if (tags['amenity'] == 'hospital' || tags['amenity'] == 'pharmacy') return Icons.medical_services;
    if (tags['tourism'] != null) return Icons.camera_alt;
    return Icons.place;
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final response = await _api.searchPlaces(query, lat: _currentLocation.latitude, lng: _currentLocation.longitude);
      final List<dynamic> results = response.data is List ? response.data : [];
      
      if (results.isNotEmpty) {
        final first = results.first;
        final lat = double.parse(first['lat']);
        final lon = double.parse(first['lon']);
        final newPoint = LatLng(lat, lon);
        
        setState(() {
          _currentLocation = newPoint;
          _selectedPlace = {
            'name': first['display_name'].split(',').first,
            'type': 'SEARCH RESULT',
            'distance': 'Found via search',
            'hours': '',
            'icon': Icons.search,
          };
        });
        
        _mapController.move(newPoint, 15.0);
        await _reverseGeocode(newPoint);
        await _fetchNearbyPlaces();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No places found matching your search.')));
      }
    } catch (e) {
      debugPrint('Search Error: $e');
    } finally {
       if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSettingsUpdated(String label, String type) {
    setState(() {
      _selectedCategory = label;
      _selectedType = type;
      _selectedPlace = null;
    });
  }

  Marker _buildCustomMarker(double lat, double lng, String label, IconData icon, String name, Map tags) {
    return Marker(
      point: LatLng(lat, lng),
      width: 120,
      height: 90,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPlace = {
              'name': name,
              'type': label,
              'distance': '${_calculateDistanceString(lat, lng)} away',
              'hours': tags['opening_hours'] ?? 'Check local hours',
              'icon': icon,
            };
          });
          _mapController.move(LatLng(lat, lng), 16.0);
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2E46).withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Flexible(child: Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
            const Icon(Icons.location_on, color: Color(0xFF1E2E46), size: 34),
          ],
        ),
      ),
    );
  }

  String _calculateDistanceString(double lat, double lng) {
    final distance = Geolocator.distanceBetween(_currentLocation.latitude, _currentLocation.longitude, lat, lng);
    if (distance < 1000) return '${distance.round()}m';
    return '${(distance/1000).toStringAsFixed(1)}km';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: _zoom,
              onTap: (_, __) => setState(() => _selectedPlace = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.wayfarer.app',
              ),
              MarkerLayer(markers: _markers),
              MarkerLayer(markers: [
                // Current location marker
                Marker(
                  point: _currentLocation,
                  width: 30,
                  height: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.4), blurRadius: 10, spreadRadius: 5)],
                    ),
                    child: const Center(child: Icon(Icons.person_pin_circle_outlined, color: Colors.white, size: 18)),
                  ),
                ),
              ]),
            ],
          ),

          if (_isLoading)
            Positioned(
              top: 100, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E2E46))),
                      const SizedBox(width: 12),
                      Text('Updating Map...', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                    ],
                  ),
                ),
              ),
            ),

          // Search Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E2E46), size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: _performSearch,
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF1E2E46)),
                              decoration: InputDecoration(
                                hintText: 'Near $_currentLocationName...',
                                hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune_rounded, color: Color(0xFF1E2E46), size: 22),
                            onPressed: _showFilters,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Current Location Button
                FloatingActionButton(
                  mini: true,
                  heroTag: 'location_btn',
                  backgroundColor: Colors.white,
                  onPressed: _initLocation,
                  child: const Icon(Icons.my_location, color: Color(0xFF1E2E46)),
                ),
                const SizedBox(height: 16),
                
                // Details Card
                if (_selectedPlace != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E7FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_selectedPlace!['icon'], color: const Color(0xFF1E2E46)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('NEAREST ESSENTIAL', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text(_selectedPlace!['name'], style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46)), overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text('${_selectedPlace!['distance']} • ${_selectedPlace!['hours']}', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF475569),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Navigate'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).padding.bottom + 32,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter Search', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                  IconButton(
                    onPressed: () => Navigator.pop(context), 
                    icon: const Icon(Icons.close, color: Color(0xFF1E2E46))
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('CATEGORY', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  bool isSelected = _selectedCategory == cat['label'];
                  return ChoiceChip(
                    label: Text(cat['label']),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        _onSettingsUpdated(cat['label'], cat['type']);
                      });
                    },
                    avatar: Icon(cat['icon'], size: 16, color: isSelected ? Colors.white : const Color(0xFF475569)),
                    labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF475569)),
                    selectedColor: const Color(0xFF1E2E46),
                    backgroundColor: const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide.none,
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Text('DISTANCE LIMIT', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1)),
              const SizedBox(height: 16),
              Row(
                children: [500, 1000, 2000, 5000].map((radius) {
                  bool isSelected = _selectedRadius == radius;
                  String label = radius >= 1000 ? '${(radius/1000).toInt()}km' : '${radius}m';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        setModalState(() => _selectedRadius = radius);
                      },
                      labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF475569)),
                      selectedColor: const Color(0xFF1E2E46),
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide.none,
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _fetchNearbyPlaces();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2E46),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text('Show Results', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
