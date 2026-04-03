import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  final _destinationController = TextEditingController();
  final _departureController = TextEditingController();
  final _returnController = TextEditingController();
  
  late int _adults;
  late int _children;

  final List<String> _checklistItems = ['Book Flights', 'Get Visa', 'Buy Insurance'];
  final Set<String> _selectedChecklist = {};
  
  late List<ItineraryActivity> _itinerary;
  final _activityTitleController = TextEditingController();
  final _activityTimeController = TextEditingController();
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _destinationController.text = widget.trip.destination;
    _departureController.text = DateFormat('MM/dd/yyyy').format(widget.trip.startDate);
    _returnController.text = DateFormat('MM/dd/yyyy').format(widget.trip.endDate);
    
    // Simple parsing for party size since original model is simpler
    _adults = widget.trip.partySize;
    _children = 0;
    
    _itinerary = List.from(widget.trip.itinerary);
    
    // Populate checklist if exists
    for (var item in widget.trip.checklist) {
      if (item.checked) {
        _selectedChecklist.add(item.item);
      }
    }
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
        title: Text('EDIT TRIP', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFF1E2E46), letterSpacing: 1.0)),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MANAGE DETAILS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text(widget.trip.destination, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            const SizedBox(height: 48),
            
            _buildFieldLabel('DESTINATION'),
            _buildTextField(_destinationController, 'Search cities, regions or country', prefix: const Icon(Icons.search, size: 20)),
            
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('DEPARTURE'),
                      _buildDateTile(_departureController, () => _selectDate(context, _departureController, true)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('RETURN'),
                      _buildDateTile(_returnController, () => _selectDate(context, _returnController, false)),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildFieldLabel('TRAVELERS'),
            _buildCounterField('Adults', '18+ years', _adults, (val) => setState(() => _adults = val)),
            const SizedBox(height: 12),
            _buildCounterField('Children', '0-17 years', _children, (val) => setState(() => _children = val)),
            
            const SizedBox(height: 32),
            _buildFieldLabel('QUICK CHECKLIST ITEMS'),
            _buildQuickChecklist(),
            
            const SizedBox(height: 32),
            _buildFieldLabel('MANAGE ITINERARY'),
            const SizedBox(height: 8),
            _buildItinerarySection(),
            
            const SizedBox(height: 48),
            if (_isSaving) 
              const Center(child: CircularProgressIndicator())
            else ...[
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6083),
                    elevation: 4,
                    shadowColor: const Color(0xFF1E2E46).withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Update Trip', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: _handleDelete,
                  icon: const Icon(Icons.delete_outline, color: Color(0xFF7C2D12), size: 22),
                  label: Text('Delete Trip', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF7C2D12))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF1F5F9)),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 40),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(hintText: hint, prefixIcon: prefix, border: InputBorder.none, contentPadding: const EdgeInsets.all(16)),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDeparture ? widget.trip.startDate : widget.trip.endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E2E46),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E2E46),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Widget _buildDateTile(TextEditingController controller, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                controller.text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E2E46),
                ),
              ),
            ),
            const Icon(Icons.calendar_month_outlined, size: 20, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChecklist() {
    return Column(
      children: _checklistItems.map((item) {
        final isSelected = _selectedChecklist.contains(item);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedChecklist.remove(item);
              } else {
                _selectedChecklist.add(item);
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF1E2E46) : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF1E2E46) : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                    color: isSelected ? const Color(0xFF1E2E46) : Colors.transparent,
                  ),
                  child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                ),
                const SizedBox(width: 16),
                Text(
                  item,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF1E2E46) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCounterField(String title, String subtitle, int value, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(onPressed: () => value > 0 ? onChanged(value - 1) : null, icon: const Icon(Icons.remove_circle_outline)),
              Text('$value', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add_circle)),
            ],
          ),
        ],
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
      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
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

  Future<void> _handleUpdate() async {
    setState(() => _isSaving = true);
    
    final updatedTrip = widget.trip.copyWith(
      destination: _destinationController.text,
      partySize: _adults + _children,
      itinerary: _itinerary,
      startDate: DateFormat('MM/dd/yyyy').parse(_departureController.text),
      endDate: DateFormat('MM/dd/yyyy').parse(_returnController.text),
    );

    // Update checklist in model
    final updatedChecklist = updatedTrip.checklist.map((item) {
      return item.copyWith(checked: _selectedChecklist.contains(item.item));
    }).toList();
    
    final finalTrip = updatedTrip.copyWith(checklist: updatedChecklist);
    
    final success = await context.read<TripProvider>().updateTrip(widget.trip.id, finalTrip);
    
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip updated successfully!')));
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
      setState(() => _isSaving = true);
      final success = await context.read<TripProvider>().deleteTrip(widget.trip.id);
      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          Navigator.pop(context);
          Navigator.pop(context); // Pop back twice to get out of preview as well
        }
      }
    }
  }
}
