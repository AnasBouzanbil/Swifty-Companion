import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'auth_provider.dart';

class UserProvider extends ChangeNotifier {
  final AuthProvider authProvider;

  UserProvider(this.authProvider);

  static const _baseUrl = 'https://api.intra.42.fr/v2';
  static const _campusId = 21; // 1337 Ben Guerir

  // Campus users list
  List<UserModel> _campusUsers = [];
  bool _campusLoading = false;
  String? _campusError;

  UserModel? _me;
  bool _meLoading = false;
  String? _meError;

  // Search results
  List<UserModel> _searchResults = [];
  bool _searchLoading = false;
  String? _searchError;
  Timer? _debounce;

  // Selected user profile
  UserModel? _selectedUser;
  bool _profileLoading = false;
  String? _profileError;

  // Getters
  List<UserModel> get campusUsers => _campusUsers;
  bool get campusLoading => _campusLoading;
  String? get campusError => _campusError;

  List<UserModel> get searchResults => _searchResults;
  bool get searchLoading => _searchLoading;
  String? get searchError => _searchError;

  UserModel? get selectedUser => _selectedUser;
  bool get profileLoading => _profileLoading;
  String? get profileError => _profileError;
  UserModel? get me => _me;
  bool get meLoading => _meLoading;
  String? get meError => _meError;

  Future<Map<String, String>> _authHeaders() async {
    final token = await authProvider.getValidToken();
    if (token == null) throw Exception('Not authenticated');
    return {'Authorization': 'Bearer $token'};
  }

  Future<http.Response> _authorizedGet(Uri uri) async {
    var headers = await _authHeaders();
    var response = await http.get(uri, headers: headers);

    if (response.statusCode == 401) {
      final refreshed = await authProvider.refreshAccessToken();
      if (refreshed) {
        headers = await _authHeaders();
        response = await http.get(uri, headers: headers);
      }
    }

    return response;
  }

  Future<List<ProjectUser>> _fetchProjectsUsersByLogin(
    String login,
  ) async {
    const pageSize = 100;
    var pageNumber = 1;
    final projects = <ProjectUser>[];

    while (true) {
      final response = await _authorizedGet(
        Uri.parse(
          '$_baseUrl/users/$login/projects_users?page[number]=$pageNumber&page[size]=$pageSize',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load projects (${response.statusCode})');
      }

      final List pageData = jsonDecode(response.body);
      projects.addAll(
        pageData.whereType<Map<String, dynamic>>().map(
          (p) => ProjectUser.fromJson(p),
        ),
      );

      if (pageData.length < pageSize) break;
      pageNumber++;
    }

    projects.sort((a, b) {
      final aFinished = a.isFinished ? 1 : 0;
      final bFinished = b.isFinished ? 1 : 0;
      if (aFinished != bFinished) return bFinished.compareTo(aFinished);

      final aPassed = a.isPassed ? 1 : 0;
      final bPassed = b.isPassed ? 1 : 0;
      if (aPassed != bPassed) return bPassed.compareTo(aPassed);

      final aMark = a.finalMark ?? -1;
      final bMark = b.finalMark ?? -1;
      return bMark.compareTo(aMark);
    });

    return projects;
  }

  // Load me on profile screen
  Future<void> loadMe() async {
    _meLoading = true;
    _meError = null;
    notifyListeners();

    try {
      final response = await _authorizedGet(Uri.parse('$_baseUrl/me'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);
        final projects = await _fetchProjectsUsersByLogin(user.login);

        _me = UserModel(
          id: user.id,
          login: user.login,
          displayName: user.displayName,
          email: user.email,
          phone: user.phone,
          imageUrl: user.imageUrl,
          wallet: user.wallet,
          correctionPoints: user.correctionPoints,
          location: user.location,
          isActive: user.isActive,
          cursusUsers: user.cursusUsers,
          projects: projects,
          poolMonth: user.poolMonth,
          poolYear: user.poolYear,
          campusName: user.campusName,
          kind: user.kind,
          isStaff: user.isStaff,
          isAlumni: user.isAlumni,
        );

      } else {
        _meError = 'Failed to load me (${response.statusCode})';
      }
    } catch (e) {
      _meError = 'Network error: ${e.toString()}';
    } finally {
      _meLoading = false;
      notifyListeners();
    }
  }

  // Load campus users on home screen
  Future<void> loadCampusUsers() async {
    _campusLoading = true;
    _campusError = null;
    notifyListeners();

    try {
      final response = await _authorizedGet(
        Uri.parse(
          '$_baseUrl/campus/$_campusId/users?per_page=30&sort=-updated_at',
        ),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _campusUsers = data
            .map((u) => UserModel.fromJson(u))
            .where((u) => u.isActive && u.imageUrl != null)
            .toList();
      } else {
        _campusError = 'Failed to load campus users (${response.statusCode})';
      }
    } catch (e) {
      _campusError = 'Network error: ${e.toString()}';
    } finally {
      _campusLoading = false;
      notifyListeners();
    }
  }

  // Debounced live search — called on every keypress
  void searchUsers(String query) {
    _debounce?.cancel();

    if (query.isEmpty) {
      _searchResults = [];
      _searchLoading = false;
      _searchError = null;
      notifyListeners();
      return;
    }

    _searchLoading = true;
    _searchError = null;
    notifyListeners();

    // Wait 400ms after user stops typing
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      await _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final response = await _authorizedGet(
        Uri.parse(
          '$_baseUrl/users?filter[login]=$query&per_page=10&sort=login',
        ),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _searchResults = data.map((u) => UserModel.fromJson(u)).toList();
        _searchError = null;
      } else if (response.statusCode == 404) {
        _searchResults = [];
        _searchError = 'No users found';
      } else {
        _searchError = 'Search failed (${response.statusCode})';
      }
    } catch (e) {
      _searchError = 'Network error. Check your connection.';
    } finally {
      _searchLoading = false;
      notifyListeners();
    }
  }

  // Load full user profile including projects
  Future<void> loadUserProfile(String login) async {
    _profileLoading = true;
    _profileError = null;
    _selectedUser = null;
    notifyListeners();

    try {
      final userResponse = await _authorizedGet(Uri.parse('$_baseUrl/users/$login'));

      if (userResponse.statusCode == 404) {
        _profileError = 'User "$login" not found';
        return;
      }
      if (userResponse.statusCode != 200) {
        _profileError = 'Failed to load profile (${userResponse.statusCode})';
        return;
      }

      final userJson = jsonDecode(userResponse.body);
      final user = UserModel.fromJson(userJson);
      final projects = await _fetchProjectsUsersByLogin(login);

      // Rebuild user with projects
      _selectedUser = UserModel(
        id: user.id,
        login: user.login,
        displayName: user.displayName,
        email: user.email,
        phone: user.phone,
        imageUrl: user.imageUrl,
        wallet: user.wallet,
        correctionPoints: user.correctionPoints,
        location: user.location,
        isActive: user.isActive,
        cursusUsers: user.cursusUsers,
        projects: projects,
        poolMonth: user.poolMonth,
        poolYear: user.poolYear,
        campusName: user.campusName,
        kind: user.kind,
        isStaff: user.isStaff,
        isAlumni: user.isAlumni,
      );
    } catch (e) {
      _profileError = 'Network error: ${e.toString()}';
    } finally {
      _profileLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _debounce?.cancel();
    _searchResults = [];
    _searchLoading = false;
    _searchError = null;
    notifyListeners();
  }

  void clearProfile() {
    _selectedUser = null;
    _profileError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
