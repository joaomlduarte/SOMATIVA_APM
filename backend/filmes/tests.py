from rest_framework.test import APITestCase

from .models import Filme


class ApiTests(APITestCase):
    def setUp(self):
        Filme.objects.create(
            titulo='Ponyo', imagem='https://exemplo.com/ponyo.jpg',
            duracao='2.3 horas', ano_lancamento=2006, nota=3,
        )

    def cadastrar_e_logar(self):
        self.client.post('/api/usuarios/cadastro/', {'username': 'joao', 'password': 'senha123'})
        resposta = self.client.post('/api/token/', {'username': 'joao', 'password': 'senha123'})
        return resposta.data['access']

    def test_cadastro_de_usuario(self):
        resposta = self.client.post('/api/usuarios/cadastro/', {'username': 'joao', 'password': 'senha123'})
        self.assertEqual(resposta.status_code, 201)
        self.assertNotIn('password', resposta.data)

    def test_cadastro_com_usuario_repetido(self):
        self.client.post('/api/usuarios/cadastro/', {'username': 'joao', 'password': 'senha123'})
        resposta = self.client.post('/api/usuarios/cadastro/', {'username': 'joao', 'password': 'senha123'})
        self.assertEqual(resposta.status_code, 400)

    def test_login_retorna_token_jwt(self):
        token = self.cadastrar_e_logar()
        self.assertTrue(token)

    def test_login_com_senha_errada(self):
        self.client.post('/api/usuarios/cadastro/', {'username': 'joao', 'password': 'senha123'})
        resposta = self.client.post('/api/token/', {'username': 'joao', 'password': 'errada'})
        self.assertEqual(resposta.status_code, 401)

    def test_filmes_sem_token(self):
        resposta = self.client.get('/api/filmes/')
        self.assertEqual(resposta.status_code, 401)

    def test_filmes_com_token(self):
        token = self.cadastrar_e_logar()
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
        resposta = self.client.get('/api/filmes/')
        self.assertEqual(resposta.status_code, 200)
        self.assertEqual(resposta.data[0]['titulo'], 'Ponyo')
