// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TopicModelAdapter extends TypeAdapter<TopicModel> {
  @override
  final int typeId = 1;

  @override
  TopicModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TopicModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      color: fields[3] as Color,
      createdDate: fields[4] as DateTime,
      updatedDate: fields[5] as DateTime,
      subTopics: (fields[6] as List).cast<String>(),
      notes: (fields[7] as List).cast<String>(),
      audioRecordings: (fields[8] as List).cast<String>(),
      syncStatus: fields[9] as String,
      localChangeTimestamp: fields[10] as DateTime,
      remoteChangeTimestamp: fields[11] as DateTime,
      parentId: fields[12] as String,
      titleLowerCase: fields[13] as String,
      userId: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TopicModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.createdDate)
      ..writeByte(5)
      ..write(obj.updatedDate)
      ..writeByte(6)
      ..write(obj.subTopics)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.audioRecordings)
      ..writeByte(9)
      ..write(obj.syncStatus)
      ..writeByte(10)
      ..write(obj.localChangeTimestamp)
      ..writeByte(11)
      ..write(obj.remoteChangeTimestamp)
      ..writeByte(12)
      ..write(obj.parentId)
      ..writeByte(13)
      ..write(obj.titleLowerCase)
      ..writeByte(14)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopicModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
