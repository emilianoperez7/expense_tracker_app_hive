import 'package:hive/hive.dart';

part 'expense.g.dart'; // Este archivo será generado por Hive

@HiveType(
    typeId: 0) // typeId debe ser único para cada clase que deseas almacenar
class Expense {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
  });
}
