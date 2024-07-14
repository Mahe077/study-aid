import 'package:flutter/material.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/core/configs/theme/app_colors.dart';

class RecentTile extends StatelessWidget {
  const RecentTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.grey,
      ),
      width: 200,
      height: 100,
      child: const Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_add,
                  size: 16,
                ),
                SizedBox(
                  width: 10,
                ),
                AppSubHeadings(
                  text: 'Note Title',
                  size: 16,
                )
              ],
            ),
            Spacer(),
            Text(
              'Lorem Ipsum is simply dummy text of the printing and types...',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
            ),
            Spacer(),
            Row(
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
