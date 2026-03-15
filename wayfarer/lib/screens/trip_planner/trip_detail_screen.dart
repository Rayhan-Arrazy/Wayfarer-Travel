import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/trip_model.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;
  const TripDetailScreen({super.key, required this.tripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final ApiService _api = ApiService();
  TripModel? _trip;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  Future<void> _loadTrip() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.getTrip(widget.tripId);
      final trip = TripModel.fromJson(response.data);
      setState(() {
        _trip = trip;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    if (_trip == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Center(child: Text('Trip not found', style: GoogleFonts.inter(color: AppTheme.textSecondary))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header with image and Sydney context
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider('https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?q=80&w=800&auto=format&fit=crop'), // Sydney
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.help_outline, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('UPCOMING TRIP', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Text(
                        'Sydney, Australia',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '12 Oct - 20 Oct, 2024',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.airplane_ticket_outlined, size: 18),
                        label: const Text('Boarding Pass'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weather and Rate Row
                  Row(
                    children: [
                      _buildDetailedWeatherCard(),
                      const SizedBox(width: 16),
                      _buildExchangeRateCard(),
                    ],
                  ),
                  
                  const SizedBox(height: 32),

                  // Packing Checklist Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Packing Checklist', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
                      Text('1/12 COMPLETED', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPackingItem('Passport & Visa', true),
                  _buildPackingItem('Universal Power Adapter', false),
                  _buildPackingItem('Japanese Yen Cash', false),

                  const SizedBox(height: 32),

                  // Document Checklist
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Document Checklist', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
                      Text('60% Complete', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(value: 0.6, backgroundColor: const Color(0xFFF0F0F0), color: AppTheme.primaryColor, minHeight: 4),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildDocumentRow(Icons.check_circle, 'Valid Passport', 'Expires in Dec 2026', true),
                  _buildDocumentRow(Icons.check_circle, 'ETA Travel Visa', 'Approved & Linked', true),
                  _buildDocumentRow(Icons.check_circle, 'Travel Insurance', 'Global Health Policy', true),
                  _buildDocumentRow(Icons.error_outline, 'Vaccination Certificate', 'MISSING OR EXPIRED', false, isAction: true),

                  const SizedBox(height: 32),

                  // Health Essentials
                  Text('Health Essentials', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHealthIconCard(Icons.wb_sunny_outlined, 'UV Index\nModerate'),
                      _buildHealthIconCard(Icons.medical_services_outlined, 'Medication\nPack 30+ items'),
                      _buildHealthIconCard(Icons.emergency_outlined, 'Emergency\nDial 119'),
                      _buildHealthIconCard(Icons.verified_user_outlined, 'Insurance\nJoin Required'),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Arrival Point
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Arrival Point', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
                      Text('Directions', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Sydney Kingsford Smith Airport (SYD)', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                  const SizedBox(height: 16),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: CachedNetworkImageProvider('https://images.unsplash.com/photo-1524850011238-e3d235c7d4c9?q=80&w=800&auto=format&fit=crop'), // Map placeholder
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(Icons.location_on, color: AppTheme.primaryColor, size: 32),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                            child: const Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedWeatherCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Weather', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('24°C', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                const Spacer(),
                const Icon(Icons.wb_sunny_rounded, color: Colors.orange, size: 28),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Sunny', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(width: 4),
                Text('Feels like 26°C', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWeatherMiniItem(Icons.water_drop_outlined, '62%'),
                _buildWeatherMiniItem(Icons.air, '18km/h'),
                _buildWeatherMiniItem(Icons.wb_twilight, '18:24'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherMiniItem(IconData icon, String val) {
    return Column(
      children: [
        Icon(icon, size: 14, color: AppTheme.textMuted),
        const SizedBox(height: 4),
        Text(val, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildExchangeRateCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2E46),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Exchange Rate', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white60)),
                const Icon(Icons.show_chart, color: Colors.blueAccent, size: 16),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('1.00 USD', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.compare_arrows, color: Colors.white38, size: 12),
                    const SizedBox(width: 4),
                    Text('1.35 AUD', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('last updated 12 mins ago', style: GoogleFonts.inter(fontSize: 9, color: Colors.white38)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text('Currency Converter', style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentRow(IconData icon, String title, String subtitle, bool isDone, {bool isAction = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDone ? AppTheme.successColor : AppTheme.errorColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
              ],
            ),
          ),
          if (isAction)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(8)),
              child: Text('UPLOAD', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
            )
          else if (isDone)
            const Icon(Icons.check, color: AppTheme.successColor, size: 18),
        ],
      ),
    );
  }

  Widget _buildHealthIconCard(IconData icon, String label) {
    return Container(
      width: 78,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(height: 12),
          Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, height: 1.2)),
        ],
      ),
    );
  }

  Widget _buildPackingItem(String title, bool isChecked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isChecked ? AppTheme.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isChecked ? AppTheme.primaryColor : const Color(0xFFD0D0D0), width: 1.5),
            ),
            child: isChecked ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
        ],
      ),
    );
  }
}


