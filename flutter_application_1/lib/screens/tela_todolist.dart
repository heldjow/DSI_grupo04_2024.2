import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proAluno/Widgets/addButton.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';

class TodolistScreen extends StatefulWidget {
  const TodolistScreen({super.key});

  @override
  State<TodolistScreen> createState() => _TodolistScreenState();
}

class _TodolistScreenState extends State<TodolistScreen> {
  DateTime _selectedDate = DateTime.now();

  String getCurrentDay() {
    final List<String> daysOfWeek = ['domingo','segunda','terça','quarta','quinta','sexta','sábado'];
    return daysOfWeek[DateTime.now().weekday % 7];}

  void _onDateChange(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  // função para acessar todas as tasks
  final userCredential = FirebaseAuth.instance.currentUser;

  Stream<List<Task>> _fetchTasksForSelectedDate() {
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: userCredential!.uid)
        .where('date', isEqualTo: _selectedDate.toIso8601String().split('T').first)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Task.fromJson(doc.id, doc.data());
            }).toList());
  }

  // função para deletar tasks
  Future<void> _deletetask(Task task) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Excluir Tarefa"),
          content: const Text("Você realmente deseja excluir esta tarefa?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('tasks').doc(task.id).delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Tarefa excluída com sucesso!"),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Excluir"),
            ),
          ],
        );
      },
    );
  }


  // função para editar tasks
  void _editTask(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    final dateController = TextEditingController(text: task.date);
    final timeController = TextEditingController(text: task.hour);

showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Editar Tarefa'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dateController,
                      readOnly: true, // Prevents manual editing
                      decoration: const InputDecoration(
                        labelText: 'Data',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        // Update the date in the controller
                        dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: timeController,
                      readOnly: true, 
                      decoration: InputDecoration(
                        labelText: 'Horário',
                        border: const OutlineInputBorder(),
                        hintText: task.hour,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: int.parse(task.hour.split(':')[0]),
                          minute: int.parse(task.hour.split(':')[1]),
                        ),
                      );
                      if (pickedTime != null) {
                        timeController.text = pickedTime.format(context);
              

                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog without saving
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update Firestore with all changes
              FirebaseFirestore.instance.collection('tasks').doc(task.id).update({
                'title': titleController.text,
                'description': descriptionController.text,
                'date': dateController.text,
                'hour': timeController.text,
              }).then((_) {
                Navigator.of(context).pop(); // Close dialog after saving
              });
            },
            child: const Text('Salvar'),
          ),
        ],
      );
    },
  );
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 232, 230, 230),
    appBar: AppBar(
      toolbarHeight: 70,
      backgroundColor: const Color(0xFF133E87),
      title: Text(
        "Hoje é ${getCurrentDay()}",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Picker Section
        Padding(
          padding: const EdgeInsets.all(10),
          child: DatePicker(
            DateTime.now(),
            height: 100,
            width: 80,
            locale: "pt_br",
            initialSelectedDate: _selectedDate,
            selectionColor: const Color(0xFF133E87),
            selectedTextColor: Colors.white,
            onDateChange: _onDateChange,
          ),
        ),
        // Task List Section
        Expanded(
          child: StreamBuilder<List<Task>>(
            stream: _fetchTasksForSelectedDate(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Erro ao carregar tarefas'));
              }

              final tasks = snapshot.data ?? [];
              if (tasks.isEmpty) {
                return const Center(child: Text('Nenhuma tarefa para esta data'));
              }

              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 7.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF133E87),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.hour,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      subtitle: Text(
                        task.description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black45,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.black87),
                            onPressed: () => _editTask(context, task),
                          ),
                          Checkbox(
                            value: task.isComplete,
                            onChanged: (value) {
                              FirebaseFirestore.instance
                                  .collection('tasks')
                                  .doc(task.id)
                                  .update({'isComplete': value});
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        _deletetask(task);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
    // Add the floatingActionButton here
    floatingActionButton: AddButton(
      onPressed: () {
        Navigator.pushNamed(context, '/tela_adicionartask');
      },
    ),
  );
}
}