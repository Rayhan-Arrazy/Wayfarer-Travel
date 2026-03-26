import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import 'country_guide_screen.dart';

class GuideListScreen extends StatefulWidget {
  const GuideListScreen({super.key});

  @override
  State<GuideListScreen> createState() => _GuideListScreenState();
}

class _GuideListScreenState extends State<GuideListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  List<dynamic> _countries = [];
  List<dynamic> _filteredCountries = [];

  final List<Map<String, dynamic>> _travelTypes = [
    {
      'title': 'Adventure & Hiking',
      'subtitle': 'For the thrill seekers and trailblazers.',
      'icon': Icons.terrain,
      'image': 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400&q=80',
      'tips': [
        'Always check weather forecasts before departing.',
        'Invest in high-quality, broken-in footwear.',
        'Carry a physical map and compass along with GPS.',
      ]
    },
    {
      'title': 'Cultural Tourism',
      'subtitle': 'Immerse yourself in history and heritage.',
      'icon': Icons.account_balance,
      'image': 'https://images.unsplash.com/photo-1548625361-ec23a7e37dfc?w=400&q=80',
      'tips': [
        'Learn basic greetings in the local language.',
        'Dress modestly when visiting religious sites.',
        'Read about the destination\'s history beforehand.',
      ]
    },
    {
      'title': 'Wellness & Retreat',
      'subtitle': 'Disconnect, relax, and rejuvenate.',
      'icon': Icons.spa,
      'image': 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400&q=80',
      'tips': [
        'Pack comfortable, loose-fitting clothing.',
        'Set an out-of-office response and stay offline.',
        'Embrace early morning meditation or yoga sessions.',
      ]
    },
    {
      'title': 'Backpacking',
      'subtitle': 'Travel light, travel far on a budget.',
      'icon': Icons.backpack,
      'image': 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=400&q=80',
      'tips': [
        'Roll your clothes to save space in your pack.',
        'Stay in eco-hostels to meet fellow travelers.',
        'Always carry a reusable water bottle.',
      ]
    },
    {
      'title': 'Luxury & Resort',
      'subtitle': 'Five-star excellence and premium comfort.',
      'icon': Icons.king_bed,
      'image': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&q=80',
      'tips': [
        'Book concierge services in advance for reservations.',
        'Check for inclusive spa or dining credits.',
        'Dress code is often smart casual for evening dining.',
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCountries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    try {
      final response = await _api.getAllCountries();
      setState(() {
        _countries = response.data;
        // Sort alphabetically
        _countries.sort((a, b) {
          final nameA = a['name']?['common']?.toString() ?? '';
          final nameB = b['name']?['common']?.toString() ?? '';
          return nameA.compareTo(nameB);
        });
        _filteredCountries = _countries;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterCountries(String query) {
    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _filteredCountries = _countries);
      return;
    }
    
    final lowercaseQuery = query.toLowerCase();
    final localResults = _countries.where((c) {
      final name = c['name']?['common']?.toString().toLowerCase() ?? '';
      return name.contains(lowercaseQuery);
    }).toList();

    if (localResults.isNotEmpty) {
      setState(() => _filteredCountries = localResults);
    } else {
      // DYNAMIC SEARCH: Fetch from external sources via backend
      setState(() => _isLoading = true);
      try {
        final res = await _api.searchCountryGuides(query);
        if (mounted) {
          setState(() {
            _filteredCountries = res.data;
            _isLoading = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Explore Guides', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFF97316),
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: const Color(0xFFF97316),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Destinations'),
            Tab(text: 'Travel Styles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDestinationsTab(),
          _buildTravelStylesTab(),
        ],
      ),
    );
  }

  Widget _buildDestinationsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.lightBorder),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCountries,
              decoration: InputDecoration(
                hintText: 'Search for a country...',
                hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _filteredCountries.isEmpty
              ? Center(child: Text('No countries found', style: GoogleFonts.inter(color: AppTheme.textMuted)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: _filteredCountries.length,
                  itemBuilder: (ctx, i) {
                    final country = _filteredCountries[i];
                    final name = country['name']?['common'] ?? 'Unknown';
                    final flagUrl = country['flags']?['png'] ?? '';
                    final region = country['region'] ?? '';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.lightBorder),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => CountryGuideScreen(countryData: country),
                          ));
                        },
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: flagUrl.isNotEmpty 
                            ? Image.network(flagUrl, width: 60, height: 40, fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox(width: 60, height: 40))
                            : Container(width: 60, height: 40, color: Colors.grey.shade200),
                        ),
                        title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary)),
                        subtitle: Text(region, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                        trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTravelStylesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TRAVEL PACKAGES', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text('Expertly Curated Journeys', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _travelTypes.length,
            itemBuilder: (context, index) {
              final type = _travelTypes[index];
              return GestureDetector(
                onTap: () {
                  // Find a relevant country if possible, or just default to Japan/France for demo
                  final Map<String, dynamic> fallback = {
                    'name': {'common': 'Japan'},
                    'cca2': 'JP',
                    'flags': {'png': 'https://flagcdn.com/w320/jp.png'},
                    'latlng': [36.0, 138.0],
                    'region': 'Asia',
                    'subregion': 'Eastern Asia',
                    'population': 125800000,
                  };
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CountryGuideScreen(countryData: fallback),
                  ));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
                    border: Border.all(color: AppTheme.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: Stack(
                          children: [
                            Image.network(type['image'], height: 180, width: double.infinity, fit: BoxFit.cover),
                            Positioned(
                              top: 16, right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 14),
                                    const SizedBox(width: 4),
                                    Text('4.9', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(type['title'].toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFFF97316), letterSpacing: 1.2)),
                            const SizedBox(height: 6),
                            Text(type['subtitle'], style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted, height: 1.4)),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.av_timer_outlined, size: 18, color: AppTheme.textMuted),
                                    const SizedBox(width: 6),
                                    Text('8-12 Days', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(12)),
                                  child: Text('EXPLORE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
