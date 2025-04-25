import 'package:expense_tracker_app_hive/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ExpenseDatabase extends ChangeNotifier {
  late Box<Expense> _expenseBox;
  bool _isInitialized = false;
  List<Expense> _allExpenses = [];

  // Constructor
  ExpenseDatabase() {
    _initialize();
  }

  // Inicializa la base de datos
  Future<void> _initialize() async {
    _expenseBox = await Hive.openBox<Expense>('expenses');
    readExpenses();
    _isInitialized = true;
    notifyListeners();
  }

  bool get isInitialized => _isInitialized;

  // Leer todos los gastos y almacenarlos en _allExpenses
  void readExpenses() {
    if (!_isInitialized) return;
    _allExpenses = _expenseBox.values.toList();
    notifyListeners();
  }

  // Obtener todos los gastos
  List<Expense> getAllExpenses() {
    return _allExpenses;
  }

  // Agregar un nuevo gasto
  Future<void> addExpense(Expense expense) async {
    if (!_isInitialized) return;
    await _expenseBox.add(expense);
    readExpenses(); // ahora sí actualiza la lista y la UI
  }

  // Actualizar un gasto en un índice específico
  Future<void> updateExpense(int index, Expense updatedExpense) async {
    if (!_isInitialized || index < 0 || index >= _expenseBox.length) return;
    await _expenseBox.putAt(index, updatedExpense);
    readExpenses();
  }

  // Eliminar un gasto en un índice específico
  Future<void> deleteExpense(int index) async {
    if (!_isInitialized || index < 0 || index >= _expenseBox.length) return;
    await _expenseBox.deleteAt(index);
    readExpenses();
  }

  // Calcular el total mensual de todos los gastos
  Future<Map<String, double>> calculateMonthlyExpenses() async {
    if (!_isInitialized) return {};
    readExpenses();

    Map<String, double> monthlyTotals = {};

    for (var expense in _allExpenses) {
      String yearMonth =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlyTotals[yearMonth] =
          (monthlyTotals[yearMonth] ?? 0) + expense.amount;
    }

    return monthlyTotals;
  }

  // Calcular el total del mes actual
  Future<double> calculateCurrentMonthTotal() async {
    if (!_isInitialized) return 0;
    readExpenses();

    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    List<Expense> currentMonthExpenses = _allExpenses.where((expense) {
      return expense.date.year == currentYear &&
          expense.date.month == currentMonth;
    }).toList();

    double total =
        currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);
    return total;
  }

  // Obtener el primer mes con gastos
  int getStartMonth() {
    if (_allExpenses.isEmpty) return DateTime.now().month;
    _allExpenses.sort((a, b) => a.date.compareTo(b.date));
    return _allExpenses.first.date.month;
  }

  // Obtener el primer año con gastos
  int getStartYear() {
    if (_allExpenses.isEmpty) return DateTime.now().year;
    _allExpenses.sort((a, b) => a.date.compareTo(b.date));
    return _allExpenses.first.date.year;
  }
}
