import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/journal_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../models/journal_model.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/wayfarer_app_bar.dart';

class AddJournalScreen extends StatefulWidget {
  const AddJournalScreen({super.key});

  @override
  State<AddJournalScreen> createState() => _AddJournalScreenState();
}

class _AddJournalScreenState extends State<AddJournalScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedMood = 'Adventurous';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Adventurous', 'icon': Icons.explore},
    {'label': 'Happy', 'icon': Icons.sentiment_satisfied},
    {'label': 'Tired', 'icon': Icons.nights_stay},
    {'label': 'Peaceful', 'icon': Icons.spa},
  ];

  @override
  void initState() {
    super.initState();
    final tp = context.read<TripProvider>();
    if (tp.upcomingTrip != null) {
      _locationController.text = tp.upcomingTrip!.destination;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title and some notes!')));
      return;
    }

    setState(() => _isLoading = true);
    
    final auth = context.read<AuthProvider>();
    final tp = context.read<TripProvider>();
    
    final entry = JournalEntryModel(
      id: '',
      userId: auth.user!.id,
      tripId: tp.upcomingTrip?.id ?? '',
      title: _titleController.text,
      note: _noteController.text,
      mood: _selectedMood,
      location: JournalLocation(name: _locationController.text),
      photos: [],
      createdAt: DateTime.now(),
    );

    final success = await context.read<JournalProvider>().createEntry(entry);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Memory published successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to publish memory.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingWidget();
    final dateStr = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: WayfarerAppBar(
        showMenu: false,
        extraActions: [
          TextButton(
            onPressed: _handlePublish,
            child: Text('Publish', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF132F5C))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NEW ENTRY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text('Capture your journey.', style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), height: 1.1)),
            
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                   const Icon(Icons.calendar_today, color: Color(0xFF1E40AF), size: 20),
                   const SizedBox(width: 16),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text("TODAY'S DATE", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                       Text(dateStr, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E40AF))),
                     ],
                   ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            _buildFieldLabel('ENTRY TITLE'),
            _buildTextField(_titleController, 'A name for this memory...'),
            
            const SizedBox(height: 32),
            _buildFieldLabel('LOCATION'),
            _buildTextField(_locationController, 'Where are you?', prefix: const Icon(Icons.location_on, size: 20, color: Color(0xFF94A3B8))),
            
            const SizedBox(height: 32),
            _buildFieldLabel('HOW ARE YOU FEELING?'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._moods.map((mood) => _buildMoodChip(mood['label'], mood['icon'])),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildFieldLabel('NOTE'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: TextField(
                controller: _noteController,
                maxLines: 8,
                style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF475569), height: 1.6),
                decoration: InputDecoration(
                  hintText: 'Start writing your story here...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                  border: InputBorder.none,
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handlePublish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2E46),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Publish Entry', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.0)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {Widget? prefix}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 18, color: const Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: prefix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildMoodChip(String label, IconData icon) {
    final isSelected = _selectedMood == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : const Color(0xFF1E40AF)),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF1E40AF))),
          ],
        ),
      ),
    );
  }
}
