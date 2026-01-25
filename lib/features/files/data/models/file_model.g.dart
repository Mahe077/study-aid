// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FileModelAdapter extends TypeAdapter<FileModel> {
  @override
  final int typeId = 5;

  @override
  FileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FileModel(
      id: fields[1] as String,
      fileName: fields[2] as String,
      fileUrl: fields[3] as String,
      fileType: fields[4] as String,
      fileSizeBytes: fields[5] as int,
      uploadedDate: fields[6] as DateTime,
      updatedDate: fields[7] as DateTime,
      userId: fields[8] as String,
      topicId: fields[9] as String,
      relatedNoteId: fields[10] as String?,
      syncStatus: fields[11] as String,
      localChangeTimestamp: fields[12] as DateTime,
      remoteChangeTimestamp: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FileModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.fileUrl)
      ..writeByte(4)
      ..write(obj.fileType)
      ..writeByte(5)
      ..write(obj.fileSizeBytes)
      ..writeByte(6)
      ..write(obj.uploadedDate)
      ..writeByte(7)
      ..write(obj.updatedDate)
      ..writeByte(8)
      ..write(obj.userId)
      ..writeByte(9)
      ..write(obj.topicId)
      ..writeByte(10)
      ..write(obj.relatedNoteId)
      ..writeByte(11)
      ..write(obj.syncStatus)
      ..writeByte(12)
      ..write(obj.localChangeTimestamp)
      ..writeByte(13)
      ..write(obj.remoteChangeTimestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
