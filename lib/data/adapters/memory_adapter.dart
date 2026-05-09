import 'package:hive/hive.dart';
import 'package:memorias_ancladas/data/models/memory_model.dart';

class MemoryAdapter extends TypeAdapter<Memory> {
  @override
  final int typeId = 0;

  @override
  Memory read(BinaryReader reader) {
    return Memory(
      id: reader.readString(),
      anchorImagePaths: reader.readList().cast<String>(),
      type: reader.readString(),
      content: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      imageHashes: reader.readList().cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Memory obj) {
    writer.writeString(obj.id);
    writer.writeList(obj.anchorImagePaths);
    writer.writeString(obj.type);
    writer.writeString(obj.content);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeList(obj.imageHashes);
  }
}