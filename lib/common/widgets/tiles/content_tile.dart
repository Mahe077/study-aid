import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/bannerbars/base_bannerbar.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/core/utils/helpers/helpers.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/common/widgets/tiles/note_tag.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/topics/domain/entities/topic.dart';
import 'package:study_aid/features/notes/presentation/pages/note_page.dart';
import 'package:study_aid/features/topics/presentation/pages/topic_page.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';
import 'package:study_aid/features/voice_notes/data/models/audio_recording.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';
import 'package:study_aid/features/voice_notes/presentation/pages/voice_drawer.dart';
import 'package:study_aid/features/files/domain/entities/file_entity.dart';
import 'package:study_aid/features/files/presentation/providers/files_providers.dart';
import 'package:study_aid/features/notes/presentation/providers/summarization_provider.dart';
import 'package:study_aid/features/notes/presentation/widgets/summarization_dialog.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_tab_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ContentTile extends ConsumerStatefulWidget {
  final Enum type;
  final dynamic entity;
  final String userId;
  final String parentTopicId;
  final String dropdownValue;
  final Color tileColor;

  const ContentTile({
    super.key,
    required this.type,
    required this.entity,
    required this.userId,
    required this.parentTopicId,
    required this.dropdownValue,
    required this.tileColor,
  });

  @override
  ConsumerState<ContentTile> createState() => _ContentTileState();
}

class _ContentTileState extends ConsumerState<ContentTile> {
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
    _initializeAudioLogic();
  }

  @override
  void didUpdateWidget(ContentTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the entity has changed and trigger audio logic if necessary
    if (widget.entity != oldWidget.entity) {
      _initializeAudioLogic();
    }
  }

  void _initializeAudioLogic() {
    if (widget.entity is AudioRecording) {
      playerController = PlayerController();
      _preparePlayer(playerController!, widget.entity.localpath);

      // Subscribe to player state changes
      playerStateSubscription =
          playerController?.onPlayerStateChanged.listen((_) {
        setState(() {});
      });
    } else {
      // If the entity is not AudioRecording, cancel the player state subscription
      playerStateSubscription?.cancel();
      playerController = null;
    }
  }

  void _preparePlayer(PlayerController controller, String? localPath) async {
    try {
      if (localPath != null) {
        Logger().i("Content Tile :: Audio file path: $localPath");
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
      child: _tileBody(),
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

  Container _tileBody() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: (widget.entity is FileEntity)
              ? widget.tileColor
              : (widget.entity.color ?? AppColors.grey)),
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
                    : (widget.entity is FileEntity)
                        ? const SizedBox.shrink() // Files don't have tags
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          widget.entity is FileEntity
              ? 'Uploaded: ${formatDateTime(widget.entity.uploadedDate)}'
              : 'Created: ${formatDateTime(widget.entity.createdDate)}',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
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
          // ] else if (widget.entity is Topic &&
          //     widget.entity.description != '') ...[
          //   const SizedBox(height: 8),
          //   Expanded(
          //     child: Text(
          //       widget.entity.description,
          //       maxLines: 3,
          //       style: const TextStyle(
          //         fontSize: 10,
          //         fontWeight: FontWeight.w400,
          //       ),
          //       overflow: TextOverflow.ellipsis,
          //     ),
          //   )
        ] else if ((widget.entity is AudioRecording ||
                widget.entity is AudioRecordingModel) &&
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
        ] else if (widget.entity is FileEntity) ...[
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Type: ${widget.entity.fileType.toUpperCase()}",
                  style: const TextStyle(fontSize: 10),
                ),
                Text(
                  "Size: ${_formatSize(widget.entity.fileSizeBytes)}",
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          )
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
        if (widget.type == TopicType.file || widget.entity is FileEntity)
          _buildFileIcon(widget.entity is FileEntity
              ? widget.entity.fileType
              : 'file'),
        const SizedBox(width: 10),
        Expanded(
          child: AppSubHeadings(
            text: widget.entity is FileEntity
                ? widget.entity.fileName
                : widget.entity.title,
            size: 16,
            maxLine: 1,
            alignment: TextAlign.start,
          ),
        ),
        if (widget.type == TopicType.topic || widget.entity is Topic) ...[
          SpeedDial(
            mini: false,
            icon: Icons.more_vert,
            iconTheme: IconThemeData(size: 30),
            buttonSize: const Size(25, 25),
            childrenButtonSize: const Size(0, 0),
            backgroundColor: widget.entity.color,
            // backgroundColor: Colors.white,
            elevation: 0,
            overlayColor: Colors.black,
            overlayOpacity: 0.4,
            spacing: 0,
            childMargin: EdgeInsets.zero,
            childPadding: EdgeInsets.zero,
            children: [
              SpeedDialChild(
                label: 'Delete Topic',
                onTap: _deleteTopic,
                backgroundColor: AppColors.grey,
              ),
            ],
          ),
        ],
        if (widget.type == TopicType.file || widget.entity is FileEntity) ...[
          SpeedDial(
            mini: false,
            icon: Icons.more_vert,
            iconTheme: IconThemeData(size: 30),
            buttonSize: const Size(25, 25),
            childrenButtonSize: const Size(0, 0),
            backgroundColor: widget.tileColor,
            elevation: 0,
            overlayColor: Colors.black,
            overlayOpacity: 0.4,
            spacing: 0,
            childMargin: EdgeInsets.zero,
            childPadding: EdgeInsets.zero,
            children: [
              SpeedDialChild(
                label: 'Summarize',
                onTap: _summarizeFile,
                backgroundColor: AppColors.primary,
                labelBackgroundColor: AppColors.white,
              ),
              SpeedDialChild(
                label: 'Delete File',
                onTap: _deleteFile,
                backgroundColor: AppColors.grey,
              ),
            ],
          ),
        ]
      ],
    );
  }

  void _deleteTopic() async {
    final toast = CustomToast(context: context);
    showCustomDialog(
      context,
      DialogMode.delete,
      "Confirm Delete",
      const Text('Are you sure you want to delete this topic & its contents?'),
      () async {
        try {
          await ref
              .read(topicsProvider(
                      TopicParams(widget.userId, widget.dropdownValue))
                  .notifier)
              .deleteTopic(widget.entity.id, widget.parentTopicId,
                  widget.userId, widget.dropdownValue);
          toast.showSuccess(description: "Topic deleted successfully.");
        } catch (e) {
          // Log the error and notify the user
          Logger().e("Error deleting topic: $e");
          toast.showFailure(description: 'Failed to delete the topic');
        }
      },
    );
  }

  void _deleteFile() async {
    final toast = CustomToast(context: context);
    showCustomDialog(
      context,
      DialogMode.delete,
      "Confirm Delete",
      const Text('Are you sure you want to delete this file?'),
      () async {
        try {
          await ref
              .read(filesProvider(
                      FilesParams(topicId: widget.parentTopicId, sortBy: widget.dropdownValue))
                  .notifier)
              .deleteFile(widget.entity.id, widget.userId, widget.dropdownValue);
          toast.showSuccess(description: "File deleted successfully.");
        } catch (e) {
          // Log the error and notify the user
          Logger().e("Error deleting file: $e");
          toast.showFailure(description: 'Failed to delete the file');
        }
      },
    );
  }

  void _summarizeFile() async {
    if (widget.entity is! FileEntity) return;

    final fileEntity = widget.entity as FileEntity;
    final toast = CustomToast(context: context);

    // 1. Show loading
    toast.showInfo(
        title: 'Processing', description: 'Extracting text from file...');

    try {
      final extractor = ref.read(fileTextExtractorServiceProvider);
      final text =
          await extractor.extractText(fileEntity.fileUrl, fileEntity.fileType);

      if (text.isEmpty) {
        toast.showInfo(
            title: 'No Text',
            description: 'Could not extract any text from this file.');
        return;
      }

      // 2. Show Dialog
      if (context.mounted) {
        final result = await showDialog(
          context: context,
          builder: (_) => SummarizationDialog(
            content: text,
            topicId: widget.parentTopicId,
            userId: widget.userId,
            title: 'Summary: ${fileEntity.fileName}',
            noteColor: widget.tileColor,
          ),
        );
        if (result is Note && mounted) {
          ref
              .read(tabDataProvider(
                      TabDataParams(widget.parentTopicId, widget.dropdownValue))
                  .notifier)
              .updateNote(result);
        }
      }
    } catch (e) {
      Logger().e("Error extracting text: $e");
      toast.showFailure(
          description: e.toString().replaceAll('Exception: ', ''));
    }
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
