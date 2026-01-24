import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:study_aid/features/files/domain/entities/file_entity.dart';

part 'file_model.g.dart';

@HiveType(typeId: 5)
class FileModel extends FileEntity {
  @HiveField(1)
  final String id;
  @HiveField(2)
  final String fileName;
  @HiveField(3)
  final String fileUrl;
  @HiveField(4)
  final String fileType;
  @HiveField(5)
  final int fileSizeBytes;
  @HiveField(6)
  final DateTime uploadedDate;
  @HiveField(7)
  final DateTime updatedDate;
  @HiveField(8)
  final String userId;
  @HiveField(9)
  final String topicId;
  @HiveField(10)
  final String? relatedNoteId;
  @HiveField(11)
  final String syncStatus;
  @HiveField(12)
  final DateTime localChangeTimestamp;
  @HiveField(13)
  final DateTime remoteChangeTimestamp;

  FileModel({
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
  }) : super(
          id: id,
          fileName: fileName,
          fileUrl: fileUrl,
          fileType: fileType,
          fileSizeBytes: fileSizeBytes,
          uploadedDate: uploadedDate,
          updatedDate: updatedDate,
          userId: userId,
          topicId: topicId,
          relatedNoteId: relatedNoteId,
          syncStatus: syncStatus,
          localChangeTimestamp: localChangeTimestamp,
          remoteChangeTimestamp: remoteChangeTimestamp,
        );

  factory FileModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FileModel(
      id: data['id'],
      fileName: data['fileName'],
      fileUrl: data['fileUrl'],
      fileType: data['fileType'],
      fileSizeBytes: data['fileSizeBytes'],
      uploadedDate: (data['uploadedDate'] as Timestamp).toDate(),
      updatedDate: (data['updatedDate'] as Timestamp).toDate(),
      userId: data['userId'],
      topicId: data['topicId'],
      relatedNoteId: data['relatedNoteId'],
      syncStatus: data['syncStatus'],
      localChangeTimestamp:
          (data['localChangeTimestamp'] as Timestamp).toDate(),
      remoteChangeTimestamp:
          (data['remoteChangeTimestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSizeBytes': fileSizeBytes,
      'uploadedDate': Timestamp.fromDate(uploadedDate),
      'updatedDate': Timestamp.fromDate(updatedDate),
      'userId': userId,
      'topicId': topicId,
      'relatedNoteId': relatedNoteId,
      'syncStatus': syncStatus,
      'localChangeTimestamp': Timestamp.fromDate(localChangeTimestamp),
      'remoteChangeTimestamp': Timestamp.fromDate(remoteChangeTimestamp),
    };
  }

  @override
  FileModel copyWith({
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
    return FileModel(
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

  factory FileModel.fromDomain(FileEntity file) {
    return FileModel(
      id: file.id,
      fileName: file.fileName,
      fileUrl: file.fileUrl,
      fileType: file.fileType,
      fileSizeBytes: file.fileSizeBytes,
      uploadedDate: file.uploadedDate,
      updatedDate: file.updatedDate,
      userId: file.userId,
      topicId: file.topicId,
      relatedNoteId: file.relatedNoteId,
      syncStatus: file.syncStatus,
      localChangeTimestamp: file.localChangeTimestamp,
      remoteChangeTimestamp: file.remoteChangeTimestamp,
    );
  }

  FileEntity toDomain() {
    return FileEntity(
      id: id,
      fileName: fileName,
      fileUrl: fileUrl,
      fileType: fileType,
      fileSizeBytes: fileSizeBytes,
      uploadedDate: uploadedDate,
      updatedDate: updatedDate,
      userId: userId,
      topicId: topicId,
      relatedNoteId: relatedNoteId,
      syncStatus: syncStatus,
      localChangeTimestamp: localChangeTimestamp,
      remoteChangeTimestamp: remoteChangeTimestamp,
    );
  }
}
