import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/journal_provider.dart';
import '../../models/journal_model.dart';

class EditJournalScreen extends StatefulWidget {
  final JournalEntryModel entry;
  const EditJournalScreen({super.key, required this.entry});

  @override
  State<EditJournalScreen> createState() => _EditJournalScreenState();
}

class _EditJournalScreenState extends State<EditJournalScreen> {
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _contentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _locationController = TextEditingController(text: widget.entry.location?.name ?? '');
    _contentController = TextEditingController(text: widget.entry.note);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    
    final updatedEntry = JournalEntryModel(
      id: widget.entry.id,
      userId: widget.entry.userId,
      tripId: widget.entry.tripId,
      tripDestination: widget.entry.tripDestination,
      title: _titleController.text,
      note: _contentController.text,
      location: JournalLocation(name: _locationController.text),
      mood: widget.entry.mood,
      photos: widget.entry.photos,
      createdAt: widget.entry.createdAt,
    );

    final success = await context.read<JournalProvider>().updateEntry(widget.entry.id, updatedEntry);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Memory updated!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update memory.')));
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Memory'),
        content: const Text('Are you sure you want to delete this memory?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      final success = await context.read<JournalProvider>().deleteEntry(widget.entry.id);
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Memory deleted.')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMMM d, yyyy').format(widget.entry.createdAt);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Color(0xFF1E2E46))),
        title: Text('Edit Memory', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('JOURNAL DETAILS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text('Refine your memory', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), height: 1.1)),
            const SizedBox(height: 8),
            Text('Recorded on $dateStr', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
            
            const SizedBox(height: 40),
            _buildFieldLabel('Title'),
            _buildUnderlineField(_titleController),
            
            const SizedBox(height: 32),
            _buildFieldLabel('Location'),
            _buildUnderlineField(_locationController, suffix: const Icon(Icons.location_on, size: 20, color: Color(0xFF94A3B8))),
            
            const SizedBox(height: 32),
            _buildFieldLabel('Journal Entry'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 8,
                style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF475569), height: 1.7),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _handleSave,
                icon: const Icon(Icons.save, color: Colors.white, size: 20),
                label: Text('Save Changes', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E40AF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            Center(
              child: TextButton.icon(
                onPressed: _handleDelete,
                icon: const Icon(Icons.delete_outline, color: Color(0xFF991B1B), size: 20),
                label: Text('Delete Entry', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF991B1B))),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
    );
  }

  Widget _buildUnderlineField(TextEditingController controller, {Widget? suffix}) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
      decoration: InputDecoration(
        suffixIcon: suffix,
        border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E40AF))),
      ),
    );
  }
}
