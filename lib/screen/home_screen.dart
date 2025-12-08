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

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: state.overLimit
                              ? [Colors.red[300]!, Colors.red[400]!]
                              : [Colors.green[300]!, Colors.teal[400]!],
                        ),
                      ),
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                state.overLimit
                                    ? Icons.warning_amber_rounded
                                    : Icons.check_circle_outline,
                                color: Colors.white,
                                size: 32.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  state.overLimit ? "Over Budget!" : "On Track",
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            "This Month's Total",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            formatter.format(state.monthlyTotal),
                            style: TextStyle(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Divider(color: Colors.white38),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Budget Limit",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                formatter.format(state.monthlyLimit),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          if (state.monthlyLimit > 0) ...[
                            SizedBox(height: 12.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: LinearProgressIndicator(
                                value: (state.monthlyTotal / state.monthlyLimit)
                                    .clamp(0.0, 1.0),
                                minHeight: 8.h,
                                backgroundColor: Colors.white30,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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
