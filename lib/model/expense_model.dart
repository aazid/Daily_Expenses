import 'dart:convert';

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isIncome;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isIncome,
  });

  // Convert DateTime to String when saving
  String toJson() {
    return jsonEncode({
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(), // ✅ Convert DateTime to String
      'isIncome': isIncome,
    });
  }

  // Parse String back to DateTime when loading
  factory ExpenseModel.fromJson(String jsonString) {
    final map = jsonDecode(jsonString);
    return ExpenseModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']), // ✅ Convert String back to DateTime
      isIncome: map['isIncome'],
    );
  }

  // Alternative: toMap and fromMap methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'isIncome': isIncome,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      isIncome: map['isIncome'],
    );
  }
}
