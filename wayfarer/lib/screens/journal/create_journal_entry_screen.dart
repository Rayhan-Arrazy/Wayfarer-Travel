import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/trip_model.dart';

class CreateJournalEntryScreen extends StatefulWidget {
  const CreateJournalEntryScreen({super.key});

  @override
  State<CreateJournalEntryScreen> createState() => _CreateJournalEntryScreenState();
}

class _CreateJournalEntryScreenState extends State<CreateJournalEntryScreen> {
  final ApiService _api = ApiService();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedMood = 'happy';
  String? _selectedTripId;
  List<TripModel> _trips = [];
  bool _isLoading = false;
  bool _isLoadingTrips = true;

  final Map<String, String> _moods = {
    'amazing': '🤩',
    'happy': '😊',
    'neutral': '😐',
    'tired': '😴',
    'sad': '😢',
  };

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadTrips() async {
    try {
      final response = await ApiService().getTrips();
      final List data = response.data;
      setState(() {
        _trips = data.map((t) => TripModel.fromJson(t)).toList();
        _isLoadingTrips = false;
        // Pre-select the first active trip or the first trip
        final activeTrips = _trips.where((t) => t.isActive).toList();
        if (activeTrips.isNotEmpty) {
          _selectedTripId = activeTrips.first.id;
        } else if (_trips.isNotEmpty) {
          _selectedTripId = _trips.first.id;
        }
      });
    } catch (e) {
      setState(() => _isLoadingTrips = false);
    }
  }

  Future<void> _createEntry() async {
    if (_selectedTripId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a trip first'), backgroundColor: AppTheme.warningColor),
      );
      return;
    }

    if (_noteController.text.trim().isEmpty && _titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title or note'), backgroundColor: AppTheme.warningColor),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = <String, dynamic>{
        'tripId': _selectedTripId,
        'title': _titleController.text.trim(),
        'note': _noteController.text.trim(),
        'mood': _selectedMood,
      };

      if (_locationController.text.trim().isNotEmpty) {
        // Try geocoding
        try {
          final geoResponse = await _api.searchPlaces(_locationController.text.trim());
          final List results = geoResponse.data;
          if (results.isNotEmpty) {
            data['location'] = {
              'lat': double.parse(results[0]['lat'].toString()),
              'lng': double.parse(results[0]['lon'].toString()),
              'name': _locationController.text.trim(),
              'country': results[0]['address']?['country'] ?? '',
            };
          }
        } catch (_) {
          data['location'] = {'lat': 0, 'lng': 0, 'name': _locationController.text.trim(), 'country': ''};
        }
      }

      await _api.createJournalEntry(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal entry added! 📝'), backgroundColor: AppTheme.successColor),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('New Entry', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip selector
            Text('Trip', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            _isLoadingTrips
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : _trips.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.lightCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info, color: AppTheme.warningColor, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('Create a trip first to add journal entries',
                                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.warningColor)),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.lightSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.lightBorder),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedTripId,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: AppTheme.lightSurface,
                          hint: Text('Select a trip', style: GoogleFonts.inter(color: AppTheme.textMuted)),
                          style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textPrimary),
                          items: _trips.map((t) => DropdownMenuItem(
                            value: t.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: t.isActive ? AppTheme.successColor : t.isCompleted ? AppTheme.primaryColor : AppTheme.warningColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(t.destination, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedTripId = v),
                        ),
                      ),

            const SizedBox(height: 24),

            // Mood
            Text('How are you feeling?', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _moods.entries.map((entry) {
                final isSelected = _selectedMood == entry.key;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.2) : AppTheme.lightCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.lightBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(entry.value, style: TextStyle(fontSize: isSelected ? 30 : 24)),
                        const SizedBox(height: 4),
                        Text(
                          entry.key[0].toUpperCase() + entry.key.substring(1),
                          style: GoogleFonts.inter(
                            fontSize: 10, fontWeight: FontWeight.w500,
                            color: isSelected ? AppTheme.primaryColor : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Title
            Text('Title (optional)', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'e.g. First day in Tokyo',
                prefixIcon: Icon(Icons.title, color: AppTheme.textMuted),
              ),
            ),

            const SizedBox(height: 24),

            // Note
            Text('Notes', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 5,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Write about your day...',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            // Location
            Text('Location (optional)', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'e.g. Shibuya, Tokyo',
                prefixIcon: Icon(Icons.location_on, color: AppTheme.textMuted),
              ),
            ),

            const SizedBox(height: 36),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text('Save Entry 📝', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
