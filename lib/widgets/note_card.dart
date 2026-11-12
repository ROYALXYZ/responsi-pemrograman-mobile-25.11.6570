import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note.dart';

/// Kartu satu catatan kuliah pada daftar beranda.
class NoteCard extends StatelessWidget {
  /// Membuat kartu catatan.
  const NoteCard({super.key, required this.note, this.onTap, this.onDelete});

  /// Catatan yang ditampilkan.
  final Note note;

  /// Dipanggil saat kartu ditekan.
  final VoidCallback? onTap;

  /// Dipanggil saat tombol hapus ditekan.
  final VoidCallback? onDelete;

  static final DateFormat _dateFormat = DateFormat('d MMM yyyy • HH:mm', 'id_ID');

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String preview = note.content.trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      note.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dateFormat.format(note.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (preview.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Hapus catatan',
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
