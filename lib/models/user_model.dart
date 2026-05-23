class UserModel {
  final int id;
  final String login;
  final String displayName;
  final String email;
  final String? phone;
  final String? imageUrl;
  final int wallet;
  final int correctionPoints;
  final String? location;
  final bool isActive;
  final List<CursusUser> cursusUsers;
  final List<ProjectUser> projects;
  final String? poolMonth;
  final String? poolYear;
  final String? campusName;
  final String kind;
  final bool isStaff;
  final bool isAlumni;

  UserModel({
    required this.id,
    required this.login,
    required this.displayName,
    required this.email,
    this.phone,
    this.imageUrl,
    required this.wallet,
    required this.correctionPoints,
    this.location,
    required this.isActive,
    required this.cursusUsers,
    required this.projects,
    this.poolMonth,
    this.poolYear,
    this.campusName,
    this.kind = 'student',
    this.isStaff = false,
    this.isAlumni = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    final imageRaw = json['image'];
    if (imageRaw is Map<String, dynamic>) {
      final versions = imageRaw['versions'];
      if (versions is Map<String, dynamic>) {
        imageUrl = versions['medium']?.toString();
      }
      imageUrl ??= imageRaw['link']?.toString();
    }

    String? campusName;
    final campusRaw = json['campus'];
    if (campusRaw is List && campusRaw.isNotEmpty) {
      final firstCampus = campusRaw.first;
      if (firstCampus is Map<String, dynamic>) {
        campusName = firstCampus['name']?.toString();
      }
    } else if (campusRaw is Map<String, dynamic>) {
      campusName = campusRaw['name']?.toString();
    }

    return UserModel(
      id: json['id'],
      login: json['login'],
      displayName: json['displayname'] ?? json['login'],
      email: json['email'] ?? '',
      phone: json['phone'] == 'hidden' ? null : json['phone'],
      imageUrl: imageUrl,
      wallet: json['wallet'] ?? 0,
      correctionPoints: json['correction_point'] ?? 0,
      location: json['location']?.toString(),
      isActive: json['active?'] ?? false,
      cursusUsers: (json['cursus_users'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((c) => CursusUser.fromJson(c))
          .toList(),
      projects: [],
      poolMonth: json['pool_month'],
      poolYear: json['pool_year'],
      campusName: campusName,
      kind: json['kind']?.toString() ?? 'student',
      isStaff: json['staff?'] == true,
      isAlumni: json['alumni?'] == true,
    );
  }

  // The main 42cursus entry (cursus_id == 21), fallback to last one
  CursusUser? get mainCursus {
    try {
      return cursusUsers.firstWhere((c) => c.cursusId == 21);
    } catch (_) {
      return cursusUsers.isNotEmpty ? cursusUsers.last : null;
    }
  }
}

class CursusUser {
  final int cursusId;
  final String cursusName;
  final double level;
  final String? grade;
  final List<Skill> skills;

  CursusUser({
    required this.cursusId,
    required this.cursusName,
    required this.level,
    this.grade,
    required this.skills,
  });

  factory CursusUser.fromJson(Map<String, dynamic> json) {
    return CursusUser(
      cursusId: json['cursus_id'],
      cursusName: json['cursus']?['name'] ?? 'Unknown',
      level: (json['level'] as num).toDouble(),
      grade: json['grade']?.toString(),
      skills:
          (json['skills'] as List? ?? []).map((s) => Skill.fromJson(s)).toList()
            ..sort((a, b) => b.level.compareTo(a.level)),
    );
  }
}

class Skill {
  final String name;
  final double level;

  Skill({required this.name, required this.level});

  double get percentage => (level / 21.0).clamp(0.0, 1.0);

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(name: json['name'], level: (json['level'] as num).toDouble());
  }
}

class ProjectUser {
  final String name;
  final String slug;
  final int? finalMark;
  final bool? validated;
  final String status;

  ProjectUser({
    required this.name,
    required this.slug,
    this.finalMark,
    this.validated,
    required this.status,
  });

  bool get isFinished => status == 'finished';
  bool get isPassed => validated == true;
  bool get isFailed => isFinished && validated == false;

  factory ProjectUser.fromJson(Map<String, dynamic> json) {
    return ProjectUser(
      name: json['project']?['name'] ?? 'Unknown',
      slug: json['project']?['slug'] ?? '',
      finalMark: json['final_mark'],
      validated: json['validated?'],
      status: json['status'] ?? '',
    );
  }
}
