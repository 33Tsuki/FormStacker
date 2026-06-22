import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../l10n/app_localizations.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../store/response_store.dart';
import '../widgets/app_drawer.dart';
import '../widgets/sync_status_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _authorized = false;
  String? _errorText;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _adminPassword;
  bool _loading = true;
  bool _responsesLoaded = false;
  final _primaryColor = const Color(0xFF673AB7);
  final _accentColor = const Color(0xFF7C4DFF);

  @override
  void initState() {
    super.initState();
    _loadAdminPassword();
  }

  Future<void> _loadAdminPassword() async {
    final pwd = await _storage.read(key: 'admin_password');
    setState(() {
      _adminPassword = pwd;
      _loading = false;
    });
  }

  Future<void> _loadResponses() async {
    await ResponseStore().refresh();
    if (mounted) {
      setState(() {
        _responsesLoaded = true;
      });
    }
  }

  Future<void> _setAdminPassword(String pwd) async {
    await _storage.write(key: 'admin_password', value: pwd);
    setState(() {
      _adminPassword = pwd;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _authenticate() {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return;
    if (_adminPassword == null) {
      _promptSetPassword();
      return;
    }

    if (_passwordController.text == _adminPassword) {
      setState(() {
        _authorized = true;
        _errorText = null;
      });
      _loadResponses();
    } else {
      setState(() {
        _errorText = l10n.incorrectPasswordShort;
      });
    }
  }

  Future<void> _promptSetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final set = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.setAdminPassword,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.newPassword,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: Text(l10n.set),
          ),
        ],
      ),
    );

    if (set == true && controller.text.isNotEmpty) {
      await _setAdminPassword(controller.text);
      setState(() {
        _authorized = true;
      });
      _loadResponses();
    }
  }

  Future<void> _syncAllResponses() async {
    final syncedCount = await SyncService().syncAllPending();
    await ResponseStore().refresh();
    if (!mounted) return;
    setState(() {});
    final message = syncedCount > 0
        ? '$syncedCount pending response${syncedCount == 1 ? '' : 's'} synced.'
        : 'No pending responses to sync.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _primaryColor,
      ),
    );
  }

  Future<void> _confirmDelete(int index, String name) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.deleteResponse,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          l10n.confirmDeleteMessage(name),
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ResponseStore().delete(index);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.responseDeleted),
            backgroundColor: _primaryColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_authorized) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.administration)),
        drawer: const AppDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Purple banner header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primaryColor, _accentColor],
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.administration,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.enterPasswordToAccess,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Password form
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pleaseEnterPassword,
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        errorText: _errorText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.lock, color: _primaryColor),
                      ),
                      onSubmitted: (_) => _authenticate(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _primaryColor),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(l10n.cancel),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _authenticate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(l10n.unlock),
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

    // Show loading indicator while responses are being fetched
    if (!_responsesLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.administration)),
        drawer: const AppDrawer(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final responses = ResponseStore().responses;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.administration),
        actions: [
          _SyncStatusIcon(
            responses: responses,
            onSyncRequested: _syncAllResponses,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const SyncStatusBar(),
          Expanded(
            child: responses.isEmpty
                ? Center(
                    child: Text(
                      l10n.noResponsesYet,
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Purple banner header
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [_primaryColor, _accentColor],
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.formResponses,
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.responseCount(responses.length),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Responses list
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: responses.length,
                            itemBuilder: (context, index) {
                              final r = responses[index];
                              final dob = r.dob;
                              return AdminResponseCard(
                                index: index,
                                response: r,
                                dob: dob,
                                primaryColor: _primaryColor,
                                accentColor: _accentColor,
                                onDelete: () => _confirmDelete(index, r.name),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class AdminResponseCard extends StatefulWidget {
  final int index;
  final dynamic response;
  final DateTime dob;
  final Color primaryColor;
  final Color accentColor;
  final VoidCallback onDelete;

  const AdminResponseCard({
    super.key,
    required this.index,
    required this.response,
    required this.dob,
    required this.primaryColor,
    required this.accentColor,
    required this.onDelete,
  });

  @override
  State<AdminResponseCard> createState() => _AdminResponseCardState();
}

class _AdminResponseCardState extends State<AdminResponseCard> {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Timer? _waveformTimer;
  List<double> _barHeights = [10.0, 10.0, 10.0, 10.0, 10.0];
  bool _audioFileExists = false;
  StreamSubscription? _playerStateSub;

  StreamSubscription? _positionSub;

  @override
  void initState() {
    super.initState();
    final path = widget.response.voiceRecordingPath;
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        _audioFileExists = true;
        _initPlayer(path);
      }
    }
  }

  Future<void> _initPlayer(String path) async {
    _audioPlayer = AudioPlayer();

    // Configure audio session for media playback through speaker
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
    } catch (e) {
      debugPrint('Error configuring admin audio session: $e');
    }

    _playerStateSub = _audioPlayer!.playerStateStream.listen((state) {
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
          _position = _duration;
        });
        _audioPlayer!.pause();
        _audioPlayer!.seek(Duration.zero);
      }
    });

    // Don't use durationStream - it can emit unreliable values.

    _positionSub = _audioPlayer!.positionStream.listen((p) {
      if (!mounted) return;
      setState(() {
        _position = p;
      });
    });

    try {
      final fileDuration = await _audioPlayer!.setFilePath(path);
      if (mounted && fileDuration != null) {
        setState(() {
          _duration = fileDuration;
        });
      }
    } catch (e) {
      debugPrint('Error loading audio file: $e');
    }
  }

  void _startWaveformAnimation() {
    _waveformTimer?.cancel();
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (mounted && _isPlaying) {
        setState(() {
          _barHeights = List.generate(5, (index) {
            final factor = (DateTime.now().millisecond % (index + 2)) / (index + 2);
            return 8.0 + (index % 2 == 0 ? 20.0 : 12.0) * (0.3 + 0.7 * factor);
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _waveformTimer?.cancel();
    _playerStateSub?.cancel();

    _positionSub?.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (!_audioFileExists || _audioPlayer == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer!.pause();
      } else {
        if (_audioPlayer!.processingState == ProcessingState.completed) {
          await _audioPlayer!.seek(Duration.zero);
        }
        await _audioPlayer!.play();
      }
    } catch (e) {
      debugPrint('Error playing admin audio: $e');
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

  @override
  Widget build(BuildContext context) {
    final r = widget.response;
    final dob = widget.dob;
    final primaryColor = widget.primaryColor;
    final index = widget.index;

    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final chipBg = isDark ? const Color(0xFF3D2D5C) : const Color(0xFFEDE7F6);
    final textStyleColor = isDark ? Colors.white : Colors.black87;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: primaryColor, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.dobLabel('${dob.day}/${dob.month}/${dob.year}'),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          '#${index + 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        r.synced ? Icons.cloud_done : Icons.cloud_upload,
                        color: r.synced ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                        tooltip: l10n.delete,
                        onPressed: widget.onDelete,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey[300], height: 1),
              const SizedBox(height: 12),
              Text(
                l10n.emailLabel(r.email),
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    l10n.ageLabel(r.age),
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    l10n.genderLabel(r.gender),
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.experienceLabel(r.yearsOfExperience),
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: r.languages.isNotEmpty
                    ? r.languages
                        .map<Widget>(
                          (language) => Chip(
                            label: Text(language),
                            backgroundColor: Color.fromRGBO(
                              (primaryColor.r * 255).round(),
                              (primaryColor.g * 255).round(),
                              (primaryColor.b * 255).round(),
                              0.1,
                            ),
                          ),
                        )
                        .toList()
                    : [
                        Chip(
                          label: Text(l10n.none),
                          backgroundColor: Colors.grey[200],
                        ),
                      ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.heightLabel('${r.heightFeet}\'${r.heightInches}"'),
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.weightLabel(r.weight.toStringAsFixed(r.weight == r.weight.roundToDouble() ? 0 : 1)),
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.profilePhoto}: ${r.photoPath != null ? l10n.uploaded : l10n.none}',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              Text(
                '${l10n.resumePdf}: ${r.resumePath != null ? l10n.uploaded : l10n.none}',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              Row(
                children: [
                  Text(l10n.ratingStars),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) {
                      return Icon(
                        i < r.rating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: primaryColor,
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    r.agreed ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: r.agreed ? Colors.green : Colors.red[400],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    r.agreed ? l10n.agreed : l10n.notAgreed,
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ],
              ),
              if (r.transcriptionOriginal != null && r.transcriptionOriginal!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.mic, color: primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Voice Note',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (r.voiceRecordingPath != null && r.voiceRecordingPath!.isNotEmpty) ...[
                  if (_audioFileExists) ...[
                    Row(
                      children: [
                        IconButton(
                          onPressed: _togglePlayback,
                          icon: Icon(
                            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            size: 28,
                            color: primaryColor,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              width: 3,
                              height: _isPlaying ? _barHeights[index] : 8.0,
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_formatTime(_position)} / ${_formatTime(_duration)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          'Audio not available on this device',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
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
                            'Original Transcription',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          if (r.detectedLanguage != null && r.detectedLanguage!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: chipBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                r.detectedLanguage!,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.transcriptionOriginal!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: textStyleColor,
                        ),
                      ),
                      if (r.transcriptionEnglish != null && r.transcriptionEnglish!.isNotEmpty) ...[
                        const Divider(height: 12),
                        Text(
                          'English Translation',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.transcriptionEnglish!,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: textStyleColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncStatusIcon extends StatefulWidget {
  final List<dynamic> responses;
  final VoidCallback onSyncRequested;

  const _SyncStatusIcon({required this.responses, required this.onSyncRequested});

  @override
  State<_SyncStatusIcon> createState() => _SyncStatusIconState();
}

class _SyncStatusIconState extends State<_SyncStatusIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    SyncService().syncState.addListener(_onSyncStateChanged);
  }

  @override
  void dispose() {
    SyncService().syncState.removeListener(_onSyncStateChanged);
    _rotationController.dispose();
    super.dispose();
  }

  void _onSyncStateChanged() {
    if (SyncService().syncState.value == SyncState.syncing) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }
  }

  void _showDetailsSheet(BuildContext context, int total, int synced, int pending) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sync Status Details',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow(Icons.description, 'Total Responses', total.toString()),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.cloud_done, 'Synced to Cloud', synced.toString(), color: Colors.green),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.pending_actions, 'Pending Sync', pending.toString(), color: Colors.orange),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onSyncRequested();
                    },
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF673AB7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.grey[700], size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityService().isOnline,
      builder: (context, isOnline, child) {
        return ValueListenableBuilder<SyncState>(
          valueListenable: SyncService().syncState,
          builder: (context, syncState, child) {
            final pendingCount = widget.responses.where((r) => !r.synced).length;
            final syncedCount = widget.responses.length - pendingCount;

            Widget iconWidget;
            if (!isOnline) {
              iconWidget = const Icon(Icons.cloud_off, color: Colors.grey);
            } else if (syncState == SyncState.syncing) {
              iconWidget = RotationTransition(
                turns: _rotationController,
                child: const Icon(Icons.cloud_upload, color: Colors.blue),
              );
            } else if (pendingCount == 0) {
              iconWidget = const Icon(Icons.cloud_done, color: Colors.green);
            } else {
              iconWidget = Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.cloud, color: Colors.white),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        pendingCount.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: iconWidget,
                tooltip: 'Sync Status',
                onPressed: () => _showDetailsSheet(
                  context,
                  widget.responses.length,
                  syncedCount,
                  pendingCount,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
