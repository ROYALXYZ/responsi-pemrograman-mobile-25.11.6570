import 'package:flutter/material.dart';

import '../models/note.dart';
import '../providers/app_provider.dart';
import '../utils/validators.dart';

/// Formulir penambahan catatan kuliah.
///
/// Mengembalikan `true` melalui `Navigator.pop` bila penyimpanan berhasil.
class NoteFormScreen extends StatefulWidget {
  /// Membuat layar formulir catatan.
  const NoteFormScreen({super.key});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Provider diambil sebelum await agar context tetap valid.
    final AppProvider provider = AppProvider.of(context);
    setState(() => _isSaving = true);

    final Note note = Note.create(
      title: Validators.sanitize(_titleController.text),
      content: Validators.sanitize(_contentController.text),
    );

    try {
      await provider.addNote(note);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on Exception catch (error) {
      debugPrint('Gagal menyimpan catatan: ${error.runtimeType}');
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan catatan. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Catatan')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                maxLength: Validators.titleMaxLength,
                validator: Validators.validateTitle,
                decoration: const InputDecoration(
                  labelText: 'Judul Catatan',
                  hintText: 'Misal: Ringkasan materi Flutter',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                minLines: 6,
                maxLines: 12,
                maxLength: Validators.contentMaxLength,
                textCapitalization: TextCapitalization.sentences,
                validator: Validators.validateContent,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  hintText: 'Tuliskan materi kuliah di sini...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _contentController,
                builder: (BuildContext context, TextEditingValue value, _) {
                  final int length = value.text.trim().length;
                  return Text(
                    'Panjang isi: $length karakter '
                    '(min ${Validators.contentMinLength}, '
                    'maks ${Validators.contentMaxLength})',
                    style: Theme.of(context).textTheme.labelSmall,
                  );
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Catatan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
