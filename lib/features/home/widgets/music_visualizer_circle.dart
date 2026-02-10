import 'dart:math' as math;
import 'package:flutter/material.dart';

class MusicVisualizerCircle extends StatefulWidget {
  final bool isPlaying;
  final Color color;

  const MusicVisualizerCircle({
    super.key,
    required this.isPlaying,
    required this.color,
  });

  @override
  State<MusicVisualizerCircle> createState() => _MusicVisualizerCircleState();
}

class _MusicVisualizerCircleState extends State<MusicVisualizerCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(MusicVisualizerCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripples
          if (widget.isPlaying) ...[
            _buildRipple(0.0),
            _buildRipple(0.33),
            _buildRipple(0.66),
          ],
          
          // Main Circle
          Container(
            width: 140, // Slightly smaller than container to allow ripples
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color,
                  widget.color.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.music_note,
              size: 64,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRipple(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = (_controller.value + delay) % 1.0;
        final double scale = 1.0 + (t * 0.5); // Grow to 1.5x size
        final double opacity = (1.0 - t).clamp(0.0, 1.0);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.color.withOpacity(opacity * 0.5),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}
