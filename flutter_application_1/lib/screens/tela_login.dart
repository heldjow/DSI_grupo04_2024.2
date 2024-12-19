import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proAluno/Widgets/bottomNavBar.dart';
import 'tela_cadastro.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  Future<void> _loginUsuario() async {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      _showSnackBar('Preencha todos os campos!');
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      _showSnackBar('E-mail inválido!');
      return;
    }

    if (_senhaController.text.length < 6) {
      _showSnackBar('A senha deve ter pelo menos 6 caracteres!');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _senhaController.text,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro no login. Verifique suas credenciais.');
      }
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 230, 230),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Seja bem-vindo ao ProAluno',
                style: TextStyle(
                    fontSize: 32, color: Color.fromRGBO(19, 62, 135, 1)),
              ),
              const SizedBox(height: 24),
              _buildTextField(_emailController, 'Email', Icons.email),
              const SizedBox(height: 16),
              _buildTextField(_senhaController, 'Senha', Icons.lock,
                  obscureText: true),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loginUsuario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(19, 62, 135, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(300, 35),
                ),
                child: const Text('Acessar',
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 35),
              const Text('Não tem uma conta?',
                  style: TextStyle(
                      fontSize: 13, color: Color.fromRGBO(0, 0, 0, 0.2))),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                ),
                child: const Text('Cadastre-se',
                    style: TextStyle(
                        fontSize: 13, color: Color.fromRGBO(19, 62, 135, 1))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          labelStyle: const TextStyle(color: Color.fromRGBO(19, 62, 135, 1)),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}
