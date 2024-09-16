import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/common/widgets/tiles/note_tag.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/features/notes/presentation/pages/note.dart';
import 'package:study_aid/features/topics/presentation/pages/topic_page.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';

class ContentTile extends StatelessWidget {
  final Enum type;
  final dynamic entity;
  final String userId;
  final String parentTopicId;

  const ContentTile(
      {super.key,
      required this.type,
      required this.entity,
      required this.userId,
      required this.parentTopicId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (entity is Topic) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => TopicPage(
                userId: userId,
                topicTitle: entity.title,
                entity: entity,
              ),
            ),
          );
        }
        if (entity is Note) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => NotePage(
                topicId: parentTopicId,
                topicTitle: entity.title,
                entity: entity,
                isNewNote: false,
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: entity.color ?? AppColors.grey
            // type == TopicType.topic
            //     ? entity.color ?? AppColors.grey
            //     : AppColors.grey,
            ),
        child: IntrinsicHeight(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 130, // Maximum height constraint
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (type == TopicType.topic || entity is Topic)
                        const FaIcon(
                          FontAwesomeIcons.bookOpen,
                          size: 16,
                        ),
                      if (type == TopicType.note || entity is Note)
                        const FaIcon(
                          FontAwesomeIcons.solidNoteSticky,
                          size: 16,
                        ),
                      if (type == TopicType.audio || entity is AudioRecording)
                        const FaIcon(
                          FontAwesomeIcons.microphone,
                          size: 16,
                        ),
                      const SizedBox(width: 10),
                      AppSubHeadings(
                        text: entity.title,
                        size: 16,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (entity is Note) ...[
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            entity.content ?? "",
                            maxLines: 3,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ] else if (entity is Topic &&
                          entity.description != '') ...[
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            entity.description,
                            maxLines: 3,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ] else if (entity is AudioRecording) ...[
                        const SizedBox(height: 8),
                        const Text(
                          " Empty",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 8),
                  type == TopicType.topic || entity is Topic
                      ? Row(
                          children: [
                            Tag(
                              icon: FontAwesomeIcons.bookOpen,
                              text:
                                  '${(entity is Topic) ? entity.subTopics.length.toString() : 0} Topics',
                            ),
                            const SizedBox(width: 5),
                            Tag(
                              icon: FontAwesomeIcons.solidNoteSticky,
                              text:
                                  '${(entity is Topic) ? entity.notes.length.toString() : 0} Notes',
                            ),
                            const SizedBox(width: 5),
                            Tag(
                              icon: FontAwesomeIcons.microphone,
                              text:
                                  '${(entity is Topic) ? entity.audioRecordings.length.toString() : 0} Audio Clips',
                            ),
                          ],
                        )
                      : Row(
                          children: (entity.tags as List<dynamic>)
                              .map<Widget>((tag) => Row(
                                    children: [
                                      Tag(text: tag.toString()),
                                      const SizedBox(width: 5),
                                    ],
                                  ))
                              .toList(),
                        ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Created: ${entity.createdDate}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Icon(
                        Icons.star,
                        size: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
