import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/api_service.dart';
import '../../models/trip_model.dart';
import 'package:intl/intl.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  final ApiService _api = ApiService();
  List<TripModel> _trips = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.getTrips(
        status: _filter == 'all' ? null : _filter,
      );
      final List data = response.data;
      setState(() {
        _trips = data.map((t) => TripModel.fromJson(t)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('My Trips', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.createTrip);
              _loadTrips();
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.add, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Planning', 'planning'),
                const SizedBox(width: 8),
                _buildFilterChip('Active', 'active'),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', 'completed'),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : _trips.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadTrips,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _trips.length,
                          itemBuilder: (_, i) => _buildTripCard(_trips[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isActive = _filter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _filter = value);
        _loadTrips();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppTheme.primaryColor : AppTheme.lightBorder),
        ),
        child: Text(label, style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w500,
          color: isActive ? Colors.white : AppTheme.textSecondary,
        )),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flight_takeoff, size: 64, color: AppTheme.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('No trips found', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Text('Create your first trip to get started!', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.createTrip);
              _loadTrips();
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Trip'),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(TripModel trip) {
    final dateFormat = DateFormat('MMM dd');
    final statusColor = trip.isActive ? AppTheme.successColor
        : trip.isCompleted ? AppTheme.primaryColor
        : AppTheme.warningColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.pushNamed(
              context,
              AppRoutes.tripDetail,
              arguments: trip.id,
            );
            if (result == true) _loadTrips();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
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
                      child: Row(
                        children: [
                          if (trip.destinationInfo?.flagUrl.isNotEmpty == true)
                            Container(
                              width: 32, height: 22,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                image: DecorationImage(
                                  image: NetworkImage(trip.destinationInfo!.flagUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(trip.destination,
                              style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(trip.status.toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTripInfo(Icons.calendar_today, '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}'),
                    const SizedBox(width: 16),
                    _buildTripInfo(Icons.people, '${trip.partySize} traveler${trip.partySize > 1 ? 's' : ''}'),
                    const SizedBox(width: 16),
                    _buildTripInfo(Icons.update, '${trip.durationDays} days'),
                  ],
                ),
                if (trip.checklist.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  // Checklist progress
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: trip.checklistProgress / 100,
                            backgroundColor: AppTheme.lightSurface,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              trip.checklistProgress == 100 ? AppTheme.successColor : AppTheme.primaryColor),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${trip.checklistProgress}%',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}
