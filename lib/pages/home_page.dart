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

  int selectedMonthIndex = DateTime.now().month - 1;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void refreshData() async {
    final db = Provider.of<ExpenseDatabase>(context, listen: false);
    while (!db.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    setState(() {
      _monthlyTotalsFuture = db.calculateMonthlyExpenses();
      _calculateCurrentMonthTotal = db.calculateCurrentMonthTotal();
    });
  }

  DateTime selectedDate = DateTime.now();

  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nuevo Gasto"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: "Nombre")),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: "Monto"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Fecha: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                ),
                TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(1980),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() => selectedDate = pickedDate);
                      Navigator.pop(
                          context); // cerrar y volver a abrir el diálogo
                      openNewExpenseBox(); // con fecha actualizada
                    }
                  },
                  child: const Text("Elegir Fecha"),
                ),
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
        title: const Text("Editar Gasto"),
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
        title: const Text("Borrar Gasto"),
        content: Text("¿Estás seguro de borrar: ${expense.name}?"),
        actions: [
          _cancelButton(),
          _deleteExpenseButton(expense),
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

        List<Expense> selectedMonthExpenses =
            value.getAllExpenses().where((expense) {
          return expense.date.month - 1 == selectedMonthIndex;
        }).toList();

        return Scaffold(
          backgroundColor: Colors.grey.shade300,
          floatingActionButton: FloatingActionButton(
            onPressed: openNewExpenseBox,
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: FutureBuilder<double>(
              future: _calculateCurrentMonthTotal,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  String currentMonth = (getCurrentMonthName());
                  String currentYear = (getCurrentYear().toString());
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${snapshot.data?.toStringAsFixed(2) ?? "0.00"}'),
                      Text("$currentMonth $currentYear"),
                    ],
                  );
                } else {
                  return const Text('Cargando...');
                }
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 220,
                  child: FutureBuilder(
                    future: _monthlyTotalsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, double> monthlyTotals = snapshot.data ?? {};
                        List<double> monthlySummary =
                            List.generate(monthCount, (index) {
                          int year = startYear + (startMonth + index - 1) ~/ 12;
                          int month = (startMonth + index - 1) % 12 + 1;
                          String yearMonthKey = '$year-${month.toString()}';
                          return monthlyTotals[yearMonthKey] ?? 0.0;
                        });

                        return MyBarGraph(
                          monthlySummary: monthlySummary,
                          startMonth: startMonth,
                          startYear: startYear,
                          onBarTap: (index) {
                            setState(() {
                              selectedMonthIndex =
                                  (startMonth + index - 1) % 12;
                            });
                          },
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedMonthExpenses.length,
                    itemBuilder: (context, index) {
                      int reversedIndex =
                          selectedMonthExpenses.length - 1 - index;
                      Expense individualExpense =
                          selectedMonthExpenses[reversedIndex];
                      return MyListTile(
                        title:
                            "${individualExpense.name} - ${individualExpense.date.day}/${individualExpense.date.month}/${individualExpense.date.year}",
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
      child: const Text('Cancelar'),
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
            date: selectedDate, // ✅ Usa la fecha elegida
          );
          await context.read<ExpenseDatabase>().addExpense(expense);
          refreshData();
          nameController.clear();
          amountController.clear();
          selectedDate = DateTime.now(); // ✅ Reiniciar para siguiente gasto
        }
      },
      child: const Text('Guardar'),
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
          date: expense.date,
        );
        await context
            .read<ExpenseDatabase>()
            .updateExpense(expense.id, updatedExpense);
        refreshData();
        nameController.clear();
        amountController.clear();
      },
      child: const Text('Guardar'),
    );
  }

  Widget _deleteExpenseButton(Expense expense) {
    return TextButton(
      onPressed: () async {
        Navigator.pop(context);
        await context.read<ExpenseDatabase>().deleteExpense(expense.id);
        refreshData();
      },
      child: const Text('Borrar', style: TextStyle(color: Colors.red)),
    );
  }
}
