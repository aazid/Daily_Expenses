import 'package:expense_tracker/bloc/exense_event.dart';
import 'package:expense_tracker/bloc/expense_bloc.dart';
import 'package:expense_tracker/bloc/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _budgetController = TextEditingController();
  final _dailyLimitController = TextEditingController();
  final _weeklyLimitController = TextEditingController();
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _currency = 'NPR';
  final formatter = NumberFormat.currency(symbol: "Npr ");

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _dailyLimitController.dispose();
    _weeklyLimitController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final state = context.read<ExpenseBloc>().state;

    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _currency = prefs.getString('currency') ?? 'NPR';
      _budgetController.text = state.monthlyLimit > 0
          ? state.monthlyLimit.toString()
          : '';
      _dailyLimitController.text = state.dailyLimit > 0
          ? state.dailyLimit.toString()
          : '';
      _weeklyLimitController.text = state.weeklyLimit > 0
          ? state.weeklyLimit.toString()
          : '';
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  void _showBudgetDialog() {
    final state = context.read<ExpenseBloc>().state;
    _budgetController.text = state.monthlyLimit > 0
        ? state.monthlyLimit.toString()
        : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.savings, color: Colors.blue[600], size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              'Set Monthly Budget',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Budget Amount',
                prefixText: _currency,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            if (state.monthlyLimit > 0)
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[600],
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Current: ${formatter.format(state.monthlyLimit)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          if (state.monthlyLimit > 0)
            TextButton(
              onPressed: () {
                context.read<ExpenseBloc>().add(SetBudgetLimit(0));
                Navigator.pop(context);
                _showSnackBar('Monthly budget removed successfully');
              },
              child: Text('Remove', style: TextStyle(color: Colors.red[600])),
            ),
          ElevatedButton(
            onPressed: () {
              final budget = double.tryParse(_budgetController.text);
              if (budget != null && budget > 0) {
                context.read<ExpenseBloc>().add(SetBudgetLimit(budget));
                Navigator.pop(context);
                _showSnackBar('Monthly budget updated successfully');
              } else {
                _showSnackBar('Please enter a valid amount', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDailyLimitDialog() {
    final state = context.read<ExpenseBloc>().state;
    _dailyLimitController.text = state.dailyLimit > 0
        ? state.dailyLimit.toString()
        : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.today, color: Colors.orange[600], size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              'Set Daily Limit',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _dailyLimitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Daily Limit Amount',
                prefixText: 'Npr ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            if (state.dailyLimit > 0)
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[600],
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Current: ${formatter.format(state.dailyLimit)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          if (state.dailyLimit > 0)
            TextButton(
              onPressed: () {
                context.read<ExpenseBloc>().add(SetDailyLimit(0));
                Navigator.pop(context);
                _showSnackBar('Daily limit removed successfully');
              },
              child: Text('Remove', style: TextStyle(color: Colors.red[600])),
            ),
          ElevatedButton(
            onPressed: () {
              final limit = double.tryParse(_dailyLimitController.text);
              if (limit != null && limit > 0) {
                context.read<ExpenseBloc>().add(SetDailyLimit(limit));
                Navigator.pop(context);
                _showSnackBar('Daily limit updated successfully');
              } else {
                _showSnackBar('Please enter a valid amount', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showWeeklyLimitDialog() {
    final state = context.read<ExpenseBloc>().state;
    _weeklyLimitController.text = state.weeklyLimit > 0
        ? state.weeklyLimit.toString()
        : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.date_range, color: Colors.purple[600], size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              'Set Weekly Limit',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _weeklyLimitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weekly Limit Amount',
                prefixText: 'Npr ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            if (state.weeklyLimit > 0)
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.purple[600],
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Current: ${formatter.format(state.weeklyLimit)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.purple[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          if (state.weeklyLimit > 0)
            TextButton(
              onPressed: () {
                context.read<ExpenseBloc>().add(SetWeeklyLimit(0));
                Navigator.pop(context);
                _showSnackBar('Weekly limit removed successfully');
              },
              child: Text('Remove', style: TextStyle(color: Colors.red[600])),
            ),
          ElevatedButton(
            onPressed: () {
              final limit = double.tryParse(_weeklyLimitController.text);
              if (limit != null && limit > 0) {
                context.read<ExpenseBloc>().add(SetWeeklyLimit(limit));
                Navigator.pop(context);
                _showSnackBar('Weekly limit updated successfully');
              } else {
                _showSnackBar('Please enter a valid amount', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red[600], size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              'Clear All Data',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete all expenses and reset your budget? This action cannot be undone.',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ExpenseBloc>().add(ClearAllExpenses());
              Navigator.pop(context);
              _showSnackBar('All data cleared successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                _buildProfileSection(),
                SizedBox(height: 24.h),

                // Budget Section
                _buildSectionTitle('Budget Management'),
                SizedBox(height: 12.h),
                _buildBudgetSection(state),
                SizedBox(height: 24.h),

                // App Preferences
                _buildSectionTitle('App Preferences'),
                SizedBox(height: 12.h),
                _buildPreferencesSection(),
                SizedBox(height: 24.h),

                // Data Management
                _buildSectionTitle('Data Management'),
                SizedBox(height: 12.h),
                _buildDataSection(state),
                SizedBox(height: 24.h),

                // About Section
                _buildSectionTitle('About'),
                SizedBox(height: 12.h),
                _buildAboutSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[400]!, Colors.blue[600]!],
          ),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            CircleAvatar(
              radius: 35.r,
              backgroundColor: Colors.white.withOpacity(0.3),
              child: Icon(Icons.person, size: 35.sp, color: Colors.white),
            ),
            SizedBox(height: 12.h),
            Text(
              'Expense Tracker',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Manage your finances smartly',
              style: TextStyle(fontSize: 14.sp, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildBudgetSection(ExpenseState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildSettingsTile(
              icon: Icons.savings,
              iconColor: Colors.green[600]!,
              iconBgColor: Colors.green[100]!,
              title: 'Monthly Budget',
              subtitle: state.monthlyLimit > 0
                  ? formatter.format(state.monthlyLimit)
                  : 'No budget set',
              trailing: Icon(Icons.edit, size: 20.sp, color: Colors.grey[400]),
              onTap: _showBudgetDialog,
            ),
            Divider(height: 1.h, color: Colors.grey[200]),
            _buildSettingsTile(
              icon: Icons.date_range,
              iconColor: Colors.purple[600]!,
              iconBgColor: Colors.purple[100]!,
              title: 'Weekly Limit',
              subtitle: state.weeklyLimit > 0
                  ? formatter.format(state.weeklyLimit)
                  : 'No limit set',
              trailing: Icon(Icons.edit, size: 20.sp, color: Colors.grey[400]),
              onTap: _showWeeklyLimitDialog,
            ),
            Divider(height: 1.h, color: Colors.grey[200]),
            _buildSettingsTile(
              icon: Icons.today,
              iconColor: Colors.orange[600]!,
              iconBgColor: Colors.orange[100]!,
              title: 'Daily Limit',
              subtitle: state.dailyLimit > 0
                  ? formatter.format(state.dailyLimit)
                  : 'No limit set',
              trailing: Icon(Icons.edit, size: 20.sp, color: Colors.grey[400]),
              onTap: _showDailyLimitDialog,
            ),
            if (state.monthlyLimit > 0) ...[
              Divider(height: 1.h, color: Colors.grey[200]),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Spent this month',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          formatter.format(state.monthlyTotal),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: state.overLimit
                                ? Colors.red[600]
                                : Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: (state.monthlyTotal / state.monthlyLimit).clamp(
                          0.0,
                          1.0,
                        ),
                        minHeight: 6.h,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          state.overLimit
                              ? Colors.red[400]!
                              : Colors.green[400]!,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.dark_mode,
            iconColor: Colors.purple[600]!,
            iconBgColor: Colors.purple[100]!,
            title: 'Dark Theme',
            subtitle: 'Switch to dark mode',
            value: _isDarkMode,
            onChanged: _toggleTheme,
          ),
          Divider(height: 1.h, color: Colors.grey[200]),
          _buildSwitchTile(
            icon: Icons.notifications,
            iconColor: Colors.orange[600]!,
            iconBgColor: Colors.orange[100]!,
            title: 'Notifications',
            subtitle: 'Get budget alerts',
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          Divider(height: 1.h, color: Colors.grey[200]),
          _buildSettingsTile(
            icon: Icons.attach_money,
            iconColor: Colors.blue[600]!,
            iconBgColor: Colors.blue[100]!,
            title: 'Currency',
            subtitle: 'Nepalese Rupee (NPR)',

            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(ExpenseState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.delete_sweep,
            iconColor: Colors.red[600]!,
            iconBgColor: Colors.red[100]!,
            title: 'Clear All Data',
            subtitle: 'Delete all expenses permanently',
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Colors.grey[400],
            ),
            onTap: _showClearDataDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Version',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
                ),
                Text(
                  '1.0.0',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Developer',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
                ),
                Text(
                  'Your Name',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: iconColor, size: 24.sp),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: iconColor, size: 24.sp),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: iconColor,
      ),
    );
  }
}
