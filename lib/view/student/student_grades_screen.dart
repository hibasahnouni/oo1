import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentGradesScreen extends StatefulWidget {
  static const String routeName = 'StudentGradesScreen';
  const StudentGradesScreen({Key? key}) : super(key: key);

  @override
  _StudentGradesScreenState createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen> {
  final supabase = Supabase.instance.client;

  Future<List<dynamic>> fetchGrades() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    final response = await supabase
        .from('grades')
        .select()
        .eq('student_id', userId)
        .order('subject', ascending: true);

    return response;
  }

  IconData getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
      case 'mathématiques':
        return Icons.calculate;
      case 'physique':
        return Icons.science;
      case 'informatique':
        return Icons.computer;
      case 'français':
        return Icons.menu_book;
      case 'histoire':
        return Icons.account_balance;
      case 'anglais':
        return Icons.language;
      default:
        return Icons.school;
    }
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
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Mes Notes",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: fetchGrades(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Erreur : ${snapshot.error}",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                      );
                    }

                    final grades = snapshot.data;

                    if (grades == null || grades.isEmpty) {
                      return const Center(
                        child: Text(
                          "Aucune note disponible.",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: grades.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9, // Plus petit = cartes plus compactes
                      ),
                      itemBuilder: (context, index) {
                        final grade = grades[index];
                        final subject = grade['subject'] ?? 'Inconnu';
                        final score = grade['grade']?.toString() ?? '--';
                        final date = grade['date']?.toString().split('T').first ?? '';

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(getSubjectIcon(subject), size: 34, color: Color(0xFF345FB4)),
                              const SizedBox(height: 8),
                              Text(
                                subject,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF345FB4),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Note : $score',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Date : $date',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
