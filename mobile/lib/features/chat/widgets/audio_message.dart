import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../data/models/message_model.dart';
import 'package:logger/logger.dart';
final Logger logger = Logger();


class AudioMessage extends StatefulWidget {
  final Message message;
  final bool isMe;

  const AudioMessage({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  State<AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading = state == PlayerState.disposed || state == PlayerState.stopped;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Botón de play/pause
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isMe ? Colors.white.withValues(alpha: 0.2) : Colors.grey[300],
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.isMe ? Colors.white : Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      : Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: widget.isMe ? Colors.white : Theme.of(context).primaryColor,
                          size: 24,
                        ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Waveform y progreso
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Simulación de waveform
                    SizedBox(
                      height: 30,
                      child: Row(
                        children: List.generate(20, (index) {
                          final progress = _duration.inMilliseconds > 0
                              ? _position.inMilliseconds / _duration.inMilliseconds
                              : 0.0;
                          final barProgress = index / 20;
                          final isActive = barProgress <= progress;
                          
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              height: (index % 4 + 1) * 6.0,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? (widget.isMe ? Colors.white : Theme.of(context).primaryColor)
                                    : (widget.isMe ? Colors.white.withValues(alpha: 0.3) : Colors.grey[400]),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Duración
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isMe ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isMe ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Información adicional
          if (widget.message.metadata != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.mic,
                  size: 14,
                  color: widget.isMe ? Colors.white70 : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatFileSize(widget.message.metadata!['size']),
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.isMe ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(widget.message.audioUrl!));
      }
    } catch (e) {
      logger.e('Error playing audio: $e');
      
      // Verificar que el widget sigue montado antes de usar BuildContext
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al reproducir audio')),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(dynamic bytes) {
    if (bytes == null) return '';
    
    final int size = bytes is int ? bytes : int.tryParse(bytes.toString()) ?? 0;
    
    if (size < 1024) {
      return '${size}B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
}