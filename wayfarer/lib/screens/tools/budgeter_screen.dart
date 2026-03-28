import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/trip_provider.dart';
import '../../models/trip_model.dart';
import '../../config/routes.dart';

class BudgeterScreen extends StatefulWidget {
  const BudgeterScreen({super.key});

  @override
  State<BudgeterScreen> createState() => _BudgeterScreenState();
}

class _BudgeterScreenState extends State<BudgeterScreen> {
  
  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TripProvider>();
    final trip = tp.upcomingTrip;

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Budgeter')),
        body: const Center(child: Text('No active trip found to track budget.')),
      );
    }

    final totalBudget = trip.budget.amount;
    final totalSpent = trip.expenses.fold<double>(0, (sum, item) => sum + item.amount);
    final remaining = totalBudget - totalSpent;
    final progress = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final dailyAvg = trip.expenses.isEmpty ? 0.0 : totalSpent / trip.durationDays.clamp(1, 365);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2E46))),
        title: Text('Trip Budget', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: const Color(0xFF1E2E46))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CURRENT TRIP BUDGET', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text('\$${totalBudget.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), height: 1.0)),
            const SizedBox(height: 8),
            Text('Total allocation for ${trip.destination}', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
            
            const SizedBox(height: 32),
            
            // Remaining Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('REMAINING', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.0)),
                      Text('${(progress * 100).toStringAsFixed(0)}% USED', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: progress > 0.9 ? Colors.red : const Color(0xFF1E40AF))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('\$${remaining.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: remaining < 0 ? Colors.red : const Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF1F5F9),
                      color: progress > 0.9 ? Colors.red : const Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Daily Average Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Average', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                  const SizedBox(height: 12),
                  Text('\$${dailyAvg.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFF1E40AF))),
                  const SizedBox(height: 4),
                  Text('Average spending per day across ${trip.durationDays} days.', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Recent Entries
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Entries', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(4)),
                  child: Text('LOGBOOK', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF1E40AF))),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            if (trip.expenses.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text('No expenses recorded yet.', style: GoogleFonts.inter(color: Colors.grey)),
              ))
            else
              ...trip.expenses.reversed.map((e) => _buildEntryItem(e, trip)),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.expenseForm, arguments: {'tripId': trip.id}),
        backgroundColor: const Color(0xFF0F172A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEntryItem(TripExpense expense, TripModel trip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.receipt_long, color: Color(0xFF64748B), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text(DateFormat('MMM d, h:mm a').format(expense.date), style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${expense.amount.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.expenseForm, arguments: {'tripId': trip.id, 'expense': expense}),
                      child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _handleDeleteExpense(trip, expense),
                      child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFF991B1B)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDeleteExpense(TripModel trip, TripExpense expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Remove this entry from your travel budget?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final updatedExpenses = trip.expenses.where((e) => e.id != expense.id).toList();
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
      await context.read<TripProvider>().updateTrip(trip.id, updatedTrip);
    }
  }
}
