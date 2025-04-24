import 'package:expense_tracker_app_hive/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ExpenseDatabase extends ChangeNotifier {
  late Box<Expense> _expenseBox;
  bool _isInitialized =
      false; // Variable para controlar si la base de datos está inicializada

  // Constructor
  ExpenseDatabase() {
    _initialize();
  }

  // Inicializa la base de datos
  Future<void> _initialize() async {
    // Espera a que la caja de 'expenses' se abra antes de proceder
    _expenseBox = await Hive.openBox<Expense>('expenses');
    _isInitialized = true;
    notifyListeners(); // Notifica a los consumidores para que la UI se actualice
  }

  // Verifica si la base de datos está lista
  bool get isInitialized => _isInitialized;

  // Agregar un nuevo gasto a la base de datos
  Future<void> addExpense(Expense expense) async {
    // Asegúrate de que la base de datos está inicializada
    if (!_isInitialized) return; // Si no está inicializado, no haga nada

    await _expenseBox.add(expense);
    notifyListeners(); // Notifica a los consumidores para que la UI se actualice
  }

  // Obtener todos los gastos almacenados
  List<Expense> getAllExpenses() {
    // Asegúrate de que la base de datos esté inicializada
    if (!_isInitialized) return [];
    return _expenseBox.values.toList();
  }

  void readExpenses() {}

  updateExpense(int id, Expense updatedExpense) {}
}
