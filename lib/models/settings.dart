import 'package:hive/hive.dart';

part 'settings.g.dart'; // Importación del archivo generado

@HiveType(typeId: 1) // Anotación CORRECTA para Hive
class Settings {
  @HiveField(0) // Campo anotado correctamente
  final bool darkMode;

  // Constructor corregido
  Settings({required this.darkMode});
}
