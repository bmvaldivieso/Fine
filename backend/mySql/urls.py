from django.urls import path
from .views import CustomTokenObtainPairView,DatosMongoView,normalDatosMongoView,EnviarCodigoVerificacionView,RecivValidateCodView,RegistroCompletoView,NotasView # Asegúrate de importar EspecialidadesView


urlpatterns = [
    path('token/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('cod/', EnviarCodigoVerificacionView.as_view(), name='cod_verificacion'),
    path('mongoNormal/', normalDatosMongoView.as_view(), name='datos_mongo'),
    path('verif/', RecivValidateCodView.as_view(), name='reciv_cod'),
    path('registro/', RegistroCompletoView.as_view(), name='registro_completo'),
    path('notas/', NotasView.as_view(), name='ver-notas'),
    path('mongo/', DatosMongoView.as_view(), name='datos_mongo'),

    
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


