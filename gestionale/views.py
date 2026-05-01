from django.contrib import messages
from django.contrib.auth import login
from django.contrib.auth.decorators import login_required
from django.db import IntegrityError
from django.http import JsonResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.utils import timezone

from .forms import (
    BagaglioForm,
    GestioneVoloForm,
    PrenotazioneForm,
    RegistrazionePasseggeroForm,
    RicercaVoliForm,
)
from .models import Bagaglio, Gestione_Volo, Operatore, Passeggero, Prenotazione, Volo

# FUNZIONI UTILITY
def passeggero_corrente(user):
    # profilo Passeggero associato all'utente loggato.
    return Passeggero.objects.filter(id_user=user).first()

def operatore_corrente(user):
    # profilo Operatore associato all'utente loggato
    return Operatore.objects.filter(id_user=user).first()

# VIEW PUBBLICHE
def home(request):
    # Visualizza i primi 8 voli in partenza nella home page.
    voli = (
        Volo.objects
        .select_related('codice_gate', 'id_aereo')
        .order_by('orario_partenza')[:8]
    )

    return render(request, 'gestionale/home.html', {
        'voli': voli,
    })


def registrazione_cliente(request):
    # Gestione creazione nuovo account passeggero.
    if request.method == 'POST':
        form = RegistrazionePasseggeroForm(request.POST)

        if form.is_valid():
            user = form.save()
            # login automatico dopo la registrazione
            login(request, user)
            messages.success(request, 'Registrazione completata.')
            return redirect('gestionale:ricerca_voli')
    else:
        form = RegistrazionePasseggeroForm()

    return render(request, 'gestionale/registrazione_cliente.html', {
        'form': form,
    })


def ricerca_voli(request):
    # Filtro voli per destinazione, data e stato,
    # Non modifico database --> GET
    form = RicercaVoliForm(request.GET or None)

    voli = (
        Volo.objects
        .select_related('id_aereo', 'codice_gate')
        .order_by('orario_partenza')
    )

    if form.is_valid():
        destinazione = form.cleaned_data.get('destinazione')
        data_partenza = form.cleaned_data.get('data_partenza')
        stato = form.cleaned_data.get('stato')

        if destinazione:
            # iexact = case insensitive
            voli = voli.filter(destinazione__iexact=destinazione)

        if data_partenza:
            voli = voli.filter(orario_partenza__date=data_partenza)

        if stato:
            voli = voli.filter(stato=stato)

    return render(request, 'gestionale/ricerca_voli.html', {
        'form': form,
        'voli': voli,
    })

#VIEW AREA CLIENTE (Richiedono Login)
@login_required
def prenota_volo(request, volo_id):
    # Gestione prenotazione di un posto su un volo specifico.
    passeggero = passeggero_corrente(request.user)

    if not passeggero:
        messages.error(request, 'Solo i clienti possono prenotare voli.')
        return redirect('gestionale:ricerca_voli')

    volo = get_object_or_404(Volo, pk=volo_id)

    if request.method == 'POST':
        form = PrenotazioneForm(request.POST)

        if form.is_valid():
            prenotazione = form.save(commit=False)
            prenotazione.username_passeggero = passeggero
            prenotazione.id_volo = volo

            try:
                prenotazione.save()
            except IntegrityError:
                # Gestione eventuale prenotazione doppia di un volo
                messages.error(request, 'Hai gia una prenotazione per questo volo.')
            else:
                messages.success(request, 'Prenotazione registrata.')
                return redirect('gestionale:prenotazioni_cliente')
    else:
        form = PrenotazioneForm()

    return render(request, 'gestionale/prenota_volo.html', {
        'form': form,
        'volo': volo,
    })


@login_required
def prenotazioni_cliente(request):
    # Mostra storico delle prenotazioni dell'utente loggato.
    passeggero = passeggero_corrente(request.user)

    if not passeggero:
        messages.error(request, 'Area riservata ai clienti.')
        return redirect('gestionale:home')

    prenotazioni = (
        Prenotazione.objects
        .filter(username_passeggero=passeggero)
        .select_related('id_volo', 'id_volo__codice_gate')
        .order_by('-data_acquisto')
    )

    return render(request, 'gestionale/prenotazioni_cliente.html', {
        'prenotazioni': prenotazioni,
    })

# VIEW AREA OPERATORE (Gestione)
@login_required
# Elenco voli per lo staff con permessi di admin o operatore_voli
def lista_voli_operatore(request):
    operatore = operatore_corrente(request.user)

    if not operatore or operatore.ruolo not in ('admin', 'operatore_voli'):
        messages.error(request, 'Area riservata agli operatori voli.')
        return redirect('gestionale:home')

    voli = (
        Volo.objects
        .select_related('id_aereo', 'codice_gate')
        .order_by('orario_partenza')
    )

    return render(request, 'gestionale/lista_voli_operatore.html', {
        'voli': voli,
    })


@login_required
def modifica_volo(request, volo_id):
    # Modifica stato/orari di un volo e logga l'operazione.
    operatore = operatore_corrente(request.user)

    if not operatore or operatore.ruolo not in ('admin', 'operatore_voli'):
        messages.error(request, 'Area riservata agli operatori voli.')
        return redirect('gestionale:home')
    
    volo = get_object_or_404(Volo, pk=volo_id)

    if request.method == 'POST':
        form = GestioneVoloForm(request.POST, instance=volo)
        if form.is_valid():
            form.save()
            # Registra chi ha fatto la modifica e quando in Gestione_Volo
            Gestione_Volo.objects.update_or_create(
                codice_operatore=operatore,
                id_volo=volo,
                defaults={
                    'timestamp_modifica': timezone.now(),
                    'tipo_operazione': 'modifica_stato',
                },
            )

            messages.success(request, 'Volo aggiornato.')
            return redirect('gestionale:lista_voli_operatore')
    else:
        form = GestioneVoloForm(instance=volo)

    return render(request, 'gestionale/modifica_volo.html', {
        'form': form,
        'volo': volo,
    })


@login_required
def registra_bagaglio(request):
    # Gestisce l'accettazione dei bagagli al check-in.
    operatore = operatore_corrente(request.user)

    if not operatore or operatore.ruolo not in ('admin', 'operatore_bagagli'):
        messages.error(request, 'Area riservata agli operatori bagagli.')
        return redirect('gestionale:home')

    if request.method == 'POST':
        form = BagaglioForm(request.POST)

        if form.is_valid():
            bagaglio = form.save(commit=False)
            bagaglio.codice_operatore = operatore
            bagaglio.save()

            messages.success(request, 'Bagaglio registrato.')
            return redirect('gestionale:registra_bagaglio')
    else:
        form = BagaglioForm()

    bagagli = (
        Bagaglio.objects
        .select_related('prenotazione_passeggero', 'prenotazione_volo')
        .order_by('-id_bagaglio')[:20]
    )

    return render(request, 'gestionale/registra_bagaglio.html', {
        'form': form,
        'bagagli': bagagli,
    })

# VIEW REAL-TIME (Tabellone Aeroporto)
def tabellone(request):
    # Renderizza la pagina statica del tabellone (dati caricati via API)
    return render(request, 'gestionale/tabellone.html')


def api_tabellone(request):
    #Restituisce i dati dei voli in formato JSON per l'aggiornamento dinamico del tabellone
    voli = (
        Volo.objects
        .select_related('codice_gate')
        .order_by('orario_partenza')[:30]
    )

    data = []

    for volo in voli:
        data.append({
            'numero_volo': volo.numero_volo,
            'destinazione': volo.destinazione,
            'orario_partenza': timezone.localtime(volo.orario_partenza).strftime('%H:%M'),
            'orario_arrivo': timezone.localtime(volo.orario_arrivo).strftime('%H:%M'),
            'gate': volo.codice_gate.codice_gate if volo.codice_gate else '-',
            'stato': volo.get_stato_display(),
        })

    return JsonResponse({
        'voli': data,
    })

