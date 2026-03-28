import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/journal_provider.dart';
import '../../models/journal_model.dart';
import '../../config/routes.dart';

import '../../widgets/loading_widget.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalProvider>().fetchEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final journalProvider = context.watch<JournalProvider>();
    final entries = journalProvider.entries;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu, color: Color(0xFF132F5C)),
        ),
        title: Text('Wayfarer', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1D4E89))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.person, color: Color(0xFF132F5C))),
        ],
      ),
      body: journalProvider.isLoading 
        ? const LoadingWidget() 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CHRONICLES', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text('Your Journey.', style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                const SizedBox(height: 48),

                if (entries.isEmpty) ...[
                  _buildSampleEntry(context, 'October 24, 2023', '08:45 AM', 'Kyoto International, Japan', 'The mist over the Kamo River this morning felt like a quiet invitation. Everything is deliberate here—the way the tea is poured, the way the moss grows on the temple stones. I found a small stationery shop in Gion that smelled of cedar and old paper.', ['#reflections', '#culture']),
                  _buildSampleEntry(context, 'October 22, 2023', '11:12 PM', 'Shinjuku Night Market', 'Electric blue and neon pink reflected in puddles. The city doesn\'t sleep; it just hums at a higher frequency. The best ramen I\'ve ever had was served through a wooden slot by someone I never saw. Efficiency as an art form.', []),
                  _buildSampleEntry(context, 'October 20, 2023', '06:00 AM', 'Narita Transit Terminal', 'Touchdown. The air is crisp and carries a hint of something metallic and cold. My journal is empty, waiting for the ink of the next fourteen days. The weight of the backpack feels right—a home I carry on my shoulders.', []),
                ] else ...[
                   ...entries.map((e) => _buildJournalItem(context, e)),
                ],

                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                       Icon(Icons.book, color: Colors.grey.shade300, size: 32),
                       const SizedBox(height: 12),
                       Text('END OF RECENT UPDATES', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFFCBD5E1), letterSpacing: 1.0)),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.journalAdd),
          backgroundColor: const Color(0xFF132F5C),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildJournalItem(BuildContext context, JournalEntryModel entry) {
    final dateStr = DateFormat('MMMM d, y').format(entry.createdAt);
    final timeStr = DateFormat('hh:mm a').format(entry.createdAt);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.journalEdit, arguments: entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 48),
        color: Colors.transparent, // For better hit testing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF132F5C))),
                Text(timeStr, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Color(0xFF132F5C)),
                const SizedBox(width: 8),
                Text(entry.location?.name ?? 'Unknown Location', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 16),
            Text(entry.note, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF475569), height: 1.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleEntry(BuildContext context, String date, String time, String location, String note, List<String> tags) {
    return Container(
      margin: const EdgeInsets.only(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1D4E89))),
              Text(time, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Color(0xFF1D4E89)),
              const SizedBox(width: 8),
              Text(location, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 16),
          Text(note, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF475569), height: 1.6)),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: tags.map((t) => Text(t, style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: const Color(0xFF94A3B8)))).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
