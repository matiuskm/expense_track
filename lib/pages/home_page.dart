import 'package:expense_tracker/bar_graph/bar_graph.dart';
import 'package:expense_tracker/components/my_list_tile.dart';
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/helpers/helper_functions.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text controllers
  TextEditingController _nameController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

  // futures to hold graph data & monthly total
  Future<Map<String, double>>? _monthlyTotalFuture;
  Future<double>? _calculateMonthlyTotalFuture;

  @override
  void initState() {
    // read db on initial startup
    Provider.of<ExpenseDatabase>(context, listen: false).getExpenses();

    // refresh graph data
    refreshData();

    super.initState();
  }

  void refreshData() {
    _monthlyTotalFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotals();
    _calculateMonthlyTotalFuture =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateCurrentMonthTotal();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // open new expense box
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // user iput -> expense name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Name'),
            ),

            // user input -> expense amount
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(hintText: 'Amount'),
            ),
          ],
        ),
        actions: [
          // cancel button
          _cancelButton(),
          // save button
          _saveButton(),
        ],
      ),
    );
  }

  // open edit box
  void openEditBox(Expense expense) {
    // pre-fill the existing values to textfields
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // user iput -> expense name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: existingName),
            ),

            // user input -> expense amount
            TextField(
              controller: _amountController,
              decoration: InputDecoration(hintText: existingAmount),
            ),
          ],
        ),
        actions: [
          // cancel button
          _cancelButton(),
          // edit button
          _editButton(expense),
        ],
      ),
    );
  }

  // open delete box
  void openDeleteBox(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete expense?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
        ),
        actions: [
          // cancel button
          _cancelButton(),
          // edit button
          _deleteButton(id),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {
        // get dates
        int startMonth = value.getStartMonth();
        int startYear = value.getStartYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;

        // calculate the number of months since the start month
        int monthCount = calculateMonthCount(
          startYear,
          startMonth,
          currentYear,
          currentMonth,
        );

        // only display expenses for curent month
        List<Expense> currentMonthExpenses = value.allExpenses
            .where((expense) =>
                expense.date.month == currentMonth &&
                expense.date.year == currentYear)
            .toList();

        // return UI
        return Scaffold(
          backgroundColor: Colors.grey.shade300,
          floatingActionButton: FloatingActionButton(
            onPressed: openNewExpenseBox,
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: FutureBuilder<double>(
                future: _calculateMonthlyTotalFuture,
                builder: (context, snapshot) {
                  // loaded
                  if (snapshot.connectionState == ConnectionState.done) {
                    // return the title
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // amount total
                        Text(
                          formatAmount(snapshot.data ?? 0),
                        ),
                        Text(getCurrentMonthName()),
                      ],
                    );
                  }

                  // loading
                  return const Center(child: CircularProgressIndicator());
                }),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // GRAPH UI
                SizedBox(
                  height: 300,
                  child: FutureBuilder(
                    future: _monthlyTotalFuture,
                    builder: (context, snapshot) {
                      // data is loaded
                      if (snapshot.connectionState == ConnectionState.done) {
                        // get the data
                        Map<String, double> monthlyTotals = snapshot.data ?? {};

                        // create a list of monthly totals
                        List<double> monthlySummary = List.generate(
                          monthCount,
                          (index) {
                            // calculate year-month considering startMonth & index
                            int year =
                                startYear + (startMonth + index - 1) ~/ 12;
                            int month = (startMonth + index - 1) % 12 + 1;

                            // create a key for the month and year
                            String monthYear = '$year-$month';

                            // get the total for the month
                            return monthlyTotals[monthYear] ?? 0;
                          },
                        );

                        // return the graph
                        return MyBarGraph(
                          monthlySummary: monthlySummary,
                          startMonth: startMonth,
                        );
                      }

                      // loading..
                      else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),

                // EXPENSE LIST UI
                Expanded(
                  child: ListView.builder(
                    itemCount: currentMonthExpenses.length,
                    itemBuilder: (context, index) {
                      // reverse the list to get the latest item first
                      int reversedIndex =
                          currentMonthExpenses.length - 1 - index;

                      // get individual expense
                      Expense individualExpense =
                          currentMonthExpenses[reversedIndex];

                      // return list tile UI
                      return MyListTile(
                        title: individualExpense.name,
                        date: DateFormat('d-MMM-y')
                            .format(individualExpense.date),
                        trailing: formatAmount(individualExpense.amount),
                        onEditPressed: (context) =>
                            openEditBox(individualExpense),
                        onDeletePressed: (context) =>
                            openDeleteBox(individualExpense.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // cancel button
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        // pop box
        Navigator.pop(context);

        // clear controllers
        _nameController.clear();
        _amountController.clear();
      },
      child: const Text('Cancel'),
    );
  }

  // save button
  Widget _saveButton() {
    return MaterialButton(
      onPressed: () async {
        // only save if there is something in the textfields to save
        if (_nameController.text.isNotEmpty &&
            _amountController.text.isNotEmpty) {
          // pop box
          Navigator.pop(context);

          // create a new expense
          final Expense newExpense = Expense(
            name: _nameController.text,
            amount: stringToDouble(_amountController.text),
            date: DateTime.now(),
          );

          // save the new expense
          await context.read<ExpenseDatabase>().addExpense(newExpense);
        }

        // refresh bar graph data
        refreshData();

        // clear controllers
        _nameController.clear();
        _amountController.clear();
      },
      child: const Text('Save'),
    );
  }

  // save button -> edit box
  Widget _editButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        // only save if there is something in the textfields to save
        if (_nameController.text.isNotEmpty ||
            _amountController.text.isNotEmpty) {
          // pop box
          Navigator.pop(context);

          // create a new expense
          final Expense updatedExpense = Expense(
            name: _nameController.text.isNotEmpty
                ? _nameController.text
                : expense.name,
            amount: _amountController.text.isNotEmpty
                ? stringToDouble(_amountController.text)
                : expense.amount,
            date: DateTime.now(),
          );

          int existingId = expense.id;

          // save the new expense
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);
        }

        // refresh bar graph data
        refreshData();

        // clear controllers
        _nameController.clear();
        _amountController.clear();
      },
      child: const Text('Edit'),
    );
  }

  Widget _deleteButton(int id) {
    return MaterialButton(
      onPressed: () async {
        // pop box
        Navigator.pop(context);

        // delete the expense
        await context.read<ExpenseDatabase>().deleteExpense(id);

        // refresh bar graph data
        refreshData();
      },
      child: const Text('Delete'),
    );
  }
}
