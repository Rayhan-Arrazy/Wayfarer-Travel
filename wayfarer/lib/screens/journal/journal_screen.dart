import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/journal_provider.dart';
import '../../models/journal_model.dart';
import '../../config/routes.dart';

import '../../widgets/loading_widget.dart';
import '../../widgets/wayfarer_app_bar.dart';

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

    return Column(
      children: [
        WayfarerAppBar(),
        Expanded(
          child: journalProvider.isLoading 
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
                      _buildEmptyState(),
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
        ),
      ],
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

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.book_outlined, size: 48, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 24),
              Text('No memories recorded yet', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Text('Your journey is an unwritten book.\nTap the + button to add your first chapter.', 
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}
