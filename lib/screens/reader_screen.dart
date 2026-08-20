import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';

// Only stotras with real artwork get the immersive photo background;
// everything else falls back to a plain themed background.
const Map<String, String> _stotraBackgroundImages = {
  'ramesha-stuti': 'assets/images/rameshastuti.jpeg',
  'hayagriva-stotram': 'assets/images/hayagreevastotram.jpeg',
};

const _meaningLangLabels = {'kn': 'Kannada', 'en': 'English', 'hi': 'Hindi', 'te': 'Telugu', 'ta': 'Tamil', 'sa': 'Sanskrit'};

class ReaderScreen extends StatefulWidget {
  final Stotra stotra;
  const ReaderScreen({super.key, required this.stotra});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  // Active verse and playback position update many times a second while
  // audio plays; they live in ValueNotifiers instead of State fields so
  // only the small widgets that actually depend on them repaint — calling
  // setState() on the whole screen for every tick was what made scrolling
  // and the meaning dropdown feel janky.
  final ValueNotifier<int> _activeVerseNotifier = ValueNotifier(0);
  final ValueNotifier<Duration> _positionNotifier = ValueNotifier(Duration.zero);
  int? _lastAutoScrolled;
  bool _hasAudio = true;
  final Set<int> _expandedMeanings = {};

  // Shared, app-scoped player so playback and the OS media notification
  // survive navigating away from this screen — see services/audio_handler.dart.
  AudioPlayer get _player => audioHandler.player;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  double _speed = 1.0;
  bool _isLooping = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  late final List<GlobalKey> _verseKeys;

  String get _title => resolveScriptText(widget.stotra.title).isNotEmpty ? resolveScriptText(widget.stotra.title) : 'Stotra';

  @override
  void initState() {
    super.initState();
    _verseKeys = List.generate(widget.stotra.verses.length, (_) => GlobalKey());
    _initAudio();
  }

  Future<void> _initAudio() async {
    String? realAssetPath;
    if (widget.stotra.id == 'ramesha-stuti') realAssetPath = 'assets/audio/ramesha stuti.mp4';
    if (widget.stotra.id == 'hayagriva-stotram') realAssetPath = 'assets/audio/hayagreeva stotra.mp4';

    if (realAssetPath != null) {
      try {
        // If this stotra is already the one loaded (e.g. the user navigated
        // away and back while it kept playing in the background), don't
        // reload it — that would restart it from zero.
        final alreadyLoaded = audioHandler.mediaItem.valueOrNull?.id == realAssetPath;
        if (!alreadyLoaded) {
          final loadedDuration = await audioHandler.loadStotra(
            assetPath: realAssetPath,
            title: _title,
            composer: widget.stotra.composer,
          );
          if (loadedDuration != null && mounted) setState(() => _duration = loadedDuration);
        } else if (mounted) {
          setState(() {
            _duration = _player.duration ?? Duration.zero;
            _position = _player.position;
          });
        }

        _durationSub = _player.durationStream.listen((d) {
          if (!mounted) return;
          // Some browsers report an inaccurate/short duration before the file
          // is fully buffered, then correct it later — only accept updates
          // that are at least as long as what we already know, so the
          // progress bar never shrinks out from under an in-progress track.
          if (d != null && d > _duration) setState(() => _duration = d);
        });
        _positionSub = _player.positionStream.listen((p) {
          if (!mounted) return;
          _position = p;
          _positionNotifier.value = p;
          if (_duration.inMilliseconds > 0) {
            int vCount = widget.stotra.verses.length;
            int msPerVerse = _duration.inMilliseconds ~/ vCount;
            final newActive = (p.inMilliseconds ~/ msPerVerse).clamp(0, vCount - 1);
            if (newActive != _activeVerseNotifier.value) {
              _activeVerseNotifier.value = newActive;
            }
          }
          _scrollToActiveVerse();
        });
        _playerStateSub = _player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            if (_isLooping) {
              audioHandler.seek(Duration.zero);
              audioHandler.play();
            } else {
              audioHandler.pause();
              audioHandler.seek(Duration.zero);
            }
          }
        });
      } catch (e) {
        debugPrint('Audio file not found: $realAssetPath');
        if (mounted) setState(() => _hasAudio = false);
      }
    } else {
      setState(() => _hasAudio = false);
    }
  }

  void _scrollToActiveVerse() {
    final activeVerse = _activeVerseNotifier.value;
    if (_lastAutoScrolled == activeVerse) return;
    _lastAutoScrolled = activeVerse;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _verseKeys[activeVerse].currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic, alignment: 0.3);
      }
    });
  }

  @override
  void dispose() {
    // Don't dispose the player itself — it's shared app-wide so playback
    // and the notification keep going after this screen closes. Just stop
    // listening so we don't setState() on a disposed widget.
    _durationSub?.cancel();
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _activeVerseNotifier.dispose();
    _positionNotifier.dispose();
    super.dispose();
  }

  void _cycleSpeed() {
    setState(() {
      if (_speed == 1.0) {
        _speed = 1.25;
      } else if (_speed == 1.25) {
        _speed = 1.5;
      } else if (_speed == 1.5) {
        _speed = 2.0;
      } else if (_speed == 2.0) {
        _speed = 0.75;
      } else {
        _speed = 1.0;
      }
    });
    _player.setSpeed(_speed);
  }

  void _skip(int seconds) {
    var newPos = _position + Duration(seconds: seconds);
    if (newPos < Duration.zero) newPos = Duration.zero;
    if (newPos > _duration) newPos = _duration;
    audioHandler.seek(newPos);
  }

  void _shareStotra() {
    final buffer = StringBuffer(_title)..writeln()..writeln();
    for (final verse in widget.stotra.verses) {
      buffer.writeln(resolveScriptText(verse.text));
      buffer.writeln();
    }
    Share.share(buffer.toString().trim(), subject: _title);
  }

  void _shareVerse(int index) {
    final verse = widget.stotra.verses[index];
    final text = resolveScriptText(verse.text);
    final meaning = verse.meaning[AppState.meaningLang];
    final buffer = StringBuffer(_title)..writeln()..writeln()..writeln(text);
    if (meaning != null) {
      buffer
        ..writeln()
        ..writeln(meaning);
    }
    Share.share(buffer.toString().trim(), subject: _title);
  }

  void _showLanguagePicker() {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Widget pill(String label, String code, String currentValue, void Function(String) onSelect) {
              final selected = currentValue == code;
              return GestureDetector(
                onTap: () {
                  onSelect(code);
                  setSheetState(() {});
                  setState(() {});
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? c.accent : Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: selected ? c.accent : Colors.white.withValues(alpha: 0.32)),
                  ),
                  child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              );
            }

            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Script (verses & titles)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: scriptLangLabels.entries
                              .map((e) => pill(e.value, e.key, AppState.scriptLang, (v) => AppState.scriptLang = v))
                              .toList(),
                          ),
                          const SizedBox(height: 20),
                          const Text('Meaning Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _meaningLangLabels.entries
                              .map((e) => pill(e.value, e.key, AppState.meaningLang, (v) => AppState.meaningLang = v))
                              .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bgImage = _stotraBackgroundImages[widget.stotra.id];
    final hasBg = bgImage != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_title, style: const TextStyle(fontSize: 16, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareStotra),
          IconButton(
            icon: const Text('अA', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            onPressed: _showLanguagePicker,
          ),
          ValueListenableBuilder<Set<String>>(
            valueListenable: AppState.favorites,
            builder: (context, favoriteIds, _) {
              final isFav = favoriteIds.contains(widget.stotra.id);
              return IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(isFav),
                    color: isFav ? c.accent : Colors.white,
                  ),
                ),
                onPressed: () => AppState.toggleFavorite(widget.stotra.id),
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (hasBg) ...[
            Image.asset(bgImage, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.55), Colors.black.withValues(alpha: 0.8)],
                ),
              ),
            ),
          ] else
            Container(color: c.background),
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: ConstrainedBox(
                        // When there are only a few verses, stretch them to fill
                        // the viewport instead of leaving dead space below —
                        // longer stotras simply outgrow this and scroll normally.
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: ValueListenableBuilder<int>(
                          valueListenable: _activeVerseNotifier,
                          builder: (context, activeVerse, _) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (int i = 0; i < widget.stotra.verses.length; i++)
                                  _buildVerseCard(context, i, hasBg, activeVerse),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildPlayerBar(c, hasBg),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard(BuildContext context, int index, bool hasBg, int activeVerse) {
    final c = context.colors;
    final verse = widget.stotra.verses[index];
    final isActive = index == activeVerse;
    final isExpanded = _expandedMeanings.contains(index);
    final verseText = resolveScriptText(verse.text);
    final meaningText = verse.meaning[AppState.meaningLang];

    final baseTextColor = hasBg ? Colors.white : c.heading;
    final mutedColor = hasBg ? Colors.white70 : c.mutedText;
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.8;

    // Active verse stays white but gets a soft orange neon-glow halo instead
    // of a solid color swap or a bounding box.
    final List<Shadow>? textShadow = hasBg
      ? (isActive
          ? [
              const Shadow(color: Colors.black87, blurRadius: 6),
              Shadow(color: c.accent, blurRadius: 14),
              Shadow(color: c.accent.withValues(alpha: 0.85), blurRadius: 28),
            ]
          : const [Shadow(color: Colors.black87, blurRadius: 6)])
      : null;

    // Verse — plain text, no box, share/dropdown docked to its right.
    Widget verseRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            style: TextStyle(fontSize: 23, height: 1.75, letterSpacing: 0.2, color: baseTextColor, fontWeight: isActive ? FontWeight.bold : (hasBg ? FontWeight.w600 : FontWeight.normal), shadows: textShadow),
            textAlign: TextAlign.left,
            child: Text(verseText, textAlign: TextAlign.left),
          ),
        ),
        Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => _shareVerse(index),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Icon(Icons.share, size: 22, color: mutedColor),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => setState(() {
                if (isExpanded) {
                  _expandedMeanings.remove(index);
                } else {
                  _expandedMeanings.add(index);
                }
              }),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  turns: isExpanded ? 0.5 : 0,
                  child: Icon(Icons.keyboard_arrow_down_rounded, size: 24, color: mutedColor),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    // Meaning bubble — chat-style reply, anchored right.
    Widget meaningBubble = _bubble(
      hasBg: hasBg,
      c: c,
      tint: c.accent.withValues(alpha: hasBg ? 0.22 : 0.12),
      radius: const BorderRadius.only(
        topLeft: Radius.circular(18),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(18),
        bottomRight: Radius.circular(18),
      ),
      child: Text(
        meaningText ?? 'Translation coming soon',
        textAlign: TextAlign.left,
        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: baseTextColor, shadows: textShadow),
      ),
    );

    return RepaintBoundary(
      child: GestureDetector(
        key: _verseKeys[index],
        onTap: () => _activeVerseNotifier.value = index,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verseRow,
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 280),
                sizeCurve: Curves.easeOutCubic,
                firstCurve: Curves.easeOut,
                secondCurve: Curves.easeIn,
                crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxBubbleWidth), child: meaningBubble),
                  ),
                ),
              ),
              if (index < widget.stotra.verses.length - 1)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Divider(height: 1, color: hasBg ? Colors.white24 : c.divider),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bubble({required bool hasBg, required AppColors c, required Widget child, Color? tint, Color? borderColor, required BorderRadius radius}) {
    // No BackdropFilter here on purpose: this bubble lives inside the
    // scrolling verse list, and a live blur has to re-sample the frame
    // behind it on every single scroll frame — that's what made scrolling
    // feel sluggish. A slightly more opaque flat tint keeps the glassy look
    // at effectively zero cost since it's just a translated layer.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: tint ?? (hasBg ? Colors.white.withValues(alpha: 0.20) : c.surface),
        borderRadius: radius,
        border: Border.all(color: borderColor ?? (hasBg ? Colors.white.withValues(alpha: 0.28) : c.divider), width: borderColor != null ? 1.5 : 1),
      ),
      child: child,
    );
  }

  Widget _pillButton({required BuildContext context, required Widget child, required VoidCallback onTap, bool active = false}) {
    final c = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? c.accent.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: active ? c.accent : Colors.white.withValues(alpha: 0.28)),
        ),
        child: child,
      ),
    );
  }

  Widget _buildPlayerBar(AppColors c, bool hasBg) {
    Widget bar = Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: hasBg ? Colors.black.withValues(alpha: 0.4) : c.chrome,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: hasBg ? Border.all(color: Colors.white.withValues(alpha: 0.15)) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<Duration>(
            valueListenable: _positionNotifier,
            builder: (context, position, _) {
              return SliderTheme(
                data: SliderTheme.of(context).copyWith(trackHeight: 3),
                child: Slider(
                  value: _duration.inMilliseconds > 0 ? (position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0) : 0.0,
                  onChanged: (v) {
                    final pos = Duration(milliseconds: (_duration.inMilliseconds * v).round());
                    audioHandler.seek(pos);
                  },
                  activeColor: c.accent,
                  inactiveColor: Colors.white30,
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _pillButton(
                context: context,
                onTap: _cycleSpeed,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${_speed}x', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Icon(Icons.expand_more, color: Colors.white, size: 18),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.replay_5, color: Colors.white), onPressed: () => _skip(-5)),
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  if (!_hasAudio) {
                    return const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.music_off, color: Colors.white54),
                    );
                  }

                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing ?? false;

                  if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                    return CircularProgressIndicator(color: c.accent);
                  }
                  return FloatingActionButton(
                    backgroundColor: c.accent,
                    onPressed: playing ? audioHandler.pause : audioHandler.play,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                      child: Icon(playing ? Icons.pause : Icons.play_arrow, key: ValueKey(playing), color: Colors.white),
                    ),
                  );
                }
              ),
              IconButton(icon: const Icon(Icons.forward_5, color: Colors.white), onPressed: () => _skip(5)),
              _pillButton(
                context: context,
                active: _isLooping,
                onTap: () => setState(() {
                  _isLooping = !_isLooping;
                  _player.setLoopMode(_isLooping ? LoopMode.one : LoopMode.off);
                }),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_isLooping ? Icons.repeat_one : Icons.repeat, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    const Text('Loop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (hasBg) {
      bar = ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24), child: bar),
      );
    }
    return bar;
  }
}
