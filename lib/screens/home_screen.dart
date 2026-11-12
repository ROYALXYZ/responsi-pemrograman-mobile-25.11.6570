import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note.dart';
import '../providers/app_provider.dart';
import '../repositories/post_repository.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import '../widgets/profile_card.dart';
import 'note_form_screen.dart';
import 'profile_screen.dart';

/// Layar utama: profil singkat, daftar catatan, dan info kampus dari API.
class HomeScreen extends StatefulWidget {
  /// Membuat layar beranda.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostRepository _postRepository = PostRepository();

  @override
  void dispose() {
    _postRepository.dispose();
    super.dispose();
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
    );
  }

  Future<void> _openNoteForm() async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const NoteFormScreen()),
    );
    if (!mounted || saved != true) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil ditambahkan')),
    );
  }

  Future<void> _confirmDelete(Note note) async {
    final AppProvider provider = AppProvider.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text(
          'Catatan "${note.title}" akan dihapus permanen, '
          'termasuk isi terenkripsinya.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await provider.deleteNote(note.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Catatan dihapus')),
      );
    } on Exception catch (error) {
      debugPrint('Gagal menghapus catatan: ${error.runtimeType}');
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal menghapus catatan. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppProvider provider = AppProvider.of(context);

    if (provider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Catatan Kuliah')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catatan Kuliah'),
          actions: <Widget>[
            IconButton(
              onPressed: _openProfile,
              tooltip: 'Profil mahasiswa',
              icon: const Icon(Icons.person_outline),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ProfileCard(
                student: provider.student,
                compact: true,
                onTap: _openProfile,
              ),
            ),
            const TabBar(
              tabs: <Widget>[
                Tab(text: 'Catatan'),
                Tab(text: 'Info Kampus'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  _NotesTab(
                    notes: provider.notes,
                    onDelete: _confirmDelete,
                    onAdd: _openNoteForm,
                  ),
                  _CampusInfoTab(repository: _postRepository),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openNoteForm,
          icon: const Icon(Icons.add),
          label: const Text('Catatan'),
        ),
      ),
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({
    required this.notes,
    required this.onDelete,
    required this.onAdd,
  });

  final List<Note> notes;
  final ValueChanged<Note> onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return EmptyState(
        icon: Icons.note_alt_outlined,
        title: 'Belum ada catatan',
        message:
            'Tekan tombol "Catatan" di bawah untuk menulis catatan kuliah pertamamu.',
        action: FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Tambah Catatan'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: notes.length,
      itemBuilder: (BuildContext context, int index) {
        final Note note = notes[index];
        return NoteCard(
          note: note,
          onDelete: () => onDelete(note),
          onTap: () => _showDetail(context, note),
        );
      },
    );
  }

  void _showDetail(BuildContext context, Note note) {
    final DateFormat formatter = DateFormat('EEEE, d MMMM yyyy • HH:mm', 'id_ID');
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                formatter.format(note.createdAt),
                style: Theme.of(dialogContext).textTheme.labelSmall,
              ),
              const SizedBox(height: 12),
              Text(note.content),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class _CampusInfoTab extends StatefulWidget {
  const _CampusInfoTab({required this.repository});

  final PostRepository repository;

  @override
  State<_CampusInfoTab> createState() => _CampusInfoTabState();
}

class _CampusInfoTabState extends State<_CampusInfoTab> {
  late Future<List<Post>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = widget.repository.fetchPosts();
  }

  void _reload() {
    setState(() => _posts = widget.repository.fetchPosts());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _posts,
      builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return EmptyState(
            icon: Icons.cloud_off,
            title: 'Gagal memuat info kampus',
            message: '${snapshot.error}',
            action: OutlinedButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          );
        }

        final List<Post> posts = snapshot.data ?? <Post>[];
        if (posts.isEmpty) {
          return const EmptyState(
            icon: Icons.article_outlined,
            title: 'Tidak ada data',
            message: 'API tidak mengembalikan data apa pun.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: posts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              final Post post = posts[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(child: Text('${post.id}')),
                  title: Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    post.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
