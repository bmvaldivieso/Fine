from django.contrib import admin
from .models import *

admin.site.register(Estudiante)
admin.site.register(Representante)
admin.site.register(CodigoVerificacionEmail)
admin.site.register(Matricula)
admin.site.register(Nota)
admin.site.register(Componente)
admin.site.register(DatosPagoMatricula)
admin.site.register(Docente)
admin.site.register(EntregaTarea)
admin.site.register(AsignacionDocenteComponente)
admin.site.register(CalificacionFinalTarea)
admin.site.register(Anuncio)
admin.site.register(ImagenAnuncio)
admin.site.register(ComentarioAnuncio)
admin.site.register(PublicacionNotas)
admin.site.register(Administrador)
admin.site.register(Notificacion)
admin.site.register(DetalleNotificacion)

#admin.site.register(AsignacionTarea)
@admin.register(AsignacionTarea)
class AsignacionTareaAdmin(admin.ModelAdmin):
    list_display = ('titulo', 'componente', 'docente', 'fecha_entrega', 'publicada')
    list_filter = ('componente', 'docente', 'publicada')
    search_fields = ('titulo', 'descripcion')
