# Mange Flix

Aplicativo mobile em **Flutter** integrado a uma API REST em **Python / Django REST Framework**, com cadastro, login (JWT) e catálogo de filmes.

```
SOMATIVA_APM/
├── backend/   → API Django REST Framework (SQLite + JWT)
├── app/       → Aplicativo Flutter
└── RELATORIO.md → passo a passo completo de configuração, execução e testes
```

## Como rodar (resumo)

**Backend**

```powershell
cd backend
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py importar_filmes
python manage.py runserver 0.0.0.0:8000
```

**App Flutter** (em outro terminal)

```powershell
cd app
flutter create --project-name mange_flix .
flutter pub get
flutter run
```

## Endpoints

| Método | Endpoint                   | Funcionalidade                        |
|--------|----------------------------|---------------------------------------|
| POST   | `/api/usuarios/cadastro/`  | Cadastrar um novo usuário             |
| POST   | `/api/token/`              | Autenticar usuário e retornar token JWT |
| GET    | `/api/filmes/`             | Listar os filmes (exige token)        |

O passo a passo detalhado está em [RELATORIO.md](RELATORIO.md).
