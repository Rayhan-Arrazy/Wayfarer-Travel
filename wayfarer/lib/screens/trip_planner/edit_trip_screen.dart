import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/trip_model.dart';
import '../../providers/trip_provider.dart';

class EditTripScreen extends StatefulWidget {
  final TripModel trip;
  const EditTripScreen({super.key, required this.trip});

  @override
  State<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  late TextEditingController _destinationController;
  late TextEditingController _departureController;
  late TextEditingController _returnController;
  late int _travelers;
  bool _isLoading = false;

  late List<ItineraryActivity> _itinerary;
  final _activityTitleController = TextEditingController();
  final _activityTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController(text: widget.trip.destination);
    _departureController = TextEditingController(text: _formatDate(widget.trip.startDate));
    _returnController = TextEditingController(text: _formatDate(widget.trip.endDate));
    _travelers = widget.trip.partySize;
    _itinerary = List.from(widget.trip.itinerary);
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _departureController.dispose();
    _returnController.dispose();
    _activityTitleController.dispose();
    _activityTimeController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    setState(() => _isLoading = true);
    
    final updatedTrip = widget.trip.copyWith(
      destination: _destinationController.text,
      partySize: _travelers,
      itinerary: _itinerary,
    );

    final success = await context.read<TripProvider>().updateTrip(widget.trip.id, updatedTrip);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip updated successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update trip.')));
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Trip'),
        content: const Text('Are you sure you want to delete this trip? This action is permanent.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      final success = await context.read<TripProvider>().deleteTrip(widget.trip.id);
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context);
        }
      }
    }
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
        title: Text('Edit Trip', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(widget.trip.destination.contains(',') ? widget.trip.destination.split(',').first + ' Trip' : widget.trip.destination + ' Trip', 
                style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            const SizedBox(height: 8),
            Text('MANAGE DETAILS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.5)),
            
            const SizedBox(height: 32),
            _buildFieldLabel('DESTINATION'),
            _buildUnderlineTextField(_destinationController),
            
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('DEPARTURE'),
                      _buildUnderlineTextField(_departureController),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('RETURN'),
                      _buildUnderlineTextField(_returnController),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildFieldLabel('TRAVELERS'),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$_travelers', style: GoogleFonts.inter(fontSize: 20, color: const Color(0xFF1E293B))),
                  Row(
                    children: [
                      IconButton(onPressed: () => setState(() => _travelers > 1 ? _travelers-- : null), icon: const Icon(Icons.remove, color: Color(0xFF475569))),
                      const SizedBox(width: 8),
                      IconButton(onPressed: () => setState(() => _travelers++), icon: const Icon(Icons.add, color: Color(0xFF475569))),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFE2E8F0), thickness: 1),
            
            const SizedBox(height: 32),
            _buildFieldLabel('MANAGE ITINERARY'),
            const SizedBox(height: 8),
            _buildItinerarySection(),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E40AF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Update Trip', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton.icon(
                onPressed: _handleDelete,
                icon: const Icon(Icons.delete_outline, color: Color(0xFF7C2D12), size: 22),
                label: Text('Delete Trip', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF7C2D12))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFF1F5F9)),
                  backgroundColor: const Color(0xFFF8FAFC),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
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
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 0.5)),
    );
  }

  Widget _buildUnderlineTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF1E293B)),
      decoration: const InputDecoration(
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF475569))),
        isCollapsed: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  Widget _buildItinerarySection() {
    return Column(
      children: [
        ..._itinerary.map((act) => _buildActivityTile(act)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
          child: Column(
            children: [
              TextField(
                controller: _activityTitleController,
                decoration: const InputDecoration(hintText: 'Activity title', border: InputBorder.none),
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(child: TextField(controller: _activityTimeController, decoration: const InputDecoration(hintText: 'Time', border: InputBorder.none))),
                  TextButton(onPressed: _addActivity, child: const Text('Add')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTile(ItineraryActivity act) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${act.time} - ${act.title}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          IconButton(onPressed: () => setState(() => _itinerary.remove(act)), icon: const Icon(Icons.close, size: 16)),
        ],
      ),
    );
  }

  void _addActivity() {
    if (_activityTitleController.text.isEmpty) return;
    setState(() {
      _itinerary.add(ItineraryActivity(title: _activityTitleController.text, time: _activityTimeController.text, location: ''));
      _activityTitleController.clear();
      _activityTimeController.clear();
    });
  }
}
