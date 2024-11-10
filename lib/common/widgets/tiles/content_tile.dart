import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/core/utils/helpers/helpers.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/common/widgets/tiles/note_tag.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/features/notes/presentation/pages/note_page.dart';
import 'package:study_aid/features/topics/presentation/pages/topic_page.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';
import 'package:study_aid/features/voice_notes/presentation/pages/voice_drawer.dart';

class ContentTile extends StatefulWidget {
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
  State<ContentTile> createState() => _ContentTileState();
}

class _ContentTileState extends State<ContentTile> {
  File? file;
  PlayerController? playerController;
  StreamSubscription<PlayerState>? playerStateSubscription;

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Colors.white,
    spacing: 6,
  );

  @override
  void initState() {
    super.initState();
    if (widget.entity is AudioRecording) {
      playerController = PlayerController();
      _preparePlayer(playerController!, widget.entity.localpath);
      playerStateSubscription =
          playerController?.onPlayerStateChanged.listen((_) {
        setState(() {});
      });
    }
  }

  void _preparePlayer(PlayerController controller, String? localPath) async {
    try {
      if (localPath != null) {
        Logger().i("Audio file path: $localPath");
        File file = File(localPath);
        if (await file.exists()) {
          await controller.extractWaveformData(path: file.path);
          Logger().i("Waveform Data: ${controller.waveformData}");
        } else {
          Logger().e("File does not exist at the provided path: $file");
        }
      }
    } catch (e) {
      Logger().e("Error preparing player: $e");
    }
  }

  @override
  void dispose() {
    playerStateSubscription?.cancel();
    playerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.entity is Topic) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => TopicPage(
                userId: widget.userId,
                topicTitle: widget.entity.title,
                entity: widget.entity,
              ),
            ),
          );
        }
        if (widget.entity is Note) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => NotePage(
                topicId: widget.parentTopicId,
                topicTitle: widget.entity.title,
                entity: widget.entity,
                isNewNote: false,
                userId: widget.userId,
              ),
            ),
          );
        }
        if (widget.entity is AudioRecording) {
          Future(() => showModalBottomSheet(
              context: context,
              builder: (context) {
                return ModalBottomSheet(
                  entity: widget.entity,
                  userId: widget.userId,
                  parentId: widget.parentTopicId,
                );
              }));
        }
      },
      child: _tileBody(),
    );
  }

  Container _tileBody() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.entity.color ?? AppColors.grey),
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
                _tileHeader(),
                _tileContent(),
                const SizedBox(height: 8),
                widget.type == TopicType.topic || widget.entity is Topic
                    ? tileTag()
                    : Row(
                        children: (widget.entity.tags as List<dynamic>)
                            .map<Widget>((tag) => Row(
                                  children: [
                                    Tag(text: tag.toString()),
                                    const SizedBox(width: 5),
                                  ],
                                ))
                            .toList(),
                      ),
                const SizedBox(height: 8),
                _tileCreatedDate(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row tileTag() {
    return Row(
      children: [
        Tag(
          icon: FontAwesomeIcons.bookOpen,
          text:
              '${(widget.entity is Topic) ? widget.entity.subTopics.length.toString() : 0} Topics',
        ),
        const SizedBox(width: 5),
        Tag(
          icon: FontAwesomeIcons.solidNoteSticky,
          text:
              '${(widget.entity is Topic) ? widget.entity.notes.length.toString() : 0} Notes',
        ),
        const SizedBox(width: 5),
        Tag(
          icon: FontAwesomeIcons.microphone,
          text:
              '${(widget.entity is Topic) ? widget.entity.audioRecordings.length.toString() : 0} Audio Clips',
        ),
      ],
    );
  }

  Row _tileCreatedDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Created: ${formatDateTime(widget.entity.createdDate)}',
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
    );
  }

  Row _tileContent() {
    return Row(
      children: [
        if (widget.entity is Note) ...[
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              widget.entity.content ?? "",
              maxLines: 3,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )
        ] else if (widget.entity is Topic &&
            widget.entity.description != '') ...[
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              widget.entity.description,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )
        ] else if (widget.entity is AudioRecording &&
            playerController != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                height: 23,
                width: 23,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.81),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_arrow,
                    size: 21,
                    color: widget.entity.color,
                  ),
                ),
              ),
              const SizedBox(width: 8), // Space between icon and waveform
              AudioFileWaveforms(
                size: const Size(300, 40.0),
                playerController: playerController!,
                enableSeekGesture: true,
                waveformType: WaveformType.fitWidth,
                waveformData: playerController!.waveformData,
                playerWaveStyle: PlayerWaveStyle(
                  fixedWaveColor: AppColors.primary.withOpacity(0.81),
                  liveWaveColor: AppColors.primary.withOpacity(0.34),
                  spacing: 6,
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }

  Row _tileHeader() {
    return Row(
      children: [
        if (widget.type == TopicType.topic || widget.entity is Topic)
          const FaIcon(
            FontAwesomeIcons.bookOpen,
            size: 16,
          ),
        if (widget.type == TopicType.note || widget.entity is Note)
          const FaIcon(
            FontAwesomeIcons.solidNoteSticky,
            size: 16,
          ),
        if (widget.type == TopicType.audio || widget.entity is AudioRecording)
          const FaIcon(
            FontAwesomeIcons.microphone,
            size: 16,
          ),
        const SizedBox(width: 10),
        AppSubHeadings(
          text: widget.entity.title,
          size: 16,
        ),
      ],
    );
  }
}
