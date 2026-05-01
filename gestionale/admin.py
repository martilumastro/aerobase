from django.contrib import admin

# Importazione di tutti i modelli definiti nell'app gestionale
from .models import (
    Aereo,
    Aeroporto,
    Bagaglio,
    Compagnia_Aerea,
    Gate,
    Gestione_Volo,
    Operatore,
    Passeggero,
    Prenotazione,
    Volo,
)

# Personalizzazione Aeroporto
@admin.register(Aeroporto)
class AeroportoAdmin(admin.ModelAdmin):
    list_display = ('codice_iata', 'nome_aeroporto', 'citta', 'nazione', 'codice_icao')
    search_fields = ('codice_iata', 'nome_aeroporto', 'citta', 'nazione')
    list_filter = ('nazione', 'citta')

# Personalizzazione Volo
@admin.register(Volo)
class VoloAdmin(admin.ModelAdmin):
    list_display = ('numero_volo', 'destinazione', 'orario_partenza', 'stato', 'id_aereo')
    list_filter = ('stato', 'destinazione', 'orario_partenza')
    search_fields = (
        'numero_volo',
        'destinazione__codice_iata',
        'destinazione__citta',
        'destinazione__nome_aeroporto',
    )
    ordering = ('orario_partenza',)


# Personalizzazione Passeggero
@admin.register(Passeggero)
class PasseggeroAdmin(admin.ModelAdmin):
    list_display = ('username', 'cognome', 'nome', 'email', 'nazionalita')
    search_fields = ('username', 'cognome', 'email')

# Personalizzazione Prenotazione per vedere i posti occupati
@admin.register(Prenotazione)
class PrenotazioneAdmin(admin.ModelAdmin):
    list_display = ('username_passeggero', 'id_volo', 'posto', 'classe', 'data_acquisto')
    list_filter = ('classe', 'data_acquisto')
    # Ricerca per nome del passeggero o per numero volo
    search_fields = ('username_passeggero__cognome', 'id_volo__numero_volo')


# Registrazione semplice per gli altri modelli
admin.site.register(Compagnia_Aerea)
admin.site.register(Aereo)
admin.site.register(Gate)
admin.site.register(Operatore)
admin.site.register(Gestione_Volo)
admin.site.register(Bagaglio)

