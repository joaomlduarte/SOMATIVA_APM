from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView

from .views import CadastroView, FilmeListView

urlpatterns = [
    path('usuarios/cadastro/', CadastroView.as_view(), name='cadastro'),
    path('token/', TokenObtainPairView.as_view(), name='token'),
    path('filmes/', FilmeListView.as_view(), name='filmes'),
]
