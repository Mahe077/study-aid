import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:study_aid/features/notes/data/models/note.dart';

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 3;

  @override
  NoteModel read(BinaryReader reader) {
    return NoteModel(
      id: reader.readString(),
      title: reader.readString(),
      color: Color(reader.readInt()), // Read as int and convert to Color
      tags: reader.readList().cast<String>(),
      createdDate: reader.read(),
      updatedDate: reader.read(),
      content: reader.readString(),
      contentJson: reader.readString(),
      syncStatus: reader.readString(),
      localChangeTimestamp: reader.read(),
      remoteChangeTimestamp: reader.read(),
      parentId: reader.readString(),
      titleLowerCase: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeInt(obj.color.value); // Store color as int
    writer.writeList(obj.tags);
    writer.write(obj.createdDate);
    writer.write(obj.updatedDate);
    writer.writeString(obj.content);
    writer.writeString(obj.contentJson);
    writer.writeString(obj.syncStatus);
    writer.write(obj.localChangeTimestamp);
    writer.write(obj.remoteChangeTimestamp);
    writer.writeString(obj.parentId);
    writer.writeString(obj.titleLowerCase);
  }
}
