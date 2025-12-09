import 'package:expense_tracker/bloc/exense_event.dart';
import 'package:expense_tracker/bloc/expense_bloc.dart';
import 'package:expense_tracker/bloc/expense_state.dart';
import 'package:expense_tracker/screen/Add_expense_screen.dart';
import 'package:expense_tracker/screen/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: "Npr ");
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          // Calculate daily total
          final now = DateTime.now();
          final dailyTotal = state.expenses
              .where(
                (e) =>
                    !e.isIncome &&
                    e.date.year == now.year &&
                    e.date.month == now.month &&
                    e.date.day == now.day,
              )
              .fold(0.0, (sum, e) => sum + e.amount);

          // Calculate weekly total
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(Duration(days: 7));
          final weeklyTotal = state.expenses
              .where(
                (e) =>
                    !e.isIncome &&
                    e.date.isAfter(weekStart.subtract(Duration(days: 1))) &&
                    e.date.isBefore(weekEnd),
              )
              .fold(0.0, (sum, e) => sum + e.amount);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.h,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    "Expense Tracker",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black26,
                          offset: Offset(2.w, 2.h),
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: state.overLimit
                            ? [Colors.red[400]!, Colors.red[700]!]
                            : [Colors.blue[400]!, Colors.purple[600]!],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 80.sp,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.settings,
                      size: 24.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // Budget Overview Cards
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 240.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    children: [
                      // Daily Limit Card
                      if (state.dailyLimit > 0) ...[
                        SizedBox(
                          width: 280.w,
                          child: _buildLimitCard(
                            context: context,
                            title: "Today's Spending",
                            total: dailyTotal,
                            limit: state.dailyLimit,
                            icon: Icons.today,
                            colors: [Colors.orange[300]!, Colors.orange[500]!],
                            formatter: formatter,
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],

                      // Weekly Limit Card
                      if (state.weeklyLimit > 0) ...[
                        SizedBox(
                          width: 280.w,
                          child: _buildLimitCard(
                            context: context,
                            title: "This Week's Spending",
                            total: weeklyTotal,
                            limit: state.weeklyLimit,
                            icon: Icons.date_range,
                            colors: [Colors.purple[300]!, Colors.purple[500]!],
                            formatter: formatter,
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],

                      // Monthly Budget Card
                      if (state.monthlyLimit > 0)
                        SizedBox(
                          width: 280.w,
                          child: _buildLimitCard(
                            context: context,
                            title: "This Month's Spending",
                            total: state.monthlyTotal,
                            limit: state.monthlyLimit,
                            icon: Icons.calendar_month,
                            colors: state.overLimit
                                ? [Colors.red[300]!, Colors.red[400]!]
                                : [Colors.green[300]!, Colors.teal[400]!],
                            formatter: formatter,
                            showStatus: true,
                            isOverLimit: state.overLimit,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              if (state.expenses.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Transactions",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          "${state.expenses.length} items",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Expenses List
              if (state.expenses.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 100.sp,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "No Expenses Yet",
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Tap + to add your first expense",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final e = state.expenses[index];
                      return Dismissible(
                        key: Key(e.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20.w),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 32.sp,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Delete Expense'),
                                content: Text(
                                  'Are you sure you want to delete "${e.title}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          context.read<ExpenseBloc>().add(DeleteExpenses(e.id));
                        },
                        child: Card(
                          margin: EdgeInsets.only(bottom: 12.h),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  e.isIncome
                                      ? Colors.green[50]!
                                      : Colors.red[50]!,
                                ],
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 12.h,
                              ),
                              leading: CircleAvatar(
                                radius: 28.r,
                                backgroundColor: e.isIncome
                                    ? Colors.green[100]
                                    : Colors.red[100],
                                child: Icon(
                                  _getCategoryIcon(e.category),
                                  color: e.isIncome
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                  size: 28.sp,
                                ),
                              ),
                              title: Text(
                                e.title,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 6.h),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Text(
                                        e.category,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14.sp,
                                      color: Colors.grey[500],
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      DateFormat.MMMd().format(e.date),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${e.isIncome ? '+' : '-'}${formatter.format(e.amount)}",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: e.isIncome
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }, childCount: state.expenses.length),
                  ),
                ),

              // Bottom Padding
              SliverToBoxAdapter(child: SizedBox(height: 80.h)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          );
        },
        icon: Icon(Icons.add, size: 24.sp, color: Colors.white),
        label: Text(
          "Add Expense",
          style: TextStyle(fontSize: 16.sp, color: Colors.white),
        ),
        backgroundColor: Colors.blue[600],
      ),
    );
  }

  Widget _buildLimitCard({
    required BuildContext context,
    required String title,
    required double total,
    required double limit,
    required IconData icon,
    required List<Color> colors,
    required NumberFormat formatter,
    bool showStatus = false,
    bool isOverLimit = false,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  showStatus
                      ? (isOverLimit
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline)
                      : icon,
                  color: Colors.white,
                  size: 28.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    showStatus
                        ? (isOverLimit ? "Over Budget!" : "On Track")
                        : title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              formatter.format(total),
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "of ${formatter.format(limit)}",
              style: TextStyle(fontSize: 14.sp, color: Colors.white70),
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: (total / limit).clamp(0.0, 1.0),
                minHeight: 8.h,
                backgroundColor: Colors.white30,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'travel':
        return Icons.flight;
      case 'bills':
        return Icons.receipt;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }
}
