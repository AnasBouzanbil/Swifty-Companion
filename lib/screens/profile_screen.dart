import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  final bool showSelectedUser;

  const ProfileScreen({super.key, this.showSelectedUser = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!widget.showSelectedUser) {
        context.read<UserProvider>().loadMe();
      }
    });
  }

  void _retry(UserProvider userProvider) {
    if (widget.showSelectedUser) {
      final login = userProvider.selectedUser?.login;
      if (login != null && login.isNotEmpty) {
        userProvider.loadUserProfile(login);
      }
      return;
    }
    userProvider.loadMe();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = widget.showSelectedUser
        ? userProvider.selectedUser
        : userProvider.me;
    final loading = widget.showSelectedUser
        ? userProvider.profileLoading
        : userProvider.meLoading;
    final error = widget.showSelectedUser
        ? userProvider.profileError
        : userProvider.meError;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Builder(
          builder: (_) {
            if (loading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BABC)),
                ),
              );
            }
            if (error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                error,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _retry(userProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BABC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (user == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_off_rounded,
                      size: 64,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No profile data.',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }
            return _ProfileBody(user: user, isDark: isDark);
          },
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final UserModel user;
  final bool isDark;

  const _ProfileBody({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cursus = user.mainCursus;
    final level = cursus?.level ?? 0;
    final progress = (level - level.floor()).clamp(0.0, 1.0);
    final skills = cursus?.skills ?? const <Skill>[];

    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white60 : Colors.black54;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: isDark
              ? const Color(0xFF121212)
              : const Color(0xFFF5F7FA),
          elevation: 0,
          centerTitle: true,
          title: Text(
            user.login,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: Navigator.of(context).canPop()
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                )
              : null,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00BABC), Color(0xFF00585A)],
                    ),
                  ),
                ),
                Positioned(
                  right: -40,
                  top: -40,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                Positioned(
                  left: -20,
                  bottom: -20,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.8),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: user.imageUrl == null
                                ? Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.person,
                                      size: 64,
                                      color: Colors.black26,
                                    ),
                                  )
                                : Image.network(
                                    user.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.person,
                                        size: 64,
                                        color: Colors.black26,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.login,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            child: Column(
              children: [
                // Quick Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatBadge(
                      icon: Icons.account_balance_wallet_rounded,
                      value: '${user.wallet}',
                      label: 'Wallet',
                      isDark: isDark,
                    ),
                    _StatBadge(
                      icon: Icons.star_rounded,
                      value: '${user.correctionPoints}',
                      label: 'Eval Pts',
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Info Grid
                Row(
                  children: [
                    Expanded(
                      child: _SmallCard(
                        icon: Icons.school_rounded,
                        label: 'Cursus',
                        value: cursus?.cursusName ?? '-',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SmallCard(
                        icon: Icons.grade_rounded,
                        label: 'Grade',
                        value: _gradeLabel(cursus),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SmallCard(
                        icon: Icons.location_city_rounded,
                        label: 'Campus',
                        value: user.campusName ?? '-',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SmallCard(
                        icon: Icons.pool_rounded,
                        label: 'Pool',
                        value: _poolLabel(user),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Level & Progress
                _LevelCard(level: level, progress: progress, isDark: isDark),
                const SizedBox(height: 24),

                // Skills
                if (skills.isNotEmpty) ...[
                  _SkillsCard(skills: skills, isDark: isDark),
                  const SizedBox(height: 24),
                ],

                // Availability
                _AvailabilityCard(
                  location: user.location,
                  email: user.email,
                  phone: user.phone,
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                // Projects
                if (user.projects.isNotEmpty) ...[
                  _ProjectsCard(projects: user.projects, isDark: isDark),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00BABC), size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _SmallCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00BABC), size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final double level;
  final double progress;
  final bool isDark;

  const _LevelCard({
    required this.level,
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00BABC), Color(0xFF00989A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BABC).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Level',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            level.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.black.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  final String? location;
  final String email;
  final String? phone;
  final bool isDark;

  const _AvailabilityCard({
    required this.location,
    required this.email,
    required this.phone,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final fixedLocation = (location == null || location!.isEmpty)
        ? 'Offline'
        : location!;
    final isOnline = fixedLocation != 'Offline';
    final fixedPhone = (phone == null || phone!.isEmpty) ? 'No phone' : phone!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isOnline
                  ? const Color(0xFF1ED760).withOpacity(0.15)
                  : Colors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0xFF1ED760) : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isOnline ? fixedLocation : 'Unavailable',
                  style: TextStyle(
                    color: isOnline
                        ? const Color(0xFF1ED760)
                        : (isDark ? Colors.grey : Colors.grey.shade700),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _InfoRow(icon: Icons.email_rounded, text: email, isDark: isDark),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.phone_rounded, text: fixedPhone, isDark: isDark),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.white54 : Colors.black54),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _SkillsCard extends StatelessWidget {
  final List<Skill> skills;
  final bool isDark;

  const _SkillsCard({required this.skills, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: Color(0xFF00BABC)),
              const SizedBox(width: 8),
              Text(
                'Skills',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (skills.isEmpty)
            Text(
              'No skills found.',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
            )
          else
            ...skills
                .take(8)
                .map((skill) => _SkillRow(skill: skill, isDark: isDark)),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final Skill skill;
  final bool isDark;

  const _SkillRow({required this.skill, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  skill.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                'Lvl ${skill.level.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: skill.percentage,
              minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white12
                  : Colors.grey.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF00BABC)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectsCard extends StatelessWidget {
  final List<ProjectUser> projects;
  final bool isDark;

  const _ProjectsCard({required this.projects, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code_rounded, color: Color(0xFF00BABC)),
              const SizedBox(width: 8),
              Text(
                'Projects',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (projects.isEmpty)
            Text(
              'No projects found.',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
            )
          else
            ...projects.map(
              (project) => _ProjectRow(project: project, isDark: isDark),
            ),
        ],
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  final ProjectUser project;
  final bool isDark;

  const _ProjectRow({required this.project, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusLabel = _projectStatusLabel(project);
    final statusColor = _projectStatusColor(project);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              project.name,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerRight,
              child: project.finalMark != null
                  ? Text(
                      '${project.finalMark}',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 80,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.2)),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

String _gradeLabel(CursusUser? cursus) {
  final apiGrade = cursus?.grade?.trim();
  if (apiGrade != null && apiGrade.isNotEmpty) return apiGrade;

  final level = cursus?.level ?? 0;
  if (level >= 10) return 'Master';
  if (level >= 7) return 'Advanced';
  if (level >= 4) return 'Intermediate';
  if (level > 0) return 'Beginner';
  return '-';
}

String _poolLabel(UserModel user) {
  if (user.poolMonth == null || user.poolYear == null) return '-';
  return '${_capitalize(user.poolMonth!)} ${user.poolYear!}';
}

String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

String _projectStatusLabel(ProjectUser project) {
  if (project.isPassed) return 'Passed';
  if (project.isFailed) return 'Failed';
  if (project.isFinished) return 'Finished';
  if (project.status.isEmpty) return 'Unknown';
  return project.status.replaceAll('_', ' ');
}

Color _projectStatusColor(ProjectUser project) {
  if (project.isPassed) return const Color(0xFF1ED760);
  if (project.isFailed) return const Color(0xFFFF6B6B);
  if (project.isFinished) return const Color(0xFFE0C341);
  return const Color(0xFF9AA0B4);
}
