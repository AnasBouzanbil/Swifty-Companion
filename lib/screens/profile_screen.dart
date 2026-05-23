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

    return Scaffold(
      backgroundColor: const Color(0xFF4A7E7E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7E7E),
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
      ),
      body: SafeArea(
        child: Builder(
          builder: (_) {
            if (loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (error != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _retry(userProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (user == null) {
              return const Center(
                child: Text(
                  'No profile data.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return _ProfileBody(user: user);
          },
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final UserModel user;

  const _ProfileBody({required this.user});

  @override
  Widget build(BuildContext context) {
    final cursus = user.mainCursus;
    final level = cursus?.level ?? 0;
    final progress = (level - level.floor()).clamp(0.0, 1.0);
    final skills = cursus?.skills ?? const <Skill>[];

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          _HeaderImage(imageUrl: user.imageUrl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            color: const Color(0xFF4A7E7E),
            child: Column(
              children: [
                // const Icon(Icons.shield, color: Color(0xFF1ED5DB), size: 36),
                const SizedBox(height: 8),
                Text(
                  user.login,
                  style: const TextStyle(
                    color: Color(0xFF1ED5DB),
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 17,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${user.wallet}',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(width: 18),
                    const Icon(
                      Icons.keyboard_double_arrow_up,
                      size: 18,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${user.correctionPoints}',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  user.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  user.login,
                  style: const TextStyle(color: Colors.white70, fontSize: 19),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _SmallCard(
                        label: 'Cursus',
                        value: cursus?.cursusName ?? '-',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SmallCard(
                        label: 'Grade',
                        value: _gradeLabel(cursus),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _SmallCard(
                        label: 'Campus',
                        value: user.campusName ?? '-',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SmallCard(label: 'Pool', value: _poolLabel(user)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _LevelCard(level: level, progress: progress),
                const SizedBox(height: 14),
                _SkillsCard(skills: skills),
                const SizedBox(height: 14),
                _AvailabilityCard(
                  location: user.location,
                  email: user.email,
                  phone: user.phone,
                ),
                const SizedBox(height: 14),
                _ProjectsCard(projects: user.projects),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  final String? imageUrl;

  const _HeaderImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 250,
      child: imageUrl == null
          ? Container(
              color: Colors.black26,
              child: const Icon(Icons.person, size: 84, color: Colors.white70),
            )
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.black26,
                  child: const Icon(
                    Icons.person,
                    size: 84,
                    color: Colors.white70,
                  ),
                );
              },
            ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  final String label;
  final String value;

  const _SmallCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2F6768),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
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

  const _LevelCard({required this.level, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Level',
            style: TextStyle(color: Color(0xFF1ED5DB), fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            level.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF1ED5DB)),
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

  const _AvailabilityCard({
    required this.location,
    required this.email,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final fixedLocation = (location == null || location!.isEmpty)
        ? 'Unavailable'
        : location!;
    final fixedPhone = (phone == null || phone!.isEmpty) ? '-' : phone!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            'Available',
            style: TextStyle(color: Colors.white, fontSize: 34),
          ),
          const SizedBox(height: 6),
          Text(
            fixedLocation,
            style: const TextStyle(
              color: Color(0xFF1ED5DB),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(email, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 3),
          Text(fixedPhone, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}

class _SkillsCard extends StatelessWidget {
  final List<Skill> skills;

  const _SkillsCard({required this.skills});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skills',
            style: TextStyle(color: Color(0xFF1ED5DB), fontSize: 20),
          ),
          const SizedBox(height: 10),
          if (skills.isEmpty)
            const Text(
              'No skills found.',
              style: TextStyle(color: Colors.white70),
            )
          else
            ...skills.take(8).map((skill) => _SkillRow(skill: skill)),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final Skill skill;

  const _SkillRow({required this.skill});

  @override
  Widget build(BuildContext context) {
    final percent = (skill.percentage * 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  skill.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Lvl ${skill.level.toStringAsFixed(2)} - $percent%',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: skill.percentage,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF1ED5DB)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectsCard extends StatelessWidget {
  final List<ProjectUser> projects;

  const _ProjectsCard({required this.projects});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Projects',
            style: TextStyle(color: Color(0xFF1ED5DB), fontSize: 20),
          ),
          const SizedBox(height: 10),
          if (projects.isEmpty)
            const Text(
              'No projects found.',
              style: TextStyle(color: Colors.white70),
            )
          else
            ...projects.map((project) => _ProjectRow(project: project)),
        ],
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  final ProjectUser project;

  const _ProjectRow({required this.project});

  @override
  Widget build(BuildContext context) {
    final statusLabel = _projectStatusLabel(project);
    final statusColor = _projectStatusColor(project);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              project.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (project.finalMark != null)
            Text(
              '${project.finalMark}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: statusColor.withValues(alpha: 0.35)),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
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
