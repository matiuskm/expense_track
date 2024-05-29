import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];

  /*
  * S E T U P
  */

  // initialize the database
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  /*
  * G E T T E R S
  */

  List<Expense> get allExpenses => _allExpenses;

  /*
  * O P E R A T I O N S
  */

  // Create - add a new expense
  Future<void> addExpense(Expense expense) async {
    await isar.writeTxn(() => isar.expenses.put(expense));

    getExpenses();
  }

  // Read - expenses from db
  Future<void> getExpenses() async {
    // fetch all expenses from db
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    // update the list of expenses
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    // update UI
    notifyListeners();
  }

  // Update - update an expense
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    updatedExpense.id = id;

    await isar.writeTxn(() => isar.expenses.put(updatedExpense));

    getExpenses();
  }

  // Delete - delete an expense
  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));

    getExpenses();
  }

  /*
  * H E L P E R S
  */

  // calculate total expenses for a month
  Future<Map<String, double>> calculateMonthlyTotals() async {
    // ensure the expenses are read from the db
    await getExpenses();

    // create a map to hold the monthly totals
    Map<String, double> monthlyTotals = {};

    // loop through all expenses
    for (Expense expense in _allExpenses) {
      // get the month and year of the expense
      int month = expense.date.month;
      int year = expense.date.year;

      // create a key for the month and year
      String monthYear = '$year-$month';

      // add the expense amount to the total for the month
      if (monthlyTotals.containsKey(monthYear)) {
        monthlyTotals[monthYear] = monthlyTotals[monthYear]! + expense.amount;
      } else {
        monthlyTotals[monthYear] = expense.amount;
      }
    }

    return monthlyTotals;
  }

  // calculate current month total
  Future<double> calculateCurrentMonthTotal() async {
    // ensure to read from the db first
    await getExpenses();

    // get the current month and year
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    //filter the expenses for the current month and year
    List<Expense> currentMonthExpenses = _allExpenses
        .where((expense) =>
            expense.date.month == currentMonth &&
            expense.date.year == currentYear)
        .toList();

    // calculate the total for the current month
    double total =
        currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);

    // return the total for the current month
    return total;
  }

  // get start month
  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().month;
    }

    // sort expenses by date to find the earliest expense
    _allExpenses.sort((a, b) => a.date.compareTo(b.date));

    return _allExpenses.first.date.month;
  }

  // get start year
  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().year;
    }

    // sort expenses by date to find the earliest expense
    _allExpenses.sort((a, b) => a.date.compareTo(b.date));

    return _allExpenses.first.date.year;
  }
}
