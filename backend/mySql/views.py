from django.shortcuts import render
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import *
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework.permissions import BasePermission
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
from django.contrib.auth.decorators import login_required
from django.shortcuts import redirect
from django.contrib import messages
from django.contrib.auth import authenticate, login
from django.http import HttpResponseForbidden
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth import logout

from .serializers import PerfilEstudianteSerializer

from rest_framework.parsers import MultiPartParser, FormParser
from mySql.utils.mongodb import MongoDBConnection

import pymongo
from django.http import HttpResponse

#Docente
from .forms import LoginDocenteForm, AsignacionTareaForm, CrearAnuncioForm
from django.views.decorators.http import require_POST
from .forms import NotaForm
from django.forms import modelformset_factory
from .models import Nota

#Administrador
from .forms import LoginAdministradorForm
from .forms import PublicacionNotasForm, PublicacionNotasEditarForm
from .models import Docente
from .forms import DocenteUserForm
from .forms import DocenteUserEditForm
from .models import Estudiante
from .models import Matricula
from .models import Componente
from django.db.models import Count

#Notificaciones
from .utils.notificaciones import crear_notificacion
from django.utils.timezone import localtime





# Docentes
@login_required
def docente_redirect(request):
    if hasattr(request.user, 'perfil_docente'):
        return redirect('docente_bienvenida')
    else:
        return redirect('docente_login') 

@login_required
def docentes_bienvenida(request):
    perfil = getattr(request.user, 'perfil_docente', None)
    return render(request, 'docentes/docente_bienvenida.html', {'perfil': perfil})        


def login_docente_view(request):
    form = LoginDocenteForm()

    if request.method == 'POST':
        form = LoginDocenteForm(request.POST)
        if form.is_valid():
            correo = form.cleaned_data['email']
            password = form.cleaned_data['password']

            try:
                user = User.objects.get(email=correo)
            except User.DoesNotExist:
                messages.error(request, 'Correo no registrado.')
                return render(request, 'docentes/docente_login.html', {'form': form})

            user = authenticate(request, username=user.username, password=password)
            if user is not None:
                if hasattr(user, 'perfil_docente'):
                    login(request, user)
                    return redirect('docente_redirect')
                else:
                    return HttpResponseForbidden("Acceso no autorizado para este panel.")
            else:
                messages.error(request, 'Credenciales incorrectas.')

    return render(request, 'docentes/docente_login.html', {'form': form})

@login_required
def logout_docente_view(request):
    logout(request)
    return redirect('docente_login')    

@login_required
def componentes_docente(request):
    docente = request.user.perfil_docente
    asignaciones = AsignacionDocenteComponente.objects.filter(docente=docente).select_related('componente')
    componentes = [asignacion.componente for asignacion in asignaciones]
    return render(request, 'docentes/componentes_list.html', {'componentes': componentes})

@login_required
def tareas_componente(request, componente_id):
    docente = request.user.perfil_docente
    componente = get_object_or_404(Componente, id=componente_id)
    tareas = AsignacionTarea.objects.filter(docente=docente, componente=componente)
    return render(request, 'docentes/tareas_list.html', {'tareas': tareas, 'componente': componente})

@login_required
def crear_tarea(request, componente_id):
    docente = request.user.perfil_docente
    componente = get_object_or_404(Componente, id=componente_id)
    form = AsignacionTareaForm(request.POST or None)

    if request.method == 'POST' and form.is_valid():
        tarea = form.save(commit=False)
        tarea.docente = docente
        tarea.componente = componente
        tarea.save()

        # Crear notas finales iniciales en 0.0
        from mySql.models import Matricula, CalificacionFinalTarea
        componentes_matriculados = Matricula.objects.filter(
            componente_cursado=componente,
            activa=True,
            estado__in=['activa', 'confirmada']
        ).select_related('estudiante')

        for matricula in componentes_matriculados:
            CalificacionFinalTarea.objects.get_or_create(
                estudiante=matricula.estudiante,
                tarea=tarea,
                defaults={'nota_final': 0.0}
            )

        # 🔔 Crear notificación de nueva tarea
        crear_notificacion(
            autor=docente,
            tipo='nueva_tarea',
            descripcion=f"Se ha creado la tarea '{tarea.titulo}' en el componente '{componente.nombre}'",
            tarea=tarea
        )

        return redirect('tareas_componente', componente_id=componente.id)

    return render(request, 'docentes/crear_tarea.html', {'form': form, 'componente': componente})


@login_required
def editar_tarea(request, tarea_id):
    tarea = get_object_or_404(AsignacionTarea, id=tarea_id, docente=request.user.perfil_docente)
    form = AsignacionTareaForm(request.POST or None, instance=tarea)

    fecha_anterior = tarea.fecha_entrega  # Guarda la fecha original

    if request.method == 'POST' and form.is_valid():
        tarea_editada = form.save()

        # 🔔 Verificar cambio de fecha y notificar
        if fecha_anterior != tarea_editada.fecha_entrega:
            crear_notificacion(
                autor=request.user.perfil_docente,
                tipo='cambio_fecha',
                descripcion=f"La fecha de entrega de la tarea '{tarea.titulo}' fue modificada.",
                tarea=tarea
            )

        return redirect('tareas_componente', componente_id=tarea.componente.id)

    return render(request, 'docentes/editar_tarea.html', {'form': form, 'tarea': tarea})

@login_required
def eliminar_tarea(request, tarea_id):
    tarea = get_object_or_404(AsignacionTarea, id=tarea_id, docente=request.user.perfil_docente)
    if request.method == 'POST':
        tarea.delete()
        #messages.success(request, 'Tarea eliminada.')
        return redirect('tareas_componente', componente_id=tarea.componente.id)
    return render(request, 'docentes/confirmar_eliminacion_tarea.html', {'tarea': tarea})


@login_required
def calificar_entrega(request, entrega_id):
    entrega = get_object_or_404(EntregaTarea, id=entrega_id, asignacion__docente=request.user.perfil_docente)

    if request.method == 'POST':
        calificacion = request.POST.get('calificacion')
        observaciones = request.POST.get('observaciones')

        entrega.calificacion = calificacion
        entrega.observaciones = observaciones
        entrega.save()

        # Recalcular la nota final con el intento más alto
        entregas = EntregaTarea.objects.filter(
            asignacion=entrega.asignacion,
            estudiante=entrega.estudiante,
            calificacion__isnull=False
        ).order_by('-intento_numero')

        if entregas.exists():
            intento_final = entregas.first()
            nota_final = float(intento_final.calificacion)
        else:
            nota_final = 0.0  

        # Actualizar o crear registro en CalificacionFinalTarea
        CalificacionFinalTarea.objects.update_or_create(
            estudiante=entrega.estudiante,
            tarea=entrega.asignacion,
            defaults={'nota_final': nota_final}
        )

        # 🔔 Crear notificación de calificación
        crear_notificacion(
            autor=request.user.perfil_docente,
            tipo='calificacion',
            descripcion=f"Se calificó un intento de la tarea '{entrega.asignacion.titulo}' del estudiante '{entrega.estudiante.nombres_apellidos}'",
            entrega=entrega
        )

        return redirect('entregas_estudiante_tarea', entrega.asignacion.id, entrega.estudiante.id)

    return render(request, 'docentes/calificar_entrega.html', {'entrega': entrega})


def obtener_archivos_entrega(entrega_id):
    collection = MongoDBConnection.get_entregas_collection()
    doc = collection.find_one({'entrega_id': entrega_id})
    return doc.get('archivos', []) if doc else []


@login_required
def ver_pdf_mongo(request, entrega_id, nombre):
    collection = MongoDBConnection.get_entregas_collection()
    doc = collection.find_one({'entrega_id': entrega_id})

    if not doc:
        return HttpResponse('Archivo no encontrado', status=404)

    for archivo in doc.get('archivos', []):
        if archivo['tipo'] == 'file' and archivo['nombre'] == nombre and archivo['extension'] == '.pdf':
            contenido = base64.b64decode(archivo['contenido_base64'])
            response = HttpResponse(contenido, content_type='application/pdf')
            response['Content-Disposition'] = f'inline; filename="{nombre}"'
            return response

    return HttpResponse('Archivo PDF no disponible', status=404)


@login_required
def descargar_archivo_mongo(request, entrega_id, nombre):
    collection = MongoDBConnection.get_entregas_collection()
    doc = collection.find_one({'entrega_id': entrega_id})

    if not doc:
        return HttpResponse('Archivo no encontrado', status=404)

    for archivo in doc.get('archivos', []):
        if archivo['tipo'] == 'file' and archivo['nombre'] == nombre:
            contenido = base64.b64decode(archivo['contenido_base64'])
            extension = archivo['extension'].lower()
            content_type = {
                '.pdf': 'application/pdf',
                '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
            }.get(extension, 'application/octet-stream')

            response = HttpResponse(contenido, content_type=content_type)
            response['Content-Disposition'] = f'attachment; filename="{nombre}"'
            return response

    return HttpResponse('Archivo no disponible para descarga', status=404)

@login_required
def lista_estudiantes_entregaron(request, tarea_id):
    tarea = get_object_or_404(AsignacionTarea, id=tarea_id, docente=request.user.perfil_docente)

    entregas = EntregaTarea.objects.filter(asignacion=tarea).select_related('estudiante')

    estudiantes_entregaron = {}
    for entrega in entregas:
        estudiante_id = entrega.estudiante.id
        if estudiante_id not in estudiantes_entregaron:
            estudiantes_entregaron[estudiante_id] = entrega.estudiante

    notas_finales_qs = CalificacionFinalTarea.objects.filter(tarea=tarea)
    notas_finales = {nota.estudiante.id: nota for nota in notas_finales_qs}

    return render(request, 'docentes/entregantes_tarea.html', {
        'tarea': tarea,
        'estudiantes': estudiantes_entregaron.values(),
        'notas_finales': notas_finales
    })

@login_required
def entregas_estudiante_tarea(request, tarea_id, estudiante_id):
    tarea = get_object_or_404(AsignacionTarea, id=tarea_id, docente=request.user.perfil_docente)
    estudiante = get_object_or_404(Estudiante, id=estudiante_id)

    entregas = EntregaTarea.objects.filter(asignacion=tarea, estudiante=estudiante)

    for entrega in entregas:
        entrega.archivos = obtener_archivos_entrega(entrega.id)

    return render(request, 'docentes/entregas_estudiante.html', {
        'tarea': tarea,
        'estudiante': estudiante,
        'entregas': entregas
    })
    









# Vistas de la funcionalidad de anuncios profesor
@login_required
def componentes_docente_anuncio(request):
    docente = request.user.perfil_docente
    componentes = Componente.objects.filter(docentes_asignados__docente=docente).distinct()

    return render(request, 'docentes/anuncios/componentes_docente_anuncio.html', {
        'componentes': componentes
    })


@login_required
def anuncios_por_componente(request, componente_id):
    docente = request.user.perfil_docente
    componente = get_object_or_404(Componente, id=componente_id)

    # Validar que el docente está asignado al componente
    if not componente.docentes_asignados.filter(docente=docente).exists():
        return HttpResponseForbidden("No autorizado")

    anuncios = Anuncio.objects.filter(componente=componente).order_by('-fecha_creacion')

    return render(request, 'docentes/anuncios/anuncios_por_componente.html', {
        'componente': componente,
        'anuncios': anuncios
    })

@login_required
def crear_anuncio(request, componente_id):
    docente = request.user.perfil_docente
    componente = get_object_or_404(Componente, id=componente_id)

    # Validar acceso al componente
    if not componente.docentes_asignados.filter(docente=docente).exists():
        return HttpResponseForbidden("No autorizado")

    if request.method == 'POST':
        form = CrearAnuncioForm(request.POST, request.FILES)

        if form.is_valid():
            anuncio = form.save(commit=False)
            anuncio.docente = docente
            anuncio.componente = componente
            anuncio.save()

            # Imágenes en Django
            imagenes = request.FILES.getlist('imagenes')
            for img in imagenes:
                ImagenAnuncio.objects.create(
                    anuncio=anuncio,
                    imagen=img
                )

            # Archivos y links en MongoDB
            coleccion = MongoDBConnection.get_anuncios_collection()

            # Archivos PDF/DOCX
            archivos = request.FILES.getlist('archivos')
            for archivo in archivos:
                extension = archivo.name.split('.')[-1].lower()
                if extension in ['pdf', 'docx']:
                    contenido_base64 = base64.b64encode(archivo.read()).decode('utf-8')
                    coleccion.insert_one({
                        "anuncio_id": anuncio.id,
                        "nombre": archivo.name,
                        "extension": extension,
                        "tipo": "documento",
                        "contenido_base64": contenido_base64,
                        "fecha": datetime.utcnow()
                    })

            # Links ingresados por el docente
            links_raw = request.POST.get('links', '')
            links = [link.strip() for link in links_raw.splitlines() if link.strip()]
            for link in links:
                coleccion.insert_one({
                    "anuncio_id": anuncio.id,
                    "tipo": "link",
                    "url": link,
                    "fecha": datetime.utcnow()
                })

            # messages.success(request, "Anuncio creado con éxito.")
            return redirect('anuncios_por_componente', componente_id=componente.id)
    else:
        form = CrearAnuncioForm()

    return render(request, 'docentes/anuncios/crear_anuncio.html', {
        'form': form,
        'componente': componente
    })

@login_required
def editar_anuncio(request, anuncio_id):
    anuncio = get_object_or_404(Anuncio, id=anuncio_id)
    docente = request.user.perfil_docente

    # Seguridad: solo el autor puede editar
    if anuncio.docente != docente:
        return HttpResponseForbidden("No autorizado")

    # Obtener archivos y links de MongoDB
    mongo_db = MongoDBConnection.get_db()
    archivos_raw = mongo_db["archivos_anuncio"].find({"anuncio_id": anuncio.id})

    archivos_mongo = []
    for archivo in archivos_raw:
        archivo["id_str"] = str(archivo["_id"])
        archivos_mongo.append(archivo)

    if request.method == 'POST':
        form = CrearAnuncioForm(request.POST, request.FILES, instance=anuncio)

        if form.is_valid():
            form.save()

            # Nuevas imágenes
            nuevas_imagenes = request.FILES.getlist('imagenes')
            for img in nuevas_imagenes:
                ImagenAnuncio.objects.create(anuncio=anuncio, imagen=img)

            # Nuevos archivos (PDF/DOCX)
            nuevos_archivos = request.FILES.getlist('archivos')
            for archivo in nuevos_archivos:
                extension = archivo.name.split('.')[-1].lower()
                if extension in ['pdf', 'docx']:
                    contenido_base64 = base64.b64encode(archivo.read()).decode('utf-8')
                    mongo_db["archivos_anuncio"].insert_one({
                        "anuncio_id": anuncio.id,
                        "nombre": archivo.name,
                        "extension": extension,
                        "tipo": "documento",
                        "contenido_base64": contenido_base64,
                        "fecha": datetime.utcnow()
                    })

            # Nuevos enlaces
            links_raw = request.POST.get('links', '')
            links = [link.strip() for link in links_raw.splitlines() if link.strip()]
            for link in links:
                mongo_db["archivos_anuncio"].insert_one({
                    "anuncio_id": anuncio.id,
                    "tipo": "link",
                    "url": link,
                    "fecha": datetime.utcnow()
                })

            #messages.success(request, "Anuncio actualizado correctamente.")
            return redirect('anuncios_por_componente', componente_id=anuncio.componente.id)

    else:
        form = CrearAnuncioForm(instance=anuncio)

    return render(request, 'docentes/anuncios/editar_anuncio.html', {
        'form': form,
        'anuncio': anuncio,
        'archivos_mongo': archivos_mongo
    })

@login_required
@require_POST
def eliminar_adjunto_anuncio(request, anuncio_id):
    archivo_id = request.POST.get('archivo_id')
    docente = request.user.perfil_docente

    anuncio = get_object_or_404(Anuncio, id=anuncio_id)
    if anuncio.docente != docente:
        return JsonResponse({'error': 'No autorizado'}, status=403)

    mongo_db = MongoDBConnection.get_db()
    resultado = mongo_db["archivos_anuncio"].delete_one({
        "_id": ObjectId(archivo_id),
        "anuncio_id": anuncio.id
    })

    if resultado.deleted_count == 1:
        return JsonResponse({'success': True})
    else:
        return JsonResponse({'error': 'Adjunto no encontrado'}, status=404)

@login_required
@require_POST
def eliminar_imagen_anuncio(request, anuncio_id):
    imagen_id = request.POST.get('imagen_id')
    docente = request.user.perfil_docente

    anuncio = get_object_or_404(Anuncio, id=anuncio_id)
    if anuncio.docente != docente:
        return JsonResponse({'error': 'No autorizado'}, status=403)

    imagen = get_object_or_404(ImagenAnuncio, id=imagen_id, anuncio=anuncio)
    imagen.delete()

    return JsonResponse({'success': True})            

@login_required
def eliminar_anuncio(request, anuncio_id):
    anuncio = get_object_or_404(Anuncio, id=anuncio_id)
    docente = request.user.perfil_docente

    if anuncio.docente != docente:
        return HttpResponseForbidden("No autorizado")

    # Obtener archivos y links desde Mongo
    mongo_db = MongoDBConnection.get_db()
    archivos_mongo = list(mongo_db["archivos_anuncio"].find({"anuncio_id": anuncio.id}))

    if request.method == 'POST':
        # Eliminar imágenes en Django
        ImagenAnuncio.objects.filter(anuncio=anuncio).delete()

        # Eliminar archivos y links en Mongo
        mongo_db["archivos_anuncio"].delete_many({"anuncio_id": anuncio.id})

        # Eliminar el anuncio
        anuncio.delete()

        return redirect('anuncios_por_componente', componente_id=anuncio.componente.id)

    return render(request, 'docentes/anuncios/eliminar_anuncio.html', {
        'anuncio': anuncio,
        'archivos_mongo': archivos_mongo
    })











# Vistas de subida de notas profesor
@login_required
def componentes_docente_notas(request):
    docente = request.user.perfil_docente
    componentes = Componente.objects.filter(docentes_asignados__docente=docente).distinct()
    habilitados = PublicacionNotas.objects.filter(componente__in=componentes, habilitado=True)

    return render(request, 'docentes/subida_notas/componentes_docente_notas.html', {
        'componentes': [h.componente for h in habilitados]
    })


@login_required
def estudiantes_componente_notas(request, componente_id):
    componente = get_object_or_404(Componente, id=componente_id)
    docente = request.user.perfil_docente
    matriculas = Matricula.objects.filter(componente_cursado=componente).select_related('estudiante')

    estudiantes = []
    for m in matriculas:
        nota = Nota.objects.filter(
            estudiante=m.estudiante,
            componente=componente,
            docente=docente
        ).first() 

        estudiantes.append({
            'id': m.estudiante.id,
            'nombres_apellidos': m.estudiante.nombres_apellidos,
            'identificacion': m.estudiante.identificacion,
            'email': m.estudiante.email,
            'nota_id': nota.id if nota else None,  
        })

    return render(request, 'docentes/subida_notas/estudiantes_componente.html', {
        'componente': componente,
        'estudiantes': estudiantes
    })

@login_required
def editar_nota_notas(request, estudiante_id, componente_id):
    estudiante = get_object_or_404(Estudiante, id=estudiante_id)
    componente = get_object_or_404(Componente, id=componente_id)
    docente = request.user.perfil_docente

    notas = Nota.objects.filter(estudiante=estudiante, componente=componente, docente=docente).order_by('bimestre')

    # Crear notas si no existen para ambos bimestres
    bimestres = [1, 2]
    notas_existentes = Nota.objects.filter(estudiante=estudiante, componente=componente)

    bimestres_existentes = set(notas_existentes.values_list('bimestre', flat=True))
    bimestres_faltantes = [b for b in bimestres if b not in bimestres_existentes]

    for b in bimestres_faltantes:
        Nota.objects.create(
            estudiante=estudiante,
            componente=componente,
            docente=docente,
            bimestre=b
        )

    # Consulta actualizada luego de crear las que faltaban
    notas = Nota.objects.filter(estudiante=estudiante, componente=componente).order_by('bimestre')

    NotaFormSet = modelformset_factory(
        Nota,
        fields=['tareas', 'lecciones', 'grupales', 'individuales', 'inasistencias'],
        extra=0
    )

    if request.method == 'POST':
        formset = NotaFormSet(request.POST, queryset=notas)
        print(formset.errors)  # útil durante desarrollo

        if formset.is_valid():
            formset.save()
            return redirect('estudiantes_componente_notas', componente_id=componente.id)
    else:
        formset = NotaFormSet(queryset=notas)

    pares = zip(formset.forms, notas)    

    return render(request, 'docentes/subida_notas/editar_nota.html', {
        'formset': formset,
        'notas': notas,
        'estudiante': estudiante,
        'componente': componente,
        'pares': pares,
    })




















#Vistas del Administrador
@login_required
def administrador_redirect(request):
    if hasattr(request.user, 'perfil_administrador'):
        return redirect('administrador_bienvenida')
    else:
        return redirect('administrador_login') 

@login_required
def administrador_bienvenida(request):
    perfil = getattr(request.user, 'perfil_administrador', None)

    return render(request, 'administrador/login/administrador_bienvenida.html', {
        'perfil': perfil
    })     

def login_administrador_view(request):
    form = LoginAdministradorForm()

    if request.method == 'POST':
        form = LoginAdministradorForm(request.POST)
        if form.is_valid():
            correo = form.cleaned_data['email']
            password = form.cleaned_data['password']

            try:
                user = User.objects.get(email=correo)
            except User.DoesNotExist:
                messages.error(request, 'Correo no registrado.')
                return render(request, 'administrador/login/administrador_login.html', {'form': form})

            user = authenticate(request, username=user.username, password=password)
            if user is not None:
                if hasattr(user, 'perfil_administrador'):
                    login(request, user)
                    return redirect('administrador_redirect')
                else:
                    return HttpResponseForbidden("Acceso no autorizado para este panel.")
            else:
                messages.error(request, 'Credenciales incorrectas.')

    return render(request, 'administrador/login/administrador_login.html', {'form': form})

@login_required
def logout_administrador_view(request):
    logout(request)
    return redirect('administrador_login') 



@login_required
def lista_habilitar_notas(request):
    registros = PublicacionNotas.objects.all()

    return render(request, 'administrador/subida_notas/lista_habilitar_notas.html', {
        'registros': registros
    })

@login_required
def administrador_habilitar_notas(request, componente_id):
    componente = get_object_or_404(Componente, id=componente_id)

    publicacion, created = PublicacionNotas.objects.get_or_create(componente=componente)

    if request.method == 'POST':
        form = PublicacionNotasEditarForm(request.POST, instance=publicacion)
        if form.is_valid():
            form.save()
            return redirect('lista_habilitar_notas')
    else:
        form = PublicacionNotasEditarForm(instance=publicacion)

    return render(request, 'administrador/subida_notas/habilitar_notas.html', {
        'form': form,
        'componente': componente
    })

@login_required
def administrador_crear_publicacion(request):
    if request.method == 'POST':
        form = PublicacionNotasForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('lista_habilitar_notas')
    else:
        form = PublicacionNotasForm()

    return render(request, 'administrador/subida_notas/habilitar_nuevo.html', {
        'form': form
    })

@login_required
def listado_docentes(request):
    docentes = Docente.objects.all()
    total_docentes = docentes.count()
    return render(request, 'administrador/agregar_docentes/lista_docentes.html', {
        'docentes': docentes,
        'total_docentes': total_docentes
    })

@login_required
def agregar_docente(request):
    if request.method == 'POST':
        form = DocenteUserForm(request.POST, request.FILES)
        if form.is_valid():
            form.save()
            return redirect('listado_docentes')
    else:
        form = DocenteUserForm()

    return render(request, 'administrador/agregar_docentes/agregar_docente.html', {
        'form': form
    })   

@login_required
def editar_docente(request, docente_id):
    docente = get_object_or_404(Docente, id=docente_id)

    if request.method == 'POST':
        form = DocenteUserEditForm(request.POST, request.FILES, instance=docente)
        if form.is_valid():
            form.save()
            return redirect('listado_docentes')
    else:
        form = DocenteUserEditForm(instance=docente)

    return render(request, 'administrador/agregar_docentes/editar_docente.html', {
        'form': form,
        'docente': docente
    })    

@login_required
def eliminar_docente(request, docente_id):
    docente = get_object_or_404(Docente, id=docente_id)
    usuario = docente.user  

    if request.method == 'POST':
        usuario.delete()  
        return redirect('listado_docentes')

    return render(request, 'administrador/agregar_docentes/eliminar_docente.html', {
        'docente': docente
    })


@login_required
def info_estudiantes(request):
    estudiantes = Estudiante.objects.all()
    total_estudiantes = estudiantes.count()

    estudiantes_por_componente = (
        Matricula.objects
        .values('componente_cursado__nombre', 'componente_cursado__programa_academico')
        .annotate(total=Count('estudiante'))
        .order_by('componente_cursado__nombre')
    )

    context = {
        'estudiantes': estudiantes,
        'total_estudiantes': total_estudiantes,
        'estudiantes_por_componente': estudiantes_por_componente,
    }
    return render(request, 'administrador/estudiantes_info/info_estudiantes.html', context)















# Esto te da el endpoint para obtener el token al hacer login
class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        data = super().validate(attrs)
        data['is_superuser'] = self.user.is_superuser
        data['user_id'] = self.user.id

        try:
            estudiante = Estudiante.objects.get(user=self.user)
            data['estudiante_id'] = estudiante.id
        except Estudiante.DoesNotExist:
            data['estudiante_id'] = None

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



class ComponentesDisponiblesView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        estudiante = get_object_or_404(Estudiante, user=request.user)
        componentes = Componente.objects.filter(
            programa_academico=estudiante.programa_academico,
            cupos_disponibles__gt=0
        ).order_by('nombre')

        data = [{
            'id': componente.id,
            'nombre': componente.nombre,
            'programa_academico': componente.programa_academico,
            'precio': componente.precio,
            'periodo': componente.periodo,
            'horario': componente.horario,
            'cupos_disponibles': componente.cupos_disponibles,
        } for componente in componentes]

        return Response({'componentes': data})


class CrearMatriculaView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        estudiante = get_object_or_404(Estudiante, user=request.user)
        componente_id = request.data.get('componente_id')

        # Validar componente
        try:
            componente = Componente.objects.get(id=componente_id)
        except Componente.DoesNotExist:
            return Response({'error': 'Componente no encontrado'}, status=404)

        # Verificar disponibilidad de cupos
        if componente.cupos_disponibles <= 0:
            return Response({'error': 'Este componente no tiene cupos disponibles'}, status=400)

        # Verificar si ya existe una matrícula activa o confirmada para este estudiante
        if Matricula.objects.filter(
            estudiante=estudiante,
            estado__in=['activa', 'confirmada']
        ).exists():
            return Response({'error': 'Ya tienes una matrícula activa o confirmada'}, status=400)

        # Verificar si ya está matriculado en el mismo componente
        if Matricula.objects.filter(
            estudiante=estudiante,
            componente_cursado=componente
        ).exists():
            return Response({'error': 'Ya estás matriculado en este componente'}, status=400)

        try:
            # Crear matrícula
            matricula = Matricula.objects.create(
                estudiante=estudiante,
                componente_cursado=componente,
                metodo_pago=request.data.get('metodo_pago'),
                medio_entero=request.data.get('medio_entero'),
                costo_matricula=componente.precio,
                estado='confirmada'
            )

            # Decrementar cupos
            componente.cupos_disponibles -= 1
            componente.save()

            # Enviar factura y credenciales
            self.enviar_factura(estudiante, componente, matricula)
            self.enviar_credenciales(estudiante)

            return Response({'message': 'Matrícula completada exitosamente'}, status=200)

        except Exception as e:
            logger.error(f"Error al crear matrícula: {e}")
            return Response({'error': 'Ocurrió un error al crear la matrícula'}, status=500)

    def enviar_factura(self, estudiante, componente, matricula):
        subject = 'Factura de Matrícula'
        from_email = settings.EMAIL_HOST_USER
        to_email = [estudiante.email]

        html_message = render_to_string('factura_matricula.html', {
            'estudiante': estudiante,
            'componente': componente,
            'matricula': matricula,
        })

        try:
            send_mail(subject, '', from_email, to_email, html_message=html_message)
            logger.info(f"Factura enviada a {estudiante.email}")
        except Exception as e:
            logger.error(f"Error al enviar la factura: {e}")

    def enviar_credenciales(self, estudiante):
        correo_utpl = f"{estudiante.user.username}@utpl.edu.ec"
        contraseña = ''.join(secrets.choice(string.ascii_letters + string.digits) for _ in range(10))

        subject = 'Tus Credenciales Académicas UTPL'
        from_email = settings.EMAIL_HOST_USER
        to_email = [estudiante.email]

        html_message = render_to_string('credenciales_utpl.html', {
            'correo_utpl': correo_utpl,
            'contraseña': contraseña,
            'estudiante': estudiante
        })

        try:
            send_mail(subject, '', from_email, to_email, html_message=html_message)
            logger.info(f"Credenciales enviadas a {estudiante.email}")
        except Exception as e:
            logger.error(f"Error al enviar las credenciales: {e}")




@api_view(['POST'])
@permission_classes([IsAuthenticated])
def registrar_datos_pago(request):
    try:
        estudiante = request.user.perfil_estudiante
    except Estudiante.DoesNotExist:
        return Response({'error': 'No se encontró perfil de estudiante vinculado'}, status=400)

    componente_id = request.data.get('componente_id')
    metodo = request.data.get('metodo_pago')

    if not componente_id or not metodo:
        return Response({'error': 'componente_id y metodo_pago son obligatorios'}, status=400)

    try:
        componente = Componente.objects.get(id=componente_id)
    except Componente.DoesNotExist:
        return Response({'error': 'Componente no encontrado'}, status=404)

    datos = DatosPagoMatricula.objects.create(
        estudiante=estudiante,
        componente=componente,
        metodo_pago=metodo,
        referencia=request.data.get('referencia'),
        monto=request.data.get('monto'),
        fecha_deposito=request.data.get('fecha_deposito'),
        id_depositante=request.data.get('id_depositante'),
        nombre_tarjeta=request.data.get('nombre_tarjeta'),
        numero_tarjeta=request.data.get('numero_tarjeta'),
        vencimiento=request.data.get('vencimiento'),
        cvv=request.data.get('cvv'),
    )

    return Response({"mensaje": "Datos de pago guardados correctamente"})


class NotasView(APIView, ValidateMatriculaMixin):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if not self.tiene_matricula(request):
            logger.warning("El usuario no tiene matrícula actualmente.")
            return Response({"detalle": "El usuario no tiene matrícula actualmente."}, status=400)

        try:
            estudiante = Estudiante.objects.get(user=request.user)
        except Estudiante.DoesNotExist:
            return Response({'error': 'Estudiante no encontrado'}, status=404)

        notas = Nota.objects.filter(estudiante=estudiante)

        if not notas.exists():
            return Response([], status=200)

        resultado = {}

        for nota in notas:
            componente_nombre = nota.componente.nombre
            resultado.setdefault(componente_nombre, {'componente': componente_nombre, 'notas': []})

            nota_bimestre = nota.calcular_nota_final()
            resultado[componente_nombre]['notas'].append({
                'bimestre': nota.bimestre,
                'tareas': nota.tareas,
                'lecciones': nota.lecciones,
                'grupales': nota.grupales,
                'individuales': nota.individuales,
                'inasistencias': nota.inasistencias,
                'nota_bimestre': round(nota_bimestre, 2)
            })

        for comp in resultado.values():
            bimestres = comp['notas']
            if len(bimestres) == 2:
                promedio = sum(b['nota_bimestre'] for b in bimestres) / 2
                comp['nota_final'] = round(promedio, 2)

        return Response(list(resultado.values()))
      


class PerfilEstudianteView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            estudiante = Estudiante.objects.get(user=request.user)
        except Estudiante.DoesNotExist:
            return Response({'error': 'Estudiante no encontrado'}, status=404)

        serializer = PerfilEstudianteSerializer(estudiante)
        return Response(serializer.data)



class EntregarTareaView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request, asignacion_id):
        user = request.user

        try:
            estudiante = Estudiante.objects.get(user=user)
        except Estudiante.DoesNotExist:
            return Response({'error': 'Estudiante no válido'}, status=404)

        try:
            asignacion = AsignacionTarea.objects.get(id=asignacion_id, publicada=True)
        except AsignacionTarea.DoesNotExist:
            return Response({'error': 'Asignación no disponible'}, status=404)

        intentos_usados = EntregaTarea.objects.filter(
            asignacion=asignacion, estudiante=estudiante
        ).count()

        if intentos_usados >= asignacion.intentos_maximos:
            return Response({'error': 'Ya se han usado todos los intentos'}, status=403)

        intento_numero = intentos_usados + 1

        entrega = EntregaTarea.objects.create(
            asignacion=asignacion,
            estudiante=estudiante,
            intento_numero=intento_numero,
            entregado=True
        )

        archivos_enviados = []

        for file_key in request.FILES:
            archivo = request.FILES[file_key]
            nombre = archivo.name
            extension = nombre.split('.')[-1].lower()

            if extension not in ['pdf', 'docx']:
                return Response({'error': f'Extensión no permitida: {extension}'}, status=400)

            contenido_binario = archivo.read()
            contenido_base64 = base64.b64encode(contenido_binario).decode('utf-8')

            archivo_doc = {
                "tipo": "file",
                "nombre": nombre,
                "extension": f".{extension}",
                "contenido_base64": contenido_base64
            }
            archivos_enviados.append(archivo_doc)

        enlace = request.data.get("enlace")
        if enlace:
            archivos_enviados.append({
                "tipo": "link",
                "url": enlace
            })

        entregas_collection = MongoDBConnection.get_entregas_collection()
        entregas_collection.insert_one({
            "entrega_id": entrega.id,
            "asignacion_id": asignacion.id,
            "estudiante_id": estudiante.id,
            "intento_numero": intento_numero,
            "fecha_subida": timezone.now().isoformat(),
            "archivos": archivos_enviados,
            "estado": "entregado"
        })

        return Response({"mensaje": "Tarea subida correctamente", "intento": intento_numero})


class ConsultarEntregaView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, asignacion_id):
        user = request.user

        try:
            estudiante = Estudiante.objects.get(user=user)
        except Estudiante.DoesNotExist:
            return Response({'error': 'Estudiante no válido'}, status=404)

        entregas_collection = MongoDBConnection.get_entregas_collection()

        entregas = list(entregas_collection.find({
            "asignacion_id": asignacion_id,
            "estudiante_id": estudiante.id
        }))

        if not entregas:
            return Response({'mensaje': 'No se han realizado entregas'}, status=200)

        resultado = []
        for entrega in entregas:
            intento_numero = entrega.get("intento_numero")
    
            entrega_obj = EntregaTarea.objects.filter(
                estudiante=estudiante,
                asignacion_id=asignacion_id,
                intento_numero=intento_numero
            ).first()

            resultado.append({
                '_id': str(entrega['_id']),
                "intento": intento_numero,
                "fecha": entrega.get("fecha_subida"),
                "estado": entrega.get("estado"),
                "archivos": entrega.get("archivos", []),
                "calificacion": entrega_obj.calificacion if entrega_obj else None
            })

        return Response({"entregas": resultado})




class IntentosRestantesView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, asignacion_id):
        user = request.user
        try:
            estudiante = Estudiante.objects.get(user=user)
        except Estudiante.DoesNotExist:
            return Response({'error': 'Estudiante no válido'}, status=404)

        try:
            asignacion = AsignacionTarea.objects.get(id=asignacion_id)
        except AsignacionTarea.DoesNotExist:
            return Response({'error': 'Asignación no encontrada'}, status=404)

        intentos_usados = EntregaTarea.objects.filter(
            asignacion=asignacion, estudiante=estudiante
        ).count()

        intentos_maximos = asignacion.intentos_maximos
        intentos_restantes = max(intentos_maximos - intentos_usados, 0)

        return Response({
            'intentos_usados': intentos_usados,
            'intentos_maximos': intentos_maximos,
            'intentos_restantes': intentos_restantes
        })




class AsignacionesDisponiblesView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            estudiante = Estudiante.objects.get(user=request.user)
        except Estudiante.DoesNotExist:
            return Response({'error': 'Estudiante no válido'}, status=404)

        # Obtener IDs de componentes donde está matriculado activamente
        componentes_matriculados = Matricula.objects.filter(
            estudiante=estudiante,
            activa=True,
            estado__in=['activa', 'confirmada']
        ).values_list('componente_cursado_id', flat=True)

        # Filtrar asignaciones visibles del estudiante
        asignaciones = AsignacionTarea.objects.filter(
            publicada=True,
            componente_id__in=componentes_matriculados
        )

        resultado = []

        for a in asignaciones:
            entregado = EntregaTarea.objects.filter(
                asignacion=a,
                estudiante=estudiante
            ).exists()

            # Buscar calificación final si existe
            nota_final_obj = CalificacionFinalTarea.objects.filter(
                estudiante=estudiante,
                tarea=a
            ).first()

            resultado.append({
                'id': a.id,
                'titulo': a.titulo,
                'descripcion': a.descripcion,
                'fecha_entrega': a.fecha_entrega.isoformat(),
                'intentos_maximos': a.intentos_maximos,
                'entregado': entregado,
                'nota_final': nota_final_obj.nota_final if nota_final_obj else None
            })

        return Response(resultado)






class DescargarArchivoView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, entrega_id, nombre_archivo):
        try:
            client = pymongo.MongoClient('mongodb://localhost:27017/')
            db = client['fine_entregas']
            coleccion = db['archivos_entregas']

            entrega = coleccion.find_one({'_id': ObjectId(entrega_id)})
            if not entrega:
                return Response({'error': 'Entrega no encontrada'}, status=404)

            archivo = next((a for a in entrega.get('archivos', [])
                            if a.get('nombre') == nombre_archivo), None)
            if not archivo:
                return Response({'error': 'Archivo no encontrado'}, status=404)

            contenido_base64 = archivo.get('contenido_base64', '')
            contenido_binario = base64.b64decode(contenido_base64)

            extension = archivo.get('extension', '.pdf').replace('.', '')
            mime_type = 'application/pdf' if extension == 'pdf' else 'application/octet-stream'

            # Detectar si es vista previa
            preview = request.GET.get('preview') == 'true'
            disposition_type = 'inline' if preview else 'attachment'

            response = HttpResponse(contenido_binario, content_type=mime_type)
            response['Content-Disposition'] = f'{disposition_type}; filename="{nombre_archivo}"'
            return response

        except Exception as e:
            return Response({'error': str(e)}, status=500)


class AnunciosEstudianteAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        usuario = request.user

        try:
            estudiante = usuario.perfil_estudiante
        except:
            return Response({'error': 'No autorizado'}, status=403)

        componentes_ids = Matricula.objects.filter(estudiante=estudiante).values_list('componente_cursado_id', flat=True)

        anuncios = Anuncio.objects.filter(
            componente_id__in=componentes_ids,
            publicada=True
        ).order_by('-fecha_creacion')

        resultado = [
            {
                'id': a.id,
                'titulo': a.titulo,
                'fecha_creacion': a.fecha_creacion.isoformat()
            }
            for a in anuncios
        ]

        return Response(resultado)          


class AnuncioDetalleEstudianteAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, anuncio_id):
        usuario = request.user

        try:
            estudiante = usuario.perfil_estudiante
        except AttributeError:
            return Response({'error': 'No autorizado'}, status=403)

        componentes_ids = estudiante.matriculas.values_list('componente_cursado_id', flat=True)

        try:
            anuncio = Anuncio.objects.get(id=anuncio_id, publicada=True)
        except Anuncio.DoesNotExist:
            return Response({'error': 'Anuncio no encontrado'}, status=404)

        if anuncio.componente_id not in componentes_ids:
            return Response({'error': 'No tiene acceso a este anuncio'}, status=403)

        # 🔹 Imágenes
        imagenes = [
            request.build_absolute_uri(img.imagen.url)
            for img in anuncio.imagenes.all()
        ]

        # 🔹 Archivos con enlaces al endpoint personalizado
        archivos_cursor = MongoDBConnection.get_anuncios_collection().find({'anuncio_id': anuncio.id})
        archivos = []
        for archivo in archivos_cursor:
            nombre = archivo.get('nombre', '')
            tipo = archivo.get('tipo', 'pdf')
            url_base = request.build_absolute_uri(
                f"/api/descargar/anuncio/{anuncio.id}/{nombre}"
            )
            archivos.append({
                'nombre': nombre,
                'tipo': tipo,
                'url': url_base
            })

        # 🔹 Enlaces simples
        enlaces_cursor = MongoDBConnection.get_db()["archivos_anuncio"].find({
            'anuncio_id': anuncio.id,
            'tipo': 'link'  
        })
        enlaces = []
        for enlace in enlaces_cursor:
            url = enlace.get('url', '')
            nombre = enlace.get('nombre') or url.split('//')[-1].split('/')[0]  
            enlaces.append({
                'nombre': nombre,
                'url': url
            })


        # 🔹 JSON final
        resultado = {
            'id': anuncio.id,
            'titulo': anuncio.titulo,
            'contenido': anuncio.contenido,
            'imagenes': imagenes,
            'archivos': archivos,
            'enlaces': enlaces,
            'fecha_creacion': anuncio.fecha_creacion.isoformat()
        }

        return Response(resultado)

class DescargarArchivoAnuncioView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, anuncio_id, nombre_archivo):
        try:
            coleccion = MongoDBConnection.get_anuncios_collection()
            
            archivo = coleccion.find_one({
                'anuncio_id': int(anuncio_id),
                'nombre': nombre_archivo
            })

            if not archivo:
                return Response({'error': 'Archivo no encontrado'}, status=404)

            contenido_base64 = archivo.get('contenido_base64', '')
            contenido_binario = base64.b64decode(contenido_base64)

            extension = archivo.get('extension', 'pdf').lower()
            mime_type = 'application/pdf' if extension == 'pdf' else \
                'application/octet-stream'

            preview = request.GET.get('preview') == 'true'
            disposition = 'inline' if preview else 'attachment'

            response = HttpResponse(contenido_binario, content_type=mime_type)
            response['Content-Disposition'] = f'{disposition}; filename="{nombre_archivo}"'
            return response

        except Exception as e:
            return Response({'error': str(e)}, status=500)


class ListarNotificacionesEstudianteView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, estudiante_id):
        try:
            estudiante = Estudiante.objects.get(id=estudiante_id)

            resultado = []

            # Entregas del estudiante
            entregas = EntregaTarea.objects.filter(estudiante=estudiante)

            # Notificaciones vinculadas a entregas
            notifs_entregas = Notificacion.objects.filter(
                detalle__entrega__in=entregas
            ).select_related('detalle__tarea', 'detalle__entrega').order_by('-fecha_hora')

            for notif in notifs_entregas:
                detalle = notif.detalle
                tarea = detalle.tarea
                entrega = detalle.entrega

                resultado.append({
                    "id": notif.id,
                    "tipo": notif.tipo,
                    "descripcion": notif.descripcion,
                    "fecha": localtime(notif.fecha_hora).strftime('%Y-%m-%d %H:%M:%S'),
                    "tarea_titulo": tarea.titulo if tarea else None,
                    "componente": tarea.componente.nombre if tarea else None,
                    "calificacion": entrega.calificacion if entrega else None,
                    "intento_numero": entrega.intento_numero if entrega else None
                })

            # Componentes en los que está matriculado
            componentes = Matricula.objects.filter(
                estudiante=estudiante,
                activa=True,
                estado__in=['activa', 'confirmada']
            ).values_list('componente_cursado', flat=True)

            # Notificaciones por tarea sin entrega asociada
            notifs_tareas = Notificacion.objects.filter(
                tipo__in=['nueva_tarea', 'cambio_fecha'],
                detalle__tarea__componente__in=componentes,
                detalle__entrega__isnull=True  # Asegura que no tenga entrega
            ).select_related('detalle__tarea').order_by('-fecha_hora')

            for notif in notifs_tareas:
                detalle = notif.detalle
                tarea = detalle.tarea

                resultado.append({
                    "id": notif.id,
                    "tipo": notif.tipo,
                    "descripcion": notif.descripcion,
                    "fecha": localtime(notif.fecha_hora).strftime('%Y-%m-%d %H:%M:%S'),
                    "tarea_titulo": tarea.titulo if tarea else None,
                    "componente": tarea.componente.nombre if tarea else None,
                    "calificacion": None,
                    "intento_numero": None
                })

            # Ordenar todas las notificaciones combinadas por fecha
            resultado.sort(key=lambda x: x['fecha'], reverse=True)

            return Response(resultado, status=200)

        except Estudiante.DoesNotExist:
            return Response({"error": "Estudiante no encontrado"}, status=404)
        except Exception as e:
            return Response({"error": str(e)}, status=500)


























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









































        