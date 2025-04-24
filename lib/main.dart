import 'package:expense_tracker_app_hive/database/expense_database.dart';
import 'package:expense_tracker_app_hive/models/expense.dart';
import 'package:expense_tracker_app_hive/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
// Asegúrate de que este archivo esté correctamente importado

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive y abre la caja de Expense
  await Hive.initFlutter();
  Hive.registerAdapter(
      ExpenseAdapter()); // Registra el adaptador para la clase Expense
  await Hive.openBox<Expense>('expenses'); // Abre la caja

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ExpenseDatabase(),
        ),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(), // Aquí se pasa la HomePage como pantalla principal
      ),
    );
  }
}
