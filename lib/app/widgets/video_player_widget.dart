import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  final String videoTitle;

  const VideoPlayerWidget({super.key, required this.videoPath, required this.videoTitle});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..addListener(() {
        setState(() {
          _sliderValue =
              _controller.value.position.inSeconds.toDouble();
        });
      });
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {
        // _controller.play();
        _controller.setLooping(false);
        _controller.setVolume(1.0);
        _controller.setPlaybackSpeed(1.0);

      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _rewind() {
    final Duration position = _controller.value.position;
    const Duration rewindDuration = Duration(seconds: 10);
    final Duration newDuration = position - rewindDuration;
    _controller.seekTo(newDuration);
  }

  void _forward() {
    final Duration position = _controller.value.position;
    const Duration forwardDuration = Duration(seconds: 10);
    final Duration newDuration = position + forwardDuration;
    _controller.seekTo(newDuration);
  }

  void _onSliderChanged(double value) {
    setState(() {
      _sliderValue = value;
    });
    final Duration newPosition = Duration(seconds: value.toInt());
    _controller.seekTo(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  _buildControls(),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildControls() {
    final position = _controller.value.position;
    final duration = _controller.value.duration;

    String formatDuration(Duration d) {
      final minutes = d.inMinutes.toString().padLeft(2, '0');
      final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _rewind,
              icon: const Icon(Icons.fast_rewind, color: Colors.blue,),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              onPressed: _playPause,
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: _forward,
              icon: const Icon(Icons.fast_forward, color: Colors.blue,),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              formatDuration(position),
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            Expanded(
              child: Slider(
                min: 0.0,
                max: _controller.value.duration.inSeconds.toDouble(),
                value: _sliderValue,
                onChanged: _onSliderChanged,
              ),
            ),
            Text(
              formatDuration(duration - position),
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ],
        ),
      ],
    );
  }
}

