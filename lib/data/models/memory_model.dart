import 'package:hive/hive.dart';

enum MemoryType {
  text,
  image,
  video,
}

@HiveType(typeId: 0)
class Memory {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String anchorImagePath; // Foto del objeto físico

  @HiveField(2)
  final String type; // Guardar como String

  @HiveField(3)
  final String content; // Texto o ruta de imagen/video

  @HiveField(4)
  final DateTime createdAt;

  Memory({
    required this.id,
    required this.anchorImagePath,
    required this.type,
    required this.content,
    required this.createdAt,
  });

  // Constructor usando enum
  factory Memory.fromEnum({
    required String id,
    required String anchorImagePath,
    required MemoryType memoryType,
    required String content,
    required DateTime createdAt,
  }) {
    String typeString;
    switch (memoryType) {
      case MemoryType.text:
        typeString = 'text';
        break;
      case MemoryType.image:
        typeString = 'image';
        break;
      case MemoryType.video:
        typeString = 'video';
        break;
    }
    return Memory(
      id: id,
      anchorImagePath: anchorImagePath,
      type: typeString,
      content: content,
      createdAt: createdAt,
    );
  }

  // Getter para obtener enum
  MemoryType get memoryType {
    switch (type) {
      case 'text':
        return MemoryType.text;
      case 'image':
        return MemoryType.image;
      case 'video':
        return MemoryType.video;
      default:
        return MemoryType.text;
    }
  }

  String get previewText {
    if (memoryType == MemoryType.text) {
      return content.length > 50 ? '${content.substring(0, 50)}...' : content;
    }
    return memoryType == MemoryType.image ? '📷 Imagen' : '🎥 Video';
  }
}