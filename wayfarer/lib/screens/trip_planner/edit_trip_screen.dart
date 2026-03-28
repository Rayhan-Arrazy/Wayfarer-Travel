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

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController(text: widget.trip.destination);
    _departureController = TextEditingController(text: _formatDate(widget.trip.startDate));
    _returnController = TextEditingController(text: _formatDate(widget.trip.endDate));
    _travelers = widget.trip.partySize;
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
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    setState(() => _isLoading = true);
    
    // Simplistic parsing for this demo (should use proper date pickers)
    final updatedTrip = TripModel(
      id: widget.trip.id,
      userId: widget.trip.userId,
      destination: _destinationController.text,
      countryCode: widget.trip.countryCode,
      countryName: widget.trip.countryName,
      startDate: widget.trip.startDate, // Keep original for demo simplicity
      endDate: widget.trip.endDate,
      partySize: _travelers,
      notes: widget.trip.notes,
      status: widget.trip.status,
      budget: widget.trip.budget,
      expenses: widget.trip.expenses,
      itinerary: widget.trip.itinerary,
      destinationInfo: widget.trip.destinationInfo,
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip deleted.')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2E46))),
        title: Text('Edit Trip', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
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
            
            const SizedBox(height: 48),
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
            
            const SizedBox(height: 48),
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
            
            const SizedBox(height: 24),
            Text(
              'WARNING: THIS ACTION IS PERMANENT AND CANNOT BE UNDONE.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8), letterSpacing: 0.5, height: 1.5),
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
}
