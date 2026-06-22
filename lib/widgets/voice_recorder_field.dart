import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../services/transcription_service.dart';

enum RecorderState { idle, recording, processing, done }

class VoiceRecorderField extends StatefulWidget {
  final Function({
    required String? voiceRecordingPath,
    required String? transcriptionOriginal,
    required String? transcriptionEnglish,
    required String? detectedLanguage,
  }) onChanged;

  const VoiceRecorderField({super.key, required this.onChanged});

  @override
  State<VoiceRecorderField> createState() => _VoiceRecorderFieldState();
}

class _VoiceRecorderFieldState extends State<VoiceRecorderField>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  AudioPlayer? _audioPlayer;
  final stt.SpeechToText _speech = stt.SpeechToText();

  RecorderState _recorderState = RecorderState.idle;
  bool _isPlaying = false;
  bool _speechInitialized = false;

  String? _recordingPath;
  String _transcription = '';
  String _englishTranslation = '';
  String _detectedLanguage = '';
  String _detectedLanguageCode = '';

  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  Duration _totalDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;

  late AnimationController _pulseController;
  Timer? _waveformTimer;
  List<double> _barHeights = [10.0, 10.0, 10.0, 10.0, 10.0];

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;

  bool _isFingerDown = false;
  bool _isLongPress = false;
  bool _isStarting = false;
  bool _isStopping = false;
  bool _sourceLoaded = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  /// Configure audio session for media playback through the speaker.
  /// This is critical: after recording + speech_to_text, Android's AudioManager
  /// may be stuck in MODE_IN_COMMUNICATION which routes audio through the
  /// earpiece at very low volume. This resets it to MODE_NORMAL + STREAM_MUSIC.
  Future<void> _configurePlaybackSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      ));
      await session.setActive(true);
      debugPrint('Audio session configured for media playback');
    } catch (e) {
      debugPrint('Error configuring audio session: $e');
    }
  }

  /// Initialize a just_audio player for the given file path
  Future<void> _initPlayer(String path) async {
    // Dispose previous player if any
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioPlayer?.dispose();

    // CRITICAL: Configure audio session for playback BEFORE creating player.
    // This switches Android out of communication mode (earpiece) to normal
    // mode (speaker) with STREAM_MUSIC, ensuring audible playback.
    await _configurePlaybackSession();

    final player = AudioPlayer();
    _audioPlayer = player;

    // Listen to player state changes for play/pause/complete
    _playerStateSubscription = player.playerStateStream.listen((state) {
      if (!mounted) return;
      final playing = state.playing;
      setState(() {
        _isPlaying = playing;
      });
      if (playing) {
        _startWaveformAnimation();
      } else {
        _waveformTimer?.cancel();
      }
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
        player.pause();
        player.seek(Duration.zero);
      }
    });

    // Listen to position changes for progress indicator
    _positionSubscription = player.positionStream.listen((p) {
      if (!mounted) return;
      setState(() {
        _currentPosition = p;
      });
    });

    try {
      final fileDuration = await player.setFilePath(path);
      if (mounted && fileDuration != null) {
        setState(() {
          _totalDuration = fileDuration;
          _sourceLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading audio file for playback: $e');
      _sourceLoaded = false;
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _waveformTimer?.cancel();
    _pulseController.dispose();
    _audioRecorder.dispose();
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<bool> _initSpeech() async {
    if (_speechInitialized) return true;
    try {
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('STT Status: $status'),
        onError: (error) => debugPrint('STT Error: $error'),
      );
      _speechInitialized = available;
      return available;
    } catch (e) {
      debugPrint('STT Initialization failed: $e');
      return false;
    }
  }

  void _startWaveformAnimation() {
    _waveformTimer?.cancel();
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (mounted && _isPlaying) {
        setState(() {
          _barHeights = List.generate(5, (index) {
            final factor = (DateTime.now().millisecond % (index + 2)) / (index + 2);
            return 8.0 + (index % 2 == 0 ? 24.0 : 16.0) * (0.3 + 0.7 * factor);
          });
        });
      }
    });
  }

  void _startRecordingTimer() {
    _recordingSeconds = 0;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingSeconds++;
        });
      }
    });
  }

  Future<void> _startRecording() async {
    if (_isStarting || _recorderState != RecorderState.idle) return;
    _isStarting = true;
    try {
      final locale = Localizations.localeOf(context).toString();

      // Permission check first
      final status = await Permission.microphone.status;
      if (!status.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          _showPermissionDeniedDialog();
          return;
        }
      }

      // Stop any existing playback before recording
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
        await _audioPlayer!.dispose();
        _audioPlayer = null;
        _sourceLoaded = false;
      }

      final speechAvailable = await _initSpeech();
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Explicit RecordConfig
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      if (mounted) {
        setState(() {
          _recorderState = RecorderState.recording;
          _recordingPath = null;
          _transcription = '';
          _englishTranslation = '';
          _detectedLanguage = '';
          _detectedLanguageCode = '';
        });
      }

      _startRecordingTimer();
      _pulseController.repeat(reverse: true);

      if (speechAvailable) {
        TranscriptionService.instance.setLiveTranscription('');

        await _speech.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                _transcription = result.recognizedWords;
              });
              TranscriptionService.instance.setLiveTranscription(result.recognizedWords);
            }
          },
          localeId: locale,
          listenFor: const Duration(minutes: 5),
          pauseFor: const Duration(seconds: 15),
        );
      }

      // If this was started by a long-press gesture, check if the finger has already been released
      if (_isLongPress && !_isFingerDown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _stopRecording();
        });
      }
    } catch (e) {
      debugPrint('Error starting recorder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      _isStarting = false;
    }
  }

  Future<void> _stopRecording() async {
    if (_isStopping || _recorderState != RecorderState.recording) return;
    _isStopping = true;
    _recordingTimer?.cancel();
    _pulseController.stop();

    // 1. Stop speech recognition FIRST
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (e) {
      debugPrint('Error stopping speech recognition: $e');
    }

    // 2. Stop the audio recorder and get the file path
    try {
      final path = await _audioRecorder.stop();
      if (mounted) {
        setState(() {
          _recorderState = RecorderState.processing;
        });
      }

      if (path != null) {
        // Verify the recorded file
        final file = File(path);
        final exists = await file.exists();
        debugPrint('Recording saved to: $path');
        debugPrint('File exists: $exists');
        if (exists) {
          final fileSize = await file.length();
          debugPrint('File size: $fileSize bytes');
          if (fileSize == 0) {
            debugPrint('WARNING: Recorded file is 0 bytes!');
          }
        } else {
          debugPrint('ERROR: File does not exist at path: $path');
        }

        // 3. Small delay to ensure recorder fully releases audio resources.
        //    On Android, the recorder holds AudioRecord which keeps the
        //    AudioManager in recording mode. We need it fully released.
        await Future.delayed(const Duration(milliseconds: 300));

        final result = await TranscriptionService.instance.transcribe(path);

        String translation = '';
        final codeLower = result.languageCode.split('-').first.toLowerCase();
        if (codeLower != 'en' && result.originalText.isNotEmpty) {
          translation = await TranscriptionService.instance.translateToEnglish(
            result.originalText,
            result.languageCode,
          );
        }

        if (mounted) {
          setState(() {
            _recorderState = RecorderState.done;
            _recordingPath = path;
            _transcription = result.originalText;
            _detectedLanguage = result.detectedLanguage;
            _detectedLanguageCode = result.languageCode;
            _englishTranslation = translation;
            _totalDuration = Duration(seconds: _recordingSeconds);
            _currentPosition = Duration.zero;
            _sourceLoaded = false;
          });
        }

        // 4. Initialize the player for the new recording.
        //    _initPlayer calls _configurePlaybackSession which resets
        //    Android AudioManager from communication mode to normal mode.
        await _initPlayer(path);

        widget.onChanged(
          voiceRecordingPath: path,
          transcriptionOriginal: result.originalText.isNotEmpty ? result.originalText : null,
          transcriptionEnglish: translation.isNotEmpty ? translation : null,
          detectedLanguage: result.detectedLanguage.isNotEmpty ? result.detectedLanguage : null,
        );
      } else {
        if (mounted) {
          setState(() {
            _recorderState = RecorderState.idle;
          });
        }
      }
    } catch (e) {
      debugPrint('Error stopping recorder: $e');
      if (mounted) {
        setState(() {
          _recorderState = RecorderState.idle;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping recorder: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      _isStopping = false;
    }
  }

  Future<void> _clearRecording() async {
    try {
      _waveformTimer?.cancel();
      _playerStateSubscription?.cancel();
      _positionSubscription?.cancel();
      await _audioPlayer?.stop();
      await _audioPlayer?.dispose();
      _audioPlayer = null;

      if (mounted) {
        setState(() {
          _recorderState = RecorderState.idle;
          _isPlaying = false;
          _sourceLoaded = false;
          _isLongPress = false;
          _isFingerDown = false;
          _recordingPath = null;
          _transcription = '';
          _englishTranslation = '';
          _detectedLanguage = '';
          _detectedLanguageCode = '';
          _recordingSeconds = 0;
          _totalDuration = Duration.zero;
          _currentPosition = Duration.zero;
        });
      }

      widget.onChanged(
        voiceRecordingPath: null,
        transcriptionOriginal: null,
        transcriptionEnglish: null,
        detectedLanguage: null,
      );
    } catch (e) {
      debugPrint('Error clearing recording: $e');
    }
  }

  Future<void> _togglePlayback() async {
    if (_recordingPath == null) return;

    try {
      if (_audioPlayer == null || !_sourceLoaded) {
        await _initPlayer(_recordingPath!);
      }

      final player = _audioPlayer;
      if (player == null) return;

      if (_isPlaying) {
        await player.pause();
      } else {
        // Ensure audio session is configured for playback (speaker, full volume)
        await _configurePlaybackSession();
        if (player.processingState == ProcessingState.completed) {
          await player.seek(Duration.zero);
        }
        await player.play();
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _sourceLoaded = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTime(Duration d) {
    return _formatDuration(d.inSeconds);
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
          'Microphone access is required to record voice notes. Please grant microphone permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    // Style configurations matching standard requirements
    final cardBg = isDark ? const Color(0xFF2D2D2D) : Theme.of(context).cardColor;
    final chipBg = isDark ? const Color(0xFF3D2D5C) : const Color(0xFFEDE7F6);
    final textStyleColor = isDark ? Colors.white : Colors.black87;

    return Card(
      elevation: 2,
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mic, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Voice Note (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textStyleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_recorderState == RecorderState.idle || _recorderState == RecorderState.recording) ...[
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_recorderState == RecorderState.idle) {
                          _isLongPress = false;
                          _isFingerDown = false;
                          _startRecording();
                        } else if (_recorderState == RecorderState.recording) {
                          _stopRecording();
                        }
                      },
                      onLongPressStart: (_) {
                        if (_recorderState == RecorderState.idle) {
                          _isLongPress = true;
                          _isFingerDown = true;
                          _startRecording();
                        }
                      },
                      onLongPressEnd: (_) {
                        if (_isLongPress) {
                          _isFingerDown = false;
                          if (_recorderState == RecorderState.recording) {
                            _stopRecording();
                          }
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_recorderState == RecorderState.recording)
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width: 60 + 20 * _pulseController.value,
                                  height: 60 + 20 * _pulseController.value,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(1.0 - _pulseController.value),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              },
                            ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _recorderState == RecorderState.recording
                                  ? Colors.red
                                  : primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: _recorderState == RecorderState.recording
                                  ? null
                                  : Border.all(color: primaryColor, width: 2),
                            ),
                            child: Icon(
                              _recorderState == RecorderState.recording ? Icons.stop : Icons.mic,
                              size: _recorderState == RecorderState.recording ? 30 : 36,
                              color: _recorderState == RecorderState.recording ? Colors.white : primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _recorderState == RecorderState.recording
                          ? 'Recording... ${_formatDuration(_recordingSeconds)}'
                          : 'Tap or hold to record voice response',
                      style: TextStyle(
                        fontSize: 14,
                        color: _recorderState == RecorderState.recording ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        fontWeight: _recorderState == RecorderState.recording ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (_recorderState == RecorderState.recording && _transcription.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          '"$_transcription"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else if (_recorderState == RecorderState.processing) ...[
              // Transcribing loader
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: primaryColor),
                    const SizedBox(height: 12),
                    Text(
                      'Transcribing and detecting language...',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_recorderState == RecorderState.done) ...[
              // Playing / Done state
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: _togglePlayback,
                        icon: Icon(
                          _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          size: 36,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Animated Waveform
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            width: 4,
                            height: _isPlaying ? _barHeights[index] : 10.0,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_formatTime(_currentPosition)} / ${_formatTime(_totalDuration)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _clearRecording,
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Transcription details card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Transcription',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            if (_detectedLanguage.isNotEmpty)
                              Chip(
                                avatar: Icon(
                                  Icons.language,
                                  size: 14,
                                  color: primaryColor,
                                ),
                                label: Text(
                                  _detectedLanguage,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: chipBg,
                                padding: EdgeInsets.zero,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _transcription.isNotEmpty ? _transcription : '(Silence/No Speech Recognized)',
                          style: TextStyle(
                            fontSize: 14,
                            color: textStyleColor,
                          ),
                        ),
                        if (_englishTranslation.isNotEmpty) ...[
                          const Divider(height: 16),
                          Text(
                            'English Translation',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _englishTranslation,
                            style: TextStyle(
                              fontSize: 14,
                              color: textStyleColor,
                            ),
                          ),
                        ] else if (_transcription.isNotEmpty && _detectedLanguage.toLowerCase() == 'english') ...[
                          const Divider(height: 16),
                          Row(
                            children: [
                              Icon(Icons.check_circle_outline, size: 14, color: Colors.green[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Already in English',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
