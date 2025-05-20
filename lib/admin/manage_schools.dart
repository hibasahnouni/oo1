import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageSchoolsScreen extends StatefulWidget {
  static const String routeName = '/manageSchools';
  const ManageSchoolsScreen({super.key});

  @override
  _ManageSchoolsScreenState createState() => _ManageSchoolsScreenState();
}

class _ManageSchoolsScreenState extends State<ManageSchoolsScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allSchools = [];
  List<Map<String, dynamic>> filteredSchools = [];

  @override
  void initState() {
    super.initState();
    fetchSchools();
  }

  Future<void> fetchSchools() async {
    final response = await supabase.from('school').select();
    setState(() {
      allSchools = List<Map<String, dynamic>>.from(response);
      filteredSchools = allSchools;
    });
  }

  void _searchSchools(String query) {
    final results = allSchools
        .where((school) =>
            school['name']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredSchools = results;
    });
  }

  Future<void> _addSchool() async {
    String schoolName = '';
    String directorName = '';
    String schoolAddress = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
          title: Text('➕ Ajouter une école',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildInputField('Nom de l\'école', Icons.school, (value) => schoolName = value),
                _buildInputField('Nom du directeur', Icons.person, (value) => directorName = value),
                _buildInputField('Adresse', Icons.location_on, (value) => schoolAddress = value),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Annuler', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              onPressed: () async {
                if (schoolName.isNotEmpty &&
                    directorName.isNotEmpty &&
                    schoolAddress.isNotEmpty) {
                  await supabase.from('school').insert({
                    'name': schoolName,
                    'director': directorName,
                    'address': schoolAddress,
                  });
                  fetchSchools();
                  Navigator.pop(context);
                }
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editSchool(int index) async {
    String schoolName = filteredSchools[index]['name']!;
    String directorName = filteredSchools[index]['director']!;
    String schoolAddress = filteredSchools[index]['address']!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('✏️ Modifier l\'école',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildInputField('Nom de l\'école', Icons.school, (value) => schoolName = value, initialValue: schoolName),
                _buildInputField('Nom du directeur', Icons.person, (value) => directorName = value, initialValue: directorName),
                _buildInputField('Adresse', Icons.location_on, (value) => schoolAddress = value, initialValue: schoolAddress),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Annuler', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              onPressed: () async {
                if (schoolName.isNotEmpty &&
                    directorName.isNotEmpty &&
                    schoolAddress.isNotEmpty) {
                  await supabase.from('school').update({
                    'name': schoolName,
                    'director': directorName,
                    'address': schoolAddress,
                  }).eq('id', filteredSchools[index]['id']);
                  fetchSchools();
                  Navigator.pop(context);
                }
              },
              child: Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSchool(int index) async {
    await supabase.from('school').delete().eq('id', filteredSchools[index]['id']);
    fetchSchools();
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚠️ Suppression'),
        content: Text('Confirmer la suppression de cette école ?'),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
            onPressed: () {
              _deleteSchool(index);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon, Function(String) onChanged,
      {String? initialValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      "🏫 Gestion des écoles",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: _addSchool,
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchSchools,
                  decoration: InputDecoration(
                    hintText: '🔍 Rechercher une école',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.search, color: Colors.indigo),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // School List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredSchools.length,
                  itemBuilder: (context, index) {
                    final school = filteredSchools[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.black,
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Icon(Icons.school, color: Colors.grey),
                        ),
                        title: Text(
                          school['name'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                        subtitle: Text(
                            "🎓 Directeur: ${school['director'] ?? ''}\n📍 ${school['address'] ?? ''}"),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _editSchool(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmation(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
