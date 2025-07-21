from django.urls import path
from .views import CustomTokenObtainPairView,EnviarCodigoVerificacionView,RecivValidateCodView,RegistroCompletoView,NotasView,ComponentesDisponiblesView,CrearMatriculaView,registrar_datos_pago,PerfilEstudianteView,EntregarTareaView,ConsultarEntregaView,IntentosRestantesView,AsignacionesDisponiblesView,DescargarArchivoView,login_docente_view,docente_redirect,docentes_bienvenida,logout_docente_view,componentes_docente,tareas_componente,crear_tarea,editar_tarea,eliminar_tarea,calificar_entrega,obtener_archivos_entrega,descargar_archivo_mongo,ver_pdf_mongo,lista_estudiantes_entregaron,entregas_estudiante_tarea  # Asegúrate de importar EspecialidadesView
from .views import componentes_docente_anuncio, anuncios_por_componente, crear_anuncio, editar_anuncio, eliminar_anuncio, eliminar_adjunto_anuncio, eliminar_imagen_anuncio
from .views import AnunciosEstudianteAPIView, AnuncioDetalleEstudianteAPIView, DescargarArchivoAnuncioView
from .views import componentes_docente_notas, estudiantes_componente_notas, editar_nota_notas
from .views import lista_habilitar_notas, info_estudiantes, listado_docentes,login_administrador_view,administrador_redirect,administrador_bienvenida,logout_administrador_view
from .views import administrador_habilitar_notas, administrador_crear_publicacion

urlpatterns = [
    #flutter
    path('token/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('cod/', EnviarCodigoVerificacionView.as_view(), name='cod_verificacion'), 
    path('verif/', RecivValidateCodView.as_view(), name='reciv_cod'),
    path('registro/', RegistroCompletoView.as_view(), name='registro_completo'),
    path('componentes/', ComponentesDisponiblesView.as_view(), name='componentes_disponibles'),
    path('matricula/', CrearMatriculaView.as_view(), name='crear_matricula'),
    path('datos-pago/', registrar_datos_pago),
    path('estudiante/perfil/', PerfilEstudianteView.as_view(), name='perfil-estudiante'),
    path('notas/', NotasView.as_view(), name='notas'),
    path('asignaciones/<int:asignacion_id>/entregar/', EntregarTareaView.as_view(), name='entregar-tarea'),
    path('asignaciones/<int:asignacion_id>/entrega/', ConsultarEntregaView.as_view(), name='consultar-entrega'),
    path('asignaciones/<int:asignacion_id>/intentos/', IntentosRestantesView.as_view(), name='intentos-restantes'),
    path('asignaciones/', AsignacionesDisponiblesView.as_view(), name='asignaciones-disponibles'),
    path('descargar/<str:entrega_id>/<str:nombre_archivo>/', DescargarArchivoView.as_view()),
    #anuncios-estudiantes
    path('api/estudiante/anuncios/', AnunciosEstudianteAPIView.as_view(), name='anuncios_estudiante_view'),
    path('api/estudiante/anuncio/<str:anuncio_id>/', AnuncioDetalleEstudianteAPIView.as_view(), name='anuncio_detalle_estudiante'),
    path('api/descargar/anuncio/<str:anuncio_id>/<str:nombre_archivo>/', DescargarArchivoAnuncioView.as_view(), name='descargar_archivo_anuncio'),



    #docentes
    path('', login_docente_view, name='docente_login'),
    path('docente/', docente_redirect, name='docente_redirect'),
    path('docente/bienvenida/', docentes_bienvenida, name='docente_bienvenida'),
    path('logout-docente/', logout_docente_view, name='logout_docente'),
    path('docente/componentes/', componentes_docente, name='componentes_docente'),
    path('docente/componente/<int:componente_id>/tareas/', tareas_componente, name='tareas_componente'),
    path('docente/componente/<int:componente_id>/tareas/crear/', crear_tarea, name='crear_tarea'),
    path('docente/tarea/<int:tarea_id>/editar/', editar_tarea, name='editar_tarea'),
    path('docente/tarea/<int:tarea_id>/eliminar/', eliminar_tarea, name='eliminar_tarea'),
    path('docente/entrega/<int:entrega_id>/calificar/', calificar_entrega, name='calificar_entrega'),
    path('docente/entrega/<int:entrega_id>/archivos/', obtener_archivos_entrega, name='obtener_archivos_entrega'),
    path('docente/entrega/<int:entrega_id>/ver/<str:nombre>/', ver_pdf_mongo, name='ver_pdf_mongo'),
    path('docente/entrega/<int:entrega_id>/descargar/<str:nombre>/', descargar_archivo_mongo, name='descargar_archivo_mongo'),
    path('docente/tarea/<int:tarea_id>/entregantes/', lista_estudiantes_entregaron, name='lista_estudiantes_entregaron'),
    path('docente/tarea/<int:tarea_id>/estudiante/<int:estudiante_id>/entregas/', entregas_estudiante_tarea, name='entregas_estudiante_tarea'),
    # docentes-anuncios
    path('docente/componentes_anuncios/', componentes_docente_anuncio, name='componentes_docente_anuncio'),
    path('docente/componente/<int:componente_id>/anuncios/', anuncios_por_componente, name='anuncios_por_componente'),
    path('docente/componente/<int:componente_id>/anuncios/crear/', crear_anuncio, name='crear_anuncio'),
    path('docente/anuncio/<int:anuncio_id>/editar/', editar_anuncio, name='editar_anuncio'),
    path('docente/componente/<int:anuncio_id>/anuncios/eliminar-adjunto/', eliminar_adjunto_anuncio, name='eliminar_adjunto_anuncio'),
    path('docente/anuncio/<int:anuncio_id>/eliminar-imagen/', eliminar_imagen_anuncio, name='eliminar_imagen_anuncio'),
    path('docente/anuncio/<int:anuncio_id>/eliminar/', eliminar_anuncio, name='eliminar_anuncio'),
    #docente-notas
    path('docente/componentes_notas/', componentes_docente_notas, name='componentes_docente_notas'),
    path('docente/componente/<int:componente_id>/notas/', estudiantes_componente_notas, name='estudiantes_componente_notas'),
    path('docente/notas/editar/<int:estudiante_id>/<int:componente_id>/', editar_nota_notas, name='editar_nota_notas'),


    #administardor
    path('administrador/lista_habilitar_notas/', lista_habilitar_notas, name='lista_habilitar_notas'),
    path('administrador/info_estudiantes/', info_estudiantes, name='info_estudiantes'),
    path('administrador/listado_docentes/', listado_docentes, name='listado_docentes'),
    path('administrador/login/', login_administrador_view, name='administrador_login'),
    path('administrador/logout/', logout_administrador_view, name='administrador_logout'),
    path('administrador/bienvenida/', administrador_bienvenida, name='administrador_bienvenida'),
    path('administrador/redirect/', administrador_redirect, name='administrador_redirect'),
    path('administrador/habilitar_notas/<int:componente_id>/', administrador_habilitar_notas, name='administrador_habilitar_notas'),
    path('administrador/crear_publicacion/', administrador_crear_publicacion, name='administrador_crear_publicacion'),






    #path('mongoNormal/', normalDatosMongoView.as_view(), name='datos_mongo'),
    #path('mongo/', DatosMongoView.as_view(), name='datos_mongo'),

    #path('user-info/', UserInfoView.as_view(), name='user_info'),
    #path('admin/', AdminView.as_view(), name='admin_view'),
    #path('updateEspecialista/', UpdateEspecialista.as_view(), name='datos_mongo'),
    #path('postEspeCreate/', AdminPostCreate.as_view(), name='datos_mongo'),
    #path('postEspeDeleted/', deletedEspecialista.as_view(), name='datos_mongo'),
    #path('personAdmin/', personAdmin.as_view(), name='datos_mongo'),
    #path('citasAdmin/', citasAdmin.as_view(), name='datos_mongo'),
    #path('normalpersonView/', normalpersonView.as_view(), name='datos_mongo'),
    #path('horariosGet/', horarios.as_view(), name='datos_mongo'),
    #path('horariosNormales/', horariosNormales.as_view(), name='datos_mongo'),
    #path('deleEspecialidad/', deletedEspecialidad.as_view(), name='datos_mongo'),
    #path('updateEspecialidad/',  UpdateEspecialidad.as_view(), name='datos_mongo'),
    #path('InsertEspecialidad/',  InsertEspecialidad.as_view(), name='datos_mongo'),
    #path('citasNormales/',  CitasNormales.as_view(), name='datos_mongo'),
    #path('citasNormalesDeleted/', citasNormalesDeleted.as_view(), name='datos_mongo'),
    #path('addHoras/', addHoras.as_view(), name='datos_mongo'),
    #path('deltedHorarios/', deltedHorarios.as_view(), name='datos_mongo'),
    
] 


