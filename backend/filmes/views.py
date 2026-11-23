from rest_framework import generics
from rest_framework.permissions import AllowAny

from .models import Filme
from .serializers import CadastroSerializer, FilmeSerializer


class CadastroView(generics.CreateAPIView):
    """POST /api/usuarios/cadastro/ - cadastra um novo usuário (aberto, sem token)."""
    serializer_class = CadastroSerializer
    permission_classes = [AllowAny]


class FilmeListView(generics.ListAPIView):
    """GET /api/filmes/ - lista os filmes (exige token JWT)."""
    queryset = Filme.objects.all()
    serializer_class = FilmeSerializer
