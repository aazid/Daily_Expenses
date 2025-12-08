import 'package:expense_tracker/bloc/exense_event.dart';
import 'package:expense_tracker/bloc/expense_bloc.dart';
import 'package:expense_tracker/model/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = "Food";
  bool _isIncome = false;
  DateTime _date = DateTime.now();

  final _uuid = Uuid();
  final List<String> _categories = [
    "Food",
    "Travel",
    "Bills",
    "Shopping",
    "Entertainment",
    "Healthcare",
    "Others",
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Gradient App Bar
          SliverAppBar(
            expandedHeight: 120.h,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Add Transaction',
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
                    colors: _isIncome
                        ? [Colors.green[400]!, Colors.teal[600]!]
                        : [Colors.blue[400]!, Colors.purple[600]!],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _isIncome ? Icons.trending_up : Icons.trending_down,
                    size: 60.sp,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

          // Form Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Income/Expense Toggle Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          gradient: LinearGradient(
                            colors: _isIncome
                                ? [Colors.green[50]!, Colors.green[100]!]
                                : [Colors.red[50]!, Colors.red[100]!],
                          ),
                        ),
                        child: SwitchListTile(
                          title: Row(
                            children: [
                              Icon(
                                _isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: _isIncome
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                size: 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                _isIncome ? "Income" : "Expense",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: _isIncome
                                      ? Colors.green[800]
                                      : Colors.red[800],
                                ),
                              ),
                            ],
                          ),
                          value: _isIncome,
                          activeColor: Colors.green[700],
                          onChanged: (v) => setState(() => _isIncome = v),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Title Field
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: "Title",

                            prefixIcon: Icon(
                              Icons.title,
                              color: Colors.purple[600],
                              size: 24.sp,
                            ),
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple[600],
                            ),
                          ),
                          style: TextStyle(fontSize: 16.sp),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Please enter a title'
                              : null,
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: "Amount",
                            hintText: "0.00",
                            prefixIcon: Icon(
                              Icons.attach_money,
                              color: Colors.green[600],
                              size: 24.sp,
                            ),
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[600],
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Please enter amount';
                            if (double.tryParse(v) == null)
                              return 'Please enter valid number';
                            return null;
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 4.h,
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _category,
                          decoration: InputDecoration(
                            labelText: "Category",
                            prefixIcon: Icon(
                              _getCategoryIcon(_category),
                              color: Colors.orange[600],
                              size: 24.sp,
                            ),
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange[600],
                            ),
                          ),
                          items: _categories
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getCategoryIcon(c),
                                        size: 20.sp,
                                        color: Colors.grey[700],
                                      ),
                                      SizedBox(width: 12.w),
                                      Text(
                                        c,
                                        style: TextStyle(fontSize: 16.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _category = v!),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                        leading: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: Colors.blue[700],
                            size: 24.sp,
                          ),
                        ),
                        title: Text(
                          "Date",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(_date),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16.sp,
                          color: Colors.grey[400],
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.purple[600]!,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) setState(() => _date = picked);
                        },
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Save Button
                    Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple[400]!, Colors.purple[700]!],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.4),
                            blurRadius: 12,
                            offset: Offset(0, 6.h),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _saveExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 24.sp,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Save Transaction',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final expense = ExpenseModel(
        amount: double.parse(_amountController.text),
        category: _category,
        date: _date,
        id: _uuid.v4(),
        isIncome: _isIncome,
        title: _titleController.text,
      );
      context.read<ExpenseBloc>().add(AddExpenses(expense));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Text(
                'Transaction saved successfully!',
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );

      Navigator.pop(context);
    }
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
      case 'entertainment':
        return Icons.movie;
      case 'healthcare':
        return Icons.local_hospital;
      default:
        return Icons.category;
    }
  }
}
