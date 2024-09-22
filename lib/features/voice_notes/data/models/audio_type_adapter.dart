import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:study_aid/features/voice_notes/data/models/audio_recording.dart';

class AudioRecordingModelAdapter extends TypeAdapter<AudioRecordingModel> {
  @override
  final int typeId = 4;

  @override
  AudioRecordingModel read(BinaryReader reader) {
    return AudioRecordingModel(
      id: reader.readString(),
      title: reader.readString(),
      color: Color(reader.readInt()), // Read as int and convert to Color
      tags: reader.readList().cast<String>(),
      createdDate: reader.read(),
      updatedDate: reader.read(),
      url: reader.readString(),
      localpath: reader.readString(),
      syncStatus: reader.readString(),
      localChangeTimestamp: reader.read(),
      remoteChangeTimestamp: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, AudioRecordingModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeInt(obj.color.value); // Store color as int
    writer.writeList(obj.tags);
    writer.write(obj.createdDate);
    writer.write(obj.updatedDate);
    writer.writeString(obj.url);
    writer.writeString(obj.localpath);
    writer.writeString(obj.syncStatus);
    writer.write(obj.localChangeTimestamp);
    writer.write(obj.remoteChangeTimestamp);
  }
}
