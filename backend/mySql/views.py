from django.shortcuts import render
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import *
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework.permissions import BasePermission
from mySql.utils.mongodb import MongoDBConnection
import base64
from io import BytesIO
import logging
from bson import ObjectId
from gridfs import GridFS
import json
from django.core.exceptions import ObjectDoesNotExist
from django.http import JsonResponse
from django.db.models import Prefetch
logger = logging.getLogger(__name__)
from django.shortcuts import get_object_or_404
from datetime import datetime
import secrets
import string
from rest_framework import status
from django.utils import timezone
from datetime import timedelta
from django.contrib.auth.hashers import make_password
from django.contrib.auth.models import User
from rest_framework_simplejwt.tokens import RefreshToken




# Esto te da el endpoint para obtener el token al hacer login
class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        data = super().validate(attrs)
        data['is_superuser'] = self.user.is_superuser
        return data
    
class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

class IsSuperUser(BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_superuser
    

#este valida la matricula si el usuario al menos tiene una matricula asocidada


class ValidateMatriculaMixin:
    """
    Este mixin valida si el usuario autenticado tiene matrícula activa.
    Se puede usar en cualquier vista protegida.
    """

    def tiene_matricula(self, request):
        user = request.user

        # Solo se permite a usuarios que no son superusuarios
        if user.is_superuser:
            return False

        try:
            estudiante = Estudiante.objects.get(user=user)
        except Estudiante.DoesNotExist:
            return False

        return Matricula.objects.filter(estudiante=estudiante).exists()








#vista de ejemplo llamando a la clase matricula para valdar esta vista deberia devolve las notas
#todavia no esta implementada la tabla notas

class NotasView(APIView, ValidateMatriculaMixin):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if not self.tiene_matricula(request):
            logger.warning("El usuario no tiene matrícula actualmente.")
            return Response({"detalle": "El usuario no tiene matrícula actualmente."}, status=400)
        return Response({"detalle": "Notas preparadas."}, status=200)












def generar_codigo_verificacion(longitud=6):
    caracteres = string.digits
    return ''.join(secrets.choice(caracteres) for _ in range(longitud))



def crear_y_guardar_codigo(correo):
    CodigoVerificacionEmail.objects.filter(correo=correo).delete()
    codigo = generar_codigo_verificacion()
    expiracion = timezone.now() + timedelta(minutes=5)
    CodigoVerificacionEmail.objects.create(correo=correo,codigo=codigo, expiracion=expiracion)
    return codigo



from rest_framework.permissions import AllowAny

class EnviarCodigoVerificacionView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        logger.warning("Entrando a EnviarCodigoVerificacionView")
        correo = request.data.get('email')
        try:
            if not correo:
                return Response({'error': 'El campo "email" es requerido'}, status=status.HTTP_400_BAD_REQUEST)

            codigo_verificacion = crear_y_guardar_codigo(correo.strip())
            logger.warning(f"Código de verificación generado: {codigo_verificacion}")
            logger.warning(f"Correo electrónico recibido: {correo}")
            sendEmail(codigo_verificacion, correo)

            return Response({'message': 'Código enviado correctamente'}, status=status.HTTP_200_OK)
        except Exception as e:
            logger.error(f"Error al enviar el código de verificación: {e}")
            return Response({'error': 'Error al enviar el código de verificación'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)






## Enviar correo electrónico con el código de verificación

from django.core.mail import send_mail
from django.conf import settings
from django.template.loader import render_to_string

def sendEmail(codigo_verificacion,email):

    subject = 'Código de Verificación'
    html_message = render_to_string('correo_cita.html', {'Cod': codigo_verificacion,})

    from_email = settings.EMAIL_HOST_USER
    recipient_list = [email]

    try:
        send_mail(subject, '', from_email, recipient_list, html_message=html_message)
        print("Correo enviado con éxito.")
    except Exception as e:
        print(f"Error al enviar correo: {e}")
        return Response({"mensaje": {e}}, status=201)
        






#validacion y devolucion

from rest_framework.permissions import AllowAny

class RecivValidateCodView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        logger.warning("Entrando a RecivValidateCodView")
        codigo = request.data.get('codigo')
        correo = request.data.get('email')
        try:
            if not codigo and not correo:
                return Response({'error': 'El campo "codigo" y correo es requerido'}, status=status.HTTP_400_BAD_REQUEST)

            codigo_user = codigo.strip()
            correo_user = correo.strip()
            logger.warning(f"Código de verificación recibido: {codigo_user}")
            logger.warning(f"Correo electrónico recibido: {correo_user}")


            try:
                registro = CodigoVerificacionEmail.objects.get(correo=correo, codigo=codigo)
                logger.warning(f"Registro encontrado: {registro}")

                if registro.esta_expirado() and registro == None:
                    return Response({'success': False, 'error': 'Código inválido'}, status=400)

                registro.delete()
                return Response({'success': True, 'message': 'Código verificado correctamente'}, status=200)

            except CodigoVerificacionEmail.DoesNotExist:
                return Response({'error': 'Código inválido'}, status=400)


        except Exception as e:
            logger.error(f"Error al verificar el codigo: {e}")
            return Response({'error': 'error al verificar el codigo'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        



# Registro completo de usuario, estudiante y representante

class RegistroCompletoView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        logger.warning("Entrando a RegistroCompletoView")
        data = request.data
        try:
            # Crear usuario
            user = User.objects.create(username=data['user'],password=make_password(data['password']),email=data['email'])

            logger.warning(f"Usuario creado: {user}")

            # Crear Estudiante

            fecha_nacimiento_str = request.data.get('fechaNacimiento')
            try:
                fecha_nacimiento = datetime.fromisoformat(fecha_nacimiento_str).date()
            except ValueError:
                return Response({'error': 'Fecha inválida'}, status=400)
            
            estudiante = Estudiante.objects.create(
                user=user,
                tipo_identificacion=data['tipoIdentificacion'],
                identificacion=data['identificacion'],
                nombres_apellidos=data['nombresApellidos'],
                fecha_nacimiento=fecha_nacimiento,
                genero=data['genero'],
                ocupacion=data['ocupacion'],
                nivel_estudio=data['nivelEstudio'],
                lugar_estudio_trabajo=data['lugarEstudioTrabajo'],
                direccion=data['direccion'],
                email=data['email'],
                celular=data['celular'],
                telefono_convencional=data.get('telefonoConvencional'),
                parroquia=data['parroquia'],
                programa_academico=data['programaAcademico']
            )

            logger.warning(f"Estudiante creado: {estudiante}")
            logger.warning(f"datos {user} , {data['tipoIdentificacion']} , {data['identificacion']} , {data['nombresApellidos']} , {fecha_nacimiento} , {data['genero']} , {data['ocupacion']} , {data['nivelEstudio']} , {data['lugarEstudioTrabajo']} , {data['direccion']} , {data['email']} , {data['celular']} , {data.get('telefonoConvencional')} , {data['parroquia']} , {data['programaAcademico']}")

            # Crear Representante
            Representante.objects.create(
                estudiante=estudiante,
                emitir_factura_al_estudiante=data['emitirFactura'],
                tipo_identificacion=data['rTipoIdentificacion'],
                identificacion=data['ridentificacion'],
                razon_social=data['razonSocial'],
                direccion=data['rdireccion'],
                email=data['remail'],
                celular=data['rcelular'],
                telefono_convencional=data.get('rtelefonoConvencional'),
                sexo=data['sexo'],
                estado_civil=data['estadoCivil'],
                origen_ingresos=data['origenIngresos'],
                parroquia=data['rparroquia']
            )

            logger.warning(f"Representante creado: {estudiante.representante}")
            logger.warning(f"datos {data['emitirFactura']} , {data['rTipoIdentificacion']} , {data['ridentificacion']} , {data['razonSocial']} , {data['rdireccion']} , {data['remail']} , {data['rcelular']} , {data.get('rtelefonoConvencional')} , {data['sexo']} , {data['estadoCivil']} , {data['origenIngresos']} , {data['rparroquia']}")

            # Generar token
            refresh = RefreshToken.for_user(user)
            return Response({'access': str(refresh.access_token),'refresh': str(refresh),'is_superuser': user.is_superuser,'success': True}, status=status.HTTP_200_OK)

        except Exception as e:
            logger.error(f"Error durante el registro completo: {e}")
            return Response({'success': False, 'error': 'Error al registrar los datos'}, status=400)























"""
class AdminView(APIView):
    permission_classes = [IsSuperUser]

    def get(self, request):
        imagenes = []
        image_data = BytesIO()


        especialidades = Especialidad.objects.all().order_by('id').values('nombre', 'owner_id')
        usuario = request.user.first_name
        db = MongoDBConnection.get_db()
        files_collection = db['fs.files']
        chunks_collection = db['fs.chunks']
        

        for especialidad in especialidades:
            owner_id = especialidad['owner_id']
            try:
                file_doc = files_collection.find_one({'_id': ObjectId(owner_id)})
            except Exception as e:
                logger.error(f"Error al convertir owner_id a ObjectId: {e}")
                continue    
            
            
            #revisar la imagen no llega se pone otro owner_id;
            if not file_doc:
                logger.warning(f"No se encontró archivo para owner_id: {owner_id}")
                file_doc = files_collection.find_one({'_id': ObjectId('6776235c043dda8d2809d7b6')})
                continue

            file_id = file_doc['_id']
            chunks = chunks_collection.find({'files_id': file_id}).sort('n', 1)
            

            image_data.truncate(0)
            image_data.seek(0)

            for chunk in chunks:
                image_data.write(chunk['data'])

            image_data.seek(0)
            encoded_image = base64.b64encode(image_data.read()).decode('utf-8')

            imagenes.append({
                'imagen': encoded_image,
                'metadatos': {
                    'filename': file_doc.get('filename', 'desconocido'),
                    'content_type': file_doc.get('contentType', 'unknown'),
                }
            })

        return Response({
            'especialidades': list(Especialidad.objects.all().order_by('id').values('nombre','descripcion')),
            'imagenes': imagenes,
            'usuario': usuario,
        })
    
    
"""
"""
class AdminPostCreate(APIView):
        
        permission_classes = [IsSuperUser]

        def post(self, request):

            db = MongoDBConnection.get_db()
            fs = GridFS(db)

            image_data = request.data.get('imagen')
            metadata = request.data.get('metadata', {})
            nameEspe = request.data.get('nombre')
            apelli = request.data.get('apellido')
            cedula = request.data.get('cedula')
            correo = request.data.get('correo')
            describe = request.data.get('describe')
            nuevas_especialidades = request.data.get('especialidades')
            service = request.data.get('service')

            imagen_bytes = base64.b64decode(image_data)
            object_id = fs.put(imagen_bytes,custom_metadata=metadata)
        
            especialista = Especialista.objects.create(
                nombre=nameEspe,
                apellido=apelli,
                cedula=cedula,
                correo=correo,
                descripcion=describe,
                servicios=service,
                owner_id=str(object_id)  
            )

            if nuevas_especialidades:
                especialidades_objs = Especialidad.objects.filter(nombre__in=nuevas_especialidades)
                especialista.especialidades.add(*especialidades_objs)
                especialista.save()

            return Response({
                 'message': 'Especialista Creado correctamente desde Django'
                 }, status=200)

"""
"""         

class UserInfoView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        imagenes = []
        image_data = BytesIO()


        especialidades = Especialidad.objects.all().order_by('id').values('nombre', 'owner_id')
        usuario = request.user.first_name
        db = MongoDBConnection.get_db()
        files_collection = db['fs.files']
        chunks_collection = db['fs.chunks']
        

        for especialidad in especialidades:
            owner_id = especialidad['owner_id']
            try:
                file_doc = files_collection.find_one({'_id': ObjectId(owner_id)})
            except Exception as e:
                logger.error(f"Error al convertir owner_id a ObjectId: {e}")
                continue    
            
            
            #revisar la imagen no llega se pone otro owner_id;
            if not file_doc:
                logger.warning(f"No se encontró archivo para owner_id: {owner_id}")
                file_doc = files_collection.find_one({'_id': ObjectId('6776235c043dda8d2809d7b6')})
                continue

            file_id = file_doc['_id']
            chunks = chunks_collection.find({'files_id': file_id}).sort('n', 1)
            

            image_data.truncate(0)
            image_data.seek(0)

            for chunk in chunks:
                image_data.write(chunk['data'])

            image_data.seek(0)
            encoded_image = base64.b64encode(image_data.read()).decode('utf-8')

            imagenes.append({
                'imagen': encoded_image,
                'metadatos': {
                    'filename': file_doc.get('filename', 'desconocido'),
                    'content_type': file_doc.get('contentType', 'unknown'),
                }
            })

        return Response({
            'especialidades': list(Especialidad.objects.all().order_by('id').values('nombre','descripcion')),
            'imagenes': imagenes,
            'usuario': usuario,
        })
    
"""
    

class normalDatosMongoView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        image_data = BytesIO()
        owner_id = request.user.last_name

        db = MongoDBConnection.get_db()
        files_collection = db['fs.files']
        chunks_collection = db['fs.chunks']

        try:
            file_doc = files_collection.find_one({'_id': ObjectId(owner_id)})
        except Exception as e:
            logger.error(f"Error al convertir owner_id a ObjectId: {e}") 


        if not file_doc:
                logger.warning(f"No se encontró archivo para owner_id: {owner_id}")
                file_doc = files_collection.find_one({'_id': ObjectId('6776235c043dda8d2809d7b6')})  


        file_id = file_doc['_id']
        chunks = chunks_collection.find({'files_id': file_id}).sort('n', 1)

        for chunk in chunks:
            image_data.write(chunk['data'])

        image_data.seek(0)
        encoded_image = base64.b64encode(image_data.read()).decode('utf-8')

        return Response({
            'imagen': encoded_image, 
            'filename': file_doc.get('filename', 'desconocido'),
        })
    

"""
class normalpersonView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request):
        imagenes = []
        image_data = BytesIO()
        especialistas_list = []
        data = request.body.decode('utf-8')
        especialistas = Especialista.objects.filter(especialidades__nombre=data).all().prefetch_related('especialidades').order_by('nombre')
        db = MongoDBConnection.get_db()
        files_collection = db['fs.files']
        chunks_collection = db['fs.chunks']
        usuario = request.user.first_name
        
        for especialista in especialistas:

            especialidades = [especialidad.nombre for especialidad in especialista.especialidades.all()]
            
            especialistas_list.append({
                'nombre': especialista.nombre,
                'apellido': especialista.apellido,
                'cedula': especialista.cedula,
                'correo': especialista.correo,
                'describe':especialista.descripcion,
                'service':especialista.servicios,
                'owner_id': especialista.owner_id,
                'especialidades': especialidades
            })


        for espe in especialistas_list:
            owner_id = espe['owner_id']
            try:
                file_doc = files_collection.find_one({'_id': ObjectId(owner_id)})
            except Exception as e:
                logger.error(f"Error al convertir owner_id a ObjectId: {e}")
                continue    

            if not file_doc:
                logger.warning(f"No se encontró archivo para owner_id: {owner_id}")
                file_doc = files_collection.find_one({'_id': ObjectId('67776960474c4bd8ee017d42')})
                continue

            file_id = file_doc['_id']
            chunks = chunks_collection.find({'files_id': file_id}).sort('n', 1)
            

            image_data.truncate(0)
            image_data.seek(0)

            for chunk in chunks:
                image_data.write(chunk['data'])

            image_data.seek(0)
            encoded_image = base64.b64encode(image_data.read()).decode('utf-8')

            imagenes.append({
                'imagen': encoded_image,
                'metadatos': {
                    'filename': file_doc.get('filename', 'desconocido'),
                    'content_type': file_doc.get('contentType', 'unknown'),
                }
            }) 

            del espe['owner_id']

        return Response({
            'especialistas': especialistas_list,
            'imagenes':imagenes,
            'usuario':usuario,
        })    
    



#aquiiiii
class horariosNormales(APIView):
        
        permission_classes = [IsAuthenticated]
        
        def post(self, request):
            horarios = Horario.objects.prefetch_related('especialistas', 'fechas')
            horario_list = []
            usuario_nombre = request.user.first_name
            usuario_email = request.user.email 

            
            for horario in horarios:
                
                horario_list.append({
                "id": horario.id,
                "horaInicio": horario.hora_inicio.strftime('%H:%M:%S'),
                "horaFin": horario.hora_fin.strftime('%H:%M:%S'),
                "especialistas": [
                    {
                        "id": especialista.id,
                        "nombre": especialista.nombre,
                        "cedula": especialista.cedula,
                        "especialidades": [especialidad.nombre for especialidad in especialista.especialidades.all()]
                    }
                    for especialista in horario.especialistas.all()
                ],
                "fechas": [
                    {
                        "id": fecha.id,
                        "fecha": fecha.fecha.strftime('%Y-%m-%d')
                    }
                    for fecha in horario.fechas.all()
                ]
             })  
                

            info = json.loads(request.body.decode('utf-8'))   
 
                
            cedula_especialista = info.get("cedulaE")
            especialidadFiltro =  info.get("especialidad")

            citas_especialista = Cita.objects.filter(especialista__cedula=cedula_especialista).select_related("fecha")

            if citas_especialista.exists():
                 nombre_especialista = citas_especialista.first().especialista.nombre
            else:
                 nombre_especialista = "Especialista no encontrado"
                 

            citas_list = []

            for cita in citas_especialista:
                if cita.fecha and cita.fecha.horario:
                    citas_list.append({
                        "horaInicio": cita.fecha.horario.hora_inicio.strftime('%H:%M:%S'),
                        "horaFin": cita.fecha.horario.hora_fin.strftime('%H:%M:%S'),
                        "fecha": cita.fecha.fecha.strftime('%Y-%m-%d')
                        })      


             
            citas_usuario = Cita.objects.filter(correo=usuario_email).select_related("fecha")

            cita_filtrada = citas_usuario.filter(especialista__cedula=cedula_especialista,especialidad__nombre=especialidadFiltro).first() 


            # 🔹 Extraer la fecha y horario de la cita
            if cita_filtrada and cita_filtrada.fecha:
                    fecha_cita = cita_filtrada.fecha.fecha.strftime('%Y-%m-%d')

                    if cita_filtrada.fecha.horario:
                      hora_inicio = cita_filtrada.fecha.horario.hora_inicio.strftime('%H:%M:%S')
                      hora_fin = cita_filtrada.fecha.horario.hora_fin.strftime('%H:%M:%S')
                    else:
                         hora_inicio = 'horario nulo'
                         hora_fin = 'horario nulo'
            else:
                 fecha_cita = 'fecha nula'
                 hora_inicio = 'horario nulo'
                 hora_fin = 'horario nulo'


            return Response({
                 'listaHorarios': horario_list,
                 'usuario': usuario_nombre,
                 "citas": {
                      "nombre": nombre_especialista,
                      "citas": citas_list
                      },
                 'email': usuario_email,    
                 'fechas_usuario':fecha_cita,
                 'horaInicio': hora_inicio,
                 'horaFin': hora_fin
                 })
                


from django.core.mail import send_mail
from django.conf import settings
from django.template.loader import render_to_string

//////aqui essssss///
class CitasNormales(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:

            json_info_cita = json.loads(request.body.decode('utf-8'))
            logger.warning("Esta es la información recibida: %s", json_info_cita)

            fecha_str = json_info_cita.get("fecha")
            especialidad_nombre = json_info_cita.get("especialidad")
            especialista_cedula = json_info_cita.get("especialista_cedula")
            hora_inicio_str = json_info_cita.get("horaInicio")
            hora_fin_str = json_info_cita.get("horaFin")
            fecha_posterior = json_info_cita.get("comodinFecha")
            usuario_email = request.user.email 

            
            if not all([fecha_str, especialidad_nombre, especialista_cedula]):
                return Response({"error": "Faltan datos en la solicitud"}, status=400)

            especialidad = get_object_or_404(Especialidad, nombre=especialidad_nombre)
            especialista = get_object_or_404(Especialista, cedula=especialista_cedula)
            #esta es la fecha convertida que llega 
            #enviar la fecha comodin por si el error.
            #error de fecha veras como 27 ya paso y haora estamos febrerero y alhoritmo toma
            #por defecto el mes de la computadora entonces cuando quise agendar el 27 me busco
            #el 27 de febrero cosa que no existe por que solo etngo el 2 de febrero revisar 
            #una logica cuando se pase al siguiente mes y quieran agendar una cita que hace.
            fecha_obj = datetime.strptime(fecha_str, '%Y-%m-%d').date()
            fecha_obj_next = datetime.strptime(fecha_posterior, '%Y-%m-%d').date()


            # Convertir horas de inicio y fin de cadenas a objetos time
            hora_inicio = datetime.strptime(hora_inicio_str, '%H:%M:%S').time()
            hora_fin = datetime.strptime(hora_fin_str, '%H:%M:%S').time()


            # Buscar el horario que coincida con las horas de inicio y fin
            horario = get_object_or_404(Horario, hora_inicio=hora_inicio, hora_fin=hora_fin)


            if not horarios:
                return Response({"error": "No se encontraron horarios para las horas proporcionadas"}, status=404)
            
            # Obtener todas las fechas asociadas a ese horario
            fechas_asociadas = horario.fechas.all()


            fechaF = fechas_asociadas.filter(fecha=fecha_obj).first()

            if not fechaF:
                fechaF = fechas_asociadas.filter(fecha=fecha_obj_next).first()
                logger.warning("aqui error fijo")
                logger.warning(fechaF)
                return Response({"error": "No se encontró una fecha válida para el horario y la fecha proporcionados"}, status=404)
            

            citas_usuario = Cita.objects.filter(correo=usuario_email).select_related("fecha")
            cita_filtrada = citas_usuario.filter(especialidad__nombre=especialidad_nombre).first()

            if not cita_filtrada:
                 m = "Cita creada correctamente"; 
                 nueva_cita = Cita.objects.create(
                      nombre = request.user.first_name,  
                      apellido="No asignado",
                      cedula="No asignado", 
                      correo = request.user.email , 
                      especialidad=especialidad,
                      especialista=especialista,
                      edificio="1", 
                      consultorio="No asignado",
                      fecha=fechaF
                      )
                 logger.warning(nueva_cita)
                 nueva_cita.save() 
            else:
                 m = "duplicado";
             
            subject = 'Tu cita se ha agendado correctamente'
            # Renderiza la plantilla HTML con los datos de la cita
            html_message = render_to_string('correo_cita.html', {
                'nombre': nueva_cita.nombre,
                'especialidad': nueva_cita.especialidad,
                'especialista': nueva_cita.especialista,
                'fecha': nueva_cita.fecha,
                'edificio': nueva_cita.edificio,
                'consultorio': nueva_cita.consultorio,
            })

            from_email = settings.EMAIL_HOST_USER
            recipient_list = [usuario_email]

            try:
                send_mail(subject, '', from_email, recipient_list, html_message=html_message)
                print("Correo enviado con éxito.")
            except Exception as e:
                print(f"Error al enviar correo: {e}")

            return Response({"mensaje": m}, status=201)
        
        except Exception as e:
            logger.error("Error al procesar la solicitud: %s", str(e))
            return Response({"error": "Error interno del servidor"}, status=500)
        


class citasNormalesDeleted(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:

            json_info_cita = json.loads(request.body.decode('utf-8'))
            logger.warning("Esta es la información recibida: %s", json_info_cita)

            especialidad_nombre = json_info_cita.get("especialidad")
            especialista_cedula = json_info_cita.get("especialista_cedula")
            usuario_email = request.user.email 

        
            if not all([especialidad_nombre, especialista_cedula]):
                return Response({"error": "Faltan datos en la solicitud"}, status=400)
            
            citas_usuario = Cita.objects.filter(correo=usuario_email).select_related("fecha")
            cita_filtrada = citas_usuario.filter(especialista__cedula=especialista_cedula,especialidad__nombre=especialidad_nombre).first() 
            

            if not cita_filtrada:
                 m = "con errores"; 
            else:
                 cita_filtrada.delete()
                 m = "correctamente";  
                   
            return Response({"mensaje": "cita elimnada "+m}, status=201)
        
        except Exception as e:
            logger.error("Error al procesar la solicitud: %s", str(e))
            return Response({"error": "Error interno del servidor"}, status=500)

"""

class DatosMongoView(APIView):
    permission_classes = [IsSuperUser]

    def get(self, request):
        image_data = BytesIO()
        owner_id = request.user.last_name

        db = MongoDBConnection.get_db()
        files_collection = db['fs.files']
        chunks_collection = db['fs.chunks']

        try:
            file_doc = files_collection.find_one({'_id': ObjectId(owner_id)})
        except Exception as e:
            logger.error(f"Error al convertir owner_id a ObjectId: {e}") 


        if not file_doc:
                logger.warning(f"No se encontró archivo para owner_id: {owner_id}")
                file_doc = files_collection.find_one({'_id': ObjectId('6776235c043dda8d2809d7b6')})  


        file_id = file_doc['_id']
        chunks = chunks_collection.find({'files_id': file_id}).sort('n', 1)

        for chunk in chunks:
            image_data.write(chunk['data'])

        image_data.seek(0)
        encoded_image = base64.b64encode(image_data.read()).decode('utf-8')

        return Response({
            'imagen': encoded_image, 
            'filename': file_doc.get('filename', 'desconocido'),
        })
    


"""
class personAdmin(APIView):
    permission_classes = [IsSuperUser]

    def get(self, request):
        imagenes = []
        image_data = BytesIO()
        especialistas_list = []

        especialistas = Especialista.objects.all().prefetch_related('especialidades').order_by('nombre')
        db = MongoDBConnection.get_db()
        files_collection = db['fs.files']
        chunks_collection = db['fs.chunks']
        
        for especialista in especialistas:

            especialidades = [especialidad.nombre for especialidad in especialista.especialidades.all()]
            
            especialistas_list.append({
                'nombre': especialista.nombre,
                'apellido': especialista.apellido,
                'cedula': especialista.cedula,
                'correo': especialista.correo,
                'describe':especialista.descripcion,
                'service':especialista.servicios,
                'owner_id': especialista.owner_id,
                'especialidades': especialidades
            })


        for espe in especialistas_list:
            owner_id = espe['owner_id']
            try:
                file_doc = files_collection.find_one({'_id': ObjectId(owner_id)})
            except Exception as e:
                logger.error(f"Error al convertir owner_id a ObjectId: {e}")
                continue    

            if not file_doc:
                logger.warning(f"No se encontró archivo para owner_id: {owner_id}")
                file_doc = files_collection.find_one({'_id': ObjectId('67776960474c4bd8ee017d42')})
                continue

            file_id = file_doc['_id']
            chunks = chunks_collection.find({'files_id': file_id}).sort('n', 1)
            

            image_data.truncate(0)
            image_data.seek(0)

            for chunk in chunks:
                image_data.write(chunk['data'])

            image_data.seek(0)
            encoded_image = base64.b64encode(image_data.read()).decode('utf-8')

            imagenes.append({
                'imagen': encoded_image,
                'metadatos': {
                    'filename': file_doc.get('filename', 'desconocido'),
                    'content_type': file_doc.get('contentType', 'unknown'),
                }
            }) 

            del espe['owner_id']
            
        return Response({
            'especialistas': especialistas_list,
            'imagenes':imagenes
        })
    


class horarios(APIView):
        
        permission_classes = [IsSuperUser]

        def get(self, request, *args, **kwargs):
            horarios = Horario.objects.prefetch_related('especialistas', 'fechas')
            horario_list = []
            
            for horario in horarios:
                
                horario_list.append({
                "id": horario.id,
                "horaInicio": horario.hora_inicio.strftime('%H:%M:%S'),
                "horaFin": horario.hora_fin.strftime('%H:%M:%S'),
                "especialistas": [
                    {
                        "id": especialista.id,
                        "nombre": especialista.nombre,
                        "cedula": especialista.cedula,
                        "especialidades": [especialidad.nombre for especialidad in especialista.especialidades.all()]
                    }
                    for especialista in horario.especialistas.all()
                ],
                "fechas": [
                    {
                        "id": fecha.id,
                        "fecha": fecha.fecha.strftime('%Y-%m-%d')
                    }
                    for fecha in horario.fechas.all()
                ]
             })
            especialistas = Especialista.objects.prefetch_related(Prefetch('especialidades', queryset=Especialidad.objects.order_by('nombre')))
            # Construir manualmente la estructura de respuesta
            especialistas_con_especialidades = [
                 {
                      "nombre": especialista.nombre,
                      "apellido": especialista.apellido,
                      "cedula": especialista.cedula,
                      "correo": especialista.correo,
                      "descripcion": especialista.descripcion,
                      "servicios": especialista.servicios,
                      "especialidades": [especialidad.nombre for especialidad in especialista.especialidades.all()]
                 }
                 for especialista in especialistas
            ]    

           
           #aqui modificacion#
            citas_especialista = Cita.objects.all().select_related("fecha", "especialista", "especialidad")

            if citas_especialista.exists():
                 nombre_especialista = citas_especialista.first().especialista.nombre
            else:
                 nombre_especialista = "Especialista no encontrado"
                 

            citas_list = []

            for cita in citas_especialista:
                if cita.fecha and cita.fecha.horario:
                    citas_list.append({
                        "horaInicio": cita.fecha.horario.hora_inicio.strftime('%H:%M:%S'),
                        "horaFin": cita.fecha.horario.hora_fin.strftime('%H:%M:%S'),
                        "fecha": cita.fecha.fecha.strftime('%Y-%m-%d'),
                        "especialista": cita.especialista.cedula, 
                        "especialidad": cita.especialidad.nombre,
                        })    


            return Response({
                  'listaHorarios': horario_list,
                  'especialidades': list(Especialidad.objects.all().order_by('id').values('nombre','descripcion')),
                  'especialistas': especialistas_con_especialidades,
                  "citas": {
                      "nombre": nombre_especialista,
                      "citas": citas_list
                      },
                 })
                



class addHoras(APIView):
        permission_classes = [IsSuperUser]

        def post(self,request):
                logger.warning("si llego al end point")
                try:
                    # Obtener los datos del cuerpo de la solicitud
                    
                    json_info_fecha = json.loads(request.body.decode('utf-8'))
                    logger.warning("Esta es la información recibida: %s", json_info_fecha)

                    fecha = json_info_fecha.get("fecha")
                    horaInicio = json_info_fecha.get("hora_inicio")
                    horaFin = json_info_fecha.get("hora_fin")
                    especialistaCedu = json_info_fecha.get("especialista_cedula")
                    especialidadName = json_info_fecha.get("especialidad")

                    # Validar datos
                    if not all([fecha,horaInicio,horaFin,especialistaCedu,especialidadName]):
                        return Response({"error": "Faltan datos requeridos"}, status=400)
                    

                    # Buscar la especialidad por nombre
                    try:
                         especialidad = Especialidad.objects.get(nombre=especialidadName)
                         logger.warning(f"Especialidad encontrada: {especialidad.nombre}")
                         m ="Especialidad encontrada"
                    except ObjectDoesNotExist:
                         logger.warning("Especialidad no encontrada")
                         m = "Especialidad no encontrada"

                    # Buscar el especialista por cédula
                    try:
                         especialista = Especialista.objects.get(cedula=especialistaCedu)

                         logger.warning(f"Especialista encontrado: {especialista.nombre} {especialista.apellido}")
                         z = "Especialista encontrado"
                    except ObjectDoesNotExist:
                         logger.warning("Especialista no encontrado") 
                         z = "Especialista no encontrado"
                         
                    

                    fecha_obj = datetime.strptime(fecha, '%Y-%m-%d').date()
                    hora_inicio_obj = datetime.strptime(horaInicio, '%H:%M:%S').time()
                    hora_fin_obj = datetime.strptime(horaFin, '%H:%M:%S').time()
                    horario = get_object_or_404(Horario, hora_inicio=hora_inicio_obj, hora_fin=hora_fin_obj)
                    # Crear la fecha y relacionarla con el horario

                    nueva_fecha = Fecha.objects.create(fecha=fecha_obj, horario=horario)
                    logger.warning(f"Fecha creada: {nueva_fecha}")

                    # Relacionar el horario con el especialista (si no están ya relacionados)


                    logger.warning("da error aqui en la relacion")
                    if not horario.especialistas.filter(cedula=especialistaCedu).exists():
                         horario.especialistas.add(especialista)
                         logger.warning(f"Especialista {especialista.nombre} relacionado con el horario {horario}")

                    # Relacionar el horario con la nueva fecha (si no están ya relacionados)
                    if not horario.fechas.filter(id=nueva_fecha.id).exists():
                         horario.fechas.add(nueva_fecha)
                         logger.warning(f"Fecha {nueva_fecha.fecha} relacionada con el horario {horario}")


                    return Response({
                        "mensaje": "Horario asignado correctamente",
                        "respuesta especialidad":m,
                        "respuesta especialista":z,
                    })

                except Exception as e:
                    return Response({"error": f"Error inesperado: {str(e)}"}, status=500)
                

"""
"""
class deltedHorarios(APIView):
    permission_classes = [IsSuperUser]

    def post(self, request):
        try:
            # Obtener los datos del cuerpo de la solicitud
            json_info_fecha = json.loads(request.body.decode('utf-8'))
            logger.warning("Esta es la información recibida: %s", json_info_fecha)

            fecha = json_info_fecha.get("fecha")
            hora_inicio = json_info_fecha.get("hora_inicio")
            hora_fin = json_info_fecha.get("hora_fin")

            # Validar datos
            if not all([fecha, hora_inicio, hora_fin]):
                return JsonResponse({"error": "Faltan datos requeridos"}, status=400)

            # Convertir la fecha y horas a los formatos correctos
            fecha_obj = datetime.strptime(fecha, '%Y-%m-%d').date()
            hora_inicio_obj = datetime.strptime(hora_inicio, '%H:%M:%S').time()
            hora_fin_obj = datetime.strptime(hora_fin, '%H:%M:%S').time()

            # Buscar el horario
            horario = get_object_or_404(Horario, hora_inicio=hora_inicio_obj, hora_fin=hora_fin_obj)

            # Buscar todas las fechas asociadas al horario
            fechas_a_eliminar = Fecha.objects.filter(fecha=fecha_obj, horario=horario)

            # Verificar si hay fechas para eliminar
            if not fechas_a_eliminar.exists():
                return JsonResponse({"error": "No se encontraron fechas para eliminar"}, status=404)

            # Eliminar la relación entre el horario y las fechas
            for fecha_a_eliminar in fechas_a_eliminar:
                horario.fechas.remove(fecha_a_eliminar)
                logger.warning(f"Relación eliminada entre el horario {horario} y la fecha {fecha_a_eliminar}")

                # Eliminar la fecha de la base de datos
                fecha_a_eliminar.delete()
                logger.warning(f"Fecha {fecha_a_eliminar} eliminada de la base de datos")

            return JsonResponse({
                "mensaje": "Fechas eliminadas correctamente",
                "fecha": fecha_obj.strftime('%Y-%m-%d'),
                "horario": f"{horario.hora_inicio} - {horario.hora_fin}"
            })

        except json.JSONDecodeError:
            logger.error("Error al decodificar el cuerpo de la solicitud JSON")
            return JsonResponse({"error": "Formato JSON inválido"}, status=400)
        except Exception as e:
            logger.error(f"Error inesperado: {str(e)}")
            return JsonResponse({"error": f"Error inesperado: {str(e)}"}, status=500)





                
class InsertEspecialidad(APIView):
        
        permission_classes = [IsSuperUser]

        def post(self, request):
            
            db = MongoDBConnection.get_db()
            fs = GridFS(db)
            try:
            # Parsear el JSON recibido
                especialidad = json.loads(request.body.decode('utf-8'))
                image_data = especialidad.get('imagen')
                metadata = especialidad.get('metadata', {})
                nameEspe = especialidad.get('nombre')
                describe = especialidad.get('describe')
                
            # Buscar la especialidad en MySQL
                imagen_bytes = base64.b64decode(image_data)
                object_id = fs.put(imagen_bytes,custom_metadata=metadata)
                especialidad = Especialidad.objects.create(
                     nombre=nameEspe,
                     descripcion=describe,
                     owner_id=str(object_id), 
                )
                especialidad.save()

                return Response({'message': 'Especialidad creada Correctamente desde Django'}, status=200)
             
            except Exception as e:
                return JsonResponse({'error': str(e)}, status=500)
            





class deletedEspecialidad(APIView):
        permission_classes = [IsSuperUser]

        def post(self, request):
            
            db = MongoDBConnection.get_db()
            files_collection = db['fs.files']
            chunks_collection = db['fs.chunks']
            try:
            # Parsear el JSON recibido
                data = json.loads(request.body)
                nombre = data.get('nombre')
            
            # Buscar la especialidad en MySQL
                try:
                    especialidad = Especialidad.objects.get(nombre=nombre)
                except ObjectDoesNotExist:
                    return JsonResponse({'error': 'Especialidad no encontrada.'}, status=404)

                owner_id = especialidad.owner_id
                image = files_collection.find_one({'_id': ObjectId(owner_id)})
                if image:
                    image_id = image['_id']
                    files_collection.delete_one({'_id': image_id})
                    chunks_collection.delete_many({'files_id': image_id})

                especialidad.delete()

                return JsonResponse({'message': 'Especialidad eliminada correctamente.'})

            except Exception as e:
                return JsonResponse({'error': str(e)}, status=500)
            
            


class UpdateEspecialidad(APIView):
        
        permission_classes = [IsSuperUser]

        def post(self, request):
            
            db = MongoDBConnection.get_db()
            fs = GridFS(db)
            files_collection = db['fs.files']
            chunks_collection = db['fs.chunks']
            
            try:
            # Parsear el JSON recibido
                image_data = request.data.get('imagen')
                metadata = request.data.get('metadata', {})
                nameEspe = request.data.get('nombre')
                nameOld= request.data.get('oldName')
                describe = request.data.get('describe')
                
                nombreNew = nameEspe
                imagen = image_data
                metadata = metadata
                descripcion =describe
                
            # Buscar la especialidad en MySQL
                try:
                    logger.warning(f"metadata: {metadata}")
                    logger.warning(f"nameEspe: {nameEspe}")
                    logger.warning(f"nameOld: {nameOld}")
                    logger.warning(f"describe: {describe}")
                    especialidad = Especialidad.objects.get(nombre=nameOld)
                    logger.warning(f"especialidad: {especialidad}")
                except ObjectDoesNotExist:
                    return JsonResponse({'error': 'Especialidad no encontrada.'}, status=404)
                
                owner_id = especialidad.owner_id
                logger.warning(f"owner_id: {owner_id}");
                
                
                if nombreNew != nameOld:
                        logger.warning("sie ntra a nombre")
                        especialidad.nombre = nombreNew
                        logger.warning(f"entro a cambiar el nombre{especialidad.nombre}")
                        especialidad.save()  
                        logger.warning("si guardo nombre")
                if descripcion != especialidad.descripcion:
                        logger.warning("sie ntra a descripcion")
                        especialidad.descripcion = descripcion
                        logger.warning(f"entro a cambiar la descripcion{especialidad.descripcion}")

                        especialidad.save()   
                        logger.warning("si guardo descripcion")

                logger.warning("paso la busqueda del nombre y la descripcion")                      
                image = files_collection.find_one({'_id': ObjectId(owner_id)})
                logger.warning("paso la busqueda de la imagen")
                if image:
                    image_id = image['_id']
                    files_collection.delete_one({'_id': image_id})
                    chunks_collection.delete_many({'files_id': image_id})
                logging.warning("si paso la eliminacion")    
                      
                imagen_bytes = base64.b64decode(imagen)
                object_id = fs.put(imagen_bytes,custom_metadata=metadata) 
                especialidad.owner_id = str(object_id)
                logger.warning("casi llego hasta el final")
                especialidad.save()    
                return JsonResponse({
                     'especialidades': list(Especialidad.objects.all().order_by('id').values('nombre','descripcion')),
                     'message': 'Especialidad Actualizada correctamente.'
                     })

            except Exception as e:
                return JsonResponse({'error': str(e)}, status=500)




///
class deletedEspecialista(APIView):
        permission_classes = [IsSuperUser]

        def post(self, request):
            
            db = MongoDBConnection.get_db()
            files_collection = db['fs.files']
            chunks_collection = db['fs.chunks']
            try:
            # Parsear el JSON recibido
                data = json.loads(request.body)
                cedula = data.get('cedula')
            
            # Buscar el especialista en MySQL
                try:
                    especialista = Especialista.objects.get(cedula=cedula)
                except ObjectDoesNotExist:
                    return JsonResponse({'error': 'especialista no encontrada.'}, status=404)

                owner_id = especialista.owner_id
                image = files_collection.find_one({'_id': ObjectId(owner_id)})
                if image:
                    image_id = image['_id']
                    files_collection.delete_one({'_id': image_id})
                    chunks_collection.delete_many({'files_id': image_id})

                especialista.delete()
                return JsonResponse({'message': 'especialista eliminado correctamente.'})
            except Exception as e:
                return JsonResponse({'error': str(e)}, status=500)








class UpdateEspecialista(APIView):
        
        permission_classes = [IsSuperUser]

        def post(self, request):
            
            db = MongoDBConnection.get_db()
            fs = GridFS(db)
            files_collection = db['fs.files']
            chunks_collection = db['fs.chunks']
            
            try:
            # Parsear el JSON recibido
                image_data = request.data.get('imagen')
                metadata = request.data.get('metadata', {})
                nameEspe = request.data.get('nombre')
                apellido = request.data.get('apellido')
                cedula= request.data.get('cedula')
                correo = request.data.get('correo')
                describe = request.data.get('describe')
                nuevas_especialidades = request.data.get('especialidades')
                service = request.data.get('service')

            # Buscar el especialista en MySQL
                try:
                    logger.warning(f"metadata: {metadata}")
                    logger.warning(f"nameEspe: {nameEspe}")
                    logger.warning(f"describe: {describe}")
                    especialista = Especialista.objects.get(cedula=cedula)
                    logger.warning(f"especialidad: {especialista}")
                except ObjectDoesNotExist:
                    return JsonResponse({'error': 'Especialista no encontrada.'}, status=404)
                
                owner_id = especialista.owner_id
                logger.warning(f"owner_id: {owner_id}");
                
                
                if nameEspe != especialista.nombre:
                        logger.warning("sie ntra a nombre")
                        especialista.nombre = nameEspe
                        logger.warning(f"entro a cambiar el nombre{especialista.nombre}")
                        especialista.save()  
                        logger.warning("si guardo nombre")
                if apellido != especialista.apellido:
                        logger.warning("sie ntra a descripcion")
                        especialista.apellido = apellido
                        logger.warning(f"entro a cambiar la descripcion{especialista.descripcion}")
                        especialista.save()   
                        logger.warning("si guardo descripcion")

                if correo != especialista.correo:
                     especialista.correo = correo
                     especialista.save()


                if describe != especialista.descripcion:
                     especialista.descripcion = describe
                     especialista.save()

                if service != especialista.servicios:
                     especialista.servicios =  service
                     especialista.save() 

                especialista.especialidades.clear()     
                nuevas_instancias = Especialidad.objects.filter(nombre__in=nuevas_especialidades)
                especialista.especialidades.add(*nuevas_instancias)

                logger.warning("paso la busqueda del nombre y la descripcion")                      
                image = files_collection.find_one({'_id': ObjectId(owner_id)})
                logger.warning("paso la busqueda de la imagen")

                if image:
                    image_id = image['_id']
                    files_collection.delete_one({'_id': image_id})
                    chunks_collection.delete_many({'files_id': image_id})
                logging.warning("si paso la eliminacion") 

                imagen_bytes = base64.b64decode(image_data)
                object_id = fs.put(imagen_bytes,custom_metadata=metadata) 
                especialista.owner_id = str(object_id)
                logger.warning("casi llego hasta el final")
                especialista.save()    
                logger.warning("ya guardo esta generando el listado")

                return JsonResponse({'message': 'Especialista actualizado correctamente.'})

            except Exception as e:
                return JsonResponse({'error': str(e)}, status=500)



#citas
from django.contrib.auth.models import User 

class citasAdmin(APIView):
    permission_classes = [IsSuperUser]

    def get(self, request):
        try:
            # Obtener todas las citas con sus relaciones
            citas = Cita.objects.all().select_related('especialidad','especialista','fecha')
            
            citas_data = []
            imagenes = []
            image_data = BytesIO()
            db = MongoDBConnection.get_db()
            files_collection = db['fs.files']
            chunks_collection = db['fs.chunks']
            
            for cita in citas:
                # Buscar el usuario por correo
                try:
                    usuario = User.objects.get(email=cita.correo)
                    owner_id = usuario.last_name
                    try:
                         file_doc = files_collection.find_one({'_id': ObjectId(owner_id)})
                    except Exception as e:
                         logger.error(f"Error al convertir owner_id a ObjectId: {e}")
                         continue    

                    if not file_doc:
                        logger.warning(f"No se encontró archivo para owner_id: {owner_id}")
                        file_doc = files_collection.find_one({'_id': ObjectId('67776960474c4bd8ee017d42')})
                        continue

                    file_id = file_doc['_id']
                    chunks = chunks_collection.find({'files_id': file_id}).sort('n', 1)

                    image_data.truncate(0)
                    image_data.seek(0)

                    for chunk in chunks:
                        image_data.write(chunk['data'])

                    image_data.seek(0)
                    encoded_image = base64.b64encode(image_data.read()).decode('utf-8')

                    imagenes.append({
                        'imagen': encoded_image,
                        'metadatos': {
                            'filename': file_doc.get('filename', 'desconocido'),
                            'content_type': file_doc.get('contentType', 'unknown'),
                        }
                    }) 

                except User.DoesNotExist:
                    owner_id = "No encontrado"
                except Exception as e:
                    logger.error(f"Error buscando usuario: {str(e)}")
                    owner_id = "Error en búsqueda"

                # Obtener datos de la fecha si existe
                fecha_data = {}
                if cita.fecha:
                    fecha_data = {'fecha': cita.fecha.fecha.strftime('%Y-%m-%d'),'horario': f"{cita.fecha.horario.hora_inicio} - {cita.fecha.horario.hora_fin}"}

                citas_data.append({
                    'nombre': cita.nombre,
                    'correo': cita.correo,
                    'especialidad': {
                        'nombre': cita.especialidad.nombre,
                    },
                    'especialista': {
                        'nombre': cita.especialista.nombre,
                        'apellido':cita.especialista.apellido
                    },
                    'fecha': fecha_data,
                    'ubicacion': {
                        'edificio': cita.edificio,
                        'consultorio': cita.consultorio
                    }
                })

            return Response({'citas': citas_data,'imagenes':imagenes})    

        except Exception as e:
            logger.error(f"Error general: {str(e)}")
            return JsonResponse({'error': 'Error al obtener las citas','detalle': str(e)}, status=500)

"""









































        