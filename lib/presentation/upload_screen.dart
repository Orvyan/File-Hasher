import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../application/file_hash_service.dart';
import '../infrastructure/storage_service.dart';
import 'package:flutter/services.dart';
import 'widgets/glass_panel.dart';
import 'widgets/loader_overlay.dart';
import 'widgets/orvyan_bg.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  double _progress = 0.0;
  bool _working = false;
  String? _hash;
  String? _filename;
  List<HashRecord> _history = [];

  final _fileHashService = FileHashService();
  final _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final hist = await _storage.loadHistory();
    setState(() => _history = hist);
  }

  Future<void> _pickAndHash() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: false);
      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path == null) return;
      setState(() {
        _working = true;
        _progress = 0;
        _hash = null;
        _filename = result.files.single.name;
      });

      final file = File(path);

      final started = DateTime.now();
      final computedHash = await _fileHashService.computeSha256(file, onProgress: (p) {
        setState(() => _progress = p);
      });

      final elapsed = DateTime.now().difference(started);
      if (elapsed.inMilliseconds < 3000) {
        await Future.delayed(Duration(milliseconds: 3000 - elapsed.inMilliseconds));
      }

      final record = HashRecord(
        filename: result.files.single.name,
        hash: computedHash,
        timestampEpochMs: DateTime.now().millisecondsSinceEpoch,
      );
      await _storage.saveRecord(record);
      await _loadHistory();

      setState(() {
        _working = false;
        _hash = computedHash;
        _progress = 1.0;
      });
    } catch (e) {
      setState(() => _working = false);
      _showSnackbar('Error: $e');
    }
  }

  void _copyHash() {
    final value = _hash;
    if (value == null) return;
    Clipboard.setData(ClipboardData(text: value));
    _showSnackbar('Hash copied to clipboard');
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _headline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('File Hasher', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(
          'Select a file and create a verifiable SHA-256 fingerprint.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _actionBar() {
    return Row(
      children: [
        FilledButton.tonalIcon(
          onPressed: _working ? null : _pickAndHash,
          icon: const Icon(Icons.upload_file),
          label: const Text('Choose file'),
        ),
        const SizedBox(width: 12),
        if (_working)
          Expanded(child: LinearProgressIndicator(value: _progress))
        else if (_hash != null)
          const Expanded(child: LinearProgressIndicator(value: 1.0)),
      ],
    );
  }

  Widget _resultCard() {
    if (_hash == null) return const SizedBox.shrink();
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, size: 22),
              const SizedBox(width: 8),
              Text('Result', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                tooltip: 'Copy hash',
                icon: const Icon(Icons.copy),
                onPressed: _copyHash,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(_hash!, style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
          const SizedBox(height: 6),
          Text('File: ${_filename ?? "-"}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _historyList() {
    if (_history.isEmpty) {
      return GlassPanel(
        child: Row(
          children: [
            const Icon(Icons.inbox_outlined),
            const SizedBox(width: 8),
            const Expanded(child: Text('No entries yet. Start by hashing a file.')),
          ],
        ),
      );
    }
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history),
              const SizedBox(width: 8),
              Text('History', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Tooltip(
                message: 'Clear history',
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await _storage.clearHistory();
                    await _loadHistory();
                    _showSnackbar('History cleared');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._history.map((r) {
            final dt = DateTime.fromMillisecondsSinceEpoch(r.timestampEpochMs).toLocal();
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() { _hash = r.hash; _filename = r.filename; });
                _showSnackbar('Loaded from history');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(r.filename, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 12),
                    Text(
                      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
                      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                    ),
                    IconButton(
                      tooltip: 'Copy hash',
                      icon: const Icon(Icons.copy),
                      onPressed: () => Clipboard.setData(ClipboardData(text: r.hash)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrvyanBackground(
      child: Scaffold(
        appBar: AppBar(
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: ListView(
                    children: [
                      _headline(),
                      const SizedBox(height: 16),
                      _actionBar(),
                      const SizedBox(height: 16),
                      _resultCard(),
                      const SizedBox(height: 16),
                      _historyList(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            if (_working) LoaderOverlay(progress: _progress, label: 'Hashing'),
          ],
        ),
      ),
    );
  }
}
