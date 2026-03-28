import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/journal_provider.dart';
import '../../models/journal_model.dart';
import '../../widgets/loading_widget.dart';

class EditJournalScreen extends StatefulWidget {
  final JournalEntryModel entry;
  const EditJournalScreen({super.key, required this.entry});

  @override
  State<EditJournalScreen> createState() => _EditJournalScreenState();
}

class _EditJournalScreenState extends State<EditJournalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _noteController;
  late TextEditingController _dateController;
  late DateTime _selectedDate;
  String _selectedMood = "Peaceful";
  bool _isLoading = false;



  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _locationController = TextEditingController(text: widget.entry.location?.name ?? "");
    _noteController = TextEditingController(text: widget.entry.note);
    _selectedDate = widget.entry.createdAt;
    _dateController = TextEditingController(text: DateFormat('MM/dd/yyyy').format(_selectedDate));
    // Mood is not in model, using default for mockup perfection
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final updatedEntry = JournalEntryModel(
      id: widget.entry.id,
      userId: widget.entry.userId,
      tripId: widget.entry.tripId,
      title: _titleController.text,
      note: _noteController.text,
      location: JournalLocation(name: _locationController.text),
      createdAt: _selectedDate,
    );

    final success = await context.read<JournalProvider>().updateEntry(widget.entry.id, updatedEntry);
    if (success && mounted) {
      Navigator.pop(context);
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update memory')));
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Memory?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('DELETE', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final provider = context.read<JournalProvider>();
      final success = await provider.deleteEntry(widget.entry.id);
      if (mounted) {
        if (success) {
          Navigator.pop(context);
        } else {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingWidget();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 24, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDBEAFE), width: 1.5, style: BorderStyle.solid), // Dashed look roughly with light blue
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF64748B), size: 18),
          ),
        ),
        title: Text('Edit Journal Entry', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF132F5C))),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.history, color: Color(0xFF132F5C))),
          IconButton(onPressed: () {}, icon: const Icon(Icons.person, color: Color(0xFF132F5C))),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('JOURNAL DETAILS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1.0)),
              const SizedBox(height: 8),
              Text('Refine your memory', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
              const SizedBox(height: 8),
              Text('Update the details of your visit to ${widget.entry.location?.name ?? 'your destination'}.', 
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
              
              const SizedBox(height: 32),
              
              _buildLabel('Title'),
              _buildTextField(_titleController, 'A name for this memory...'),
              
              const SizedBox(height: 24),
              _buildLabel('Date'),
              _buildTextField(_dateController, 'Select date', isDate: true),
              
              const SizedBox(height: 24),
              _buildLabel('Location'),
              _buildTextField(_locationController, 'Where were you?', suffixIcon: Icons.location_on),
              
              const SizedBox(height: 24),
              _buildLabel('Mood & Vibe'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                   _buildMoodChip(Icons.wb_sunny_outlined, 'Peaceful'),
                   _buildMoodChip(Icons.settings_suggest_outlined, 'Inspired'),
                   _buildMoodChip(Icons.local_cafe_outlined, 'Quiet'),
                   _buildAddChip(),
                ],
              ),
              
              const SizedBox(height: 32),
              _buildLabel('Journal Entry'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                   children: [
                     TextFormField(
                       controller: _noteController,
                       maxLines: 8,
                       decoration: const InputDecoration(border: InputBorder.none, filled: false, contentPadding: EdgeInsets.zero),
                       style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF475569), height: 1.6),
                     ),
                     const SizedBox(height: 12),
                     Row(
                       children: [
                         Icon(Icons.format_bold, size: 18, color: Colors.grey.shade300),
                         const SizedBox(width: 16),
                         Icon(Icons.format_italic, size: 18, color: Colors.grey.shade300),
                         const SizedBox(width: 16),
                         Icon(Icons.link, size: 18, color: Colors.grey.shade300),
                       ],
                     ),
                   ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.save),
                  label: Text('Save Changes', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF132F5C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: _handleDelete,
                  icon: const Icon(Icons.delete_outline, color: Color(0xFF991B1B)),
                  label: Text('Delete Entry', style: GoogleFonts.inter(color: const Color(0xFF991B1B), fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 40),
              Center(
                 child: Text('LAST AUTOSAVED 2M AGO     104 Words', 
                   style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFCBD5E1), fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isDate = false, IconData? suffixIcon}) {
    return TextFormField(
      controller: controller,
      readOnly: isDate,
      onTap: isDate ? () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
            _dateController.text = DateFormat('MM/dd/yyyy').format(date);
          });
        }
      } : null,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: Icon(suffixIcon ?? (isDate ? Icons.calendar_today_outlined : null), size: 18, color: const Color(0xFF94A3B8)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
      ),
    );
  }

  Widget _buildMoodChip(IconData icon, String mood) {
    final bool isSelected = _selectedMood == mood;
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = mood),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(mood, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildAddChip() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
      ),
      child: const Icon(Icons.add, size: 16, color: Color(0xFF94A3B8)),
    );
  }
}
