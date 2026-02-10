import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:ringo_ringtones/core/services/ringtone_manager.dart';
import 'package:ringo_ringtones/core/services/audio_processing_service.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:ringo_ringtones/l10n/app_localizations.dart';
import 'package:ringo_ringtones/core/services/audio_service.dart';

// --- Constants / Theme ---
// We keep neon accents as a "Studio" feature, but background adapts
const Color kNeonCyan = Color(0xFF2D4A86);
const Color kNeonPurple = Color(0xFFD600FF);

class EditorScreen extends ConsumerStatefulWidget {
  final String? initialFilePath;
  const EditorScreen({super.key, this.initialFilePath});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  String? selectedPath;
  late PlayerController _playerController;

  // Tools & State
  RangeValues _trimRange = const RangeValues(0, 30);
  double _maxDuration = 30.0;
  double _currentPos = 0.0;
  
  bool _isPlaying = false;
  bool _isExporting = false;
  bool _isLoading = false;
  
  // Manual Input Controllers
  late TextEditingController _startController;
  late TextEditingController _endController;
  final FocusNode _startFocus = FocusNode();
  final FocusNode _endFocus = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // Stop background music
    ref.read(audioServiceProvider).pause();
    
    _startController = TextEditingController(text: "0:00");
    _endController = TextEditingController(text: "0:30");
    
    _playerController = PlayerController();
    _playerController.onCompletion.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
    _playerController.onCurrentDurationChanged.listen((ms) {
       if (mounted) {
         final double seconds = ms / 1000;
         if (_isPlaying && seconds >= _trimRange.end) {
            _playerController.pausePlayer();
            _playerController.seekTo((_trimRange.start * 1000).toInt());
            setState(() {
              _isPlaying = false;
              _currentPos = _trimRange.start;
            });
         } else {
            setState(() => _currentPos = seconds);
         }
       }
    });

    if (widget.initialFilePath != null) {
      // Defer loading to allow context/widget readiness if needed, though initState is fine for data prep
      WidgetsBinding.instance.addPostFrameCallback((_) {
         _loadAudioFromFile(widget.initialFilePath!);
      });
    }
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _startFocus.dispose();
    _endFocus.dispose();
    _playerController.dispose();
    super.dispose();
  }

  // Sync helpers
  void _updateControllers() {
     if (!_startFocus.hasFocus) {
        _startController.text = _format(_trimRange.start);
     }
     if (!_endFocus.hasFocus) {
        _endController.text = _format(_trimRange.end);
     }
  }

  Future<void> _loadAudioFromFile(String path) async {
      setState(() {
        _isLoading = true; // Start loading
        selectedPath = path;
        _currentPos = 0;
        _isPlaying = false;
        _trimRange = const RangeValues(0, 30);
      });

      // We still use preparePlayer from Waveforms package logic even if we don't show the waveform
      await _playerController.preparePlayer(
        path: selectedPath!,
        shouldExtractWaveform: false, // Don't need visual
        noOfSamples: 100,
        volume: 1.0,
      );
      final ms = await _playerController.getDuration();
      if (mounted) {
          setState(() {
            if (ms > 0) {
              _maxDuration = ms / 1000.0;
              _trimRange = RangeValues(0, _maxDuration);
              _updateControllers();
            }
            _isLoading = false; // Stop loading
          });
      }
  }

  Future<void> _pickAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null && result.files.single.path != null) {
        await _loadAudioFromFile(result.files.single.path!);
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  Future<void> _togglePlay() async {
    if (_playerController.playerState.isPlaying) {
      await _playerController.pausePlayer();
      setState(() => _isPlaying = false);
    } else {
      await _playerController.startPlayer();
      setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          selectedPath == null ? _buildEmptyStudioState() : _buildStudioInterface(),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(l10n.editorTitle),
      actions: [
         if (selectedPath != null) ...[
           Padding(
             padding: const EdgeInsets.only(right: 8),
             child: TextButton.icon(
               onPressed: _isExporting ? null : () => _exportAndSet(),
               icon: const Icon(Icons.ring_volume, size: 16),
               label: Text(l10n.editorSet),
               style: TextButton.styleFrom(
                 foregroundColor: kNeonCyan,
               ),
             ),
           ),
           Padding(
             padding: const EdgeInsets.only(right: 16),
             child: FilledButton.icon(
               onPressed: _isExporting ? null : _exportRingtone,
               icon: _isExporting 
                   ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                   : const Icon(Icons.save_alt, size: 16),
               label: Text(_isExporting ? l10n.labelSaving : l10n.editorExport),
               style: FilledButton.styleFrom(
                 backgroundColor: kNeonPurple,
                 foregroundColor: Colors.white,
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
               ),
             ),
           )
         ]
      ],
    );
  }

  Widget _buildEmptyStudioState() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.audio_file_outlined, size: 80, color: colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _pickAudio,
            icon: const Icon(Icons.add),
            label: Text(l10n.editorImport),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStudioInterface() {
     final colorScheme = Theme.of(context).colorScheme;
     final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // 1. Header Info (Compact)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          color: colorScheme.surface,
          child: Center(
            child: Text(
              selectedPath!.split('/').last, 
              style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
               color: colorScheme.surfaceContainerHighest, // Adaptive Theme Color
               borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))]
            ),
            // Wrap in LayoutBuilder to allow scrolling but keep expansion when possible
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           const SizedBox(height: 30),
                           
                           // 2. MAIN SEEKER (Waveform Area)
                           Text(l10n.previewSeek, style: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.5), fontSize: 10, letterSpacing: 1.5)),
                           const SizedBox(height: 10),
                           SizedBox(
                             height: 120, // Tall waveform area
                             child: WaveformSeeker(
                                duration: _maxDuration > 0 ? _maxDuration : 30.0,
                                currentPos: _currentPos,
                                trimStart: _trimRange.start,
                                trimEnd: _trimRange.end,
                                onSeek: (pos) {
                                   // Constrain seek to trim range
                                   final double constrained = pos.clamp(_trimRange.start, _trimRange.end);
                                   _playerController.seekTo((constrained * 1000).toInt());
                                   setState(() => _currentPos = constrained);
                                },
                             ),
                           ),
                           
                           const SizedBox(height: 40),

                           // 3. TRIM DECK (Dedicated Slider)
                           Text(l10n.trimRange, style: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.5), fontSize: 10, letterSpacing: 1.5)),
                           const SizedBox(height: 10),
                           TrimEditor(
                              duration: _maxDuration > 0 ? _maxDuration : 30.0,
                              trimStart: _trimRange.start,
                              trimEnd: _trimRange.end,
                              onTrimChange: (start, end) {
                                  // Logic: If start handle moves, seek to it.
                                  if (start != _trimRange.start) {
                                     _playerController.seekTo((start * 1000).toInt());
                                     // Update current pos visual immediately
                                     setState(() {
                                        _trimRange = RangeValues(start, end);
                                        _currentPos = start;
                                        _updateControllers(); // Sync text boxes
                                     });
                                  } else {
                                     setState(() {
                                        _trimRange = RangeValues(start, end);
                                        _updateControllers(); // Sync text boxes
                                     });
                                  }
                              },
                           ),
                           const SizedBox(height: 8),
                           // Duration & Time Info moved here
                           Text(
                             "${_format(_trimRange.start)} - ${_format(_trimRange.end)} • Duration: ${_formatDouble(_trimRange.end - _trimRange.start)}s",
                             style: TextStyle(color: kNeonCyan, fontSize: 12),
                           ),

                           const SizedBox(height: 16),
                           // 4. Manual Text Input Row
                           _buildManualTimeRow(colorScheme),

                           const Spacer(),

                           // 5. Transport Controls
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               IconButton(
                                 onPressed: () {
                                    // Jump to Start
                                    double target = _trimRange.start - 5.0;
                                    if (target < 0) target = 0;
                                    _playerController.seekTo((target * 1000).toInt());
                                    setState(() => _currentPos = target);
                                 }, 
                                 icon: Icon(Icons.replay_5, color: colorScheme.onSurfaceVariant),
                                 iconSize: 32,
                               ),
                               const SizedBox(width: 30),
                               GestureDetector(
                                 onTap: _togglePlay,
                                 child: Container(
                                   width: 80, height: 80,
                                   decoration: BoxDecoration(
                                     shape: BoxShape.circle,
                                     color: _isPlaying ? kNeonCyan : colorScheme.surfaceContainerHighest,
                                     boxShadow: _isPlaying 
                                       ? [BoxShadow(color: kNeonCyan.withOpacity(0.5), blurRadius: 30, spreadRadius: 2)] 
                                       : []
                                   ),
                                   child: Icon(
                                     _isPlaying ? Icons.pause : Icons.play_arrow_rounded, 
                                     size: 40, 
                                     color: _isPlaying ? Colors.black : colorScheme.onSurface
                                   ),
                                 ),
                               ),
                               const SizedBox(width: 30),
                               IconButton(
                                 onPressed: (){
                                    // Jump forward
                                    double target = _currentPos + 5.0;
                                    if (target > _maxDuration) target = _maxDuration;
                                    _playerController.seekTo((target * 1000).toInt());
                                    setState(() => _currentPos = target);
                                 }, 
                                 icon: Icon(Icons.forward_5, color: colorScheme.onSurfaceVariant),
                                 iconSize: 32,
                               ),
                             ],
                           ),
                           const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualTimeRow(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           // Start Input
           _buildTimeInput("Start", _startController, _startFocus, (val) {
              final d = _parseDuration(val);
              if (d != null && d >= 0 && d < _trimRange.end) {
                 final newStart = d;
                 setState(() {
                    _trimRange = RangeValues(newStart, _trimRange.end);
                    _currentPos = newStart;
                 });
                 _playerController.seekTo((newStart * 1000).toInt());
              } else {
                // Revert if invalid
                _updateControllers();
              }
           }),
           const SizedBox(width: 20),
           // End Input
           _buildTimeInput("End", _endController, _endFocus, (val) {
              final d = _parseDuration(val);
              if (d != null && d > _trimRange.start && d <= _maxDuration) {
                 setState(() => _trimRange = RangeValues(_trimRange.start, d));
              } else {
                 _updateControllers();
              }
           }),
        ],
      ),
    );
  }

  Widget _buildTimeInput(String label, TextEditingController ctrl, FocusNode focus, Function(String) onSubmitted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          height: 40,
          child: TextField(
            controller: ctrl,
            focusNode: focus,
            keyboardType: TextInputType.datetime, // Better for colons
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
               filled: true,
               fillColor: Colors.white.withOpacity(0.05),
               contentPadding: const EdgeInsets.only(bottom: 2), // Center vertically roughly
               enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
               focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kNeonCyan)),
            ),
            onSubmitted: onSubmitted,
            onEditingComplete: () {
               focus.unfocus();
               onSubmitted(ctrl.text);
            },
          ),
        )
      ],
    );
  }
  
  // Helpers
  String _format(double s) {
     final int m = s ~/ 60;
     final int sec = (s % 60).toInt();
     return "$m:${sec.toString().padLeft(2,'0')}";
  }
  
  String _formatDouble(double s) {
     return s.toStringAsFixed(1);
  }

  // Parse "MM:SS" or "SS" to seconds
  double? _parseDuration(String input) {
     try {
       if (input.contains(':')) {
          final parts = input.split(':');
          if (parts.length == 2) {
             final int m = int.parse(parts[0]);
             final double s = double.parse(parts[1]);
             return (m * 60) + s;
          }
       }
       return double.tryParse(input);
     } catch (e) {
       return null;
     }
  }  
  // Wrapper to Export then Show Options
  Future<void> _exportAndSet() async {
      await _exportRingtone(showOptions: true);
  }

  Future<void> _exportRingtone({bool showOptions = false}) async {
    if (selectedPath == null) return;
    final l10n = AppLocalizations.of(context)!;
    
    setState(() => _isExporting = true);

    try {
      final String inputPath = selectedPath!;
      final Directory tempDir = await getTemporaryDirectory();
      final String title = "Ringo_Edited_${DateTime.now().millisecondsSinceEpoch}.m4a";
      final String outPath = "${tempDir.path}/$title";

      // Calculate parameters
      final double start = _trimRange.start;
      final double end = _trimRange.end;

      debugPrint("Exporting native trim: $start to $end");

      final String? resultPath = await ref.read(audioProcessingServiceProvider).trimAudio(
        inputPath: inputPath,
        outputPath: outPath,
        start: start,
        end: end,
      );

      if (resultPath != null) {
          if (showOptions) {
              if (mounted) _showSetOptions(resultPath);
          } else {
              // Normal Save to Music
              final String? publicPath = await ref.read(ringtoneManagerProvider).saveToMusic(resultPath, title);
              
              if (mounted) {
                if (publicPath != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${l10n.msgSavedToMusic}: $publicPath"), duration: const Duration(seconds: 4)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.failedToSaveMusic)),
                  );
                }
              }
          }
      } else {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(l10n.nativeTrimFailed)),
           );
         }
      }
      
    } catch (e) {
       debugPrint("Export Error: $e");
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric(e.toString()))));
       }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showSetOptions(String filePath) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.call),
                title: Text(l10n.setAsRingtone),
                onTap: () => _handleSetRingtone(filePath, 'ringtone'),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(l10n.setAsNotification),
                onTap: () => _handleSetRingtone(filePath, 'notification'),
              ),
              ListTile(
                leading: const Icon(Icons.alarm),
                title: Text(l10n.setAsAlarm),
                onTap: () => _handleSetRingtone(filePath, 'alarm'),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(l10n.setForContact),
                onTap: () => _handleSetRingtone(filePath, 'contact'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSetRingtone(String filePath, String type) async {
    Navigator.pop(context); // Close sheet
    final l10n = AppLocalizations.of(context)!;
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final ringtoneManager = ref.read(ringtoneManagerProvider);
      bool success = false;
      
      switch (type) {
        case 'ringtone':
          success = await ringtoneManager.setRingtone(filePath);
          break;
        case 'notification':
          success = await ringtoneManager.setNotification(filePath);
          break;
        case 'alarm':
          success = await ringtoneManager.setAlarm(filePath);
          break;
        case 'contact':
           if (await FlutterContacts.requestPermission()) {
               final contact = await FlutterContacts.openExternalPick();
               if (contact != null) {
                   String contactUri = "content://com.android.contacts/contacts/${contact.id}";
                   success = await ringtoneManager.setRingtoneForContact(filePath, contactUri);
               } else {
                 if (mounted) Navigator.pop(context);
                 return;
               }
           } else {
              if (mounted) {
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.permissionContact)),
                 );
              }
              return;
           }
          break;
      }

      if (mounted) {
        Navigator.pop(context); // Close loading
        if (success) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('${l10n.detailSetSuccess} $type')),
           );
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(l10n.detailSetFailed)),
           );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric(e.toString()))));
      }
    }
  }
}

// ==========================================
// 1. WAVEFORM SEEKER WIDGET
// ==========================================
class WaveformSeeker extends StatelessWidget {
  final double duration;
  final double currentPos;
  final double trimStart;
  final double trimEnd;
  final Function(double) onSeek;
  
  const WaveformSeeker({super.key, required this.duration, required this.currentPos, required this.trimStart, required this.trimEnd, required this.onSeek});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
       onHorizontalDragUpdate: (d) => _handleSeek(context, d.localPosition.dx),
       onTapDown: (d) => _handleSeek(context, d.localPosition.dx),
       child: Container(
         width: double.infinity,
         color: Colors.transparent, // Hit test for full area
         child: CustomPaint(
            painter: _WaveformPainter(
              duration: duration,
              currentPos: currentPos,
              trimStart: trimStart,
              trimEnd: trimEnd,
              // Pass theme color for bars
              barColor: colorScheme.onSurface,
            ),
         ),
       ),
    );
  }
  
  void _handleSeek(BuildContext context, double dx) {
     final RenderBox box = context.findRenderObject() as RenderBox;
     final double width = box.size.width;
     final double pos = (dx / width).clamp(0.0, 1.0) * duration;
     onSeek(pos);
  }
}

class _WaveformPainter extends CustomPainter {
  final double duration;
  final double currentPos;
  final double trimStart;
  final double trimEnd;
  final Color barColor;
  
  _WaveformPainter({
    required this.duration, 
    required this.currentPos, 
    required this.trimStart, 
    required this.trimEnd, 
    required this.barColor
  });

  @override
  void paint(Canvas canvas, Size size) {
     final double cy = size.height / 2;
     
     // 1. Draw Dummy Waveform Bars (Background)
     final Paint barPaint = Paint()..strokeWidth = 3..strokeCap = StrokeCap.round;
     final int barCount = 40;
     final double spacing = size.width / barCount;
     
     for (int i = 0; i < barCount; i++) {
        double x = i * spacing + spacing/2;
        double progress = i / barCount;
        double time = progress * duration;
        
        // Determine color based on "In Trim Range"
        bool inRange = time >= trimStart && time <= trimEnd;
        // Use theme color with opacity instead of white
        barPaint.color = inRange ? barColor.withOpacity(0.5) : barColor.withOpacity(0.15);
        
        // Dynamic height (simulated sine)
        double h = 20 + 20 * (0.5 + 0.5 *  (i % 5) / 5);
        canvas.drawLine(Offset(x, cy - h), Offset(x, cy + h), barPaint);
     }
     
     // 2. Playhead Line
     final double xPlay = (currentPos / duration) * size.width;
     final Paint playPaint = Paint()..color = kNeonCyan..strokeWidth = 2;
     canvas.drawLine(Offset(xPlay, 0), Offset(xPlay, size.height), playPaint);
     
     // 3. Playhead Knob
     canvas.drawCircle(Offset(xPlay, 0), 4, Paint()..color = kNeonCyan);
     canvas.drawCircle(Offset(xPlay, size.height), 4, Paint()..color = kNeonCyan);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


// ==========================================
// 2. TRIM EDITOR WIDGET
// ==========================================
class TrimEditor extends StatefulWidget {
  final double duration;
  final double trimStart;
  final double trimEnd;
  final Function(double, double) onTrimChange;

  const TrimEditor({super.key, required this.duration, required this.trimStart, required this.trimEnd, required this.onTrimChange});

  @override
  State<TrimEditor> createState() => _TrimEditorState();
}

class _TrimEditorState extends State<TrimEditor> {
  int? _activeHandle; // 0: Start, 1: End

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
       onHorizontalDragStart: (d) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final double w = box.size.width;
          final double x = d.localPosition.dx;
          
          final double xStart = (widget.trimStart / widget.duration) * w;
          final double xEnd = (widget.trimEnd / widget.duration) * w;
          
          const double hitRadius = 40.0;
          
          if ((x - xStart).abs() < hitRadius) {
             _activeHandle = 0;
          } else if ((x - xEnd).abs() < hitRadius) {
             _activeHandle = 1;
          } else {
            // Drag middle to move both? Optional.
            _activeHandle = null;
          }
       },
       onHorizontalDragUpdate: (d) {
          if (_activeHandle == null) return;
          final RenderBox box = context.findRenderObject() as RenderBox;
          final double w = box.size.width;
          final double time = (d.localPosition.dx / w).clamp(0.0, 1.0) * widget.duration;
          
          if (_activeHandle == 0) {
             // Start
             if (time < widget.trimEnd - 1.0) {
                widget.onTrimChange(time, widget.trimEnd);
             }
          } else {
             // End
             if (time > widget.trimStart + 1.0) {
                widget.onTrimChange(widget.trimStart, time);
             }
          }
       },
       onHorizontalDragEnd: (_) => _activeHandle = null,
       child: SizedBox(
         height: 60,
         width: double.infinity,
         child: CustomPaint(
            painter: _TrimPainter(
               duration: widget.duration,
               trimStart: widget.trimStart,
               trimEnd: widget.trimEnd,
               // Pass theme color for track
               trackColor: colorScheme.onSurface,
            ),
         ),
       ),
    );
  }
}

class _TrimPainter extends CustomPainter {
  final double duration;
  final double trimStart;
  final double trimEnd;
  final Color trackColor;
  
  _TrimPainter({
    required this.duration, 
    required this.trimStart, 
    required this.trimEnd, 
    required this.trackColor
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cy = size.height / 2;
    
    // 1. Track (Adaptive Color)
    final Paint trackPaint = Paint()..color = trackColor.withOpacity(0.15)..strokeWidth = 4..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), trackPaint);
    
    // 2. Active Range (Highlighted)
    final double xStart = (trimStart / duration) * size.width;
    final double xEnd = (trimEnd / duration) * size.width;
    
    final Paint activePaint = Paint()..color = kNeonCyan..strokeWidth = 4;
    canvas.drawLine(Offset(xStart, cy), Offset(xEnd, cy), activePaint);
    
    // 3. Handles (Distinct Capsules)
    final Paint handlePaint = Paint()..color = kNeonCyan;
    final Paint gripPaint = Paint()..color = Colors.black..strokeWidth = 2;
    
    void drawHandle(double x) {
       final Rect r = Rect.fromCenter(center: Offset(x, cy), width: 20, height: 40);
       final RRect rr = RRect.fromRectAndRadius(r, const Radius.circular(8));
       canvas.drawRRect(rr, handlePaint);
       // Grip
       canvas.drawLine(Offset(x, cy - 8), Offset(x, cy + 8), gripPaint);
    }
    
    drawHandle(xStart);
    drawHandle(xEnd);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
