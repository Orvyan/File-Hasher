import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HashRecord {
  final String filename;
  final String hash;
  final int timestampEpochMs;
  HashRecord({required this.filename, required this.hash, required this.timestampEpochMs});

  Map<String, dynamic> toJson() => {
        'filename': filename,
        'hash': hash,
        'timestamp': timestampEpochMs,
      };

  static HashRecord fromJson(Map<String, dynamic> j) => HashRecord(
        filename: j['filename'] as String,
        hash: j['hash'] as String,
        timestampEpochMs: j['timestamp'] as int,
      );
}

class StorageService {
  static const _key = 'file_hasher_history_v1';

  Future<void> saveRecord(HashRecord r) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.insert(0, jsonEncode(r.toJson()));
    final trimmed = list.length > 200 ? list.sublist(0, 200) : list;
    await prefs.setStringList(_key, trimmed);
  }

  Future<List<HashRecord>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((s) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return HashRecord.fromJson(m);
    }).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
