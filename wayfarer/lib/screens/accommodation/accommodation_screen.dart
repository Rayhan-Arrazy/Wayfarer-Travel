import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class AccommodationScreen extends StatefulWidget {
  const AccommodationScreen({super.key});

  @override
  State<AccommodationScreen> createState() => _AccommodationScreenState();
}

class _AccommodationScreenState extends State<AccommodationScreen> {
  final ApiService _api = ApiService();
  final _searchController = TextEditingController();
  String _selectedType = 'All';
  final List<String> _types = ['All', 'Hotel', 'Hostel', 'Apartment', 'Resort'];

  List<dynamic> _accommodations = [];
  bool _isLoading = true;
  double _lat = -6.2088;
  double _lng = 106.8456;

  @override
  void initState() {
    super.initState();
    _loadAccommodation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAccommodation() async {
    setState(() => _isLoading = true);
    try {
      final type = _selectedType == 'All' ? null : _selectedType.toLowerCase();
      final response = await _api.searchAccommodation(_lat, _lng, type: type, radius: 5000);
      setState(() {
        _accommodations = response.data['accommodations'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    try {
      final response = await _api.searchPlaces(query);
      final List results = response.data;
      if (results.isNotEmpty) {
        setState(() {
          _lat = double.parse(results[0]['lat'].toString());
          _lng = double.parse(results[0]['lon'].toString());
        });
        _loadAccommodation();
      }
    } catch (e) {
      // Handle error
    }
  }

  String _getTypeIcon(String type) {
    switch (type) {
      case 'hotel': return '🏨';
      case 'hostel': return '🛏️';
      case 'apartment': return '🏢';
      case 'resort': return '🏖️';
      case 'motel': return '🏩';
      case 'guest_house': return '🏠';
      default: return '🏨';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Accommodation', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primaryColor, size: 20),
                  onPressed: () => _searchLocation(_searchController.text),
                ),
              ),
              onSubmitted: _searchLocation,
            ),
          ),
          // Type filter
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _types.length,
              itemBuilder: (_, i) {
                final isActive = _selectedType == _types[i];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedType = _types[i]);
                    _loadAccommodation();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primaryColor : AppTheme.lightCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isActive ? AppTheme.primaryColor : AppTheme.lightBorder),
                    ),
                    alignment: Alignment.center,
                    child: Text(_types[i], style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: isActive ? Colors.white : AppTheme.textSecondary,
                    )),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : _accommodations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.hotel, size: 48, color: AppTheme.textMuted),
                            const SizedBox(height: 12),
                            Text('No accommodations found', style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textSecondary)),
                            const SizedBox(height: 8),
                            Text('Try searching a different location', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadAccommodation,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAccommodation,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _accommodations.length,
                          itemBuilder: (_, i) => _buildHotelCard(_accommodations[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(dynamic hotel) {
    final name = hotel['name'] ?? 'Accommodation';
    final type = hotel['type'] ?? 'hotel';
    final phone = hotel['phone'] ?? '';
    final website = hotel['website'] ?? '';
    final address = hotel['address'] ?? '';
    final amenities = hotel['amenities'] as List? ?? [];
    final stars = hotel['stars'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_getTypeIcon(type), style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(name, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(type.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                        ),
                        if (stars != null) ...[
                          const SizedBox(width: 8),
                          Row(
                            children: List.generate(
                              stars is int ? stars : 0,
                              (_) => const Icon(Icons.star, size: 14, color: Color(0xFFFFD700)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Expanded(child: Text(address, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
          if (amenities.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: (amenities).map<Widget>((a) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.lightBorder),
                ),
                child: Text(a.toString(), style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
              )).toList(),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (phone.isNotEmpty)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse('tel:$phone');
                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                    },
                    icon: const Icon(Icons.call, size: 16),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                  ),
                ),
              if (phone.isNotEmpty && website.isNotEmpty)
                const SizedBox(width: 10),
              if (website.isNotEmpty)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(website.startsWith('http') ? website : 'https://$website');
                      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Website'),
                    style: ElevatedButton.styleFrom(visualDensity: VisualDensity.compact),
                  ),
                ),
              if (phone.isEmpty && website.isEmpty)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Show on map
                      if (hotel['lat'] != null && hotel['lng'] != null) {
                        final lat = hotel['lat'];
                        final lng = hotel['lng'];
                        launchUrl(Uri.parse('https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=17/$lat/$lng'));
                      }
                    },
                    icon: const Icon(Icons.map, size: 16),
                    label: const Text('View on Map'),
                    style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
