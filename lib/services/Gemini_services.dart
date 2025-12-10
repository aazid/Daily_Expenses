import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/model/expense_model.dart';

class GeminiServices {
  final String _apiKey = 'AIzaSyBmIHCrQYCT60P8aJ7-JqJeg_1nzW6hE98';
  late final GenerativeModel? _model;

  GeminiServices() {
    try {
      _model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
      print('Gemini model initialized successfully');
    } catch (e) {
      print('Gemini model initialization failed: $e');
      print('Will use local analysis instead');
      _model = null;
    }
  }

  Future<String> getFinancialAdvice({
    required List<ExpenseModel> expenses,
    required double monthlyIncome,
    required double monthlyExpenses,
    required double dailyLimit,
    required double weeklyLimit,
    required double monthlyLimit,
    String? userQuestion,
  }) async {
    print('DEBUG: getFinancialAdvice called');
    print('DEBUG: _model is null? ${_model == null}');

    if (_model != null) {
      print('DEBUG: Attempting to use Gemini API');
      try {
        final result = await _getGeminiAdvice(
          expenses: expenses,
          monthlyIncome: monthlyIncome,
          monthlyExpenses: monthlyExpenses,
          dailyLimit: dailyLimit,
          weeklyLimit: weeklyLimit,
          monthlyLimit: monthlyLimit,
          userQuestion: userQuestion,
        );
        print('DEBUG: Successfully got Gemini response');
        return result;
      } catch (e) {
        print('DEBUG: Gemini API failed with error: $e');
        print('DEBUG: Falling back to local analysis');
      }
    } else {
      print('DEBUG: Model is null, using local analysis directly');
    }

    print('DEBUG: Using local analysis');
    return _getLocalAdvice(
      expenses: expenses,
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlyExpenses,
      dailyLimit: dailyLimit,
      weeklyLimit: weeklyLimit,
      monthlyLimit: monthlyLimit,
      userQuestion: userQuestion,
    );
  }

  Future<String> _getGeminiAdvice({
    required List<ExpenseModel> expenses,
    required double monthlyIncome,
    required double monthlyExpenses,
    required double dailyLimit,
    required double weeklyLimit,
    required double monthlyLimit,
    String? userQuestion,
  }) async {
    print('DEBUG: _getGeminiAdvice called');
    print('DEBUG: Model is null? ${_model == null}');
    print('DEBUG: Number of expenses: ${expenses.length}');
    print('DEBUG: User question: $userQuestion');

    final categoryBreakdown = <String, double>{};
    final recentExpenses = <String>[];

    for (var expense in expenses.where((e) => !e.isIncome)) {
      categoryBreakdown[expense.category] =
          (categoryBreakdown[expense.category] ?? 0) + expense.amount;

      if (recentExpenses.length < 10) {
        recentExpenses.add(
          '${DateFormat('MMM dd').format(expense.date)}: ${expense.title} - ${expense.category} - NPR ${expense.amount.toStringAsFixed(2)}',
        );
      }
    }

    final incomeTotal = expenses
        .where((e) => e.isIncome)
        .fold(0.0, (sum, e) => sum + e.amount);

    final savingRate = incomeTotal > 0
        ? ((incomeTotal - monthlyExpenses) / incomeTotal * 100).toStringAsFixed(
            1,
          )
        : '0';

    final categoryBreakdownStr = categoryBreakdown.entries
        .map((e) => '${e.key}: NPR ${e.value.toStringAsFixed(2)}')
        .join('\n');

    final timestamp = DateTime.now().toIso8601String();

    final promptText =
        '''
You are a personal financial advisor analyzing a user's expense tracking data.

FINANCIAL OVERVIEW (Analysis Time: $timestamp):
- Monthly Income: NPR ${incomeTotal.toStringAsFixed(2)}
- Monthly Expenses: NPR ${monthlyExpenses.toStringAsFixed(2)}
- Saving Rate: $savingRate%
- Daily Limit: NPR ${dailyLimit.toStringAsFixed(2)}
- Weekly Limit: NPR ${weeklyLimit.toStringAsFixed(2)}
- Monthly Limit: NPR ${monthlyLimit.toStringAsFixed(2)}

EXPENSE BREAKDOWN BY CATEGORY:
$categoryBreakdownStr

RECENT TRANSACTIONS (Last 10):
${recentExpenses.join('\n')}

${userQuestion != null ? '\nUSER QUESTION: $userQuestion\n' : ''}

Please provide:
1. A brief analysis of their spending patterns
2. Specific areas where they can save money
3. Personalized recommendations based on their data
4. Tips to improve their saving rate
${userQuestion != null ? '5. A direct answer to their question' : ''}

Keep the response conversational, encouraging, and actionable.
''';

    print('DEBUG: Prompt length: ${promptText.length} characters');
    print('DEBUG: Category breakdown: $categoryBreakdownStr');

    if (_model == null) {
      print('DEBUG: Model is NULL - returning error');
      return 'Gemini model not initialized. Please check your API key and internet connection.';
    }

    print('DEBUG: Calling Gemini API...');
    final content = [Content.text(promptText)];
    final response = await _model.generateContent(content);

    print('DEBUG: Got response from Gemini');
    print('DEBUG: Response text length: ${response.text?.length ?? 0}');
    print(
      'DEBUG: Response preview: ${response.text?.substring(0, response.text!.length > 100 ? 100 : response.text!.length)}...',
    );

    if (response.text != null && response.text!.isNotEmpty) {
      return response.text!;
    } else {
      print('DEBUG: Response was empty');
      return 'Unable to generate advice at this time. Please try again later.';
    }
  }

  String _getLocalAdvice({
    required List<ExpenseModel> expenses,
    required double monthlyIncome,
    required double monthlyExpenses,
    required double dailyLimit,
    required double weeklyLimit,
    required double monthlyLimit,
    String? userQuestion,
  }) {
    final categoryBreakdown = <String, double>{};

    for (var expense in expenses.where((e) => !e.isIncome)) {
      categoryBreakdown[expense.category] =
          (categoryBreakdown[expense.category] ?? 0) + expense.amount;
    }

    final incomeTotal = expenses
        .where((e) => e.isIncome)
        .fold(0.0, (sum, e) => sum + e.amount);

    final savingRate = incomeTotal > 0
        ? ((incomeTotal - monthlyExpenses) / incomeTotal * 100)
        : 0.0;

    final topCategory = categoryBreakdown.entries.isNotEmpty
        ? categoryBreakdown.entries.reduce((a, b) => a.value > b.value ? a : b)
        : null;

    final buffer = StringBuffer();
    buffer.writeln('Financial Analysis (Local AI Mode)\n');

    buffer.writeln('Your Financial Overview:');
    buffer.writeln('Monthly Income: NPR ${incomeTotal.toStringAsFixed(2)}');
    buffer.writeln(
      'Monthly Expenses: NPR ${monthlyExpenses.toStringAsFixed(2)}',
    );
    buffer.writeln('Saving Rate: ${savingRate.toStringAsFixed(1)}%\n');

    buffer.writeln('Spending Analysis:');
    if (topCategory != null) {
      final percentage = (topCategory.value / monthlyExpenses * 100)
          .toStringAsFixed(1);
      buffer.writeln(
        'Your biggest expense category is ${topCategory.key} (NPR ${topCategory.value.toStringAsFixed(2)}, $percentage% of total)',
      );
    }

    if (categoryBreakdown.length > 1) {
      buffer.writeln(
        'You\'re spending across ${categoryBreakdown.length} different categories',
      );
    }
    buffer.writeln('');

    buffer.writeln('Recommendations:');

    if (savingRate < 10) {
      buffer.writeln(
        'Your saving rate is quite low. Try to save at least 20% of your income.',
      );
    } else if (savingRate < 20) {
      buffer.writeln(
        'You\'re saving ${savingRate.toStringAsFixed(1)}%. Try to increase it to 20% or more!',
      );
    } else {
      buffer.writeln(
        'Excellent! You\'re saving ${savingRate.toStringAsFixed(1)}% of your income!',
      );
    }

    if (topCategory != null && topCategory.value > monthlyExpenses * 0.4) {
      buffer.writeln(
        'Consider reducing ${topCategory.key} expenses - they\'re taking up a large portion of your budget',
      );
    }

    if (monthlyExpenses > monthlyLimit && monthlyLimit > 0) {
      final overspend = monthlyExpenses - monthlyLimit;
      buffer.writeln(
        'You\'re NPR ${overspend.toStringAsFixed(2)} over your monthly budget limit',
      );
    }

    buffer.writeln(
      'Track daily expenses to stay within your NPR ${dailyLimit.toStringAsFixed(2)} daily limit',
    );
    buffer.writeln('Review and categorize all expenses regularly');
    buffer.writeln('Set up automatic savings transfers if possible\n');

    buffer.writeln('Quick Tips:');
    buffer.writeln('Use the 50/30/20 rule: 50% needs, 30% wants, 20% savings');
    buffer.writeln('Review subscriptions and recurring expenses');
    buffer.writeln('Plan meals to reduce food expenses');
    buffer.writeln('Compare prices before making purchases\n');

    if (userQuestion != null && userQuestion.isNotEmpty) {
      buffer.writeln('Regarding your question: "$userQuestion"');
      buffer.writeln(
        'Based on your data, focus on tracking expenses in your highest spending category and look for opportunities to reduce unnecessary costs.\n',
      );
    }

    buffer.writeln(
      'Note: This is a local analysis. For AI-powered insights, please check your Gemini API configuration.',
    );

    return buffer.toString();
  }

  Future<String> askQuestion(
    String question,
    List<ExpenseModel> expenses,
  ) async {
    if (_model != null) {
      try {
        final totalExpenses = expenses
            .where((e) => !e.isIncome)
            .fold(0.0, (sum, e) => sum + e.amount);

        final totalIncome = expenses
            .where((e) => e.isIncome)
            .fold(0.0, (sum, e) => sum + e.amount);

        final categoryBreakdown = <String, double>{};
        final recentExpenses = <String>[];

        for (var expense in expenses.where((e) => !e.isIncome)) {
          categoryBreakdown[expense.category] =
              (categoryBreakdown[expense.category] ?? 0) + expense.amount;

          if (recentExpenses.length < 10) {
            recentExpenses.add(
              '${DateFormat('MMM dd').format(expense.date)}: ${expense.title} - ${expense.category} - NPR ${expense.amount.toStringAsFixed(2)}',
            );
          }
        }

        final categoryBreakdownStr = categoryBreakdown.entries
            .map((e) => '${e.key}: NPR ${e.value.toStringAsFixed(2)}')
            .join('\n');

        final timestamp = DateTime.now().toIso8601String();

        final promptText =
            '''
You are a helpful financial assistant analyzing expense data.

FINANCIAL DATA (as of $timestamp):
- Total Income: NPR ${totalIncome.toStringAsFixed(2)}
- Total Expenses: NPR ${totalExpenses.toStringAsFixed(2)}
- Number of transactions: ${expenses.length}
- Net Savings: NPR ${(totalIncome - totalExpenses).toStringAsFixed(2)}

EXPENSE BREAKDOWN BY CATEGORY:
$categoryBreakdownStr

RECENT TRANSACTIONS (Last ${recentExpenses.length}):
${recentExpenses.join('\n')}

USER'S QUESTION: $question

Please provide a specific, personalized answer based on their actual expense data shown above. 
Reference specific categories, amounts, or patterns you see in their data.
Keep the response conversational and actionable.
''';

        final content = [Content.text(promptText)];
        final response = await _model.generateContent(content);

        if (response.text != null && response.text!.isNotEmpty) {
          return response.text!;
        }
      } catch (e) {
        print('Gemini API error: $e');
      }
    }

    return '''
Question: $question

Based on your expense data, here are some general tips:
- Review your spending categories regularly
- Set realistic budgets for each category
- Track daily expenses to avoid overspending
- Save at least 20% of your income

For more personalized advice, please check your Gemini API configuration.
''';
  }
}
