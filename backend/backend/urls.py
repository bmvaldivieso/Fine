from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('mySql.urls')),
    path('', include('mySql.urls')),
]
