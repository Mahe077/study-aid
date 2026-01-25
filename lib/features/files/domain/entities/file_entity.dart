import 'package:study_aid/core/utils/helpers/custome_types.dart';

class FileEntity extends BaseEntity {
  @override
  final String id;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSizeBytes;
  final DateTime uploadedDate;
  @override
  final DateTime updatedDate;
  final String userId;
  final String topicId;
  final String? relatedNoteId;
  final String syncStatus;
  final DateTime localChangeTimestamp;
  final DateTime remoteChangeTimestamp;

  FileEntity({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSizeBytes,
    required this.uploadedDate,
    required this.updatedDate,
    required this.userId,
    required this.topicId,
    this.relatedNoteId,
    required this.syncStatus,
    required this.localChangeTimestamp,
    required this.remoteChangeTimestamp,
  });

  FileEntity copyWith({
    String? id,
    String? fileName,
    String? fileUrl,
    String? fileType,
    int? fileSizeBytes,
    DateTime? uploadedDate,
    DateTime? updatedDate,
    String? userId,
    String? topicId,
    String? relatedNoteId,
    String? syncStatus,
    DateTime? localChangeTimestamp,
    DateTime? remoteChangeTimestamp,
  }) {
    return FileEntity(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      uploadedDate: uploadedDate ?? this.uploadedDate,
      updatedDate: updatedDate ?? this.updatedDate,
      userId: userId ?? this.userId,
      topicId: topicId ?? this.topicId,
      relatedNoteId: relatedNoteId ?? this.relatedNoteId,
      syncStatus: syncStatus ?? this.syncStatus,
      localChangeTimestamp: localChangeTimestamp ?? this.localChangeTimestamp,
      remoteChangeTimestamp:
          remoteChangeTimestamp ?? this.remoteChangeTimestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSizeBytes': fileSizeBytes,
      'uploadedDate': uploadedDate.millisecondsSinceEpoch,
      'updatedDate': updatedDate.millisecondsSinceEpoch,
      'userId': userId,
      'topicId': topicId,
      'relatedNoteId': relatedNoteId,
      'syncStatus': syncStatus,
      'localChangeTimestamp': localChangeTimestamp.millisecondsSinceEpoch,
      'remoteChangeTimestamp': remoteChangeTimestamp.millisecondsSinceEpoch,
    };
  }
}
