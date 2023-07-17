import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../widgets/chart/chart.dart';
import '../widgets/chart/chart_days.dart';
import 'package:expenses_tracker/widgets/expenses_list/expenses_list.dart';
import '../widgets/new_expenses.dart';
import 'package:expenses_tracker/widgets/expenses_list/expense_database.dart';

class Expenses extends StatefulWidget {
  const Expenses({Key? key}) : super(key: key);

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _registeredExpenses = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    final expenses = await ExpenseDatabase.getExpenses();
    setState(() {
      _registeredExpenses.addAll(expenses);
    });
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return NewExpense(onAddExpense: _addExpense);
      },
    );
  }

  Future<void> _addExpense(Expense expense) async {
    await ExpenseDatabase.insertExpense(expense);
    setState(() {
      _registeredExpenses.add(expense);
    });
  }

  Future<void> _removeExpense(Expense expense) async {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.removeAt(expenseIndex);
    });
    await ExpenseDatabase.deleteExpense(expense.id);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Expense Deleted!'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await ExpenseDatabase.insertExpense(expense);
            setState(() {
              _registeredExpenses.insert(expenseIndex, expense);
            });
          },
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear List'),
          content: const Text('Are you sure you want to clear the list?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                removeAllExpenses(); // Call the function to remove all expenses
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void removeAllExpenses() async {
    // Remove all expenses from the database
    await ExpenseDatabase.deleteAllExpenses();

    // Clear the registered expenses list
    setState(() {
      _registeredExpenses.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget mainContent = const Center(
      child: Text('No expenses found. Start Adding Some'),
    );

    if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpenseList(
        expenses: _registeredExpenses,
        onRemoveExpense: _removeExpense,
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Expense Tracker App'),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _showConfirmationDialog(); // Show a confirmation dialog before clearing the list
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'clear',
                child: Text('Clear List'),
              ),
            ],
          ),
        ],
      ),
      body: width < 600
          ? Column(
              children: [
                ChartWeekDays(expenses: _registeredExpenses),
                Chart(expenses: _registeredExpenses),
                Center(
                  child: Text(
                    'Digital Wellbeing'.toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge,
                    selectionColor: Colors.blue,
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: mainContent,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Chart(expenses: _registeredExpenses),
                ),
                Expanded(
                  child: mainContent,
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpenseOverlay,
        child: const Icon(Icons.add),
      ),
    );
  }
}
