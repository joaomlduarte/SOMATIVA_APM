import json
from urllib.request import urlopen

from django.core.management.base import BaseCommand

from filmes.models import Filme

URL_FILMES = 'https://raw.githubusercontent.com/danielvieira95/DESM-2/master/filmes.json'


class Command(BaseCommand):
    help = 'Importa os filmes do JSON de referência para o banco SQLite'

    def handle(self, *args, **options):
        with urlopen(URL_FILMES, timeout=15) as resposta:
            dados = json.loads(resposta.read().decode('utf-8'))

        for item in dados:
            Filme.objects.update_or_create(
                titulo=item['nome'].strip(),
                defaults={
                    'imagem': item['imagem'].strip(),
                    'duracao': item['duração'].strip(),
                    'ano_lancamento': int(item['ano de lançamento']),
                    'nota': float(item['nota']),
                },
            )

        self.stdout.write(self.style.SUCCESS(f'{len(dados)} filmes importados.'))
