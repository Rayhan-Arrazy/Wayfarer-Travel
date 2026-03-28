import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';

import '../../services/api_service.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';

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

  // Additional data for prototype match
  double? _exchangeRate;
  Map<String, dynamic>? _weather;
  String _homeCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.getTrip(widget.tripId);
      final trip = TripModel.fromJson(response.data);
      
      _trip = trip;

      // Fetch supplementary data
      final auth = context.read<AuthProvider>();
      _homeCurrency = auth.user?.homeCurrency ?? 'USD';
      
      String destCurrency = 'AUD'; // Default to match prototype
      if (trip.destinationInfo?.currency != null && trip.destinationInfo!.currency.isNotEmpty) {
        destCurrency = trip.destinationInfo!.currency;
      }

      await Future.wait([
        _fetchExchangeRate(_homeCurrency, destCurrency),
        _fetchWeather(-33.8688, 151.2093), // Default Sydney coordinates
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchExchangeRate(String from, String to) async {
    try {
      final response = await _api.getExchangeRates(from, to: to);
      final rates = response.data['rates'] as Map<String, dynamic>?;
      if (rates != null && rates.containsKey(to)) {
        _exchangeRate = (rates[to] as num).toDouble();
      }
    } catch (_) {}
  }

  Future<void> _fetchWeather(double lat, double lng) async {
    try {
      final response = await _api.getWeather(lat, lng);
      _weather = response.data;
    } catch (_) {}
  }

  Future<void> _toggleChecklist(int index) async {
    if (_trip == null) return;
    try {
      await _api.toggleChecklistItem(widget.tripId, index);
      
      // Re-fetch trip data softly without showing main loading spinner
      final response = await _api.getTrip(widget.tripId);
      setState(() {
        _trip = TripModel.fromJson(response.data);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    if (_trip == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(title: const Text('Trip Not Found')),
        body: const Center(child: Text('Could not load trip details')),
      );
    }

    final coverImg = _trip!.coverImage.isNotEmpty
        ? _trip!.coverImage
        : 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=800&q=80'; // Sydney Opera House

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            // HERO HEADER matches prototype
            Stack(
              children: [
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: coverImg,
                    fit: BoxFit.cover,
                    color: Colors.black.withValues(alpha: 0.35),
                    colorBlendMode: BlendMode.darken,
                    errorWidget: (_, __, ___) => Container(color: AppTheme.primaryColor),
                  ),
                ),
                SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          margin: const EdgeInsets.only(left: 20, top: 10),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFDBEAFE), width: 1.5),
                          ),
                          child: const Icon(Icons.arrow_back, color: Color(0xFF64748B), size: 18),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 30, left: 20, right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('UPCOMING TRIP', style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(_trip!.destination, style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, height: 1.1)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                          const SizedBox(width: 6),
                          Text('${DateFormat('MMM dd').format(_trip!.startDate)} - ${DateFormat('MMM dd, yyyy').format(_trip!.endDate)}', 
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.flight_takeoff, color: Colors.white, size: 18),
                        label: Text('Boarding Pass', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),

            // CURRENT WEATHER 
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Current Weather', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.primaryColor)),
                          const Icon(Icons.wb_sunny, color: Color(0xFFF97316), size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${(_weather?['temperature'] as num?)?.round() ?? 24}°C', style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w400, color: AppTheme.primaryColor, height: 1.0)),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_weather?['description'] ?? 'Sunny', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.primaryColor)),
                                Text('Feels like ${(_weather?['temperature'] as num?)?.round() ?? 26}°C', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildWeatherDay('MON', Icons.cloud, '22°'),
                          _buildWeatherDay('TUE', Icons.wb_sunny, '25°'),
                          _buildWeatherDay('WED', Icons.wb_sunny_outlined, '23°'),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            // EXCHANGE RATE (Dark blue box)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2E46),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Exchange Rate', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
                        const Icon(Icons.payments_outlined, color: Colors.white70, size: 20),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1.00 $_homeCurrency', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                        const Icon(Icons.sync_alt, color: Colors.white54, size: 16),
                        Text('${_exchangeRate?.toStringAsFixed(2) ?? "1.52"} ${_trip!.destinationInfo?.currency ?? "AUD"}', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Last updated 5 mins ago', style: GoogleFonts.inter(fontSize: 10, color: Colors.white54)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // PRE-DEPARTURE DOCUMENT CHECKLIST
            if (_trip!.checklist.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.lightBorder),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('PRE-DEPARTURE', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFFF97316), letterSpacing: 1.0)),
                                const SizedBox(height: 4),
                                Text('Document\nChecklist', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primaryColor, height: 1.1)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${_trip!.checklistProgress}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                              Text('Complete', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary)),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 60, height: 6,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: _trip!.checklistProgress / 100,
                                    backgroundColor: Colors.grey.shade200,
                                    color: const Color(0xFFF97316),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      ..._trip!.checklist.asMap().entries.take(4).map((entry) {
                        int idx = entry.key;
                        var item = entry.value;
                        return _buildDocumentChecklistItem(item.item, item.checked, () => _toggleChecklist(idx));
                      }),
                      // Dummy item for Vaccination Certificate with UPLOAD button
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF6ED),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFEDD5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20, height: 20,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFF97316), width: 2),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Vaccination Certificate', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFEA580C))),
                                  Text('Required for entry', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(6)),
                              child: Text('UPLOAD', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

             const SizedBox(height: 24),

            // HEALTH ESSENTIALS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, color: AppTheme.primaryColor, size: 18),
                      const SizedBox(width: 8),
                      Text('Health Essentials', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildHealthCard(Icons.vaccines, 'Vaccines', 'Up to date')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildHealthCard(Icons.medical_services, 'Medication', 'Pack in carry-on')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildHealthCard(Icons.emergency, 'Emergency', 'Dial 000')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildHealthCard(Icons.wb_sunny, 'Sunscreen', 'SPF 50+ Required')),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ARRIVAL POINT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.lightBorder),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: AppTheme.textSecondary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Arrival Point', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primaryColor)),
                              Text('${_trip!.destination.split(',').first} Airport', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('Get\nDirections', textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11, color: AppTheme.primaryColor)),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: 0.6,
                            child: CachedNetworkImage(
                              imageUrl: 'https://images.unsplash.com/photo-1596489354063-4bd2bd0ce79d?w=800&q=80',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Terminal 1 - International', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.primaryColor)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(color: const Color(0xFF1E2E46), shape: BoxShape.circle),
                                  child: const Icon(Icons.flight_land, color: Colors.white, size: 20),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDay(String day, IconData icon, String temp) {
    return Column(
      children: [
        Text(day, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(height: 8),
        Text(temp, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildDocumentChecklistItem(String title, bool isChecked, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFF1E2E46) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isChecked ? const Color(0xFF1E2E46) : AppTheme.textMuted, width: 2),
              ),
              child: isChecked ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E2E46))),
                  Text('Required Document', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Icon(isChecked ? Icons.task_alt : Icons.description_outlined, color: AppTheme.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFE0E7FF), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primaryColor)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
