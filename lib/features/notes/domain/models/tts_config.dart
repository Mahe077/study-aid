/// Available OpenAI TTS voices
enum TtsVoice {
  alloy,
  echo,
  fable,
  onyx,
  nova,
  shimmer;

  String get name => toString().split('.').last;
}

/// Configuration for TTS playback
class TtsConfig {
  final TtsVoice voice;
  final double speed; // 0.25 to 4.0
  final bool continuousPlay;

  const TtsConfig({
    this.voice = TtsVoice.alloy,
    this.speed = 1.0,
    this.continuousPlay = true,
  });

  TtsConfig copyWith({
    TtsVoice? voice,
    double? speed,
    bool? continuousPlay,
  }) {
    return TtsConfig(
      voice: voice ?? this.voice,
      speed: speed ?? this.speed,
      continuousPlay: continuousPlay ?? this.continuousPlay,
    );
  }

  Map<String, dynamic> toJson() => {
        'voice': voice.name,
        'speed': speed,
        'continuousPlay': continuousPlay,
      };

  factory TtsConfig.fromJson(Map<String, dynamic> json) {
    return TtsConfig(
      voice: TtsVoice.values.firstWhere(
        (v) => v.name == json['voice'],
        orElse: () => TtsVoice.alloy,
      ),
      speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
      continuousPlay: json['continuousPlay'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TtsConfig &&
          runtimeType == other.runtimeType &&
          voice == other.voice &&
          speed == other.speed &&
          continuousPlay == other.continuousPlay;

  @override
  int get hashCode => Object.hash(voice, speed, continuousPlay);
}
