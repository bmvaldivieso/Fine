from mySql.models import Notificacion, DetalleNotificacion

def crear_notificacion(autor, tipo, descripcion, tarea=None, entrega=None):
    notificacion = Notificacion.objects.create(
        autor=autor,
        tipo=tipo,
        descripcion=descripcion
    )
    DetalleNotificacion.objects.create(
        notificacion=notificacion,
        tarea=tarea,
        entrega=entrega
    )
