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

class ContentTile extends StatelessWidget {
  final String title;
  final Enum type;
  final dynamic entity;

  const ContentTile(
      {required this.title,
      super.key,
      required this.type,
      required this.entity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (entity is Topic) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      TopicPage(topicTitle: entity.title, entity: entity)));
        }
        if (entity is Note) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => NotePage(
                      topicTitle: title, entity: entity, isNewNote: false)));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.grey,
        ),
        constraints: const BoxConstraints(maxHeight: 130),
        // height: 130,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  if (type == TopicType.topic)
                    const FaIcon(
                      FontAwesomeIcons.bookOpen,
                      size: 16,
                    ),
                  if (type == TopicType.note)
                    const FaIcon(
                      FontAwesomeIcons.solidNoteSticky,
                      size: 16,
                    ),
                  if (type == TopicType.audio)
                    const FaIcon(
                      FontAwesomeIcons.microphone,
                      size: 16,
                    ),
                  const SizedBox(width: 10),
                  AppSubHeadings(
                    text: title,
                    size: 16,
                  )
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (entity is Note)
                    Expanded(
                      child: Text(
                        entity.content ?? "",
                        maxLines: 3,
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w400),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    // TODO:change here
                    const Text(" Empty",
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w400)),
                  //TODO:chanmge here
                ],
              ),
              const SizedBox(height: 8),
              type == TopicType.topic
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
                  : const Row(
                      children: [
                        Tag(
                          text: 'Tag 1',
                        ),
                        SizedBox(width: 5),
                        Tag(
                          text: 'Tag 2',
                        ),
                        SizedBox(width: 5),
                        Tag(
                          text: 'Tag 3',
                        ),
                      ],
                    ),
              const Spacer(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created: 08:45 AM 24/04/2023',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                  ),
                  Icon(
                    Icons.star,
                    size: 12,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
