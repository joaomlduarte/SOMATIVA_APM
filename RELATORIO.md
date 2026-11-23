# Relatório – Mange Flix

**Situação de aprendizagem:** aplicativo mobile em Flutter integrado a uma API REST em Python com Django REST Framework (DRF), com cadastro, autenticação JWT e catálogo de filmes.

**Tecnologias:** Python 3.13 · Django 5.2 · Django REST Framework 3.18 · Simple JWT 5.5 · SQLite · Flutter / Dart · pacote `http`

## Estrutura do repositório

```
SOMATIVA_APM/
├── backend/
│   ├── manage.py
│   ├── requirements.txt
│   ├── mangeflix/            → configurações do projeto (settings.py, urls.py)
│   └── filmes/               → app com models, serializers, views, urls e testes
│       └── management/commands/importar_filmes.py
└── app/
    ├── pubspec.yaml
    ├── lib/
    │   ├── main.dart
    │   ├── tema.dart                 → cores e estilo do app
    │   ├── models/filme.dart         → classe Filme (fromJson)
    │   ├── services/api_service.dart → requisições GET/POST para a API
    │   ├── widgets/logo.dart
    │   └── screens/
    │       ├── login_screen.dart     → tela inicial (login)
    │       ├── cadastro_screen.dart  → cadastro de usuário
    │       └── movies_screen.dart    → MoviesScreen (catálogo)
    └── test/widget_test.dart
```

---

## 1. Criação do ambiente virtual Python

Dentro da pasta `backend`:

```powershell
cd backend
python -m venv venv
.\venv\Scripts\activate
```

O ambiente virtual isola as bibliotecas do projeto das bibliotecas instaladas no computador.

## 2. Instalação do Django e do Django REST Framework

```powershell
pip install django djangorestframework djangorestframework-simplejwt django-cors-headers
pip freeze > requirements.txt
```

| Pacote | Para que serve |
|---|---|
| `django` | framework web |
| `djangorestframework` | criação da API REST |
| `djangorestframework-simplejwt` | autenticação por token JWT |
| `django-cors-headers` | libera o acesso do app Flutter (inclusive Flutter Web) |

Para quem clonar o repositório, basta `pip install -r requirements.txt`.

Criação do projeto e do app:

```powershell
django-admin startproject mangeflix .
python manage.py startapp filmes
```

Em `mangeflix/settings.py` os apps foram registrados:

```python
INSTALLED_APPS = [
    ...,
    'rest_framework',
    'corsheaders',
    'filmes',
]
MIDDLEWARE = ['corsheaders.middleware.CorsMiddleware', ...]
ALLOWED_HOSTS = ['*']          # permite acesso pelo emulador (10.0.2.2) e pela rede
CORS_ALLOW_ALL_ORIGINS = True  # ambiente de desenvolvimento
LANGUAGE_CODE = 'pt-br'        # mensagens de erro da API em português
```

## 3. Configuração do banco de dados

Foi usado o **SQLite**, que é o banco padrão do Django e não precisa de instalação. Ele fica no arquivo `backend/db.sqlite3`:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}
```

Os **usuários** ficam na tabela `auth_user` (sistema de autenticação do Django) e os **filmes** na tabela `filmes_filme`. As tabelas são criadas com:

```powershell
python manage.py makemigrations filmes
python manage.py migrate
```

## 4. Modelos, serializers, views e rotas

**Modelo** – `filmes/models.py`

```python
class Filme(models.Model):
    titulo = models.CharField(max_length=200, unique=True)
    imagem = models.URLField(max_length=500)
    duracao = models.CharField(max_length=50)
    ano_lancamento = models.PositiveIntegerField()
    nota = models.FloatField()
```

**Serializers** – `filmes/serializers.py`

- `FilmeSerializer`: converte os filmes do banco em JSON.
- `CadastroSerializer`: recebe `username`, `email` e `password`. A senha é `write_only` (nunca é devolvida), tem no mínimo 6 caracteres e é salva com `User.objects.create_user()`, que grava a senha criptografada.

**Views** – `filmes/views.py`

- `CadastroView` (`CreateAPIView`): cadastra usuário. Aberta a todos (`AllowAny`).
- `FilmeListView` (`ListAPIView`): lista os filmes. Exige token JWT.

**Rotas** – `mangeflix/urls.py` inclui `filmes/urls.py` com o prefixo `api/`:

| Método | Endpoint | View | Funcionalidade |
|---|---|---|---|
| POST | `/api/usuarios/cadastro/` | `CadastroView` | Cadastrar um novo usuário |
| POST | `/api/token/` | `TokenObtainPairView` (Simple JWT) | Autenticar e retornar token JWT |
| GET | `/api/filmes/` | `FilmeListView` | Listar os filmes |

**Importação dos filmes** – `filmes/management/commands/importar_filmes.py`

Comando que baixa o JSON de referência (`https://raw.githubusercontent.com/danielvieira95/DESM-2/master/filmes.json`) e grava cada filme no banco. Os campos do JSON são convertidos assim: `nome → titulo`, `imagem → imagem`, `duração → duracao`, `ano de lançamento → ano_lancamento`, `nota → nota`. Ele usa `update_or_create`, então pode ser executado mais de uma vez sem duplicar filmes.

```powershell
python manage.py importar_filmes
# 7 filmes importados.
```

Os filmes também podem ser vistos e editados pelo painel `/admin` (após `python manage.py createsuperuser`).

## 5. Configuração da autenticação

A autenticação usa o sistema de usuários do Django com **JWT** (biblioteca Simple JWT). Em `settings.py`:

```python
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(hours=8),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=1),
}
```

Fluxo:

1. O app envia usuário e senha para `POST /api/token/`.
2. O Django valida as credenciais e devolve `access` (token de acesso) e `refresh`.
3. O app envia o token no cabeçalho `Authorization: Bearer <access>` ao chamar `GET /api/filmes/`.
4. Sem token (ou com token inválido) a API responde **401**.

## 6. Execução e testes da API

Iniciar o servidor:

```powershell
python manage.py runserver 0.0.0.0:8000
```

`0.0.0.0` deixa a API acessível para o emulador Android e para celulares na mesma rede.

### 6.1 Testes automatizados

Arquivo `filmes/tests.py`, executado com `python manage.py test filmes -v 2`:

```
Found 6 test(s).
test_cadastro_com_usuario_repetido ... ok
test_cadastro_de_usuario ... ok
test_filmes_com_token ... ok
test_filmes_sem_token ... ok
test_login_com_senha_errada ... ok
test_login_retorna_token_jwt ... ok
----------------------------------------------------------------------
Ran 6 tests in 5.876s

OK
```

### 6.2 Testes manuais (log das requisições)

Requisições feitas com o servidor rodando em `http://127.0.0.1:8000`:

```
>>> POST /api/usuarios/cadastro/
    corpo: {"username":"aluno","email":"aluno@exemplo.com","password":"senha123"}
<<< HTTP 201
{"id":1,"username":"aluno","email":"aluno@exemplo.com"}

>>> POST /api/usuarios/cadastro/   (usuário repetido)
<<< HTTP 400
{"username":["Um usuário com este nome de usuário já existe."]}

>>> POST /api/usuarios/cadastro/   (senha com 3 caracteres)
<<< HTTP 400
{"password":["Certifique-se de que este campo tenha mais de 6 caracteres."]}

>>> POST /api/token/   (senha errada)
<<< HTTP 401
{"detail":"No active account found with the given credentials"}

>>> POST /api/token/   (credenciais corretas)
<<< HTTP 200
{"refresh": "eyJhbGciOiJIUzI1NiIsInR5c...", "access": "eyJhbGciOiJIUzI1NiIsInR5c..."}

>>> GET /api/filmes/   (sem token)
<<< HTTP 401
{"detail":"As credenciais de autenticação não foram fornecidas."}

>>> GET /api/filmes/   (com Authorization: Bearer <access>)
<<< HTTP 200
[{"id":1,"titulo":"A Viagem de Chihiro","imagem":"https://br.web.img3.acsta.net/...","duracao":"2 horas","ano_lancamento":2004,"nota":5.0},
 {"id":5,"titulo":"Castelo Animado", ... ,"ano_lancamento":2006,"nota":4.0},
 {"id":3,"titulo":"Homem de ferro 3", ... ,"ano_lancamento":2015,"nota":5.0},
 {"id":6,"titulo":"Mario Bros", ... ,"ano_lancamento":2023,"nota":5.0},
 {"id":2,"titulo":"Ponyo", ... ,"ano_lancamento":2006,"nota":3.0},
 {"id":7,"titulo":"Velozes e Furiosos 10", ... ,"ano_lancamento":2023,"nota":5.0},
 {"id":4,"titulo":"Vingadores", ... ,"ano_lancamento":2012,"nota":5.0}]
```

Os mesmos testes podem ser repetidos com Postman/Insomnia ou com `curl`:

```bash
curl -X POST http://127.0.0.1:8000/api/usuarios/cadastro/ -H "Content-Type: application/json" -d "{\"username\":\"aluno\",\"password\":\"senha123\"}"
curl -X POST http://127.0.0.1:8000/api/token/ -H "Content-Type: application/json" -d "{\"username\":\"aluno\",\"password\":\"senha123\"}"
curl http://127.0.0.1:8000/api/filmes/ -H "Authorization: Bearer COLE_O_TOKEN_AQUI"
```

## 7. Integração do aplicativo Flutter com o backend

### 7.1 Preparar e executar o app

Com o backend rodando, em outro terminal:

```powershell
cd app
flutter create --project-name mange_flix .   # gera as pastas android, ios, web, windows...
flutter pub get                              # instala o pacote http
flutter run                                  # escolha o emulador/dispositivo
```

O `flutter create .` só cria os arquivos que faltam. Os arquivos de `lib/`, o `pubspec.yaml` e o teste já existentes são mantidos.

### 7.2 Endereço da API

Definido em `lib/services/api_service.dart`:

| Onde o app roda | Endereço usado |
|---|---|
| Emulador Android | `http://10.0.2.2:8000` (IP do computador visto pelo emulador) |
| Chrome / Windows / simulador iOS | `http://127.0.0.1:8000` |
| Celular físico | trocar pelo IP do computador na rede, ex.: `http://192.168.0.10:8000` |

### 7.3 Como o app consome a API

A classe `ApiService` concentra todas as requisições:

- `login()` → `POST /api/token/` com usuário e senha; guarda o token `access`.
- `cadastrar()` → `POST /api/usuarios/cadastro/` com usuário, e-mail e senha.
- `listarFilmes()` → `GET /api/filmes/` com o cabeçalho `Authorization: Bearer <token>`; converte o JSON em uma lista de `Filme` (`Filme.fromJson`).

As respostas são decodificadas em UTF-8 para manter a acentuação. Erros de conexão, tempo esgotado (10 s), credenciais inválidas e dados inválidos viram mensagens em português exibidas ao usuário.

### 7.4 Telas e requisitos atendidos

| Requisito | Onde foi atendido |
|---|---|
| F – tela inicial com usuário e senha | `LoginScreen` |
| G – autenticação via POST | `ApiService.login()` → `POST /api/token/` |
| H – tela de cadastro via POST | `CadastroScreen` → `POST /api/usuarios/cadastro/` |
| I – acesso à tela de filmes após login | `Navigator.pushReplacement` para `MoviesScreen` |
| J – mensagens de erro | `SnackBar` vermelho para login/cadastro; tela de erro com "Tentar novamente" no catálogo |
| K – GET em `/api/filmes/` | `ApiService.listarFilmes()` |
| L – pôster, título, duração, ano e nota | `_CartaoFilme` em `movies_screen.dart` |
| M – `StatefulWidget` `MoviesScreen` | `class MoviesScreen extends StatefulWidget` |
| N – ListView, Card, Image e Text | `ListView.builder` → `Card` → `Image.network` + `Text` |
| O – recarregar da API ao abrir a tela | a busca é feita no `initState()` (toda vez que a tela abre, inclusive após reiniciar o app) e pelo botão Atualizar |
| P – interface organizada e responsiva | tema escuro com vermelho Mange Flix, ícones nos campos, conteúdo centralizado com largura máxima (funciona em celular, tablet e web) |
| Q – navegação entre telas | Login ↔ Cadastro (`push`/`pop`), Login → Catálogo, botão Sair → Login |
| R – indicadores de carregamento | `CircularProgressIndicator` nos botões Entrar/Cadastrar, na lista e em cada pôster |

Validações no app: campos obrigatórios, e-mail com `@`, senha com no mínimo 6 caracteres e confirmação de senha igual.

### 7.5 Teste do app

`test/widget_test.dart` verifica se a tela inicial mostra os campos Usuário, Senha e o botão Entrar:

```powershell
flutter test
```

### 7.6 Problemas comuns

| Problema | Solução |
|---|---|
| "Não foi possível conectar à API" | conferir se o `runserver` está ativo e se o endereço do item 7.2 está correto |
| Celular físico não conecta | rodar `runserver 0.0.0.0:8000`, usar o IP do PC e liberar a porta 8000 no firewall |
| Catálogo vazio | rodar `python manage.py importar_filmes` |
| "Sessão expirada" | o token vence em 8 h; sair e entrar de novo |
| Pôster não aparece no Flutter Web | alguns sites de imagem bloqueiam o navegador (CORS); no emulador Android as imagens carregam normalmente |
| APK de release sem internet | adicionar `<uses-permission android:name="android.permission.INTERNET"/>` em `android/app/src/main/AndroidManifest.xml` |

## 8. Versionamento

O projeto foi versionado com Git e publicado no GitHub, com o backend em `backend/` e o app em `app/`. O arquivo `.gitignore` deixa de fora o ambiente virtual, o banco `db.sqlite3` e as pastas geradas pelo Flutter (`build/`, `.dart_tool/`).
