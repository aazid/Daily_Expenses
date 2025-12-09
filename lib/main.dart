import 'package:expense_tracker/bloc/exense_event.dart';
import 'package:expense_tracker/bloc/expense_bloc.dart';
import 'package:expense_tracker/repo/expense_repository.dart';
import 'package:expense_tracker/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  final repo = ExpenseRepository();
  runApp(MyApp(repository: repo));
}

class MyApp extends StatelessWidget {
  final ExpenseRepository? repository;
  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (_) =>
              ExpenseBloc(repository ?? ExpenseRepository())
                ..add(LoadExpenses()),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Expense Tracker',
            theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
            home: child,
          ),
        );
      },
      child: SplashScreen(),
    );
  }
}
