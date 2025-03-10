import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mapa.dart';

class EditarLocalScreen extends StatefulWidget {
  final PontoMapa ponto;
  final VoidCallback onPontoEditado;
  const EditarLocalScreen({
    super.key,
    required this.ponto,
    required this.onPontoEditado,
  });

  @override
  EditarLocalScreenState createState() => EditarLocalScreenState();
}

class EditarLocalScreenState extends State<EditarLocalScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tituloController.text = widget.ponto.titulo;
    _descricaoController.text = widget.ponto.descricao;
  }

  Future<void> _salvarAlteracoes() async {
    try {
      final novoPonto = PontoMapa(
        id: widget.ponto.id,
        titulo: _tituloController.text,
        descricao: _descricaoController.text,
        localizacao: widget.ponto.localizacao,
        userId: widget.ponto.userId,
      );

      await FirebaseFirestore.instance
          .collection('mapa')
          .doc(widget.ponto.id)
          .update(novoPonto.toJson());

      if (!mounted) return;

      Navigator.pop(context, novoPonto); // Retorna o ponto editado
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao salvar alterações: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 230, 230),
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color(0xFF133E87),
        title: const Center(
          child: Text(
            'Editar Local',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _salvarAlteracoes,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF133E87),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Salvar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
