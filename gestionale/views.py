from django.contrib import messages
from django.contrib.auth import login
from django.contrib.auth.decorators import login_required
from django.db import IntegrityError
from django.http import JsonResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.utils import timezone
from datetime import timedelta
import random


from .forms import (
    BagaglioForm,
    GestioneVoloForm,
    PrenotazioneForm,
    RegistrazionePasseggeroForm,
    RicercaVoliForm,
)
from .models import Aeroporto, Bagaglio, Gestione_Volo, Operatore, Passeggero, Prenotazione, Volo

# FUNZIONI UTILITY
def passeggero_corrente(user):
    # profilo Passeggero associato all'utente loggato.
    return Passeggero.objects.filter(id_user=user).first()

def operatore_corrente(user):
    # profilo Operatore associato all'utente loggato
    return Operatore.objects.filter(id_user=user).first()

def aggiorna_stati_voli():
    adesso = timezone.now()

    voli = Volo.objects.exclude(stato='cancellato')

    for volo in voli:
        orario_effettivo = volo.orario_partenza + timedelta(minutes=volo.ritardo_minuti)

        if adesso >= orario_effettivo + timedelta(minutes=10):
            nuovo_stato = 'partito'
        elif adesso >= orario_effettivo - timedelta(minutes=30):
            nuovo_stato = 'imbarco'
        elif volo.ritardo_minuti > 0:
            nuovo_stato = 'in_ritardo'
        else:
            nuovo_stato = 'in_orario'

        if volo.stato != nuovo_stato:
            volo.stato = nuovo_stato
            volo.save(update_fields=['stato'])

def simula_ritardi_voli():
    adesso = timezone.now()
    finestra = adesso + timedelta(hours=4)

    voli = Volo.objects.filter(
        orario_partenza__gte=adesso,
        orario_partenza__lte=finestra,
        stato='in_orario',
        ritardo_minuti=0,
    )

    for volo in voli:
        if random.random() < 0.08:
            volo.ritardo_minuti = random.choice([10, 15, 20, 30, 45])
            volo.save(update_fields=['ritardo_minuti'])


# VIEW PUBBLICHE
def home(request):
    aggiorna_stati_voli()
    voli = (
        Volo.objects
        .select_related('codice_gate', 'destinazione')
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
    form = RicercaVoliForm(request.GET or None)

    voli = (
        Volo.objects
        .select_related(
            'partenza',
            'destinazione',
            'id_aereo',
            'id_aereo__codice_vettore',
        )
        .order_by('orario_partenza')
    )

    if form.is_valid():
        partenza = form.cleaned_data.get('partenza')
        destinazione = form.cleaned_data.get('destinazione')
        data_partenza = form.cleaned_data.get('data_partenza')

        if partenza:
            aeroporti_partenza = Aeroporto.objects.filter(
                citta__icontains=partenza
            ) | Aeroporto.objects.filter(
                nome_aeroporto__icontains=partenza
            ) | Aeroporto.objects.filter(
                codice_iata__iexact=partenza
            )

            voli = voli.filter(partenza__in=aeroporti_partenza)

        if destinazione:
            aeroporti_destinazione = Aeroporto.objects.filter(
                citta__icontains=destinazione
            ) | Aeroporto.objects.filter(
                nome_aeroporto__icontains=destinazione
            ) | Aeroporto.objects.filter(
                codice_iata__iexact=destinazione
            )

            voli = voli.filter(destinazione__in=aeroporti_destinazione)

        if data_partenza:
            voli = voli.filter(orario_partenza__date=data_partenza)

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
        .select_related('codice_gate', 'id_aereo', 'destinazione')
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
    simula_ritardi_voli()
    aggiorna_stati_voli()
    return render(request, 'gestionale/tabellone.html')


def api_tabellone(request):
    #Restituisce i dati dei voli in formato JSON per l'aggiornamento dinamico del tabellone
    simula_ritardi_voli()
    aggiorna_stati_voli()

    adesso = timezone.now()
    inizio_giorno = adesso.replace(hour=0, minute=0, second=0, microsecond=0)
    fine_giorno = inizio_giorno + timedelta(days=1)

    limite_vecchi = adesso - timedelta(minutes=20)

    voli = (
        Volo.objects
        .select_related('partenza', 'destinazione', 'codice_gate')
        .filter(
            orario_partenza__gte=inizio_giorno,
            orario_partenza__lt=fine_giorno,
        )
        .exclude(
            stato='cancellato'
        )
        .exclude(
            stato='partito',
            orario_partenza__lt=limite_vecchi
        )
        .order_by('orario_partenza')[:30]
    )

    data = []

    for volo in voli:
        orario_stimato = volo.orario_partenza + timedelta(minutes=volo.ritardo_minuti)

        data.append({
            'numero_volo': volo.numero_volo,
            'partenza': f'{volo.partenza.citta} - {volo.partenza.codice_iata}',
            'destinazione': f'{volo.destinazione.citta} - {volo.destinazione.codice_iata}',
            'orario_partenza': timezone.localtime(volo.orario_partenza).strftime('%H:%M'),
            'orario_stimato': timezone.localtime(orario_stimato).strftime('%H:%M'),
            'ritardo_minuti': volo.ritardo_minuti,
            'gate': volo.codice_gate.codice_gate if volo.codice_gate else '-',
            'stato': volo.stato,
            'stato_label': volo.get_stato_display(),
        })

    return JsonResponse({
        'voli': data,
    })

