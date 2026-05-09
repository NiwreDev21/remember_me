import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:memorias_ancladas/core/constants/app_constants.dart';
import 'package:memorias_ancladas/data/models/memory_model.dart';
import 'package:memorias_ancladas/data/services/hash_service.dart';

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
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Obtener memoria por ID
  Memory? getMemoryById(String id) {
    return _memoriesBox.get(id);
  }

  // Eliminar memoria
  Future<void> deleteMemory(String id) async {
    final memory = _memoriesBox.get(id);
    if (memory != null) {
      // Eliminar todas las imágenes ancla
      for (final path in memory.anchorImagePaths) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Eliminar contenido adicional
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

  // Guardar múltiples imágenes
  static Future<List<String>> saveMultipleImages(List<File> images, String prefix) async {
    List<String> savedPaths = [];
    for (int i = 0; i < images.length; i++) {
      final path = await saveImageLocally(images[i], '${prefix}_$i');
      savedPaths.add(path);
    }
    return savedPaths;
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

  // Buscar recuerdo por similitud de imagen
  Future<Memory?> findSimilarMemory(File scannedImage) async {
    try {
      // Guardar imagen temporal escaneada
      final tempPath = await saveImageLocally(scannedImage, 'scan_temp');

      // Generar hash de la imagen escaneada
      final scannedHash = await HashService.generateImageHash(tempPath);

      // Eliminar imagen temporal
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      if (scannedHash.isEmpty) return null;

      // Obtener todos los recuerdos
      final memories = getAllMemories();
      if (memories.isEmpty) return null;

      // Buscar mejor coincidencia
      final result = HashService.findBestMatch(scannedHash, memories);

      // Solo retornar si es una coincidencia válida
      if (result.isMatch) {
        return result.memory;
      }

      return null;

    } catch (e) {
      print('Error en findSimilarMemory: $e');
      return null;
    }
  }
}