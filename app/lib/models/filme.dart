class Filme {
  final String titulo;
  final String imagem;
  final String duracao;
  final int anoLancamento;
  final double nota;

  const Filme({
    required this.titulo,
    required this.imagem,
    required this.duracao,
    required this.anoLancamento,
    required this.nota,
  });

  factory Filme.fromJson(Map<String, dynamic> json) {
    return Filme(
      titulo: json['titulo'] ?? '',
      imagem: json['imagem'] ?? '',
      duracao: json['duracao'] ?? '',
      anoLancamento: json['ano_lancamento'] ?? 0,
      nota: (json['nota'] as num?)?.toDouble() ?? 0,
    );
  }
}
