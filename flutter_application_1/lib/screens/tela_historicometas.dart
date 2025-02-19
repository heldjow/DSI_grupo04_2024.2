import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/meta.dart';

class HistoricoMetasScreen extends StatefulWidget {
  const HistoricoMetasScreen({super.key});

  @override
  _HistoricoMetasScreenState createState() => _HistoricoMetasScreenState();
}

class _HistoricoMetasScreenState extends State<HistoricoMetasScreen> {
  final TextEditingController _dataController = TextEditingController();
  List<Meta> _metas = [];

  @override
  void initState() {
    super.initState();
    _buscarMetas();
  }

  Future<void> _buscarMetas({String? data}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Query query = FirebaseFirestore.instance
        .collection('metas')
        .where('userId', isEqualTo: user.uid);

    if (data != null && data.isNotEmpty) {
      final dateFormat = DateFormat('dd-MM-yyyy');
      final parsedDate = dateFormat.parse(data);
      final formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      query = query.where('date', isEqualTo: formattedDate);
    }

    final snapshot = await query.get();

    // Evita chamar setState() se o widget já foi descartado
    if (!mounted) return;

    setState(() {
      _metas = snapshot.docs
          .map((doc) => Meta.fromJson(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> _excluirMeta(String metaId) async {
    await FirebaseFirestore.instance.collection('metas').doc(metaId).delete();
    _buscarMetas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histórico de Metas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF133E87),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 232, 230, 230),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dataController,
              decoration: InputDecoration(
                labelText: 'Pesquisar por Data (DD-MM-YYYY)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _buscarMetas(data: _dataController.text),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _metas.length,
                itemBuilder: (context, index) {
                  final meta = _metas[index];
                  final bateuMeta = meta.taskIds.length >= meta.taskGoal;
                  final formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(meta.date));
                  return Dismissible(
                    key: Key(meta.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      _excluirMeta(meta.id);
                    },
                    child: Card(
                      child: ListTile(
                        title: Text('Meta de tarefas: ${meta.taskGoal}'),
                        subtitle: Text('Data: $formattedDate\nConcluídas: ${meta.taskIds.length}'),
                        trailing: Icon(
                          bateuMeta ? Icons.check_circle : Icons.cancel,
                          color: bateuMeta ? Colors.green : Colors.red,
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