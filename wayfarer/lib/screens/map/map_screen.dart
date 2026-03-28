import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final _searchController = TextEditingController();

  LatLng _currentLocation = const LatLng(-6.2000, 106.8166); // Default: Jakarta
  double _zoom = 15.0;
  List<Marker> _markers = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  Map<String, dynamic>? _selectedPlace;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.stars, 'label': 'All', 'type': 'all'},
    {'icon': Icons.restaurant, 'label': 'Dining', 'type': 'restaurant'},
    {'icon': Icons.train, 'label': 'Transport', 'type': 'station'},
    {'icon': Icons.atm, 'label': 'ATM', 'type': 'atm'},
    {'icon': Icons.hotel, 'label': 'Hotels', 'type': 'hotel'},
    {'icon': Icons.camera_alt, 'label': 'Attractions', 'type': 'tourism'},
  ];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() => _isLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _mapController.move(_currentLocation, _zoom);
      _fetchNearbyPlaces();
    } catch (e) {
      setState(() => _isLoading = false);
      _fetchNearbyPlaces(); // Fetch anyway with default location
    }
  }

  Future<void> _fetchNearbyPlaces() async {
    // In a real app, this would call the API. For now, we'll mock some places nearby.
    // Based on Image 2: ATM, Dining, Station
    setState(() {
      _markers = [
        _buildCustomMarker(_currentLocation.latitude + 0.002, _currentLocation.longitude - 0.003, 'ATM', Icons.atm, 'Global Bank ATM'),
        _buildCustomMarker(_currentLocation.latitude + 0.001, _currentLocation.longitude + 0.002, 'DINING', Icons.restaurant, 'L\'As du Fallafel'),
        _buildCustomMarker(_currentLocation.latitude - 0.001, _currentLocation.longitude + 0.001, 'STATION', Icons.train, 'Châtelet – Les Halles'),
      ];
    });
  }

  Marker _buildCustomMarker(double lat, double lng, String label, IconData icon, String name) {
    return Marker(
      point: LatLng(lat, lng),
      width: 100,
      height: 80,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPlace = {
              'name': name,
              'type': label,
              'distance': '200m away',
              'hours': 'Open 24h',
              'icon': icon,
            };
          });
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2E46).withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Icon(Icons.location_on, color: Color(0xFF1E2E46), size: 30),
          ],
        ),
      ),
    );
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
                  width: 20,
                  height: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, spreadRadius: 5)],
                    ),
                  ),
                ),
              ]),
            ],
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator()),

          // Search Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.search, color: Color(0xFF64748B)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Explore destinations, essentials...',
                          hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune, color: Color(0xFF64748B)),
                      onPressed: _showFilters,
                    ),
                  ],
                ),
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
                  backgroundColor: Colors.white,
                  onPressed: _initLocation,
                  child: const Icon(Icons.my_location, color: Color(0xFF1E2E46)),
                ),
                const SizedBox(height: 16),
                
                // Details Card (like Image 2)
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
                              Text(_selectedPlace!['name'], style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
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
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
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
                Text('Filters', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
                TextButton(onPressed: () {}, child: Text('Reset', style: GoogleFonts.inter(color: const Color(0xFF475569), fontWeight: FontWeight.w600))),
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
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat['label']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF475569) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat['icon'], size: 16, color: isSelected ? Colors.white : const Color(0xFF475569)),
                        const SizedBox(width: 8),
                        Text(cat['label'], style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF475569))),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            Text('DISTANCE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1)),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('500m', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                Expanded(
                  child: Slider(
                    value: 2000,
                    min: 500,
                    max: 5000,
                    activeColor: const Color(0xFF475569),
                    inactiveColor: const Color(0xFFE2E8F0),
                    onChanged: (v) {},
                  ),
                ),
                Text('5km', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF475569),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Show Results', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
