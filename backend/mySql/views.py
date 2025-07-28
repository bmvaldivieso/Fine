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




# Matricula Componente nombre
class MatriculaComponenteView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            # Buscar el perfil del estudiante vinculado al usuario autenticado
            estudiante = Estudiante.objects.get(user=request.user)

            # Buscar matrícula activa asociada al estudiante
            matricula = Matricula.objects.filter(estudiante=estudiante, activa=True).first()

            if not matricula or not matricula.componente_cursado:
                return Response(
                    {"mensaje": "No se encontró matrícula activa ni componente asociado."},
                    status=status.HTTP_404_NOT_FOUND
                )

            componente_nombre = matricula.componente_cursado.nombre
            return Response(
                {"componente": componente_nombre},
                status=status.HTTP_200_OK
            )

        except Estudiante.DoesNotExist:
            return Response(
                {"error": "Estudiante no encontrado para el usuario actual."},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {"error": f"Ocurrió un error: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )








































        