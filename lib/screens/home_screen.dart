import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserProvider>().loadCampusUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final titles = ['Home', 'Search'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildUsersList(userProvider, showSearchState: false),
          _buildSearchTab(userProvider),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(showSelectedUser: false),
              ),
            );
            return;
          }
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSearchTab(UserProvider userProvider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              final text = value.trim();
              setState(() => _query = text);
              context.read<UserProvider>().searchUsers(text);
            },
            decoration: InputDecoration(
              hintText: 'Search by login',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                        context.read<UserProvider>().clearSearch();
                      },
                    ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(child: _buildUsersList(userProvider, showSearchState: true)),
      ],
    );
  }

  Widget _buildUsersList(
    UserProvider userProvider, {
    required bool showSearchState,
  }) {
    final isSearching = showSearchState && _query.isNotEmpty;
    final isLoading = isSearching
        ? userProvider.searchLoading
        : userProvider.campusLoading;
    final error = isSearching
        ? userProvider.searchError
        : userProvider.campusError;
    final users = isSearching
        ? userProvider.searchResults
        : userProvider.campusUsers;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (isSearching) {
                  context.read<UserProvider>().searchUsers(_query);
                } else {
                  context.read<UserProvider>().loadCampusUsers();
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Text(
          isSearching ? 'No users match your search.' : 'No users found.',
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (itemContext, index) {
        final user = users[index];
        return ListTile(
          leading: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black12,
            ),
            clipBehavior: Clip.antiAlias,
            child: user.imageUrl == null
                ? const Icon(Icons.person)
                : Padding(
                    padding: const EdgeInsets.all(1),
                    child: Image.network(
                      user.imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person);
                      },
                    ),
                  ),
          ),
          title: Text(user.login),
          subtitle: Text(user.displayName),
          onTap: () async {
            await itemContext.read<UserProvider>().loadUserProfile(user.login);
            if (!itemContext.mounted) return;
            Navigator.of(itemContext).push(
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(showSelectedUser: true),
              ),
            );
          },
        );
      },
    );
  }
}
