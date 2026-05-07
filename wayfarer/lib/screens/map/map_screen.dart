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
  List<LatLng> _routePoints = [];
  List<String> _selectedTypes = ['all'];
  int _selectedRadius = 3000;
  bool _isLoading = false;
  Map<String, dynamic>? _selectedPlace;
  bool _didInitArgs = false;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.stars, 'label': 'All', 'type': 'all'},
    {'icon': Icons.medical_services, 'label': 'Emergency', 'type': 'emergency'},
    {'icon': Icons.attach_money, 'label': 'Financial', 'type': 'financial'},
    {'icon': Icons.restaurant, 'label': 'Dining', 'type': 'restaurant'},
    {'icon': Icons.train, 'label': 'Transport', 'type': 'station'},
    {'icon': Icons.hotel, 'label': 'Hotels', 'type': 'hotel'},
    {'icon': Icons.camera_alt, 'label': 'Tourism', 'type': 'tourism'},
    {'icon': Icons.shopping_bag, 'label': 'Shopping', 'type': 'shopping'},
    {'icon': Icons.miscellaneous_services, 'label': 'Services', 'type': 'services'},
  ];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        if (args.containsKey('lat') && args.containsKey('lng')) {
           final destLat = args['lat'] as double;
           final destLng = args['lng'] as double;
           final destName = args['name'] as String? ?? 'Target Location';
           final destIcon = args['icon'] as IconData? ?? Icons.place;
           
           setState(() {
             _selectedPlace = {
               'name': destName,
               'type': 'DIRECTED ROUTE',
               'lat': destLat,
               'lng': destLng,
               'distance': 'Calculating...',
               'hours': '',
               'icon': destIcon,
             };
           });
           
           Future.delayed(const Duration(milliseconds: 500), () {
             _getRouteToPlace(destLat, destLng);
           });
        }
      }
      _didInitArgs = true;
    }
  }

  Future<void> _initLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 1. Instant load with last known position
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        setState(() {
          _currentLocation = LatLng(lastPos.latitude, lastPos.longitude);
        });
        _mapController.move(_currentLocation, _zoom);
        _fetchNearbyPlaces(); // Fetch in background
      }

      // 2. Fresh lock
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 4),
      );
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentLocation, _zoom);
      await _fetchNearbyPlaces();
    } catch (e) {
      debugPrint('Location Error: $e');
      await _fetchNearbyPlaces();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchNearbyPlaces() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.getNearbyPlaces(
        _currentLocation.latitude, 
        _currentLocation.longitude, 
        _selectedTypes.join(','),
        radius: _selectedRadius,
      );
      
      final List<dynamic> elements = response.data['elements'] ?? [];
      
      setState(() {
        _markers = elements.map((e) {
          final lat = (e['lat'] ?? e['center']?['lat'])?.toDouble() ?? 0.0;
          final lon = (e['lon'] ?? e['center']?['lon'])?.toDouble() ?? 0.0;
          final tags = e['tags'] ?? {};
          final name = tags['name'] ?? tags['amenity'] ?? tags['tourism'] ?? tags['shop'] ?? 'Point of Interest';
          final typeLabel = _getTypeLabel(tags);
          final icon = _getIconForTags(tags);
          
          return _buildCustomMarker(lat, lon, typeLabel, icon, name, tags);
        }).where((m) => m.point.latitude != 0.0).toList();
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
    if (tags['shop'] != null) return (tags['shop'] as String).toUpperCase();
    if (tags['railway'] != null) return 'STATION';
    return 'PLACE';
  }

  IconData _getIconForTags(Map tags) {
    if (tags['amenity'] == 'restaurant' || tags['amenity'] == 'cafe' || tags['amenity'] == 'fast_food') return Icons.restaurant;
    if (tags['amenity'] == 'atm' || tags['amenity'] == 'bank' || tags['amenity'] == 'bureau_de_change') return Icons.attach_money;
    if (tags['railway'] == 'station' || tags['amenity'] == 'bus_station' || tags['amenity'] == 'taxi') return Icons.train;
    if (tags['tourism'] == 'hotel' || tags['tourism'] == 'hostel' || tags['tourism'] == 'guest_house') return Icons.hotel;
    if (tags['amenity'] == 'hospital' || tags['amenity'] == 'pharmacy' || tags['amenity'] == 'clinic') return Icons.medical_services;
    if (tags['shop'] != null) return Icons.shopping_bag;
    if (tags['tourism'] != null) return Icons.camera_alt;
    return Icons.place;
  }

  Future<void> _getRouteToPlace(double endLat, double endLng) async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.getRoute(_currentLocation.latitude, _currentLocation.longitude, endLat, endLng);
      // Normalized backend returns { geometry: { coordinates: [...] } } or { geometry: { type: ..., coordinates: [...] } }
      if (response.data != null && response.data['geometry'] != null) {
        final Map<String, dynamic> geometry = response.data['geometry'];
        final List<dynamic> coordinates = geometry['coordinates'];
        
        setState(() {
          _routePoints = coordinates.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();
          if (_selectedPlace != null && _selectedPlace!['distance'] == 'Calculating...') {
             final distance = Geolocator.distanceBetween(_currentLocation.latitude, _currentLocation.longitude, endLat, endLng);
             _selectedPlace!['distance'] = distance < 1000 ? '${distance.round()}m' : '${(distance/1000).toStringAsFixed(1)}km';
          }
        });
        
        final bounds = LatLngBounds.fromPoints(_routePoints);
        _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
      } else {
         throw Exception('Invalid route geometry');
      }
    } catch (e) {
      debugPrint('Routing Error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not calculate route.')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            'lat': lat,
            'lng': lon,
            'distance': 'Found via search',
            'hours': '',
            'icon': Icons.search,
          };
          _routePoints = [];
        });
        
        _mapController.move(newPoint, 15.0);
        await _fetchNearbyPlaces();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No places found.')));
      }
    } catch (e) {
      debugPrint('Search Error: $e');
    } finally {
       if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSettingsUpdated(String type) {
    if (type == 'all') {
      _selectedTypes = ['all'];
    } else {
      _selectedTypes.remove('all');
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
        if (_selectedTypes.isEmpty) _selectedTypes = ['all'];
      } else {
        _selectedTypes.add(type);
      }
    }
    _selectedPlace = null;
    _routePoints = [];
    // setState() in parent will be triggered if this is called within a setState context or explicitly
  }

  Marker _buildCustomMarker(double lat, double lng, String label, IconData icon, String name, Map tags) {
    return Marker(
      point: LatLng(lat, lng),
      width: 120,
      height: 90,
      rotate: true, // Optimizing performance
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPlace = {
              'name': name,
              'type': label,
              'lat': lat,
              'lng': lng,
              'distance': '${_calculateDistanceString(lat, lng)} away',
              'hours': tags['opening_hours'] ?? 'Check local hours',
              'icon': icon,
            };
            _routePoints = []; 
          });
          _mapController.move(LatLng(lat, lng), 16.0);
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1B32).withOpacity(0.9),
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
            const Icon(Icons.location_on, color: Color(0xFF0B1B32), size: 34),
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
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: _zoom,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              onTap: (_, __) => setState(() {
                _selectedPlace = null;
                _routePoints = [];
              }),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.wayfarer.app',
                tileDisplay: const TileDisplay.fadeIn(duration: Duration(milliseconds: 300)),
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5,
                      color: const Color(0xFF3B82F6),
                    ),
                  ],
                ),
              MarkerLayer(markers: _markers, alignment: Alignment.topCenter),
              MarkerLayer(markers: [
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
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0B1B32))),
                      const SizedBox(width: 12),
                      Text('Working...', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0B1B32))),
                    ],
                  ),
                ),
              ),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 56, width: 56,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 4))]),
                      child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0B1B32), size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 4))]),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: _performSearch,
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF0B1B32)),
                              decoration: const InputDecoration(hintText: 'Search near you...', hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)), border: InputBorder.none),
                            ),
                          ),
                          Container(height: 24, width: 1, color: const Color(0xFFE2E8F0), margin: const EdgeInsets.symmetric(horizontal: 8)),
                          IconButton(icon: const Icon(Icons.tune_rounded, color: Color(0xFF0B1B32), size: 22), onPressed: _showFilters),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 24, left: 20, right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  mini: true, heroTag: 'location_btn',
                  backgroundColor: Colors.white,
                  onPressed: _initLocation,
                  child: const Icon(Icons.my_location, color: Color(0xFF0B1B32)),
                ),
                const SizedBox(height: 16),
                if (_selectedPlace != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]),
                    child: Row(
                      children: [
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(12)), child: Icon(_selectedPlace!['icon'], color: const Color(0xFF0B1B32))),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_selectedPlace!['type'], style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text(_selectedPlace!['name'], style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0B1B32)), overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(_selectedPlace!['distance'] == 'Calculating...' ? 'Calculating path...' : '${_selectedPlace!['distance']} • ${_selectedPlace!['hours']}', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () { _getRouteToPlace(_selectedPlace!['lat'], _selectedPlace!['lng']); },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1B32), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                          child: const Row(children: [Icon(Icons.directions_rounded, size: 18), SizedBox(width: 4), Text('Route', style: TextStyle(fontWeight: FontWeight.bold))]),
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
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).padding.bottom + 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categories', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF0B1B32))),
                  TextButton(onPressed: () { setModalState(() { _selectedTypes = ['all']; }); setState(() {}); }, child: Text('Reset', style: GoogleFonts.inter(color: const Color(0xFF3B82F6), fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8, runSpacing: 10,
                children: _categories.map((cat) {
                  bool isSelected = _selectedTypes.contains(cat['type']);
                  return GestureDetector(
                    onTap: () { setModalState(() { _onSettingsUpdated(cat['type']); }); setState(() {}); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(color: isSelected ? const Color(0xFF0B1B32) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? const Color(0xFF0B1B32) : Colors.transparent)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(cat['icon'], size: 16, color: isSelected ? Colors.white : const Color(0xFF64748B)), const SizedBox(width: 8), Text(cat['label'], style: GoogleFonts.inter(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF475569)))]),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Text('Search Radius', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0B1B32))),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [100, 500, 1000, 2000, 5000, 10000].map((radius) {
                    bool isSelected = _selectedRadius == radius;
                    String label = radius >= 1000 ? '${(radius/1000).toInt()}km' : '${radius}m';
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () { setModalState(() { _selectedRadius = radius; }); setState(() {}); },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(color: isSelected ? const Color(0xFF0B1B32) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? const Color(0xFF0B1B32) : const Color(0xFFE2E8F0))),
                          child: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.white : const Color(0xFF475569))),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () { Navigator.pop(context); _fetchNearbyPlaces(); },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1B32), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                  child: Text('Apply Filters', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
