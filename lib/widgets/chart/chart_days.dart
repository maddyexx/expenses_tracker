import 'package:flutter/material.dart';
import 'chart_bar_days.dart';
import '/models/expense.dart';
import 'package:intl/intl.dart';

class ChartWeekDays extends StatelessWidget {
  const ChartWeekDays({Key? key, required this.expenses});

  final List<Expense> expenses;

  int getTotalExpensesForWeekday(int weekday) {
    return expenses
        .where((expense) => expense.date.weekday == weekday)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  int getMaxTotalExpense() {
    int maxTotalExpense = 0;
    for (int i = 1; i <= 7; i++) {
      final int totalExpense = getTotalExpensesForWeekday(i);
      if (totalExpense > maxTotalExpense) {
        maxTotalExpense = totalExpense;
      }
    }
    return maxTotalExpense;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.fromLTRB(18, 20, 10, 0),
          child: Row(
            children: [
              Text(
                'Total Expenses: ',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton(
                child: Text(
                  '${getMaxTotalExpense()} Rs',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 8,
          ),
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.3),
                Theme.of(context).colorScheme.primary.withOpacity(0.0)
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (int i = 1; i <= 7; i++)
                      ChartBarWeekDays(
                        fill: getMaxTotalExpense() == 0
                            ? 0
                            : getTotalExpensesForWeekday(i) /
                                getMaxTotalExpense(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (int i = 1; i <= 7; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Center(
                          child: Text(
                            _getWeekDayName(i),
                            style: TextStyle(
                              color: isDarkMode
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getWeekDayName(int weekday) {
    return DateFormat.E().format(DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - weekday),
    ));
  }
}
