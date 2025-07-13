from rest_framework import serializers
from .models import Estudiante

class PerfilEstudianteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Estudiante
        fields = ['nombres_apellidos']
