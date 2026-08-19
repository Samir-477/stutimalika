import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/models.dart';

class ReaderScreen extends StatefulWidget {
  final Stotra stotra;
  const ReaderScreen({super.key, required this.stotra});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  int _activeVerse = 0;
  bool _hasAudio = true;
  
  final AudioPlayer _player = AudioPlayer();
  double _speed = 1.0;
  bool _isLooping = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    String? realAssetPath;
    if (widget.stotra.id == 'ramesha-stuti') realAssetPath = 'assets/audio/ramesha stuti.mp4';
    if (widget.stotra.id == 'hayagriva-stotram') realAssetPath = 'assets/audio/hayagreeva stotra.mp4';

    if (realAssetPath != null) {
      try {
        await _player.setAsset(realAssetPath);
        _player.durationStream.listen((d) => setState(() => _duration = d ?? Duration.zero));
        _player.positionStream.listen((p) {
          if (!mounted) return;
          setState(() {
            _position = p;
            if (_duration.inMilliseconds > 0) {
              int vCount = widget.stotra.verses.length;
              int msPerVerse = _duration.inMilliseconds ~/ vCount;
              _activeVerse = (p.inMilliseconds ~/ msPerVerse).clamp(0, vCount - 1);
            }
          });
        });
        _player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            if (_isLooping) {
              _player.seek(Duration.zero);
              _player.play();
            } else {
              _player.pause();
              _player.seek(Duration.zero);
            }
          }
        });
      } catch (e) {
        debugPrint('Audio file not found: $realAssetPath');
        setState(() => _hasAudio = false);
      }
    } else {
      setState(() => _hasAudio = false);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _cycleSpeed() {
    setState(() {
      if (_speed == 1.0) _speed = 1.25;
      else if (_speed == 1.25) _speed = 1.5;
      else if (_speed == 1.5) _speed = 2.0;
      else if (_speed == 2.0) _speed = 0.75;
      else _speed = 1.0;
    });
    _player.setSpeed(_speed);
  }

  void _skip(int seconds) {
    var newPos = _position + Duration(seconds: seconds);
    if (newPos < Duration.zero) newPos = Duration.zero;
    if (newPos > _duration) newPos = _duration;
    _player.seek(newPos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stotra.title[AppState.globalLang] ?? widget.stotra.title['kn'] ?? widget.stotra.title['sa'] ?? 'Stotra', style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(
            icon: const Text('अA', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(padding: EdgeInsets.all(16), child: Text('Select Meaning Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7C5A3A)))),
                        ListTile(title: const Text('Kannada'), onTap: () { setState(() => AppState.globalLang = 'kn'); Navigator.pop(context); }),
                        ListTile(title: const Text('English'), onTap: () { setState(() => AppState.globalLang = 'en'); Navigator.pop(context); }),
                        ListTile(title: const Text('Hindi'), onTap: () { setState(() => AppState.globalLang = 'hi'); Navigator.pop(context); }),
                        ListTile(title: const Text('Telugu'), onTap: () { setState(() => AppState.globalLang = 'te'); Navigator.pop(context); }),
                        ListTile(title: const Text('Tamil'), onTap: () { setState(() => AppState.globalLang = 'ta'); Navigator.pop(context); }),
                        ListTile(title: const Text('Sanskrit'), onTap: () { setState(() => AppState.globalLang = 'sa'); Navigator.pop(context); }),
                      ],
                    ),
                  );
                }
              );
            },
          ),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.stotra.verses.length,
              itemBuilder: (context, index) {
                final verse = widget.stotra.verses[index];
                final isActive = index == _activeVerse;
                return GestureDetector(
                  onTap: () => setState(() => _activeVerse = index),
                  child: Card(
                    color: isActive ? const Color(0xFFFFE0B2) : const Color(0xFFFFFAF3),
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isActive ? const Color(0xFFE8863A) : Colors.transparent, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            verse.text[AppState.globalLang] ?? verse.text['kn'] ?? verse.text['sa'] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20, height: 1.5, color: Color(0xFF4A3B2C)),
                          ),
                          const Divider(height: 24, thickness: 1, color: Color(0xFFE2D1C3)),
                          Text(
                            verse.meaning[AppState.globalLang] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xFF8B7355)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Fake Bottom Player
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF7C5A3A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: _duration.inMilliseconds > 0 ? _position.inMilliseconds / _duration.inMilliseconds : 0,
                  onChanged: (v) {
                    final pos = Duration(milliseconds: (_duration.inMilliseconds * v).round());
                    _player.seek(pos);
                  },
                  activeColor: const Color(0xFFE8863A),
                  inactiveColor: Colors.white30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(_isLooping ? Icons.repeat_one : Icons.repeat, color: _isLooping ? const Color(0xFFE8863A) : Colors.white),
                      onPressed: () => setState(() {
                        _isLooping = !_isLooping;
                        _player.setLoopMode(_isLooping ? LoopMode.one : LoopMode.off);
                      }),
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
                          return const CircularProgressIndicator(color: Color(0xFFE8863A));
                        }
                        return FloatingActionButton(
                          backgroundColor: const Color(0xFFE8863A),
                          onPressed: playing ? _player.pause : _player.play,
                          child: Icon(playing ? Icons.pause : Icons.play_arrow, color: Colors.white),
                        );
                      }
                    ),
                    IconButton(icon: const Icon(Icons.forward_5, color: Colors.white), onPressed: () => _skip(5)),
                    TextButton(
                      onPressed: _cycleSpeed,
                      child: Text('${_speed}x', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
