import 'package:flutter/material.dart';

import '../models/student.dart';

/// Kartu profil mahasiswa.
///
/// Dua mode tampilan:
/// * [compact] = `true` → ringkasan untuk header HomeScreen,
/// * [compact] = `false` → kartu lengkap untuk ProfileScreen.
class ProfileCard extends StatelessWidget {
  /// Membuat kartu profil dari [student].
  const ProfileCard({
    super.key,
    required this.student,
    this.onTap,
    this.onEdit,
    this.compact = false,
  });

  /// Data profil yang ditampilkan.
  final Student student;

  /// Dipanggil saat kartu ditekan.
  final VoidCallback? onTap;

  /// Dipanggil saat tombol edit ditekan (mode lengkap).
  final VoidCallback? onEdit;

  /// Mode ringkas untuk header beranda.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double avatarRadius = compact ? 24 : 40;

    final Widget avatar = CircleAvatar(
      radius: avatarRadius,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        student.initials,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: compact ? null : 28,
        ),
      ),
    );

    final Widget identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          student.isComplete ? student.name : 'Lengkapi profil kamu',
          style: (compact ? theme.textTheme.titleSmall : theme.textTheme.titleLarge)
              ?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          'NIM ${_orDash(student.nim)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  avatar,
                  const SizedBox(width: 12),
                  Expanded(child: identity),
                  if (!compact && onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      tooltip: 'Edit profil',
                      icon: const Icon(Icons.edit_outlined),
                    ),
                ],
              ),
              if (!compact) ...<Widget>[
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.school_outlined,
                  label: 'Program Studi',
                  value: _orDash(student.programStudi),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  value: _orDash(student.email),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _orDash(String value) => value.trim().isEmpty ? '-' : value;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
