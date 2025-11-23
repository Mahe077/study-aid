import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:study_aid/features/topics/data/models/topic.dart';

class TopicModelAdapter extends TypeAdapter<TopicModel> {
  @override
  final int typeId = 1;

  @override
  TopicModel read(BinaryReader reader) {
    return TopicModel(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
      color: Color(reader.readInt()), // Read as int and convert to Color
      createdDate: reader.read(),
      updatedDate: reader.read(),
      subTopics: reader.readList().cast<String>(),
      notes: reader.readList().cast<String>(),
      audioRecordings: reader.readList().cast<String>(),
      syncStatus: reader.readString(),
      localChangeTimestamp: reader.read(),
      remoteChangeTimestamp: reader.read(),
      parentId: reader.readString(),
      titleLowerCase: reader.readString(),
      userId: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, TopicModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeInt(obj.color.value); // Store color as int
    writer.write(obj.createdDate);
    writer.write(obj.updatedDate);
    writer.writeList(obj.subTopics);
    writer.writeList(obj.notes);
    writer.writeList(obj.audioRecordings);
    writer.writeString(obj.syncStatus);
    writer.write(obj.localChangeTimestamp);
    writer.write(obj.remoteChangeTimestamp);
    writer.writeString(obj.parentId);
    writer.writeString(obj.titleLowerCase);
    writer.writeString(obj.userId);
  }
}
