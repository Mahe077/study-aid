import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/core/utils/helpers/helpers.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/notes/presentation/pages/note_page.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/features/topics/presentation/pages/topic_page.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';
import 'package:study_aid/features/voice_notes/presentation/pages/voice_drawer.dart';
import 'package:study_aid/features/files/domain/entities/file_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class RecentTile extends StatefulWidget {
  final Enum type;
  final dynamic entity;
  final String userId;
  final String parentTopicId;
  final String dropdownValue;
  final Color tileColor;

  const RecentTile({
    super.key,
    required this.type,
    required this.entity,
    required this.userId,
    required this.parentTopicId,
    required this.dropdownValue,
    required this.tileColor,
  });

  @override
  State<RecentTile> createState() => _RecentTileState();
}

class _RecentTileState extends State<RecentTile> {
  PlayerController? recentTilePlayerController;

  void _preparePlayer(PlayerController controller, String? localPath) async {
    try {
      if (localPath != null) {
        Logger().i("Audio file path: $localPath");
        File file = File(localPath);
        if (await file.exists()) {
          await controller.extractWaveformData(path: file.path);
        } else {
          Logger().e("File does not exist at the provided path: $file");
        }
      }
    } catch (e) {
      Logger().e("Error preparing player: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAudioLogic();
  }

  @override
  void didUpdateWidget(RecentTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if the entity has changed and trigger audio logic if necessary
    if (widget.entity != oldWidget.entity) {
      _initializeAudioLogic();
    }
  }

  void _initializeAudioLogic() {
    if (widget.entity is AudioRecording) {
      recentTilePlayerController = PlayerController();
     _preparePlayer(recentTilePlayerController!, widget.entity.localpath);
    } else {
      recentTilePlayerController = null;
    }
  }

  @override
  void dispose() {
    recentTilePlayerController?.dispose();
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
                tileColor: widget.tileColor,
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
                dropdownValue: widget.dropdownValue,
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
                  dropdownValue: widget.dropdownValue,
                );
              }));
        }
        if (widget.entity is FileEntity) {
          _openFile(context, widget.entity.fileUrl);
        }
      },
      child: _buildContentTileBody(),
    );
  }

  Future<void> _openFile(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open file')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: $e')),
        );
      }
    }
  }

  Container _buildContentTileBody() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: (widget.entity is FileEntity) ? widget.tileColor : (widget.entity.color ?? AppColors.grey),
      ),
      width: 200,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Header Row with Icon and Title
            Row(
              children: [
                if (widget.type == TopicType.topic)
                  const FaIcon(
                    FontAwesomeIcons.bookOpen,
                    size: 16,
                  ),
                if (widget.type == TopicType.note)
                  const FaIcon(
                    FontAwesomeIcons.solidNoteSticky,
                    size: 16,
                  ),
                if (widget.type == TopicType.audio)
                  const FaIcon(
                    FontAwesomeIcons.microphone,
                    size: 16,
                  ),
                if (widget.type == TopicType.file)
                  _buildFileIcon(widget.entity.fileType),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: AppSubHeadings(
                    text: widget.entity is FileEntity
                        ? widget.entity.fileName
                        : widget.entity.title,
                    size: 16,
                    alignment: TextAlign.left,
                    maxLine: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Content and Waveform Section
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: widget.entity is Note
                    ? Text(
                        widget.entity.content,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : widget.entity is Topic
                        ? Text(
                            widget.entity.description,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : widget.entity is AudioRecording
                            ? Row(
                                children: [
                                  // Play Button
                                  Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          AppColors.primary.withOpacity(0.81),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.play_arrow,
                                        size: 14,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      width:
                                          8), // Space between icon and waveform
                                  // Audio Waveform
                                  if (recentTilePlayerController != null)
                                    AudioFileWaveforms(
                                      size: const Size(150, 40.0),
                                      playerController:
                                          recentTilePlayerController!,
                                      enableSeekGesture: true,
                                      waveformType: WaveformType.fitWidth,
                                      waveformData: recentTilePlayerController!
                                          .waveformData,
                                      playerWaveStyle: PlayerWaveStyle(
                                          fixedWaveColor: AppColors.primary
                                              .withOpacity(0.81),
                                          liveWaveColor: AppColors.primary
                                              .withOpacity(0.34),
                                          spacing: 2.5,
                                          waveThickness: 1.5),
                                    ),
                                ],
                              )
                            : widget.entity is FileEntity
                                ? Text(
                                    "${widget.entity.fileType.toUpperCase()} • ${_formatSize(widget.entity.fileSizeBytes)}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
                                : Container(), // Empty for unsupported entity types
              ),
            ),
            const Spacer(),

            // Date and Star Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDateTime(widget.entity.updatedDate),
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
    );
  }

  Widget _buildFileIcon(String extension) {
    IconData iconData;
    Color color;

    switch (extension.toLowerCase()) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        color = Colors.black;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        color = Colors.black;
        break;
      case 'txt':
        iconData = Icons.text_snippet;
        color = Colors.black;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        iconData = Icons.image;
        color = Colors.black;
        break;
      default:
        iconData = Icons.insert_drive_file;
        color = Colors.black;
    }

    return Icon(iconData, color: color, size: 16);
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
