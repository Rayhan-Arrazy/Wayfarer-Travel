import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/budget_provider.dart';
import '../../models/budget_model.dart';
import '../../widgets/wayfarer_app_bar.dart';

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
    final expense = widget.initialData?['expense'] as BudgetExpense?;
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
    final budgetId = widget.initialData?['budgetId'] as String?;

    if (title.isEmpty || amountStr.isEmpty || budgetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields!')));
      return;
    }

    final amount = double.tryParse(amountStr) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount!')));
      return;
    }

    setState(() => _isLoading = true);
    
    final bp = context.read<BudgetProvider>();
    final budget = bp.budgets.firstWhere((b) => b.id == budgetId);
    
    List<BudgetExpense> updatedExpenses = List.from(budget.expenses);
    if (_isEdit) {
      final oldExpense = widget.initialData!['expense'] as BudgetExpense;
      final index = updatedExpenses.indexWhere((e) => e.id == oldExpense.id);
      if (index != -1) {
        updatedExpenses[index] = BudgetExpense(
          id: oldExpense.id,
          title: title,
          amount: amount,
          date: _selectedDate,
          category: oldExpense.category,
        );
      }
    } else {
      updatedExpenses.add(BudgetExpense(
        title: title,
        amount: amount,
        date: _selectedDate,
      ));
    }

    final updatedBudget = budget.copyWith(expenses: updatedExpenses);

    final success = await bp.updateBudget(budgetId, updatedBudget);
    
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
      appBar: WayfarerAppBar(
        showMenu: false,
        onBack: () => Navigator.pop(context),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FINANCIAL TRACKING', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text(_isEdit ? 'Edit Expense' : 'Add Expense', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text('Refine your itinerary costs.', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
            const SizedBox(height: 40),
            
            _buildFieldLabel('Item Name'),
            _buildTextField(_nameController, 'e.g. Artisanal Coffee in Kyoto', null),
            
            const SizedBox(height: 32),
            _buildFieldLabel('Amount'),
            _buildTextField(_amountController, '0.00', const Icon(Icons.attach_money, size: 18, color: Color(0xFF1E2E46)), keyboardType: TextInputType.number),
            
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
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF0F172A)),
                    const SizedBox(width: 16),
                    Text(DateFormat('MM/dd/yyyy').format(_selectedDate), style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF1E2E46))),
                    const Spacer(),
                    const Icon(Icons.calendar_today, size: 20, color: Color(0xFF0F172A)),
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
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: Text('Save Changes', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF47638A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            
            if (_isEdit) ...[
              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: () => _handleDelete(widget.initialData!['budgetId'], widget.initialData!['expense']), 
                  icon: const Icon(Icons.delete, color: Color(0xFF991B1B), size: 18),
                  label: Text('Delete Item', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF991B1B))),
                ),
              ),
            ],
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(String budgetId, BudgetExpense expense) async {
    final bp = context.read<BudgetProvider>();
    final budget = bp.budgets.firstWhere((b) => b.id == budgetId);
    final updatedExpenses = budget.expenses.where((e) => e.id != expense.id).toList();
    final updatedBudget = budget.copyWith(expenses: updatedExpenses);
    await bp.updateBudget(budgetId, updatedBudget);
    if (mounted) Navigator.pop(context);
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, Widget? prefix, {TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.info, color: Color(0xFF1E40AF), size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nomad Tip', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 8),
                Text('Most local shops in Gion are cash-only. Ensure you update your physical wallet balance after this entry.', 
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

