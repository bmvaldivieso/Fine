from django.urls import path
from .views import CustomTokenObtainPairView,EnviarCodigoVerificacionView,RecivValidateCodView,RegistroCompletoView,NotasView,ComponentesDisponiblesView,CrearMatriculaView,registrar_datos_pago,PerfilEstudianteView,EntregarTareaView,ConsultarEntregaView,IntentosRestantesView,AsignacionesDisponiblesView,DescargarArchivoView  # Asegúrate de importar EspecialidadesView


urlpatterns = [
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
    path('descargar-archivo/<str:entrega_id>/', DescargarArchivoView.as_view(), name='descargar-archivo'),



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


