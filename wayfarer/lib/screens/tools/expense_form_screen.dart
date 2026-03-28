import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/trip_provider.dart';
import '../../models/trip_model.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const ExpenseFormScreen({super.key, this.initialData});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  late bool _isEdit;
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final expense = widget.initialData?['expense'] as TripExpense?;
    _isEdit = expense != null;
    _nameController = TextEditingController(text: expense?.title ?? '');
    _amountController = TextEditingController(text: expense?.amount.toString() ?? '');
    _selectedDate = expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _nameController.text;
    final amountStr = _amountController.text;
    final tripId = widget.initialData?['tripId'] as String?;

    if (title.isEmpty || amountStr.isEmpty || tripId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields!')));
      return;
    }

    final amount = double.tryParse(amountStr) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount!')));
      return;
    }

    setState(() => _isLoading = true);
    
    final tp = context.read<TripProvider>();
    final trip = tp.trips.firstWhere((t) => t.id == tripId);
    
    List<TripExpense> updatedExpenses = List.from(trip.expenses);
    if (_isEdit) {
      final oldExpense = widget.initialData!['expense'] as TripExpense;
      final index = updatedExpenses.indexWhere((e) => e.id == oldExpense.id);
      if (index != -1) {
        updatedExpenses[index] = TripExpense(
          id: oldExpense.id,
          title: title,
          amount: amount,
          date: _selectedDate,
          category: oldExpense.category,
        );
      }
    } else {
      updatedExpenses.add(TripExpense(
        title: title,
        amount: amount,
        date: _selectedDate,
      ));
    }

    final updatedTrip = TripModel(
      id: trip.id,
      userId: trip.userId,
      destination: trip.destination,
      countryCode: trip.countryCode,
      countryName: trip.countryName,
      startDate: trip.startDate,
      endDate: trip.endDate,
      partySize: trip.partySize,
      notes: trip.notes,
      status: trip.status,
      budget: trip.budget,
      expenses: updatedExpenses,
      itinerary: trip.itinerary,
      destinationInfo: trip.destinationInfo,
    );

    final success = await tp.updateTrip(tripId, updatedTrip);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEdit ? 'Expense updated!' : 'Expense added!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save expense.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Color(0xFF1E2E46))),
        title: Text(_isEdit ? 'Edit Expense' : 'Add Expense', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1E2E46))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FINANCIAL TRACKING', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text('Refine your itinerary costs.', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            const SizedBox(height: 48),
            
            _buildFieldLabel('Item Name'),
            _buildTextField(_nameController, 'e.g. Flight to Tokyo'),
            
            const SizedBox(height: 32),
            _buildFieldLabel('Amount'),
            _buildTextField(_amountController, '0.00', keyboardType: TextInputType.number, prefix: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('\$', style: TextStyle(fontSize: 18, color: Color(0xFF1E2E46))),
            )),
            
            const SizedBox(height: 32),
            _buildFieldLabel('Transaction Date'),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context, 
                  initialDate: _selectedDate, 
                  firstDate: DateTime.now().subtract(const Duration(days: 365)), 
                  lastDate: DateTime.now().add(const Duration(days: 365))
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFF1F5F9))),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF1E40AF)),
                    const SizedBox(width: 16),
                    Text(DateFormat('MMMM d, yyyy').format(_selectedDate), style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF1E2E46))),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            _buildInfoCard(),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _handleSave,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: Text(_isEdit ? 'Save Changes' : 'Add Expense', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E40AF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
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
      child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {Widget? prefix, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(fontSize: 18, color: const Color(0xFF1E2E46)),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: prefix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info, color: Color(0xFF1E40AF), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nomad Tip', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 8),
                Text('Ensure you keep your physical receipts for customs or reimbursement requirements later.', 
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
