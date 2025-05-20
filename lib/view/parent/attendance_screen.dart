import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Assure-toi dans pubspec.yaml

class AttendanceScreen extends StatefulWidget {
  static String routeName = 'AttendanceScreen';

  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final supabase = Supabase.instance.client;
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool isLoading = true;

  // Palette couleurs identique au dashboard
  final Gradient backgroundGradient = const LinearGradient(
    colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final Color cardColor = Colors.white.withOpacity(0.95);
  final Color primaryColor = const Color(0xFF345FB4);

  @override
  void initState() {
    super.initState();
    fetchStudents();
    searchController.addListener(() {
      filterStudents(searchController.text);
    });
  }

  Future<void> fetchStudents() async {
    setState(() {
      isLoading = true;
    });
    final response = await supabase.from('students').select('id, full_name, attendance');

    if (response.error == null) {
      students = List<Map<String, dynamic>>.from(response.data as List);
      filteredStudents = students;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des élèves')),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  void filterStudents(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredStudents = students;
      });
    } else {
      setState(() {
        filteredStudents = students
            .where((student) =>
                (student['full_name'] as String).toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fond dégradé comme dans AdminDashboard
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Column(
          children: [
            // Header simple à la AdminDashboard
            Row(
              children: [
                Text(
                  'Assiduité',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 3,
                        color: Colors.black45,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Barre de recherche dans une Card blanche arrondie et ombrée
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 6,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Rechercher un élève",
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
            ),

            const SizedBox(height: 20),

            // Liste des élèves
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryColor))
                  : filteredStudents.isEmpty
                      ? Center(
                          child: Text(
                            "Aucun élève trouvé.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            final isPresent = student['attendance'] == true;

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: cardColor,
                              elevation: 6,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                title: Text(
                                  student['full_name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: primaryColor,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isPresent
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isPresent ? Icons.check_circle : Icons.cancel,
                                    color: isPresent ? Colors.green : Colors.red,
                                    size: 30,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on PostgrestList {
  get error => null;
  
  get data => null;
}
