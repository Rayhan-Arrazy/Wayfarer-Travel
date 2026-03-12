import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/api_service.dart';
import '../../models/trip_model.dart';
import 'package:intl/intl.dart';

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
  Map<String, dynamic>? _countryInfo;

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
      _loadCountryInfo(trip.countryCode);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCountryInfo(String code) async {
    if (code.isEmpty) return;
    try {
      final response = await _api.getCountryInfo(code);
      if (response.data is List && (response.data as List).isNotEmpty) {
        setState(() => _countryInfo = (response.data as List)[0]);
      } else if (response.data is Map) {
        setState(() => _countryInfo = response.data);
      }
    } catch (e) {
      // Country info is optional
    }
  }

  Future<void> _toggleChecklistItem(int index) async {
    try {
      await _api.toggleChecklistItem(widget.tripId, index);
      _loadTrip();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  Future<void> _updateStatus(String status) async {
    try {
      await _api.updateTrip(widget.tripId, {'status': status});
      _loadTrip();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trip marked as $status'), backgroundColor: AppTheme.successColor),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  Future<void> _deleteTrip() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.lightCard,
        title: Text('Delete Trip?', style: GoogleFonts.inter(color: AppTheme.textPrimary)),
        content: Text('This action cannot be undone.', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightBg,
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    if (_trip == null) {
      return Scaffold(
        backgroundColor: AppTheme.lightBg,
        appBar: AppBar(),
        body: Center(child: Text('Trip not found', style: GoogleFonts.inter(color: AppTheme.textSecondary))),
      );
    }

    final trip = _trip!;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final statusColor = trip.isActive ? AppTheme.successColor
        : trip.isCompleted ? AppTheme.primaryColor
        : AppTheme.warningColor;

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text(trip.destination, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
            color: AppTheme.lightCard,
            onSelected: (v) {
              switch (v) {
                case 'active': _updateStatus('active'); break;
                case 'completed': _updateStatus('completed'); break;
                case 'planning': _updateStatus('planning'); break;
                case 'delete': _deleteTrip(); break;
              }
            },
            itemBuilder: (_) => [
              if (!trip.isActive)
                const PopupMenuItem(value: 'active', child: Text('Mark Active')),
              if (!trip.isCompleted)
                const PopupMenuItem(value: 'completed', child: Text('Mark Completed')),
              if (!trip.isPlanning)
                const PopupMenuItem(value: 'planning', child: Text('Mark Planning')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Trip', style: TextStyle(color: AppTheme.errorColor)),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTrip,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status & Dates Header
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor.withValues(alpha: 0.15), AppTheme.lightCard],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (trip.destinationInfo?.flagUrl.isNotEmpty == true)
                              Container(
                                width: 36, height: 24,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  image: DecorationImage(
                                    image: NetworkImage(trip.destinationInfo!.flagUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            Text(trip.destination,
                              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(trip.status.toUpperCase(),
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildInfoChip(Icons.calendar_today, '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(Icons.timelapse, '${trip.durationDays} days'),
                        const SizedBox(width: 12),
                        _buildInfoChip(Icons.people, '${trip.partySize} traveler${trip.partySize > 1 ? 's' : ''}'),
                        if (trip.budget.amount > 0) ...[
                          const SizedBox(width: 12),
                          _buildInfoChip(Icons.attach_money, '${trip.budget.amount.toStringAsFixed(0)} ${trip.budget.currency}'),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Country Info
              if (_countryInfo != null) ...[
                const SizedBox(height: 24),
                Text('Country Info', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.lightBorder),
                  ),
                  child: Column(
                    children: [
                      _buildCountryRow('🏙️ Capital', _getCountryField('capital')),
                      _buildCountryRow('🗣️ Language', _getCountryField('language')),
                      _buildCountryRow('💰 Currency', _getCountryField('currency')),
                      _buildCountryRow('👥 Population', _getCountryField('population')),
                      _buildCountryRow('🌍 Region', _getCountryField('region')),
                    ],
                  ),
                ),
              ],

              // Notes
              if (trip.notes.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Notes', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.lightBorder),
                  ),
                  child: Text(trip.notes, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
                ),
              ],

              // Checklist
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Checklist', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  if (trip.checklist.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${trip.checklistProgress}%',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (trip.checklist.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.lightCard,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text('No checklist items', style: GoogleFonts.inter(color: AppTheme.textMuted)),
                  ),
                )
              else ...[
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: trip.checklistProgress / 100,
                    backgroundColor: AppTheme.lightSurface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      trip.checklistProgress == 100 ? AppTheme.successColor : AppTheme.primaryColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 14),

                // Group by category
                ..._buildChecklistByCategory(trip.checklist),
              ],

              // Quick Actions
              const SizedBox(height: 28),
              Text('Quick Actions', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildActionButton(Icons.cloud, 'Weather', AppRoutes.weather, const Color(0xFF64B5F6)),
                  const SizedBox(width: 10),
                  _buildActionButton(Icons.currency_exchange, 'Currency', AppRoutes.currency, const Color(0xFFFFB74D)),
                  const SizedBox(width: 10),
                  _buildActionButton(Icons.book, 'Journal', AppRoutes.journal, const Color(0xFFE57373)),
                  const SizedBox(width: 10),
                  _buildActionButton(Icons.map, 'Map', AppRoutes.map, const Color(0xFF4DB6AC)),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChecklistByCategory(List<ChecklistItem> checklist) {
    final categories = <String, List<MapEntry<int, ChecklistItem>>>{};
    for (int i = 0; i < checklist.length; i++) {
      final cat = checklist[i].category.isEmpty ? 'other' : checklist[i].category;
      categories.putIfAbsent(cat, () => []).add(MapEntry(i, checklist[i]));
    }

    final categoryIcons = {
      'documents': Icons.description,
      'clothing': Icons.checkroom,
      'toiletries': Icons.wash,
      'electronics': Icons.devices,
      'health': Icons.medical_services,
      'other': Icons.checklist,
    };

    return categories.entries.map((entry) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                children: [
                  Icon(categoryIcons[entry.key] ?? Icons.checklist, size: 16, color: AppTheme.textMuted),
                  const SizedBox(width: 8),
                  Text(entry.key[0].toUpperCase() + entry.key.substring(1),
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            ...entry.value.map((item) => InkWell(
              onTap: () => _toggleChecklistItem(item.key),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: item.value.checked ? AppTheme.successColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: item.value.checked ? AppTheme.successColor : AppTheme.textMuted,
                          width: 2,
                        ),
                      ),
                      child: item.value.checked
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.value.item,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: item.value.checked ? AppTheme.textMuted : AppTheme.textPrimary,
                          decoration: item.value.checked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    if (item.value.autoGenerated)
                      const Icon(Icons.auto_awesome, size: 14, color: AppTheme.accentColor),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 6),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildCountryRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
          Flexible(child: Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  String _getCountryField(String field) {
    if (_countryInfo == null) return '';
    switch (field) {
      case 'capital':
        final caps = _countryInfo!['capital'];
        if (caps is List && caps.isNotEmpty) return caps[0].toString();
        return '';
      case 'language':
        final langs = _countryInfo!['languages'];
        if (langs is Map) return langs.values.take(2).join(', ');
        return '';
      case 'currency':
        final curs = _countryInfo!['currencies'];
        if (curs is Map && curs.isNotEmpty) {
          final first = curs.values.first;
          return '${first['name']} (${first['symbol'] ?? ''})';
        }
        return '';
      case 'population':
        final pop = _countryInfo!['population'];
        if (pop is num) {
          if (pop > 1000000) return '${(pop / 1000000).toStringAsFixed(1)}M';
          if (pop > 1000) return '${(pop / 1000).toStringAsFixed(0)}K';
          return pop.toString();
        }
        return '';
      case 'region':
        return _countryInfo!['subregion']?.toString() ?? _countryInfo!['region']?.toString() ?? '';
      default:
        return '';
    }
  }

  Widget _buildActionButton(IconData icon, String label, String route, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.lightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.lightBorder),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
