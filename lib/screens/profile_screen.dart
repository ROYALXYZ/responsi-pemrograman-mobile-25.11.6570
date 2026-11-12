import 'package:flutter/material.dart';

import '../models/student.dart';
import '../providers/app_provider.dart';
import '../utils/validators.dart';
import '../widgets/profile_card.dart';

/// Layar profil mahasiswa beserta aksi edit data.
class ProfileScreen extends StatelessWidget {
  /// Membuat layar profil.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppProvider provider = AppProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
        actions: <Widget>[
          IconButton(
            onPressed: () => _openEditSheet(context),
            tooltip: 'Edit profil',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ProfileCard(student: provider.student),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _openEditSheet(context),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profil'),
            ),
            const SizedBox(height: 16),
            Text(
              'Data profil disimpan secara lokal pada perangkat. '
              'Isi catatan disimpan terenkripsi dan tidak pernah ditulis ke log.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openEditSheet(BuildContext context) {
    final Student current = AppProvider.of(context).student;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _EditProfileSheet(student: current),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.student});

  final Student student;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nimController;
  late final TextEditingController _programStudiController;
  late final TextEditingController _emailController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _nimController = TextEditingController(text: widget.student.nim);
    _programStudiController = TextEditingController(
      text: widget.student.programStudi,
    );
    _emailController = TextEditingController(text: widget.student.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _programStudiController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final AppProvider provider = AppProvider.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);

    final Student updated = widget.student.copyWith(
      name: Validators.sanitize(_nameController.text),
      nim: Validators.sanitize(_nimController.text),
      programStudi: Validators.sanitize(_programStudiController.text),
      email: Validators.sanitize(_emailController.text),
    );

    try {
      await provider.updateStudent(updated);
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      Navigator.of(context).pop();
    } on Exception catch (error) {
      debugPrint('Gagal menyimpan profil: ${error.runtimeType}');
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan profil. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: <Widget>[
          Text('Edit Profil', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            validator: Validators.validateName,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nimController,
            keyboardType: TextInputType.number,
            validator: Validators.validateNim,
            decoration: const InputDecoration(
              labelText: 'NIM',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _programStudiController,
            textCapitalization: TextCapitalization.words,
            validator: Validators.validateProgramStudi,
            decoration: const InputDecoration(
              labelText: 'Program Studi',
              prefixIcon: Icon(Icons.school_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Profil'),
          ),
        ],
      ),
    );
  }
}
