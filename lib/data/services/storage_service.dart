import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:memorias_ancladas/core/constants/app_constants.dart';
import 'package:memorias_ancladas/data/models/memory_model.dart';

class StorageService {
  late Box<Memory> _memoriesBox;

  Future<void> init() async {
    _memoriesBox = Hive.box<Memory>(AppConstants.memoriesBox);
  }

  // Guardar memoria
  Future<void> saveMemory(Memory memory) async {
    await _memoriesBox.put(memory.id, memory);
  }

  // Obtener todas las memorias
  List<Memory> getAllMemories() {
    return _memoriesBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Más reciente primero
  }

  // Obtener memoria por ID
  Memory? getMemoryById(String id) {
    return _memoriesBox.get(id);
  }

  // Eliminar memoria
  Future<void> deleteMemory(String id) async {
    final memory = _memoriesBox.get(id);
    if (memory != null) {
      // Eliminar archivos asociados
      if (memory.memoryType != MemoryType.text && memory.content.isNotEmpty) {
        final file = File(memory.content);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await _memoriesBox.delete(id);
    }
  }

  // Guardar imagen localmente
  static Future<String> saveImageLocally(File imageFile, String prefix) async {
    final directory = await getApplicationDocumentsDirectory();
    final memoriesDir = Directory('${directory.path}/${AppConstants.memoriesDir}');

    if (!await memoriesDir.exists()) {
      await memoriesDir.create();
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${prefix}_$timestamp.jpg';
    final filePath = '${memoriesDir.path}/$fileName';

    await imageFile.copy(filePath);
    return filePath;
  }

  // Obtener imagen desde ruta
  static Future<File?> getImageFromPath(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}