import 'package:flutter/material.dart';
import '../../infrastructure/storage_service.dart';

class HashTile extends StatelessWidget {
  final HashRecord record;
  final VoidCallback onCopy;
  final VoidCallback onSelect;

  const HashTile({super.key, required this.record, required this.onCopy, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.fromMillisecondsSinceEpoch(record.timestampEpochMs).toLocal();
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: scheme.surface.withOpacity(0.5),
          border: Border.all(color: scheme.outline.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(Icons.verified, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.filename, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')} • ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}',
                      style: TextStyle(color: scheme.onSurface.withOpacity(0.6))),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              onPressed: onCopy,
              tooltip: 'Copy hash',
            ),
          ],
        ),
      ),
    );
  }
}
