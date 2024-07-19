import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/core/configs/theme/app_colors.dart';
import 'package:study_aid/domain/entities/note.dart';

class RecentTile extends StatelessWidget {
  final String title;
  final Enum type;
  final dynamic entity;

  const RecentTile(
      {super.key,
      required this.type,
      required this.entity,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.grey,
      ),
      width: 200,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
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
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: AppSubHeadings(
                    text: entity.title,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                entity is NoteEntity ? entity.content : '',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
              ),
            ),
            const Spacer(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today',
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
    );
  }
}
