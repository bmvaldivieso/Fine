from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import timedelta
import logging

logger = logging.getLogger(__name__)

# Código de verificación por correo
class CodigoVerificacionEmail(models.Model):
    correo = models.EmailField()
    codigo = models.CharField(max_length=6)
    creado_en = models.DateTimeField(auto_now_add=True)
    expiracion = models.DateTimeField()

    def __str__(self):
        return f"{self.correo} - {self.codigo} - expira en {self.expiracion}"

    def esta_expirado(self):
        logger.info(f"Verificando expiración del código: {self.codigo} para {self.correo}")
        return timezone.now() > self.expiracion


# Estudiante
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


# Representante
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


# Componente académico (paralelo)
class Componente(models.Model):
    PROGRAMA_ACADEMICO_CHOICES = Estudiante.PROGRAMAS_ACADEMICOS

    nombre = models.CharField(max_length=255)
    programa_academico = models.CharField(max_length=50, choices=PROGRAMA_ACADEMICO_CHOICES)
    precio = models.DecimalField(max_digits=10, decimal_places=2)
    periodo = models.CharField(max_length=50)
    horario = models.CharField(max_length=100)
    cupos_disponibles = models.PositiveIntegerField(default=0)

    def __str__(self):
        return f"{self.nombre} ({self.programa_academico}) - {self.periodo}"


# Matrícula
class Matricula(models.Model):
    METODO_PAGO_CHOICES = [
        ('deposito', 'Depósito'),
        ('transferencia', 'Transferencia'),
        ('tarjeta', 'Tarjeta (3 a 6 meses sin intereses)'),
    ]

    MEDIO_ENTERO_CHOICES = [
        ('redes_sociales', 'Redes Sociales'),
        ('pagina_web', 'Página Web'),
        ('referido', 'Referido'),
        ('otro', 'Otro'),
    ]

    ESTADO_MATRICULA_CHOICES = [
        ('activa', 'Activa'),
        ('completada', 'Completada'),
        ('inactiva', 'Inactiva'),
        ('abandonada', 'Abandonada'),
        ('pendiente_pago', 'Pendiente de Pago'),
        ('confirmada', 'Confirmada'),
    ]

    estudiante = models.ForeignKey(Estudiante, on_delete=models.CASCADE, related_name="matriculas")
    componente_cursado = models.ForeignKey(Componente, on_delete=models.SET_NULL, null=True, blank=True)
    metodo_pago = models.CharField(max_length=50, choices=METODO_PAGO_CHOICES)
    medio_entero = models.CharField(max_length=50, choices=MEDIO_ENTERO_CHOICES)
    fecha_matricula = models.DateField(auto_now_add=True)
    costo_matricula = models.DecimalField(max_digits=10, decimal_places=2)
    observaciones = models.TextField(blank=True, null=True)
    activa = models.BooleanField(default=True)
    estado = models.CharField(max_length=20, choices=ESTADO_MATRICULA_CHOICES, default='pendiente_pago')
    cuotas = models.CharField(max_length=10, default='1')

    def __str__(self):
        return f"Matrícula de {self.estudiante.nombres_apellidos} en {self.componente_cursado.nombre if self.componente_cursado else 'N/A'}"


# Calificaciones
class Nota(models.Model):
    BIMESTRES = [(1, 'Primer Bimestre'), (2, 'Segundo Bimestre')]

    estudiante = models.ForeignKey(Estudiante, on_delete=models.CASCADE, related_name='notas')
    componente = models.ForeignKey(Componente, on_delete=models.CASCADE, related_name='notas_asociadas')
    docente = models.ForeignKey('Docente', on_delete=models.SET_NULL, null=True, related_name='notas_docente')

    bimestre = models.IntegerField(choices=BIMESTRES)
    tareas = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    lecciones = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    grupales = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    individuales = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    inasistencias = models.PositiveIntegerField(default=0)

    fecha_registro = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('estudiante', 'componente', 'bimestre')

    def calcular_nota_bimestre(self):
        return round(
            float(self.tareas) * 0.4 +
            float(self.lecciones) * 0.2 +
            float(self.grupales) * 0.2 +
            float(self.individuales) * 0.2,
            2
    )

    def __str__(self):
        return f"{self.estudiante.nombres_apellidos} - {self.componente.nombre} - Bimestre {self.bimestre}"



# Datos de pago de matrícula
class DatosPagoMatricula(models.Model):
    METODOS = [
        ('deposito', 'Depósito'),
        ('transferencia', 'Transferencia'),
        ('tarjeta', 'Tarjeta'),
    ]

    estudiante = models.ForeignKey(Estudiante, on_delete=models.CASCADE)
    componente = models.ForeignKey(Componente, on_delete=models.CASCADE)
    metodo_pago = models.CharField(max_length=20, choices=METODOS)

    # Para depósito y transferencia
    referencia = models.CharField(max_length=100, blank=True, null=True)
    monto = models.CharField(max_length=50, blank=True, null=True)
    fecha_deposito = models.CharField(max_length=50, blank=True, null=True)
    id_depositante = models.CharField(max_length=100, blank=True, null=True)

    # Para tarjeta
    nombre_tarjeta = models.CharField(max_length=100, blank=True, null=True)
    numero_tarjeta = models.CharField(max_length=30, blank=True, null=True)
    vencimiento = models.CharField(max_length=10, blank=True, null=True)
    cvv = models.CharField(max_length=10, blank=True, null=True)

    fecha_registro = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.estudiante} - {self.metodo_pago}"



class Docente(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="perfil_docente")
    nombres_apellidos = models.CharField(max_length=150)
    email = models.EmailField(unique=True)
    celular = models.CharField(max_length=15, unique=True)
    imagen_perfil = models.ImageField(upload_to='docentes/perfil/', blank=True, null=True)

    def __str__(self):
        return self.nombres_apellidos
     

class AsignacionTarea(models.Model):
    titulo = models.CharField(max_length=255)
    descripcion = models.TextField()
    fecha_entrega = models.DateTimeField()
    intentos_maximos = models.PositiveIntegerField(default=1)
    componente = models.ForeignKey(Componente, on_delete=models.CASCADE)
    docente = models.ForeignKey(Docente, on_delete=models.CASCADE)
    publicada = models.BooleanField(default=False)

    def __str__(self):
        return self.titulo


class EntregaTarea(models.Model):
    asignacion = models.ForeignKey(AsignacionTarea, on_delete=models.CASCADE)
    estudiante = models.ForeignKey(Estudiante, on_delete=models.CASCADE)
    intento_numero = models.PositiveIntegerField()
    fecha_entrega = models.DateTimeField(auto_now_add=True)
    entregado = models.BooleanField(default=False)
    calificacion = models.FloatField(null=True, blank=True)
    observaciones = models.TextField(blank=True)

    def __str__(self):
        return f'Entrega {self.intento_numero} - {self.estudiante} - {self.asignacion}'


