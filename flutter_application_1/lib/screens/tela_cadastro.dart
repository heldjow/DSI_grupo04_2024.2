import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_registro.dart'; 

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  // Controladores de campos
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  // Referência para o serviço de autenticação
  final AuthService _authService = AuthService();

  // Função para cadastrar usuário
  Future<void> _cadastrarUsuario() async {
    // Validação de entradas
    if (_nomeController.text.isEmpty ||
        _usuarioController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _senhaController.text.isEmpty) {
      _showSnackBar('Preencha todos os campos!');
      return;
    }

    // Verificação do formato do e-mail
    final String email = _emailController.text;
    final RegExp emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
    if (!emailRegex.hasMatch(email)) {
      _showSnackBar('Por favor, insira um e-mail válido!');
      return;
    }

    // Verificação do comprimento da senha
    if (_senhaController.text.length < 6) {
      _showSnackBar('A senha deve ter pelo menos 6 caracteres!');
      return;
    }

    try {
      // Criação do usuário com Firebase Authentication
      // ignore: unused_local_variable
      UserCredential userCredential = await _authService.cadastrarUsuario(
          _emailController.text, _senhaController.text);

      // Exibe mensagem de sucesso
      _showSnackBar('Cadastro realizado com sucesso!');
    } catch (e) {
      // Tratamento de erros mais específicos
      String errorMessage = 'Erro desconhecido';
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Este e-mail já está em uso';
        } else if (e.code == 'weak-password') {
          errorMessage = 'A senha fornecida é muito fraca';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'E-mail inválido';
        }
      }

      _showSnackBar(errorMessage);
    }
  }

  // Método privado para exibir SnackBar
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 232, 230, 230),
      body: Stack(
        children: [
          // Botão de Voltar
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Color.fromRGBO(19, 62, 135, 1)),
              onPressed: () {
                Navigator.pop(context); // Voltar para a tela anterior
              },
            ),
          ),

          // Conteúdo principal
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Estamos quase lá...',
                    style: TextStyle(
                      fontSize: 32,
                      color: Color.fromRGBO(19, 62, 135, 1),
                    ),
                  ),
                  const SizedBox(height: 0),
                  const Text(
                    'Informe seus dados',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Campo de Nome
                  _buildTextField(_nomeController, 'Nome', Icons.person),
                  const SizedBox(height: 16),

                  // Campo de Usuário
                  _buildTextField(
                      _usuarioController, 'Usuário', Icons.account_circle),
                  const SizedBox(height: 16),

                  // Campo de Email
                  _buildTextField(_emailController, 'Email', Icons.email),
                  const SizedBox(height: 16),

                  // Campo de Senha
                  _buildTextField(_senhaController, 'Senha', Icons.lock,
                      obscureText: true),
                  const SizedBox(height: 32),

                  // Botão Cadastrar-se
                  ElevatedButton(
                    onPressed: _cadastrarUsuario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(19, 62, 135, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(300, 50),
                    ),
                    child: const Text(
                      'Cadastrar-se',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método privado para construir os campos de texto
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return Center(
      child: SizedBox(
        width: 300,
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            labelText: label,
            labelStyle: const TextStyle(color: Color.fromRGBO(19, 62, 135, 1)),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}
