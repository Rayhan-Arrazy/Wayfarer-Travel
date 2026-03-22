import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
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

  Future<void> _toggleChecklist(int index) async {
    try {
      await _api.toggleChecklistItem(widget.tripId, index);
      await _loadTrip();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  Future<void> _deleteTrip() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Trip?', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: const Text('This will permanently remove this trip and all associated journal entries.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await _api.deleteTrip(widget.tripId);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return 'ACTIVE TRIP';
      case 'completed':
        return 'COMPLETED TRIP';
      default:
        return 'UPCOMING TRIP';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppTheme.successColor;
      case 'completed':
        return const Color(0xFF94A3B8);
      default:
        return AppTheme.accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    if (_trip == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Center(child: Text('Trip not found', style: GoogleFonts.inter(color: AppTheme.textSecondary))),
      );
    }

    final trip = _trip!;
    final daysUntil = trip.startDate.difference(DateTime.now()).inDays;
    final coverImg = trip.coverImage.isNotEmpty
        ? trip.coverImage
        : 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?q=80&w=800';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider('$coverImg?q=80&w=800&auto=format&fit=crop'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 320,
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
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (val) {
                            if (val == 'delete') _deleteTrip();
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'delete', child: Text('Delete Trip')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(trip.status),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getStatusLabel(trip.status),
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        trip.destination,
                        style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('MMM dd').format(trip.startDate)} - ${DateFormat('MMM dd, yyyy').format(trip.endDate)}',
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                      ),
                      if (trip.status == 'planning' && daysUntil > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          '$daysUntil days until departure',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.accentColor),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip Info Pills
                  Row(
                    children: [
                      _buildInfoPill(Icons.people, '${trip.partySize} travelers'),
                      const SizedBox(width: 10),
                      _buildInfoPill(Icons.calendar_today, '${trip.durationDays} days'),
                      const SizedBox(width: 10),
                      if (trip.budget.amount > 0)
                        _buildInfoPill(Icons.account_balance_wallet, '${trip.budget.currency} ${trip.budget.amount.toStringAsFixed(0)}'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Destination Info Cards
                  if (trip.destinationInfo != null) ...[
                    Row(
                      children: [
                        _buildDetailedWeatherCard(trip),
                        const SizedBox(width: 16),
                        _buildDestInfoCard(trip),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Quick Actions
                  Text('Quick Actions', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 86,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        _buildQuickAction(Icons.currency_exchange, 'Currency', AppRoutes.currency, const Color(0xFFFEF3C7), const Color(0xFFD97706)),
                        _buildQuickAction(Icons.cloud, 'Weather', AppRoutes.weather, const Color(0xFFDBEAFE), const Color(0xFF2563EB)),
                        _buildQuickAction(Icons.restaurant, 'Food', AppRoutes.food, const Color(0xFFF3E8FF), const Color(0xFF9333EA)),
                        _buildQuickAction(Icons.hotel, 'Stay', AppRoutes.accommodation, const Color(0xFFE0F2FE), const Color(0xFF0284C7)),
                        _buildQuickAction(Icons.directions_car, 'Transport', AppRoutes.transport, const Color(0xFFDCFCE7), const Color(0xFF16A34A)),
                        _buildQuickAction(Icons.sos, 'Emergency', AppRoutes.emergency, const Color(0xFFFFE4E6), const Color(0xFFDC2626)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Packing Checklist
                  if (trip.checklist.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Packing Checklist', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: trip.checklistProgress > 70
                                ? AppTheme.successColor.withValues(alpha: 0.15)
                                : AppTheme.primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${trip.checklistProgress}% done',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: trip.checklistProgress > 70 ? AppTheme.successColor : AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: trip.checklistProgress / 100,
                        backgroundColor: const Color(0xFFF0F0F0),
                        color: trip.checklistProgress > 70 ? AppTheme.successColor : AppTheme.primaryColor,
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...trip.checklist.asMap().entries.map((entry) => _buildChecklistItem(entry.key, entry.value)),
                    const SizedBox(height: 24),
                  ],

                  // Notes
                  if (trip.notes.isNotEmpty) ...[
                    Text('Notes', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF0F0F0)),
                      ),
                      child: Text(trip.notes, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // View Journal button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.journal),
                      icon: const Icon(Icons.book),
                      label: const Text('View Journal Entries'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
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

  Widget _buildInfoPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildDetailedWeatherCard(TripModel trip) {
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
            Text('Destination', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
            const SizedBox(height: 12),
            if (trip.destinationInfo!.flagUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(trip.destinationInfo!.flagUrl, width: 36, height: 24, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox()),
              ),
            const SizedBox(height: 8),
            Text(trip.countryName, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.language, size: 12, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Expanded(child: Text(trip.destinationInfo!.language, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule, size: 12, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Expanded(child: Text(trip.destinationInfo!.timezone, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestInfoCard(TripModel trip) {
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
                Text('Currency', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white60)),
                const Icon(Icons.show_chart, color: Colors.blueAccent, size: 16),
              ],
            ),
            const SizedBox(height: 16),
            Text(trip.destinationInfo!.currency, style: GoogleFonts.outfit(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Local currency', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
            if (trip.destinationInfo!.capital.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_city, size: 12, color: Colors.white38),
                  const SizedBox(width: 4),
                  Text(trip.destinationInfo!.capital, style: GoogleFonts.inter(fontSize: 11, color: Colors.white60)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.currency),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Text('Currency Converter', style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, String route, Color bg, Color iconColor) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        width: 76,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: iconColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(int index, ChecklistItem item) {
    return GestureDetector(
      onTap: () => _toggleChecklist(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: item.checked ? AppTheme.successColor.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: item.checked ? AppTheme.successColor.withValues(alpha: 0.3) : const Color(0xFFF0F0F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.checked ? AppTheme.successColor : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: item.checked ? AppTheme.successColor : const Color(0xFFD0D0D0), width: 1.5),
              ),
              child: item.checked ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.item,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: item.checked ? AppTheme.textMuted : AppTheme.textPrimary,
                  decoration: item.checked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (item.category.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(item.category.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
              ),
          ],
        ),
      ),
    );
  }
}
