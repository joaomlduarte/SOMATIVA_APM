from django.db import models


class Filme(models.Model):
    titulo = models.CharField(max_length=200, unique=True)
    imagem = models.URLField(max_length=500)
    duracao = models.CharField(max_length=50)
    ano_lancamento = models.PositiveIntegerField()
    nota = models.FloatField()

    class Meta:
        ordering = ['titulo']

    def __str__(self):
        return self.titulo
