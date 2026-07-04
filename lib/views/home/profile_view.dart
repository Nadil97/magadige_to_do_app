import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../core/utils/notifications.dart';
import '../auth/landing_view.dart';

// ─── User profile stream provider ────────────────────────────────────────────
final userProfileProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ─── ProfileView ─────────────────────────────────────────────────────────────

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView>
    with TickerProviderStateMixin {
  late AnimationController _headerAnim;
  late AnimationController _cardAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _cardFade;

  bool _editingName = false;
  bool _savingName = false;
  bool _changingPassword = false;
  final _nameController = TextEditingController();
  final _currentPwController = TextEditingController();
  final _newPwController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _cardAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _headerFade =
        CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic);
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.12), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _headerAnim, curve: Curves.easeOutCubic));
    _cardFade =
        CurvedAnimation(parent: _cardAnim, curve: Curves.easeOutCubic);
    _headerAnim.forward();
    Future.delayed(const Duration(milliseconds: 200),
        () => _cardAnim.forward());
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _cardAnim.dispose();
    _nameController.dispose();
    _currentPwController.dispose();
    _newPwController.dispose();
    super.dispose();
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Color _levelColor(int level) {
    if (level >= 10) return const Color(0xFFF59E0B);
    if (level >= 5) return const Color(0xFF8B5CF6);
    return const Color(0xFF10B981);
  }

  String _levelTitle(int level) {
    if (level >= 10) return 'Gold';
    if (level >= 5) return 'Silver';
    return 'Bronze';
  }

  IconData _levelIcon(int level) {
    if (level >= 10) return Icons.emoji_events_rounded;
    if (level >= 5) return Icons.military_tech_rounded;
    return Icons.workspace_premium_rounded;
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

  Future<void> _saveName(UserModel user) async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == user.name) {
      setState(() => _editingName = false);
      return;
    }
    setState(() => _savingName = true);
    try {
      final updated = user.copyWith(name: newName);
      await DatabaseService().updateUserProgress(updated);
      if (mounted) {
        AppNotifications.showSuccess(context, 'Name updated successfully!');
        setState(() {
          _editingName = false;
          _savingName = false;
        });
      }
    } catch (e) {
      if (mounted) {
        AppNotifications.showError(context, 'Failed to update name.');
        setState(() => _savingName = false);
      }
    }
  }

  Future<void> _changePassword() async {
    final current = _currentPwController.text.trim();
    final newPw = _newPwController.text.trim();
    if (current.isEmpty || newPw.length < 6) {
      AppNotifications.showError(
          context, 'New password must be at least 6 characters.');
      return;
    }
    setState(() => _changingPassword = true);
    try {
      await ref.read(authServiceProvider).changePassword(current, newPw);
      if (mounted) {
        _currentPwController.clear();
        _newPwController.clear();
        AppNotifications.showSuccess(context, 'Password changed successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppNotifications.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  Future<void> _logout() async {
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LandingView()),
        (route) => false,
      );
    }
  }

  void _showChangePasswordSheet() {
    _currentPwController.clear();
    _newPwController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChangePasswordSheet(
        currentPwController: _currentPwController,
        newPwController: _newPwController,
        obscureCurrent: _obscureCurrent,
        obscureNew: _obscureNew,
        onToggleCurrent: () =>
            setState(() => _obscureCurrent = !_obscureCurrent),
        onToggleNew: () => setState(() => _obscureNew = !_obscureNew),
        onSave: _changePassword,
        isLoading: _changingPassword,
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete Account',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B))),
        content: Text(
          'This will permanently delete your account and all your data. This action cannot be undone.',
          style: GoogleFonts.inter(
              color: const Color(0xFF64748B), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              AppNotifications.showError(
                  context, 'Delete account coming soon.');
            },
            child: Text('Delete',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);
    final tasksAsync = ref.watch(taskListStreamProvider);
    final tasks = tasksAsync.value ?? [];
    final doneTasks = tasks.where((t) => t.status == 'Done').toList();
    final inProgressTasks =
        tasks.where((t) => t.status == 'In Progress').toList();
    final todoTasks = tasks.where((t) => t.status == 'Todo').toList();
    final completionRate = tasks.isEmpty
        ? 0.0
        : (doneTasks.length / tasks.length);
    final points = doneTasks.length * 20;
    final level = (points / 100).floor() + 1;
    final xpInLevel = points % 100;

    return userAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1))),
      error: (e, _) =>
          Center(child: Text('Error: $e', style: GoogleFonts.inter())),
      data: (user) {
        if (user == null) {
          return const SizedBox.shrink();
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero Header SliverAppBar ──
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: const Color(0xFF4F46E5),
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _buildHeroHeader(user, level, xpInLevel, points),
                ),
                title: Text(
                  'My Profile',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

              // ── Body cards ──
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _cardFade,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name edit row
                        _buildNameCard(user),
                        const SizedBox(height: 16),

                        // Stats grid
                        _buildStatsGrid(
                            tasks.length,
                            doneTasks.length,
                            inProgressTasks.length,
                            todoTasks.length,
                            completionRate),
                        const SizedBox(height: 16),

                        // XP Progress card
                        _buildXPCard(level, xpInLevel, points),
                        const SizedBox(height: 16),

                        // Account info card
                        _buildInfoCard(user),
                        const SizedBox(height: 16),

                        // Settings card
                        _buildSettingsCard(),
                        const SizedBox(height: 16),

                        // Danger zone
                        _buildDangerZone(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Hero Header ────────────────────────────────────────────────────────────

  Widget _buildHeroHeader(
      UserModel user, int level, int xpInLevel, int points) {
    final lColor = _levelColor(level);
    return SlideTransition(
      position: _headerSlide,
      child: FadeTransition(
        opacity: _headerFade,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [lColor, lColor.withOpacity(0.6)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: lColor.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: lColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(_levelIcon(level),
                          size: 14, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  user.name,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                // Level badge pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: lColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: lColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_levelIcon(level), size: 14, color: lColor),
                      const SizedBox(width: 6),
                      Text(
                        'Level $level · ${_levelTitle(level)} Climber',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Name Edit Card ─────────────────────────────────────────────────────────

  Widget _buildNameCard(UserModel user) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
              icon: Icons.person_outline_rounded, label: 'Display Name'),
          const SizedBox(height: 12),
          if (_editingName) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    autofocus: true,
                    enabled: !_savingName,
                    style: GoogleFonts.inter(
                        color: const Color(0xFF1E293B), fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Enter new name',
                      hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: _savingName
                      ? null
                      : Icons.check_rounded,
                  loading: _savingName,
                  color: const Color(0xFF10B981),
                  onTap: () => _saveName(user),
                ),
                const SizedBox(width: 6),
                _ActionButton(
                  icon: Icons.close_rounded,
                  color: const Color(0xFFEF4444),
                  onTap: () => setState(() => _editingName = false),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    user.name,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _nameController.text = user.name;
                    setState(() => _editingName = true);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        size: 16, color: Color(0xFF6366F1)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Stats Grid ─────────────────────────────────────────────────────────────

  Widget _buildStatsGrid(int total, int done, int inProgress, int todo,
      double completionRate) {
    final pct = (completionRate * 100).toStringAsFixed(0);
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(
              icon: Icons.bar_chart_rounded, label: 'Task Statistics'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _StatTile(
                      label: 'Total',
                      value: '$total',
                      color: const Color(0xFF6366F1),
                      icon: Icons.format_list_bulleted_rounded)),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatTile(
                      label: 'Done',
                      value: '$done',
                      color: const Color(0xFF10B981),
                      icon: Icons.check_circle_outline_rounded)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _StatTile(
                      label: 'In Progress',
                      value: '$inProgress',
                      color: const Color(0xFFF59E0B),
                      icon: Icons.timelapse_rounded)),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatTile(
                      label: 'Completion',
                      value: '$pct%',
                      color: const Color(0xFF8B5CF6),
                      icon: Icons.pie_chart_outline_rounded)),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Overall Progress',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500)),
                  Text('$done / $total tasks',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: completionRate),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, val, __) => LinearProgressIndicator(
                    value: val,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── XP Card ────────────────────────────────────────────────────────────────

  Widget _buildXPCard(int level, int xpInLevel, int points) {
    final lColor = _levelColor(level);
    final xpProgress = xpInLevel / 100;
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(icon: Icons.bolt_rounded, label: 'XP & Level'),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [lColor, lColor.withOpacity(0.6)]),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$level',
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Level $level',
                            style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B))),
                        Text('$xpInLevel / 100 XP',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: lColor,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: xpProgress),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (_, val, __) => LinearProgressIndicator(
                          value: val,
                          minHeight: 10,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation(lColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${100 - xpInLevel} XP to Level ${level + 1}',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: lColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: lColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _XPStat(label: 'Total XP', value: '$points', color: lColor),
                Container(
                    width: 1, height: 30, color: lColor.withOpacity(0.2)),
                _XPStat(
                    label: 'Rank',
                    value: _levelTitle(level),
                    color: lColor),
                Container(
                    width: 1, height: 30, color: lColor.withOpacity(0.2)),
                _XPStat(
                    label: 'Tasks Done',
                    value: '${(points / 20).floor()}',
                    color: lColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Account Info Card ───────────────────────────────────────────────────────

  Widget _buildInfoCard(UserModel user) {
    final joined =
        '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}';
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(
              icon: Icons.info_outline_rounded, label: 'Account Info'),
          const SizedBox(height: 12),
          _InfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email),
          const _Divider(),
          _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Member Since',
              value: joined),
          const _Divider(),
          _InfoRow(
              icon: Icons.fingerprint_rounded,
              label: 'User ID',
              value: user.uid.substring(0, 10) + '…',
              onCopy: () {
                Clipboard.setData(ClipboardData(text: user.uid));
                AppNotifications.showSuccess(context, 'UID copied!');
              }),
        ],
      ),
    );
  }

  // ─── Settings Card ──────────────────────────────────────────────────────────

  Widget _buildSettingsCard() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(
              icon: Icons.settings_outlined, label: 'Settings'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            label: 'Change Password',
            color: const Color(0xFF6366F1),
            onTap: _showChangePasswordSheet,
          ),
          const _Divider(),
          _SettingsTile(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
            color: const Color(0xFFF59E0B),
            trailing: Switch(
              value: true,
              onChanged: (_) {},
              activeColor: const Color(0xFF6366F1),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ─── Danger Zone ────────────────────────────────────────────────────────────

  Widget _buildDangerZone() {
    return _GlassCard(
      borderColor: const Color(0xFFFEE2E2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(
              icon: Icons.warning_amber_rounded,
              label: 'Account Actions',
              color: Color(0xFFEF4444)),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            color: const Color(0xFFF59E0B),
            onTap: _logout,
          ),
          const _Divider(),
          _SettingsTile(
            icon: Icons.delete_forever_rounded,
            label: 'Delete Account',
            color: const Color(0xFFEF4444),
            textColor: const Color(0xFFEF4444),
            onTap: _showDeleteAccountDialog,
          ),
        ],
      ),
    );
  }
}

// ─── Change Password Sheet ────────────────────────────────────────────────────

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  final TextEditingController currentPwController;
  final TextEditingController newPwController;
  final bool obscureCurrent;
  final bool obscureNew;
  final VoidCallback onToggleCurrent;
  final VoidCallback onToggleNew;
  final VoidCallback onSave;
  final bool isLoading;

  const _ChangePasswordSheet({
    required this.currentPwController,
    required this.newPwController,
    required this.obscureCurrent,
    required this.obscureNew,
    required this.onToggleCurrent,
    required this.onToggleNew,
    required this.onSave,
    required this.isLoading,
  });

  @override
  ConsumerState<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  bool _localObsCurrent = true;
  bool _localObsNew = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Change Password',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter your current and new password below.',
            style: GoogleFonts.inter(
                color: const Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 20),
          _buildPwField(
            controller: widget.currentPwController,
            label: 'Current Password',
            obscure: _localObsCurrent,
            onToggle: () =>
                setState(() => _localObsCurrent = !_localObsCurrent),
          ),
          const SizedBox(height: 12),
          _buildPwField(
            controller: widget.newPwController,
            label: 'New Password (min. 6 chars)',
            obscure: _localObsNew,
            onToggle: () =>
                setState(() => _localObsNew = !_localObsNew),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Text('Save Password',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPwField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.inter(
            color: const Color(0xFF1E293B), fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
              color: const Color(0xFF64748B), fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF64748B),
              size: 20,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;

  const _GlassCard({required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: borderColor ?? const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _SectionLabel({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF6366F1);
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: c.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: c),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _XPStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _XPStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color)),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 10,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6366F1)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500)),
                Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (onCopy != null)
            GestureDetector(
              onTap: onCopy,
              child: const Icon(Icons.copy_rounded,
                  size: 16, color: Color(0xFF94A3B8)),
            ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: const Color(0xFFF1F5F9),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? textColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? const Color(0xFF1E293B),
                ),
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    size: 20, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;
  final bool loading;

  const _ActionButton({
    required this.color,
    required this.onTap,
    this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: loading
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: CircularProgressIndicator(
                    color: color, strokeWidth: 2))
            : Icon(icon, size: 18, color: color),
      ),
    );
  }
}
