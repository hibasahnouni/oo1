import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageUsersScreen extends StatefulWidget {
  static const String routeName = '/manageusers';

  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;

  final Gradient backgroundGradient = const LinearGradient(
    colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    final response = await supabase.from('users').select();
    setState(() {
      users = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  Future<void> deleteUser(String id) async {
    await supabase.from('users').delete().eq('id', id);
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Manage Users',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : users.isEmpty
                ? const Center(
                    child: Text(
                      "No users found.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 16),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: const Icon(Icons.person, color: Color(0xFF345FB4), size: 30),
                            title: Row(
                              children: [
                                const Icon(Icons.email, color: Colors.grey, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    user['email'] ?? 'No email',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Color(0xFF345FB4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                const Icon(Icons.verified_user, color: Colors.grey, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Role: ${user['role'] ?? 'Unknown'}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => deleteUser(user['id']),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ajouter un utilisateur (à personnaliser selon ton app)
        },
        backgroundColor: const Color(0xFF345FB4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
