import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagePaymentsScreen extends StatefulWidget {
  static const String routeName = '/managePayments';
  const ManagePaymentsScreen({super.key});

  @override
  State<ManagePaymentsScreen> createState() => _ManagePaymentsScreenState();
}

class _ManagePaymentsScreenState extends State<ManagePaymentsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> payments = [];
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    final response = await supabase
        .from('pyment')
        .select('id, amount, status, pyment_date, students(full_name)')
        .order('pyment_date', ascending: false);

    setState(() {
      payments = List<Map<String, dynamic>>.from(response);
    });
  }

  List<Map<String, dynamic>> _getPaymentsForDay(DateTime day) {
    return payments.where((payment) {
      final date = DateTime.tryParse(payment['pyment_date'] ?? '')?.toLocal();
      return date != null &&
          date.year == day.year &&
          date.month == day.month &&
          date.day == day.day;
    }).toList();
  }

  Future<void> _updatePayment(String id, String status) async {
    await supabase.from('pyment').update({'status': status}).eq('id', id);
    _fetchPayments();
  }

  Future<void> _deletePayment(String id) async {
    await supabase.from('pyment').delete().eq('id', id);
    _fetchPayments();
  }

  void _showAddPaymentDialog() {
    final studentController = TextEditingController();
    final amountController = TextEditingController();
    String status = 'No Paid';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("➕ Ajouter un paiement"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: studentController,
                  decoration: const InputDecoration(
                    labelText: "Nom de l'élève",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Montant",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: "Statut",
                    border: OutlineInputBorder(),
                  ),
                  items: ['Paid', 'No Paid'].map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (val) => setState(() => status = val ?? 'No Paid'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Annuler"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Ajouter"),
              onPressed: () async {
                if (studentController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  try {
                    final response = await supabase
                        .from('students')
                        .select('id')
                        .eq('full_name', studentController.text)
                        .single();

                    if (response != null) {
                      await supabase.from('pyment').insert({
                        'student_id': response['id'],
                        'amount': double.parse(amountController.text),
                        'status': status,
                        'pyment_date': DateTime.now().toIso8601String(),
                      });
                      Navigator.of(context).pop();
                      _fetchPayments();
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("❌ Élève introuvable.")),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Marquage des jours avec des paiements (vert = payé, rouge = non payé)
  Map<DateTime, List<Map<String, dynamic>>> _groupPaymentsByDay() {
    final Map<DateTime, List<Map<String, dynamic>>> data = {};
    for (var payment in payments) {
      final date = DateTime.tryParse(payment['pyment_date'] ?? '')?.toLocal();
      if (date != null) {
        final day = DateTime(date.year, date.month, date.day);
        data.putIfAbsent(day, () => []).add(payment);
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final events = _groupPaymentsByDay();

    return Scaffold(
      appBar: AppBar(
        title: const Text("💳 Gestion des paiements"),
        backgroundColor: const Color(0xFFF5F7FA),
        actions: [
          IconButton(
            icon:  Icon(Icons.add,color: Colors.black,),
            onPressed: _showAddPaymentDialog,
          ),
        ],
      ),
      backgroundColor: Color(0xFF8E9EFB), 
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) => events[DateTime(day.year, day.month, day.day)] ?? [],
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                  final isPaid = events.any((e) => ['status'] == 'Paid');
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isPaid ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _getPaymentsForDay(_selectedDay).map((payment) {
                  final studentName = payment['students']['full_name'] ?? 'Inconnu';
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text("👤 Élève : $studentName"),
                      subtitle: Text("💰 Montant : ${payment['amount']} DA\n📌 Statut : ${payment['status']}"),
                      trailing: Icon(
                        payment['status'] == 'Paid' ? Icons.check_circle : Icons.cancel,
                        color: payment['status'] == 'Paid' ? Colors.green : Colors.red,
                      ),
                      onTap: () {
                        final newStatus = payment['status'] == 'Paid' ? 'No Paid' : 'Paid';
                        _updatePayment(payment['id'], newStatus);
                      },
                      onLongPress: () => _deletePayment(payment['id']),
                    ),
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
