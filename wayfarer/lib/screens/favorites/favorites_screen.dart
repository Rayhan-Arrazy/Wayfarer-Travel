import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _favorites = [];
  bool _isLoading = true;
  String _selectedType = 'all';

  final List<Map<String, dynamic>> _filterOptions = [
    {'label': 'All', 'value': 'all', 'icon': Icons.apps},
    {'label': 'Restaurants', 'value': 'restaurant', 'icon': Icons.restaurant},
    {'label': 'Hotels', 'value': 'hotel', 'icon': Icons.hotel},
    {'label': 'Attractions', 'value': 'attraction', 'icon': Icons.place},
  ];

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.getFavorites(type: _selectedType == 'all' ? null : _selectedType);
      setState(() {
        _favorites = response.data is List ? response.data : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavorite(String id) async {
    try {
      await _api.removeFavorite(id);
      _fetchFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites'), backgroundColor: AppTheme.warningColor),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'restaurant': return Icons.restaurant;
      case 'hotel': return Icons.hotel;
      case 'attraction': return Icons.place;
      default: return Icons.star;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'restaurant': return const Color(0xFF9333EA);
      case 'hotel': return const Color(0xFFD97706);
      case 'attraction': return const Color(0xFF0EA5E9);
      default: return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bool isGuest = !auth.isAuthenticated;

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Favorites', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: isGuest 
        ? _buildGuestState()
        : Column(
            children: [
              // Filter chips
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filterOptions.length,
                  itemBuilder: (_, i) {
                    final opt = _filterOptions[i];
                    final isActive = _selectedType == opt['value'];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedType = opt['value']);
                        _fetchFavorites();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: isActive ? AppTheme.primaryColor : AppTheme.lightBorder),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Icon(opt['icon'], size: 16, color: isActive ? Colors.white : AppTheme.textMuted),
                            const SizedBox(width: 6),
                            Text(opt['label'], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? Colors.white : AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                    : _favorites.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite_border, size: 64, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                                const SizedBox(height: 16),
                                Text('No favorites yet', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
                                const SizedBox(height: 8),
                                Text('Save restaurants, hotels, and\nattractions to quick-access them later', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted, height: 1.5), textAlign: TextAlign.center),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchFavorites,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: _favorites.length,
                              itemBuilder: (_, i) => _buildFavoriteCard(_favorites[i]),
                            ),
                          ),
              ),
            ],
          ),
    );
  }

  Widget _buildGuestState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded, size: 64, color: AppTheme.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('Collect Your Favorites', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Log in to save the places you love\nand plan your dream trip.', 
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              elevation: 0,
            ),
            child: const Text('Log In / Register'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(dynamic fav) {
    final type = fav['type'] ?? 'attraction';
    final color = _getTypeColor(type);
    final imgUrl = fav['imageUrl'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.lightBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (imgUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: CachedNetworkImage(
                imageUrl: '$imgUrl?w=600&q=80',
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(height: 140, color: color.withValues(alpha: 0.1), child: Icon(_getTypeIcon(type), size: 40, color: color)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text(type.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5)),
                    ),
                    const Spacer(),
                    if (fav['rating'] != null)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 3),
                          Text(fav['rating'].toString(), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(fav['name'] ?? 'Unknown', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Expanded(child: Text(fav['address'] ?? '', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.directions, size: 16),
                        label: const Text('Directions'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.lightBorder),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () => _removeFavorite(fav['_id']),
                      icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
