import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipes/providers/auth_provider.dart';

final isRegisterProvider = StateProvider<bool>((ref) => false);

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const backgroundColor = Color(0xFF121212);
    const cardColor = Color(0xFF1E1E1E);
    const accentColor = Color(0xFFFF1744);

    final isRegister = ref.watch(isRegisterProvider);

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final usernameController = TextEditingController();

    void _login() {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha todos os campos')),
        );
        return;
      }

      print('Usuário fez login: $email');
      final notifier = ref.read(authProvider.notifier);
      notifier.login(email, password);
    }

    void _register() {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final username = usernameController.text.trim();

      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha todos os campos')),
        );
        return;
      }
      final notifier = ref.read(authProvider.notifier);

      notifier.register(email, password,username);
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Bem-vindo'),
            SizedBox(width: 8),
            Icon(Icons.lock),
          ],
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        foregroundColor: accentColor,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(70),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, size: 64, color: accentColor),
                const SizedBox(height: 20),
                Text(
                  isRegister ? 'Registro' : 'Faça login ou registre-se',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 20),
                if (isRegister)
                  Column(
                    children: [
                      TextField(
                        controller: usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (isRegister) {
                      _register();
                    } else {
                      _login();
                    }
                  },
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: Text(isRegister ? 'Registrar' : 'Login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    ref.read(isRegisterProvider.notifier).state = !isRegister;
                  },
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                      children: [
                        TextSpan(
                          text: isRegister
                              ? 'Já tem uma conta? '
                              : 'Não tem uma conta? ',
                        ),
                        TextSpan(
                          text: isRegister ? 'Faça login' : 'Cadastre-se',
                          style: const TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
