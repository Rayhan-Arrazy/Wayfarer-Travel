import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../models/trip_model.dart';

class ActivityFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const ActivityFormScreen({super.key, this.initialData});

  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  late bool _isEdit;
  late TextEditingController _nameController;
  late TextEditingController _timeController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final activity = widget.initialData?['activity'] as ItineraryActivity?;
    _isEdit = activity != null;
    _nameController = TextEditingController(text: activity?.title ?? '');
    _timeController = TextEditingController(text: activity?.time ?? '');
    _locationController = TextEditingController(text: activity?.location ?? '');
    _notesController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              border: Border.all(color: const Color(0xFFDBEAFE), width: 1.5),
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF64748B), size: 18),
          ),
        ),
        title: Text(_isEdit ? 'Edit Activity' : 'Add Activity', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF132F5C))),
        titleSpacing: 0,
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE2E8F0),
              child: Text('JD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NEW ENTRY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text(_isEdit ? 'Edit Activity' : 'Add Activity', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            const SizedBox(height: 12),
            Text(
              'Log a new waypoint for your journey. Details are automatically synced across your travel group\'s itinerary.',
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.5),
            ),
            
            const SizedBox(height: 40),
            
            _buildFieldLabel('Activity Name'),
            _buildTextField(_nameController, 'e.g. Sunset Kayaking at Lake Bled'),
            
            const SizedBox(height: 32),
            
            _buildFieldLabel('Departure Time'),
            _buildTextField(_timeController, '--:-- --', prefix: const Icon(Icons.access_time_outlined, size: 20, color: Color(0xFF1E2E46)), suffix: const Icon(Icons.access_time, size: 20, color: Colors.black)),
            
            const SizedBox(height: 32),
            
            _buildFieldLabel('Precise Location'),
            _buildTextField(_locationController, 'Search coordinates or address', prefix: const Icon(Icons.location_on, size: 20, color: Color(0xFF1E2E46))),
            
            const SizedBox(height: 32),
            
            _buildFieldLabel('Navigation Notes'),
            _buildTextField(_notesController, 'Mention parking details, meeting points, or specific instructions for the group...', maxLines: 5),
            
            const SizedBox(height: 48),
            
            _isEdit ? _buildEditButtons() : _buildAddButtons(),
            
            const SizedBox(height: 48),
            
            _buildInfoCard(),
            
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {Widget? prefix, Widget? suffix, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF1E2E46)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey.shade300),
          prefixIcon: prefix,
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final title = _nameController.text;
    final time = _timeController.text;
    final location = _locationController.text;
    final tripId = widget.initialData?['tripId'] as String?;

    if (title.isEmpty || time.isEmpty || tripId == null) return;

    final tp = context.read<TripProvider>();
    final trip = tp.trips.firstWhere((t) => t.id == tripId);
    
    List<ItineraryActivity> updatedItinerary = List.from(trip.itinerary);
    if (_isEdit) {
      final oldAct = widget.initialData!['activity'] as ItineraryActivity;
      final index = updatedItinerary.indexWhere((a) => a.title == oldAct.title);
      if (index != -1) {
        updatedItinerary[index] = ItineraryActivity(
          title: title,
          time: time,
          location: location,
          checked: oldAct.checked,
        );
      }
    } else {
      updatedItinerary.add(ItineraryActivity(
        title: title,
        time: time,
        location: location,
      ));
    }

    final updatedTrip = trip.copyWith(itinerary: updatedItinerary);
    await tp.updateTrip(tripId, updatedTrip);
    if (mounted) Navigator.pop(context);
  }

  Widget _buildAddButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E2E46),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Add Activity', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Discard Draft', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
        ),
      ],
    );
  }

  Widget _buildEditButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: _handleSave,
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            label: Text('Save Activity', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E2E46),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () async {
              final tp = context.read<TripProvider>();
              final tripId = widget.initialData!['tripId'];
              final oldAct = widget.initialData!['activity'] as ItineraryActivity;
              final trip = tp.trips.firstWhere((t) => t.id == tripId);
              final updatedItinerary = trip.itinerary.where((a) => a.title != oldAct.title).toList();
              final updatedTrip = trip.copyWith(itinerary: updatedItinerary);
              await tp.updateTrip(tripId, updatedTrip);
              if (mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline, color: Color(0xFF7C2D12)),
            label: Text('Delete Activity', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF7C2D12))),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE2E8F0),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info, color: Color(0xFF1E2E46), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GROUP VISIBILITY', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF1E2E46), letterSpacing: 1.0)),
                const SizedBox(height: 8),
                Text('This activity will be visible to all members of the Alpine Expedition 2024 trip. Changes are logged in the activity feed.', 
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
