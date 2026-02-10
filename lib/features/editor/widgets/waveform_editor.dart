import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

class WaveformEditor extends StatefulWidget {
  final String path;
  final PlayerController controller; 

  const WaveformEditor({
    super.key, 
    required this.path, 
    required this.controller
  });

  @override
  State<WaveformEditor> createState() => _WaveformEditorState();
}

class _WaveformEditorState extends State<WaveformEditor> {
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    _preparePlayer();
  }

  void _preparePlayer() async {
    // In a real app, check permission first
    await widget.controller.preparePlayer(
      path: widget.path,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );
    if (mounted) {
      setState(() {
         isReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
       return const Center(child: CircularProgressIndicator());
    }

    return AudioFileWaveforms(
      size: Size(MediaQuery.of(context).size.width, 100.0),
      playerController: widget.controller,
      enableSeekGesture: true,
      waveformType: WaveformType.fitWidth,
      playerWaveStyle: const PlayerWaveStyle(
        fixedWaveColor: Colors.white54,
        liveWaveColor: Colors.blueAccent,
        spacing: 6,
      ),
    );
  }
}
