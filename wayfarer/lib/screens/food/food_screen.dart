import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final ApiService _api = ApiService();
  final _searchController = TextEditingController();
  
  List<dynamic> _restaurants = [];
  bool _isLoading = true;
  String _activeCategory = 'Restaurants';
  
  // Default to Tokyo coordinates for demo
  double _lat = 35.6762;
  double _lng = 139.6503;

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.searchRestaurants(_lat, _lng);
      setState(() {
        _restaurants = response.data['restaurants'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchRestaurants,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                if (_isLoading)
                  ...List.generate(3, (i) => _buildSkeleton())
                else if (_restaurants.isEmpty)
                  _buildEmptyState()
                else
                  ..._restaurants.map((res) => _buildRestaurantCard(res)).toList(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade100,
      highlightColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 24, width: 200, color: Colors.white),
            const SizedBox(height: 16),
            Container(height: 220, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
            const SizedBox(height: 16),
            Container(height: 14, width: 150, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.restaurant_menu, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text('No restaurants found near here', style: GoogleFonts.inter(color: AppTheme.textMuted)),
          TextButton(onPressed: _fetchRestaurants, child: const Text('Try Again'))
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(dynamic res) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                    Text(res['name'] ?? 'Local Eatery', 
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(res['rating']?.toString() ?? '4.5', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 4),
                        Text('(${res['reviews'] ?? '80'} reviews)', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13)),
                        const SizedBox(width: 8),
                        Text('•', style: TextStyle(color: Colors.grey.shade300)),
                        const SizedBox(width: 8),
                        Text(res['cuisine'] ?? 'Local', style: GoogleFonts.inter(color: AppTheme.accentColor, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, color: AppTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: CachedNetworkImage(
              imageUrl: res['imageUrl'] ?? 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624',
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade100, child: const Icon(Icons.image, color: Colors.white)),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Expanded(child: Text(res['address'] ?? 'Nearby your location', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13))),
              Text(res['openingHours'] ?? '9 AM - 10 PM', style: GoogleFonts.inter(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 32, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (val) {
                      // Perform search logic here
                    },
                    decoration: InputDecoration(
                      hintText: 'Search in Tokyo...',
                      hintStyle: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 14),
                      icon: const Icon(Icons.search, size: 20, color: AppTheme.textMuted),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildFilterChip('Restaurants', true),
              _buildFilterChip('Cafe', false),
              _buildFilterChip('Halal', false),
              _buildFilterChip('Bakery', false),
              _buildFilterChip('Bars', false),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    bool active = _activeCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _activeCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: active ? AppTheme.primaryColor : const Color(0xFFE2E8F0)),
          boxShadow: active ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
        ),
        alignment: Alignment.center,
        child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: active ? Colors.white : AppTheme.textSecondary)),
      ),
    );
  }
}
