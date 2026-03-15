import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),

              const SizedBox(height: 10),
              Text('My Travel Logs', 
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text('CAPTURE EVERY MOMENT', 
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 1.2)),

              const SizedBox(height: 32),

              // Summary Stats Card
              _buildSummaryCard(),

              const SizedBox(height: 32),

              // Journal Entries Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Active Journeys', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // Journal Feed
              _buildJournalEntry('Tokyo: First Night at Ichiran', 'Today, 8:45 PM', 'The atmosphere was incredible. Ordering through the vending machine was a cool experience...', 'https://images.unsplash.com/photo-1591814468924-caf88d1232e1?auto=format&fit=crop&w=600'),
              _buildJournalEntry('Kyoto Temples: Golden Pavilion', 'Yesterday, 2:15 PM', 'Reached Kinkaku-ji. The reflection in the water is exactly like the photos, but more breathtaking in person.', 'https://images.unsplash.com/photo-1493976040372-50b510520638?auto=format&fit=crop&w=600'),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.menu, color: AppTheme.textPrimary, size: 28),
          ),
          const Row(
            children: [
              Icon(Icons.search, color: AppTheme.textPrimary, size: 24),
              SizedBox(width: 20),
              Icon(Icons.more_vert, color: AppTheme.textPrimary, size: 24),
            ],
          ),
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
        boxShadow: [
          BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.15), blurRadius: 25, offset: const Offset(0, 12))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Cities', '12'),
              _buildStat('Countries', '04'),
              _buildStat('Photos', '248'),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.insights, color: AppTheme.successColor, size: 16),
              const SizedBox(width: 8),
              Text('You travel 15% more than average users in 2024', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
            ],
          ),
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

  Widget _buildJournalEntry(String title, String time, String excerpt, String imageUrl) {
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(time, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentColor)),
                    const Icon(Icons.favorite_border, size: 18, color: AppTheme.textMuted),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Text(excerpt, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Read more', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, size: 14, color: AppTheme.primaryColor),
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
