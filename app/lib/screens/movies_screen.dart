import 'package:flutter/material.dart';

import '../models/filme.dart';
import '../services/api_service.dart';
import '../tema.dart';
import 'login_screen.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  late Future<List<Filme>> _filmes;

  @override
  void initState() {
    super.initState();
    // Busca os filmes na API sempre que a tela é carregada.
    _filmes = ApiService.listarFilmes();
  }

  void _recarregar() {
    setState(() => _filmes = ApiService.listarFilmes());
  }

  void _sair() {
    ApiService.token = null;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Filmes'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Atualizar', onPressed: _recarregar),
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Sair', onPressed: _sair),
        ],
      ),
      body: FutureBuilder<List<Filme>>(
        future: _filmes,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _MensagemErro(
              mensagem: snapshot.error.toString(),
              aoTentarNovamente: _recarregar,
            );
          }

          final filmes = snapshot.data!;
          if (filmes.isEmpty) {
            return const Center(child: Text('Nenhum filme cadastrado.'));
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filmes.length,
                itemBuilder: (context, indice) => _CartaoFilme(filme: filmes[indice]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CartaoFilme extends StatelessWidget {
  const _CartaoFilme({required this.filme});

  final Filme filme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            filme.imagem,
            width: 100,
            height: 150,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progresso) => progresso == null
                ? child
                : const SizedBox(
                    width: 100,
                    height: 150,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
            errorBuilder: (context, erro, pilha) => Container(
              width: 100,
              height: 150,
              color: Colors.black26,
              child: const Icon(Icons.movie, size: 40, color: Colors.white54),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filme.titulo,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _Informacao(icone: Icons.schedule, texto: 'Duração: ${filme.duracao}'),
                  _Informacao(
                    icone: Icons.calendar_today,
                    texto: 'Lançamento: ${filme.anoLancamento}',
                  ),
                  _Informacao(
                    icone: Icons.star,
                    texto: 'Nota: ${filme.nota.toStringAsFixed(1)}',
                    corIcone: Colors.amber,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Informacao extends StatelessWidget {
  const _Informacao({required this.icone, required this.texto, this.corIcone = Colors.white70});

  final IconData icone;
  final String texto;
  final Color corIcone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icone, size: 18, color: corIcone),
          const SizedBox(width: 6),
          Expanded(child: Text(texto, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }
}

class _MensagemErro extends StatelessWidget {
  const _MensagemErro({required this.mensagem, required this.aoTentarNovamente});

  final String mensagem;
  final VoidCallback aoTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: corPrincipal),
            const SizedBox(height: 16),
            Text(mensagem, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: aoTentarNovamente,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
