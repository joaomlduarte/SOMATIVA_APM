import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/logo.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _usuarioController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (_carregando || !_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    try {
      await ApiService.cadastrar(
        _usuarioController.text.trim(),
        _emailController.text.trim(),
        _senhaController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso! Faça login.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } on ApiException catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro.mensagem), backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const LogoMangeFlix(),
                    const SizedBox(height: 8),
                    const Text(
                      'Cadastre-se e comece a assistir',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _usuarioController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Usuário',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (valor) =>
                          (valor == null || valor.trim().isEmpty) ? 'Informe o usuário' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (valor) =>
                          (valor == null || !valor.contains('@')) ? 'Informe um e-mail válido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (valor) => (valor == null || valor.length < 6)
                          ? 'A senha deve ter pelo menos 6 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmarController,
                      obscureText: true,
                      onFieldSubmitted: (_) => _cadastrar(),
                      decoration: const InputDecoration(
                        labelText: 'Confirmar senha',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (valor) =>
                          valor != _senhaController.text ? 'As senhas não conferem' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _carregando ? null : _cadastrar,
                      child: _carregando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Cadastrar'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _carregando ? null : () => Navigator.of(context).pop(),
                      child: const Text('Já possui uma conta? Entrar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
