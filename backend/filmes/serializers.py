from django.contrib.auth.models import User
from rest_framework import serializers

from .models import Filme


class FilmeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Filme
        fields = ['id', 'titulo', 'imagem', 'duracao', 'ano_lancamento', 'nota']


class CadastroSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password']

    def create(self, validated_data):
        # create_user grava a senha criptografada (hash), nunca em texto puro
        return User.objects.create_user(**validated_data)
