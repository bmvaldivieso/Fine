from django.db import models
from django.contrib.auth.models import User
from django.db import models
from django.utils import timezone
from datetime import timedelta
import logging

logger = logging.getLogger(__name__)

class CodigoVerificacionEmail(models.Model):
    correo = models.EmailField()
    codigo = models.CharField(max_length=6)
    creado_en = models.DateTimeField(auto_now_add=True)
    expiracion = models.DateTimeField()

    def __str__(self):
        return f"{self.correo} - {self.codigo} - expira en {self.expiracion}"

    

    def esta_expirado(self):
        logger.warning(f"Verificando expiración del código: {self.codigo} para {self.correo}")
        return timezone.now() > self.expiracion
     
    



class Estudiante(models.Model):
    TIPO_IDENTIFICACION = [
        ('cedula', 'Cédula'),
        ('ruc', 'RUC'),
        ('pasaporte', 'Pasaporte'),
        ('extranjero', 'Extranjero'),
    ]

    GENERO = [
        ('M', 'Hombre'),
        ('F', 'Mujer'),
    ]

    OCUPACION = [
        ('estudiante', 'Estudiante'),
        ('docente', 'Docente'),
    ]

    NIVEL_ESTUDIO = [
        ('prebasica', 'Prebásica 1-2'),
        ('basica', 'Básica 1-10'),
        ('bachillerato', 'Bachillerato 1-3'),
        ('universidad', 'Universidad/Superior'),
    ]

    PARROQUIA = [
        ('el_valle', 'El Valle'),
        ('el_sagrario', 'El Sagrario'),
        ('san_sebastian', 'San Sebastián'),
    ]

    PROGRAMAS_ACADEMICOS = [
        ('b2', 'B2 FIRST PREPARATION (FCE)'),
        ('teachers', 'PREPARATION FOR TEACHERS'),
        ('youth_intensive', 'YOUTH INTENSIVE PROGRAM'),
        ('youth', 'YOUTH PROGRAM'),
        ('seniors', 'SENIORS INTENSIVE PROGRAM'),
        ('express', 'English Express'),
    ]

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="perfil_estudiante")
    tipo_identificacion = models.CharField(max_length=20, choices=TIPO_IDENTIFICACION)
    identificacion = models.CharField(max_length=30, unique=True)
    nombres_apellidos = models.CharField(max_length=150)
    fecha_nacimiento = models.DateField()
    genero = models.CharField(max_length=1, choices=GENERO)
    ocupacion = models.CharField(max_length=20, choices=OCUPACION)
    nivel_estudio = models.CharField(max_length=20, choices=NIVEL_ESTUDIO)
    lugar_estudio_trabajo = models.CharField(max_length=150)
    direccion = models.TextField()
    email = models.EmailField(unique=True)
    celular = models.CharField(max_length=15, unique=True)
    telefono_convencional = models.CharField(max_length=15, blank=True, null=True)
    parroquia = models.CharField(max_length=20, choices=PARROQUIA)
    programa_academico = models.CharField(max_length=30, choices=PROGRAMAS_ACADEMICOS)

    def __str__(self):
        return self.nombres_apellidos




class Representante(models.Model):
    estudiante = models.OneToOneField(Estudiante, on_delete=models.CASCADE, related_name="representante")

    emitir_factura_al_estudiante = models.BooleanField(default=False)

    tipo_identificacion = models.CharField(max_length=20, choices=Estudiante.TIPO_IDENTIFICACION)
    identificacion = models.CharField(max_length=30, unique=True)
    razon_social = models.CharField(max_length=150)
    direccion = models.TextField()
    email = models.EmailField(unique=True)
    celular = models.CharField(max_length=15, unique=True)
    telefono_convencional = models.CharField(max_length=15, blank=True, null=True)

    sexo = models.CharField(max_length=1, choices=Estudiante.GENERO)
    estado_civil = models.CharField(max_length=20, choices=[
        ('soltero', 'Soltero'),
        ('casado', 'Casado'),
        ('divorciado', 'Divorciado'),
        ('viudo', 'Viudo'),
    ])
    origen_ingresos = models.CharField(max_length=30, choices=[
        ('empleado_publico', 'Empleado público'),
        ('empleado_privado', 'Empleado privado'),
        ('independiente', 'Independiente'),
        ('ama_de_casa', 'Ama de casa'),
        ('remesa', 'Remesa del exterior'),
    ])
    parroquia = models.CharField(max_length=20, choices=Estudiante.PARROQUIA)

    def __str__(self):
        return self.razon_social




class Matricula(models.Model):
    METODO_PAGO_CHOICES = [
        ('deposito', 'Depósito'),
        ('transferencia', 'Transferencia'),
        ('tarjeta', 'Tarjeta (3 a 6 meses sin intereses)'),
    ]

    MEDIO_ENTERO_CHOICES = [
        ('redes', 'Redes sociales'),
        ('web', 'Página Web'),
        ('asesores', 'Contacto con Asesores Comerciales'),
        ('oficina', 'Oficina'),
        ('radio', 'Radio'),
        ('ferias', 'Ferias y/o Eventos'),
        ('otros', 'Otros'),
    ]

    estudiante = models.ForeignKey(Estudiante, on_delete=models.CASCADE, related_name="matriculas")
    nombre = models.CharField(max_length=100)
    programa = models.CharField(max_length=100)
    periodo = models.CharField(max_length=50)
    horario = models.CharField(max_length=50)
    paralelo = models.CharField(max_length=10)
    establecimiento = models.CharField(max_length=100)
    cupos = models.PositiveIntegerField()

    metodo_pago = models.CharField(max_length=20, choices=METODO_PAGO_CHOICES)
    cuotas_pagar = models.PositiveIntegerField()
    medio_entero = models.CharField(max_length=30, choices=MEDIO_ENTERO_CHOICES)

    fecha_matricula = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Matricula de {self.estudiante.nombres_apellidos} - {self.programa} ({self.periodo})"
