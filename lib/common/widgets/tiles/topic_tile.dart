import 'package:flutter/material.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/core/configs/theme/app_colors.dart';
import 'package:study_aid/common/widgets/tiles/note_tag.dart';
import 'package:study_aid/domain/entities/topic.dart';
import 'package:study_aid/presentation/topic/pages/topic_page.dart';

class TopicTile extends StatelessWidget {
  final String title;
  final Enum type;
  final dynamic entity;

  const TopicTile(
      {required this.title,
      super.key,
      required this.type,
      required this.entity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (entity is TopicEntity) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      TopicPage(topicTitle: entity.title, entity: entity)));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.grey,
        ),
        height: 130,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.topic,
                    size: 16,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  AppSubHeadings(
                    text: title,
                    size: 16,
                  )
                ],
              ),
              const Spacer(),
              const Text(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scr...",
                maxLines: 3,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
              ),
              const Spacer(),
              type == TopicType.topic
                  ? const Row(
                      children: [
                        Tag(
                          icon: Icons.topic,
                          text: '3 Sub Topics',
                        ),
                        SizedBox(width: 5),
                        Tag(
                          icon: Icons.note,
                          text: '2 Notes',
                        ),
                        SizedBox(width: 5),
                        Tag(
                          icon: Icons.mic,
                          text: '3 Audio Clips',
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
