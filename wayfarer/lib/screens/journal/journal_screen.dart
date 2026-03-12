import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/api_service.dart';
import '../../models/journal_model.dart';
import 'package:intl/intl.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final ApiService _api = ApiService();
  List<JournalEntryModel> _entries = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _loadStats();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.getJournalEntries();
      final List data = response.data;
      setState(() {
        _entries = data.map((e) => JournalEntryModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStats() async {
    try {
      final response = await _api.getJournalStats();
      setState(() => _stats = response.data);
    } catch (e) {
      // Stats optional
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Travel Journal', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: () => setState(() => _showStats = !_showStats),
            icon: Icon(_showStats ? Icons.list : Icons.bar_chart, color: AppTheme.textSecondary),
          ),
        ],
      ),
      body: _showStats ? _buildStatsView() : _buildJournalView(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AppRoutes.createJournal);
          if (result == true) {
            _loadEntries();
            _loadStats();
          }
        },
        icon: const Icon(Icons.add),
        label: Text('New Entry', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildJournalView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }
    
    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 64, color: AppTheme.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No journal entries yet', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text('Start capturing your travel memories!', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEntries,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _entries.length,
        itemBuilder: (_, i) => _buildEntryCard(_entries[i]),
      ),
    );
  }

  Widget _buildEntryCard(JournalEntryModel entry) {
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
              if (entry.mood.isNotEmpty)
                Text(_getMoodEmoji(entry.mood), style: const TextStyle(fontSize: 24)),
              Text(DateFormat('MMM dd, yyyy • HH:mm').format(entry.createdAt),
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
            ],
          ),
          if (entry.title.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(entry.title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          ],
          if (entry.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(entry.note, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary), maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
          if (entry.location != null && entry.location!.name.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppTheme.primaryColor),
                const SizedBox(width: 4),
                Text(entry.location!.name, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryColor)),
              ],
            ),
          ],
          if (entry.weather != null && entry.weather!.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.cloud, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text('${entry.weather!.temp.toStringAsFixed(1)}°C - ${entry.weather!.description}',
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsView() {
    final totalTrips = _stats['totalTrips'] ?? 0;
    final totalDays = _stats['totalDays'] ?? 0;
    final countriesVisited = _stats['countriesVisited'] ?? 0;
    final totalEntries = _stats['totalEntries'] ?? 0;
    final totalDistance = _stats['totalDistance'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Travel Stats', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 20),
          
          Row(
            children: [
              _buildStatCard('🌍', 'Countries', countriesVisited.toString(), AppTheme.accentColor),
              const SizedBox(width: 12),
              _buildStatCard('✈️', 'Trips', totalTrips.toString(), AppTheme.primaryColor),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('📅', 'Days', totalDays.toString(), const Color(0xFFFFB74D)),
              const SizedBox(width: 12),
              _buildStatCard('📝', 'Entries', totalEntries.toString(), const Color(0xFFE57373)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('🛤️', 'km Traveled', totalDistance.toString(), const Color(0xFFBA68C8)),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
          
          const SizedBox(height: 24),
          Text('Visited Countries', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          if ((_stats['countries'] as List?)?.isNotEmpty == true)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (_stats['countries'] as List).map<Widget>((c) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                ),
                child: Text(c.toString(), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primaryColor)),
              )).toList(),
            )
          else
            Text('No countries visited yet', style: GoogleFonts.inter(color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'amazing': return '🤩';
      case 'happy': return '😊';
      case 'neutral': return '😐';
      case 'tired': return '😴';
      case 'sad': return '😢';
      default: return '📝';
    }
  }
}
