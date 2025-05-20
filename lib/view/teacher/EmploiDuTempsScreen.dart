import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class EmploiDuTempsScreen extends StatefulWidget {
  @override
  _EmploiDuTempsScreenState createState() => _EmploiDuTempsScreenState();
}

class _EmploiDuTempsScreenState extends State<EmploiDuTempsScreen> {
  final Map<String, List<Map<String, String>>> emploiDuTemps = {
    'Lundi': [
      {'matière': 'Mathématiques', 'horaire': '8h00 - 9h30', 'classe': '3ème A'},
      {'matière': 'Français', 'horaire': '10h00 - 11h30', 'classe': '4ème B'},
    ],
    'Mardi': [
      {'matière': 'Histoire', 'horaire': '8h00 - 9h30', 'classe': '2ème C'},
      {'matière': 'Anglais', 'horaire': '10h00 - 11h30', 'classe': '3ème A'},
    ],
    'Mercredi': [
      {'matière': 'Sciences', 'horaire': '8h00 - 9h30', 'classe': '5ème D'},
    ],
    'Jeudi': [
      {'matière': 'Informatique', 'horaire': '9h00 - 10h30', 'classe': 'Terminale S'},
    ],
    'Vendredi': [
      {'matière': 'Philosophie', 'horaire': '8h30 - 10h00', 'classe': 'Première L'},
    ],
  };

  int currentWeekOffset = 0;

  void _showNotification(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Notification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Color(0xFF345FB4),
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF345FB4),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _exportToPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Emploi du Temps',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              )),
          ...emploiDuTemps.entries.map(
            (entry) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(entry.key,
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ...entry.value.map(
                  (cours) => pw.Text(
                    '${cours['matière']} - ${cours['horaire']} - Classe: ${cours['classe']}',
                    style: pw.TextStyle(fontSize: 16),
                  ),
                ),
                pw.SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
    // Note : tu peux ici sauvegarder ou partager le PDF
  }

  String getWeekLabel() {
    DateTime now = DateTime.now().add(Duration(days: currentWeekOffset * 7));
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 4));
    return '${DateFormat('dd MMM').format(startOfWeek)} - ${DateFormat('dd MMM').format(endOfWeek)}';
  }

  void _nextWeek() {
    setState(() {
      currentWeekOffset++;
    });
  }

  void _previousWeek() {
    setState(() {
      currentWeekOffset--;
    });
  }

  final Gradient appBarGradient = const LinearGradient(
    colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: appBarGradient),
          ),
          title: Text(
            'Emploi du temps',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.picture_as_pdf, color: Colors.white),
              onPressed: _exportToPDF,
              tooltip: 'Exporter en PDF',
            ),
          ],
          elevation: 0,
        ),
      ),
      body: Container(
        color: Color(0xFFF0F3FF), // Fond très clair bleu-violet
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _previousWeek,
                    icon: Icon(Icons.arrow_back, color: Color(0xFF345FB4)),
                  ),
                  Text(
                    'Semaine: ${getWeekLabel()}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFF345FB4),
                    ),
                  ),
                  IconButton(
                    onPressed: _nextWeek,
                    icon: Icon(Icons.arrow_forward, color: Color(0xFF345FB4)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: emploiDuTemps.keys.map((jour) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Text(
                          jour,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Color(0xFF5A6DB7),
                          ),
                        ),
                      ),
                      Column(
                        children: emploiDuTemps[jour]!.map((item) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            shadowColor: Color(0xFF8E9EFB).withOpacity(0.5),
                            child: ListTile(
                              leading: Icon(Icons.schedule, color: Color(0xFF6D7DE3)),
                              title: Text(
                                '${item['matière']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF345FB4),
                                ),
                              ),
                              subtitle: Text(
                                'Horaire: ${item['horaire']} - Classe: ${item['classe']}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.notifications,
                                    size: 25, color: Color(0xFF8E9EFB)),
                                onPressed: () {
                                  _showNotification(
                                      'Le cours de ${item['matière']} a été modifié.');
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      Divider(color: Colors.blueGrey[200], thickness: 1.2),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
