from django.urls import path

from . import views

"""Namespace dell'applicazione: permette di richiamare gli URL nei template, 
usando la sintassi {% url 'gestionale:nome_url' %}"""
app_name = 'gestionale'

urlpatterns = [
    # Home page dell'applicazione
    path('', views.home, name='home'),
    # Pagina di registrazione per i nuovi passeggeri
    path('registrazione/', views.registrazione_cliente, name='registrazione_cliente'),
    # Ricerca dei voli disponibili con filtri
    path('voli/', views.ricerca_voli, name='ricerca_voli'),
    # Prenotazione di un volo specifico.
    path('voli/<int:volo_id>/prenota/', views.prenota_volo, name='prenota_volo'),
    # Elenco delle prenotazioni effettuate dall'utente loggato
    path('cliente/prenotazioni/', views.prenotazioni_cliente, name='prenotazioni_cliente'),
    # Visualizzazione dei voli dal punto di vista gestionale
    path('operatore/voli/', views.lista_voli_operatore, name='lista_voli_operatore'),
    # Modifica dei dettagli di un volo
    path('operatore/voli/<int:volo_id>/modifica/', views.modifica_volo, name='modifica_volo'),
    # Registrazione di un bagaglio al check-in
    path('operatore/bagagli/nuovo/', views.registra_bagaglio, name='registra_bagaglio'),
    # Pagina pubblica per visualizzare il tabellone dei voli (stile aeroporto)
    path('tabellone/', views.tabellone, name='tabellone'),
    # Endpoint API per aggiornare il tabellone
    path('api/tabellone/', views.api_tabellone, name='api_tabellone'),
    # Pagina dell'operatore
    path('operatore/', views.dashboard_operatore, name='dashboard_operatore'),
    # Profilo dopo login
    path('profilo/', views.profilo, name='profilo'),

]
