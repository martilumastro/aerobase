from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    # Interfaccia di amministrazione predefinita di Django
    path('admin/', admin.site.urls),
    # Gestione login, logout e reset password con view Django
    path('accounts/', include('django.contrib.auth.urls')),
    # Delega le altre richieste a gestionale
    path('', include('gestionale.urls')),
]

