// Algunas funciones auxiliares para la aplicación
import 'package:intl/intl.dart';

// Convierte una cadena a tipo double
double convertStringtoDouble(String string) {
  // Convertir una cadena a un número decimal (double)
  double? amount = double.tryParse(string);
  return amount ?? 0.0; // Retorna 0.0 si la conversión falla
}

// Formatear el monto a pesos mexicanos (MXN) con el símbolo '$' y dos decimales
String formatAmount(double amount) {
  final format = NumberFormat.currency(
    locale: 'es_MX', // Localización para México
    symbol: '\$', // Símbolo de peso mexicano
    decimalDigits: 2, // Decimales a mostrar (centavos)
  );
  return format.format(amount); // Retorna el monto formateado
}

//calculate the number of months since the first month
int calculateMonthCount(int startYear, startMonth, currentYear, currentMonth) {
  int monthCount =
      (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
  return monthCount;
}

//get the current month name
String getCurrentMonthName() {
  DateTime now = DateTime.now();
  List<String> months = [
    'ENE',
    'FEB',
    'MAR',
    'ABR',
    'MAY',
    'JUN',
    'JUL',
    'AGO',
    'SEP',
    'OCT',
    'NOV',
    'DIC'
  ];
  return months[now.month - 1];
}
