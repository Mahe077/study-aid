// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 3;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      id: fields[1] as String,
      title: fields[2] as String,
      color: fields[3] as Color,
      tags: (fields[4] as List).cast<String>(),
      createdDate: fields[5] as DateTime,
      updatedDate: fields[6] as DateTime,
      content: fields[7] as String,
      contentJson: fields[8] as String,
      syncStatus: fields[9] as String,
      localChangeTimestamp: fields[10] as DateTime,
      remoteChangeTimestamp: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.tags)
      ..writeByte(5)
      ..write(obj.createdDate)
      ..writeByte(6)
      ..write(obj.updatedDate)
      ..writeByte(7)
      ..write(obj.content)
      ..writeByte(8)
      ..write(obj.contentJson)
      ..writeByte(9)
      ..write(obj.syncStatus)
      ..writeByte(10)
      ..write(obj.localChangeTimestamp)
      ..writeByte(11)
      ..write(obj.remoteChangeTimestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}