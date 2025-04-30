import 'package:expense_tracker_app_hive/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ExpenseDatabase extends ChangeNotifier {
  late Box<Expense> _expenseBox;
  bool _isInitialized = false;
  List<Expense> _allExpenses = [];

  ExpenseDatabase() {
    _initialize();
  }

  Future<void> _initialize() async {
    _expenseBox = await Hive.openBox<Expense>('expenses');
    _allExpenses =
        _expenseBox.values.toList(); // Cargar inmediatamente los gastos
    _isInitialized = true;
    notifyListeners();
  }

  bool get isInitialized => _isInitialized;
  void readExpenses() {
    if (!_isInitialized) return;
    _allExpenses = _expenseBox.values.toList();
    notifyListeners();
  }

  List<Expense> getAllExpenses() {
    return _allExpenses;
  }

  Future<void> addExpense(Expense expense) async {
    if (!_isInitialized) return;
    await _expenseBox.add(expense);
    readExpenses();
  }

  Future<void> updateExpense(int id, Expense updatedExpense) async {
    if (!_isInitialized) return;

    final key = _findKeyById(id);
    if (key != null) {
      await _expenseBox.put(key, updatedExpense);
      readExpenses();
    }
  }

  Future<void> deleteExpense(int id) async {
    if (!_isInitialized) return;

    final key = _findKeyById(id);
    if (key != null) {
      await _expenseBox.delete(key);
      readExpenses();
    }
  }

  int? _findKeyById(int id) {
    final expenseMap = _expenseBox.toMap();
    for (var entry in expenseMap.entries) {
      if (entry.value.id == id) {
        return entry.key;
      }
    }
    return null;
  }

  Future<Map<String, double>> calculateMonthlyExpenses() async {
    if (!_isInitialized) return {};
    readExpenses();

    Map<String, double> monthlyTotals = {};

    for (var expense in _allExpenses) {
      String yearMonth = '${expense.date.year}-${expense.date.month}';

      if (!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = 0;
      }

      monthlyTotals[yearMonth] = (monthlyTotals[yearMonth]!) + expense.amount;
    }

    return monthlyTotals;
  }

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

  int getStartMonth() {
    if (_allExpenses.isEmpty) return DateTime.now().month;
    _allExpenses.sort((a, b) => a.date.compareTo(b.date));
    return _allExpenses.first.date.month;
  }

  int getStartYear() {
    if (_allExpenses.isEmpty) return DateTime.now().year;
    _allExpenses.sort((a, b) => a.date.compareTo(b.date));
    return _allExpenses.first.date.year;
  }
}
