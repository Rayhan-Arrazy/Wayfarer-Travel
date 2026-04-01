import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/trip_provider.dart';
import '../../providers/budget_provider.dart';
import '../../models/budget_model.dart';
import '../../config/routes.dart';
import '../../widgets/loading_widget.dart';

class BudgeterScreen extends StatefulWidget {
  const BudgeterScreen({super.key});

  @override
  State<BudgeterScreen> createState() => _BudgeterScreenState();
}

class _BudgeterScreenState extends State<BudgeterScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().fetchBudgets();
      context.read<TripProvider>().fetchTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TripProvider>();
    final bp = context.watch<BudgetProvider>();
    
    if (tp.isLoading || bp.isLoading) return const LoadingWidget();

    final trip = tp.upcomingTrip;
    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Budgeter')),
        body: const Center(child: Text('No active trip found. Create a trip first!')),
      );
    }

    final budget = bp.getBudgetForTrip(trip.id);

    if (budget == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(title: const Text('Budgeter')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No budget started for this trip.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _showAddBudgetDialog(context, trip), 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF132F5C),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Start Budgeting', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final totalBudget = budget.amount;
    final totalSpent = budget.expenses.fold<double>(0, (sum, item) => sum + item.amount);
    final remaining = totalBudget - totalSpent;
    final progress = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF132F5C)),
        ),
        title: Text('The Wayfarer', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1D4E89))),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.person, color: Color(0xFF132F5C))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CURRENT TRIP BUDGET', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('\$${totalBudget.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w800, color: const Color(0xFF1D4E89).withValues(alpha: 0.8), height: 1.0)),
                    const SizedBox(height: 8),
                    Text('Total allocation for ${budget.title}', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _handleEditBudgetLimit(budget), 
                  icon: const Icon(Icons.edit, size: 16, color: Color(0xFF132F5C)),
                  label: Text('Edit', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF132F5C)))
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Remaining Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('REMAINING', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.0)),
                  const SizedBox(height: 8),
                  Text('\$${remaining.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: const Color(0xFF132F5C),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Recent Entries Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Entries', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(4)),
                  child: Text(DateFormat('MMMM yyyy').format(DateTime.now()).toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF1E40AF))),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            if (budget.expenses.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text('No expenses recorded yet.', style: GoogleFonts.inter(color: Colors.grey)),
              ))
            else
              ...budget.expenses.reversed.map((e) => _buildEntryItem(e, budget)),
            
            const SizedBox(height: 24),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.expenseForm, arguments: {'budgetId': budget.id}),
        backgroundColor: const Color(0xFF132F5C).withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Future<void> _showAddBudgetDialog(BuildContext context, dynamic trip) async {
    final controller = TextEditingController(text: '1000');
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Start Budget for ${trip.destination}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount (\$)', prefixIcon: Icon(Icons.attach_money)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('START')),
        ],
      ),
    );

    if (result == true) {
      final amount = double.tryParse(controller.text) ?? 0;
      final bp = context.read<BudgetProvider>();
      final success = await bp.createBudget(BudgetModel(
        id: '',
        userId: '',
        tripId: trip.id,
        title: trip.destination,
        amount: amount,
      ));

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Budget created successfully!')));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create budget.')));
      }
    }
  }

  Widget _buildEntryItem(BudgetExpense expense, BudgetModel budget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.expenseForm, arguments: {'budgetId': budget.id, 'expense': expense}),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text('${DateFormat('MMM d, h:mm a').format(expense.date)}', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
                ],
              ),
            ),
            Text('\$${expense.amount.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => _handleDeleteExpense(budget, expense),
              child: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF991B1B)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEditBudgetLimit(BudgetModel budget) async {
    final controller = TextEditingController(text: budget.amount.toString());
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Total Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount (\$)', prefixIcon: Icon(Icons.attach_money)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('UPDATE')),
        ],
      ),
    );

    if (result == true) {
      final amount = double.tryParse(controller.text) ?? 0;
      final updatedBudget = budget.copyWith(amount: amount);
      await context.read<BudgetProvider>().updateBudget(budget.id, updatedBudget);
    }
  }

  Future<void> _handleDeleteExpense(BudgetModel budget, BudgetExpense expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text('This will permanently remove this entry.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('DELETE')),
        ],
      )
    );

    if (confirm == true) {
      final updatedExpenses = budget.expenses.where((e) => e.id != expense.id).toList();
      final updatedBudget = budget.copyWith(expenses: updatedExpenses);
      await context.read<BudgetProvider>().updateBudget(budget.id, updatedBudget);
    }
  }
}
