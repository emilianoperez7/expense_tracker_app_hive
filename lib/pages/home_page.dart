import 'package:expense_tracker_app_hive/bar%20graph/bar_graph.dart';
import 'package:expense_tracker_app_hive/components/my_list_tile.dart';
import 'package:expense_tracker_app_hive/database/expense_database.dart';
import 'package:expense_tracker_app_hive/helper/helper_functions.dart';
import 'package:expense_tracker_app_hive/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  Future<Map<String, double>>? _monthlyTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    super.initState();
    // Solo refrescar data, ya que readExpenses no tiene uso en Hive
    refreshData();
  }

  void refreshData() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyExpenses();
    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateCurrentMonthTotal();
  }

  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Name"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: "Amount"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
            ),
          ],
        ),
        actions: [
          _cancelButton(),
          _createNewExpenseButton(),
        ],
      ),
    );
  }

  void openEditBox(Expense expense) {
    nameController.text = expense.name;
    amountController.text = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
            ),
          ],
        ),
        actions: [
          _cancelButton(),
          _editExpenseButton(expense),
        ],
      ),
    );
  }

  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Expense"),
        actions: [
          _cancelButton(),
          _deleteExpenseButton(expense.id),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {
        int startMonth = value.getStartMonth();
        int startYear = value.getStartYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;
        int monthCount = calculateMonthCount(
            startYear, startMonth, currentYear, currentMonth);

        List<Expense> allExpenses = value.getAllExpenses();
        List<Expense> currentMonthExpenses = allExpenses
            .where((expense) =>
                expense.date.year == currentYear &&
                expense.date.month == currentMonth)
            .toList();

        return Scaffold(
          backgroundColor: Colors.grey.shade300,
          floatingActionButton: FloatingActionButton(
            onPressed: openNewExpenseBox,
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: FutureBuilder<double>(
              future: _calculateCurrentMonthTotal,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${snapshot.data!.toStringAsFixed(2)}'),
                      Text(getCurrentMonthName()),
                    ],
                  );
                } else {
                  return const Text('Loading...');
                }
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: FutureBuilder(
                    future: _monthlyTotalsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, double> monthlyTotals = snapshot.data ?? {};
                        List<double> monthlySummary =
                            List.generate(monthCount, (index) {
                          int year = startYear + (startMonth + index - 1) ~/ 12;
                          int month = (startMonth + index - 1) % 12 + 1;
                          String yearMonthKey = '$year-$month';
                          return monthlyTotals[yearMonthKey] ?? 0.0;
                        });

                        return MyBarGraph(
                            monthlySummary: monthlySummary,
                            startMonth: startMonth);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentMonthExpenses.length,
                    itemBuilder: (context, index) {
                      int reversedIndex =
                          currentMonthExpenses.length - 1 - index;
                      Expense individualExpense =
                          currentMonthExpenses[reversedIndex];

                      return MyListTile(
                        title: individualExpense.name,
                        trailing: formatAmount(individualExpense.amount),
                        onEditPressed: (context) =>
                            openEditBox(individualExpense),
                        onDeletePressed: (context) =>
                            openDeleteBox(individualExpense),
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

  Widget _cancelButton() {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
        nameController.clear();
        amountController.clear();
      },
      child: const Text('Cancel'),
    );
  }

  Widget _createNewExpenseButton() {
    return TextButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          Navigator.pop(context);
          final expense = Expense(
            id: DateTime.now().millisecondsSinceEpoch,
            name: nameController.text,
            amount: convertStringtoDouble(amountController.text),
            date: DateTime.now(),
          );
          await context.read<ExpenseDatabase>().addExpense(expense);
          refreshData();
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }

  Widget _editExpenseButton(Expense expense) {
    return TextButton(
      onPressed: () async {
        Navigator.pop(context);
        final updatedExpense = Expense(
          id: expense.id,
          name: nameController.text.isNotEmpty
              ? nameController.text
              : expense.name,
          amount: amountController.text.isNotEmpty
              ? convertStringtoDouble(amountController.text)
              : expense.amount,
          date: DateTime.now(),
        );
        await context
            .read<ExpenseDatabase>()
            .updateExpense(expense.id, updatedExpense);
        refreshData();
      },
      child: const Text('Save'),
    );
  }

  Widget _deleteExpenseButton(int id) {
    return TextButton(
      onPressed: () async {
        Navigator.pop(context);
        await context.read<ExpenseDatabase>().deleteExpense(id);
        refreshData();
      },
      child: const Text('Delete'),
    );
  }
}
