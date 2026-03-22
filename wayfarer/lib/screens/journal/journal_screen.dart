import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../config/routes.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<dynamic> _entries = [];

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  Future<void> _fetchEntries() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.getJournalEntries();
      setState(() {
        _entries = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchEntries,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(context),
                const SizedBox(height: 10),
                Text('My Travel Logs', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800)),
                Text('CAPTURE EVERY MOMENT', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 1.2)),
                
                const SizedBox(height: 32),
                _buildSummaryCard(),
                
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active Journeys', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.createJournal),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                else if (_entries.isEmpty)
                  _buildEmptyState()
                else
                  ..._entries.map((e) => _buildJournalCard(e)).toList(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.book_outlined, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text('No journal entries yet', style: GoogleFonts.inter(color: AppTheme.textMuted)),
          TextButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.createJournal), child: const Text('Write your first log'))
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (canPop)
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back))
          else
            const SizedBox(width: 48),
          const Icon(Icons.search, size: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStat('Logs', _entries.length.toString()),
          _buildStat('Countries', '1'),
          _buildStat('Photos', _entries.fold<int>(0, (sum, e) => sum + (e['photos']?.length as int? ?? 0)).toString()),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildJournalCard(dynamic e) {
    final photo = (e['photos'] as List?)?.isNotEmpty == true ? e['photos'][0]['url'] : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photo != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: CachedNetworkImage(imageUrl: photo, height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e['location']?['name'] ?? 'Unknown Location', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentColor)),
                const SizedBox(height: 8),
                Text(e['title'] ?? 'No Title', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(e['note'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.wb_sunny_outlined, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text('${e['weather']?['temp'] ?? '--'}°', style: const TextStyle(fontSize: 12)),
                    const Spacer(),
                    Text('Read More', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
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
