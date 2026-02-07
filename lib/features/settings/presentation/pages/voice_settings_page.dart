import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/notes/domain/models/tts_config.dart';
import 'package:study_aid/features/notes/presentation/providers/tts_settings_provider.dart';
import 'package:widgets_easier/widgets_easier.dart';

class VoiceSettingsPage extends ConsumerWidget {
  const VoiceSettingsPage({super.key});

  String _formatVoiceName(String name) {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsSettings = ref.watch(ttsSettingsProvider);
    final ttsNotifier = ref.read(ttsSettingsProvider.notifier);

    return Scaffold(
      appBar: const BasicAppbar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Settings',
                      style: TextStyle(
                        fontSize: 24,
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Voice:',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<TtsVoice>(
                          dropdownColor: AppColors.white,
                          focusColor: AppColors.grey,
                          value: ttsSettings.voice,
                          isExpanded: true,
                          items: TtsVoice.values.map((voice) {
                            return DropdownMenuItem(
                              value: voice,
                              child: Text(_formatVoiceName(voice.name)),
                            );
                          }).toList(),
                          onChanged: (voice) {
                            if (voice != null) {
                              ttsNotifier.setVoice(voice);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
