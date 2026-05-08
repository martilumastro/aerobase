import random
import uuid

from django.contrib import messages
from django.contrib.auth import login
from django.contrib.auth.decorators import login_required
from django.db import IntegrityError
from django.http import JsonResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.utils import timezone
from datetime import timedelta
from django.db.models import Q
from django.db.models import Count
from django.contrib.auth.models import User
from django.db import connection

from .forms import (
    BagaglioForm,
    GestioneVoloForm,
    PrenotazioneForm,
    RegistrazionePasseggeroForm,
    RicercaVoliForm,
    ProfiloOperatoreForm,
    ProfiloPasseggeroForm,

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


@login_required
def profilo(request):
    operatore = operatore_corrente(request.user)

    if operatore:
        return redirect('gestionale:profilo_operatore')

    return redirect('gestionale:profilo_cliente')

@login_required
def dopo_login(request):
    operatore = operatore_corrente(request.user)

    if operatore:
        return redirect('gestionale:dashboard_operatore')

    return redirect('gestionale:prenotazioni_cliente')


@login_required
def checkout_view(request, username, volo_id):
    with connection.cursor() as cursor:
        # 1. Recuperiamo i dati usando username e volo_id (2 parametri = 2 %s)
        query = """
            SELECT p.id_prenotazione, v.numero_volo, v.prezzo, v.partenza, v.destinazione, p.username_passeggero
            FROM Prenotazione p
            JOIN Volo v ON p.id_volo = v.id_volo
            WHERE p.username_passeggero = %s AND p.id_volo = %s
        """
        cursor.execute(query, [username, volo_id])
        dati_checkout = cursor.fetchone()

    # Controllo sicurezza: la prenotazione esiste ed è dell'utente loggato?
    if not dati_checkout or dati_checkout[5] != request.user.username:
        messages.error(request, "Accesso non autorizzato o prenotazione non trovata.")
        return redirect('gestionale:ricerca_voli')

    # ESTRAIAMO l'ID REALE della prenotazione dai risultati della query
    id_prenotazione = dati_checkout[0]

    if request.method == 'POST':
        intestatario = request.POST.get('intestatario')
        numero_carta = request.POST.get('numero_carta')
        scadenza = request.POST.get('scadenza')
        salva_carta = request.POST.get('salva_carta')

        # Simulazione dati pagamento
        id_transazione_fittizio = f"TXN-{uuid.uuid4().hex[:10].upper()}"
        ultime_4 = numero_carta[-4:] if numero_carta else "0000"
        
        try:
            mese, anno = scadenza.split('/')
        except ValueError:
            mese, anno = "01", "30"

        with connection.cursor() as cursor:
            # Recuperiamo info per le FK della transazione usando l'ID estratto sopra
            cursor.execute("SELECT username_passeggero, id_volo FROM Prenotazione WHERE id_prenotazione = %s", [id_prenotazione])
            p_info = cursor.fetchone()
            
            # INSERT Transazione
            cursor.execute("""
                INSERT INTO Transazione (username_passeggero, id_volo, importo, id_transazione_esterno, metodo_usato, stato)
                VALUES (%s, %s, %s, %s, %s, 'completato')
            """, [p_info[0], p_info[1], dati_checkout[2], id_transazione_fittizio, f"Visa **** {ultime_4}"])

            # UPDATE Prenotazione: la segniamo come pagata
            cursor.execute("UPDATE Prenotazione SET stato_pagamento = 'pagato' WHERE id_prenotazione = %s", [id_prenotazione])

            # INSERT Metodo_Pagamento (se l'utente ha spuntato "salva carta")
            if salva_carta:
                cursor.execute("""
                    INSERT INTO Metodo_Pagamento (username_passeggero, intestatario, ultime_cifre, mese_scadenza, anno_scadenza, token_pagamento)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, [p_info[0], intestatario, ultime_4, mese, anno, "TOKEN_TEST"])

        return render(request, 'gestionale/pagamento_successo.html', {'txn_id': id_transazione_fittizio})

    # Passiamo 'dati_checkout' al template così puoi usare {{ volo.1 }}, {{ volo.2 }}, ecc.
    return render(request, 'gestionale/checkout.html', {'volo': dati_checkout})

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
    passeggero = passeggero_corrente(request.user)

    if not passeggero:
        messages.error(request, 'Solo i clienti possono prenotare voli.')
        return redirect('gestionale:ricerca_voli')

    volo = get_object_or_404(Volo, pk=volo_id)

    if request.method == 'POST':
        form = PrenotazioneForm(request.POST, volo=volo)

        if form.is_valid():
            prenotazione = form.save(commit=False)
            prenotazione.username_passeggero = passeggero
            prenotazione.id_volo = volo

            try:
                prenotazione.save()

                bagagli_da_creare = []

                for _ in range(form.cleaned_data.get('bagagli_cabina') or 0):
                    bagagli_da_creare.append(Bagaglio(
                        passeggero=passeggero,
                        volo=volo,
                        tipo='cabina',
                        stato='prenotato'
                    ))

                for _ in range(form.cleaned_data.get('bagagli_stiva') or 0):
                    bagagli_da_creare.append(Bagaglio(
                        passeggero=passeggero,
                        volo=volo,
                        tipo='stiva',
                        stato='prenotato'
                    ))

                for _ in range(form.cleaned_data.get('bagagli_speciali') or 0):
                    bagagli_da_creare.append(Bagaglio(
                        passeggero=passeggero,
                        volo=volo,
                        tipo='speciale',
                        stato='prenotato'
                    ))

                if bagagli_da_creare:
                    Bagaglio.objects.bulk_create(bagagli_da_creare)

            except IntegrityError:
                messages.error(request, 'Hai già una prenotazione per questo volo.')
            else:
                messages.success(request, 'Procedi al pagamento per confermare la prenotazione.')
                return redirect('gestionale:checkout', username=passeggero.username, volo_id=volo.id_volo)
    else:
        form = PrenotazioneForm(volo=volo)

    return render(request, 'gestionale/prenota_volo.html', {
        'form': form,
        'volo': volo
    })


@login_required
def prenotazioni_cliente(request):
    # Identificazione il passeggero
    passeggero = passeggero_corrente(request.user)
    
    if not passeggero:
        messages.error(request, 'Area riservata ai clienti.')
        return redirect('gestionale:home')

    # Query per le prenotazioni
    prenotazioni = (
        Prenotazione.objects
        .filter(username_passeggero=passeggero)
        .select_related('id_volo', 'id_volo__codice_gate')
        .order_by('-data_acquisto')
    )

    # Recupero bagagli notifiche
    bagagli_alert = Bagaglio.objects.filter(
    passeggero=passeggero,
    stato__in=['smarrito', 'ritrovato']
    )

    return render(request, 'gestionale/prenotazioni_cliente.html', {
        'prenotazioni': prenotazioni,
        'passeggero': passeggero,
        'bagagli_speciali': bagagli_alert,
    })


@login_required
def dashboard_cliente(request):
    passeggero = passeggero_corrente(request.user)

    if not passeggero:
        messages.error(request, 'Area riservata ai clienti.')
        return redirect('gestionale:home')

    bagagli = Bagaglio.objects.filter(passeggero=passeggero)
    avvisi_bagagli = bagagli.filter(stato__in=['smarrito', 'ritrovato'])

    return render(request, 'gestionale/dashboard_cliente.html', {
        'bagagli': bagagli,
        'avvisi': avvisi_bagagli
    })

@login_required
def profilo_cliente(request):
    passeggero = passeggero_corrente(request.user)

    if not passeggero:
        messages.error(request, 'Area riservata ai clienti.')
        return redirect('gestionale:home')

    if request.method == 'POST':
        form = ProfiloPasseggeroForm(request.POST, instance=passeggero)

        if form.is_valid():
            profilo = form.save()
            request.user.email = profilo.email
            request.user.save(update_fields=['email'])

            messages.success(request, 'Profilo aggiornato correttamente.')
            return redirect('gestionale:profilo_cliente')
    else:
        form = ProfiloPasseggeroForm(instance=passeggero)

    return render(request, 'gestionale/profilo_cliente.html', {
        'form': form,
        'passeggero': passeggero,
    })


# VIEW AREA OPERATORE (Gestione)
@login_required
def dashboard_operatore(request):
    operatore = operatore_corrente(request.user)

    if not operatore:
        messages.error(request, 'Area riservata agli operatori.')
        return redirect('gestionale:home')

    mio_aeroporto = operatore.aeroporto
    
    # Conteggi rapidi per le "Cards"
    # Q per i ritardi totali (sia arrivi che partenze)
    partenze_count = Volo.objects.filter(partenza=mio_aeroporto).count()
    arrivi_count = Volo.objects.filter(destinazione=mio_aeroporto).count()
    ritardi_count = Volo.objects.filter(
        Q(partenza=mio_aeroporto) | Q(destinazione=mio_aeroporto),
        ritardo_minuti__gt=0
    ).count()

    return render(request, 'gestionale/dashboard_operatore.html', {
        'operatore': operatore,
        'partenze': partenze_count,
        'arrivi': arrivi_count,
        'ritardi': ritardi_count,
        'aeroporto': mio_aeroporto,
    })

@login_required
# Elenco voli per lo staff con permessi di admin o operatore_voli
def lista_voli_operatore(request):
    operatore = operatore_corrente(request.user)

    if not operatore or operatore.ruolo not in ('admin', 'operatore_voli'):
        messages.error(request, 'Area riservata agli operatori voli.')
        return redirect('gestionale:home')

    voli = (
    Volo.objects
        .filter(partenza=operatore.aeroporto)
        .select_related('partenza', 'destinazione', 'codice_gate', 'id_aereo')
        .order_by('orario_partenza')
    )

    return render(request, 'gestionale/lista_voli_operatore.html', {
        'voli': voli,
    })

@login_required
def modifica_volo(request, volo_id):
    # Recupera l'operatore e verifica i permessi
    operatore = operatore_corrente(request.user)

    if not operatore or operatore.ruolo not in ('admin', 'operatore_voli'):
        messages.error(request, 'Area riservata agli operatori voli.')
        return redirect('gestionale:home')
    
    volo = get_object_or_404(
        Volo, 
        Q(partenza=operatore.aeroporto) | Q(destinazione=operatore.aeroporto), 
        pk=volo_id
    )

    if request.method == 'POST':
        form = GestioneVoloForm(request.POST, instance=volo, operatore=operatore)
        
        if form.is_valid():
            form.save()
            
            # Registra l'operazione nel log
            Gestione_Volo.objects.update_or_create(
                codice_operatore=operatore,
                id_volo=volo,
                defaults={
                    'timestamp_modifica': timezone.now(),
                    'tipo_operazione': 'modifica_stato',
                },
            )

            messages.success(request, f'Volo {volo.numero_volo} aggiornato correttamente.')
            return redirect('gestionale:lista_voli_operatore')
    else:
        form = GestioneVoloForm(instance=volo, operatore=operatore)

    return render(request, 'gestionale/modifica_volo.html', {
        'form': form,
        'volo': volo,
    })

@login_required
def registra_bagaglio(request):
    operatore = operatore_corrente(request.user)

    if not operatore or operatore.ruolo not in ('admin', 'operatore_bagagli'):
        messages.error(request, 'Area riservata agli operatori bagagli.')
        return redirect('gestionale:dashboard_operatore')

    prenotazione_trovata = None
    bagaglio_da_gestire = None
    bagagli_prenotazione = Bagaglio.objects.none()
    
    username_query = request.GET.get('username_ricerca')
    bagaglio_query = request.GET.get('bagaglio_search')

    if username_query:
        prenotazione_trovata = Prenotazione.objects.filter(
            username_passeggero=username_query
        ).first()
        if not prenotazione_trovata:
            messages.error(request, f"Nessuna prenotazione attiva per: {username_query}")
        else:
            bagagli_prenotazione = Bagaglio.objects.filter(
                passeggero=prenotazione_trovata.username_passeggero,
                volo=prenotazione_trovata.id_volo,
            ).order_by('id_bagaglio')

            if not bagagli_prenotazione.exists():
                messages.warning(request, f"La prenotazione di {username_query} non contiene bagagli da accettare.")

    if bagaglio_query:
        clean_query = bagaglio_query.replace('#', '')
        if clean_query.isdigit():
            bagaglio_da_gestire = Bagaglio.objects.filter(id_bagaglio=clean_query).first()
        else:
            bagaglio_da_gestire = Bagaglio.objects.filter(passeggero__username=clean_query).last()

        if not bagaglio_da_gestire:
            messages.error(request, f"Nessun bagaglio trovato per: {bagaglio_query}")

    if request.method == 'POST':
        if 'conferma_bagaglio' in request.POST:
            try:
                id_bagaglio = request.POST.get('id_bagaglio')

                bagaglio = Bagaglio.objects.get(
                    id_bagaglio=id_bagaglio,
                    passeggero_id=request.POST.get('passeggero_id'),
                    volo_id=request.POST.get('volo_id'),
                )

                bagaglio.peso_kg = request.POST.get('peso_kg')
                bagaglio.tipo = request.POST.get('tipo')
                bagaglio.operatore = operatore
                bagaglio.stato = 'imbarcato'
                bagaglio.save()

                messages.success(request, f"Bagaglio #{bagaglio.id_bagaglio} aggiornato ed imbarcato.")
                return redirect('gestionale:registra_bagaglio')
            except Bagaglio.DoesNotExist:
                messages.error(request, "Il bagaglio selezionato non appartiene alla prenotazione indicata.")
            except Exception as e:
                messages.error(request, f"Errore nel salvataggio: {e}")

        elif 'aggiorna_stato' in request.POST:
            try:
                id_b = request.POST.get('id_bagaglio')
                nuovo_stato = request.POST.get('nuovo_stato')
                bagaglio = Bagaglio.objects.get(id_bagaglio=id_b)
                bagaglio.stato = nuovo_stato
                bagaglio.save()
                messages.success(request, f"Stato bagaglio #{id_b} aggiornato correttamente.")
                return redirect('gestionale:registra_bagaglio')
            except Exception as e:
                messages.error(request, f"Errore nell'aggiornamento: {e}")

    # Query per le tabelle
    ultimi_bagagli = Bagaglio.objects.exclude(stato='prenotato').select_related('passeggero', 'volo').order_by('-id_bagaglio')[:10]
    bagagli_critici = Bagaglio.objects.filter(stato__in=['smarrito', 'ritrovato']).select_related('passeggero', 'volo').order_by('-id_bagaglio')

    return render(request, 'gestionale/registra_bagaglio.html', {
        'prenotazione': prenotazione_trovata,
        'bagagli_prenotazione': bagagli_prenotazione,
        'bagaglio_trovato': bagaglio_da_gestire,
        'bagagli': ultimi_bagagli,
        'bagagli_critici': bagagli_critici, 
        'query': username_query,
        'bagaglio_query': bagaglio_query
    })

@login_required
def gestione_staff(request):
    operatore_admin = operatore_corrente(request.user)
    
    # Operazione solo admin
    if not operatore_admin or operatore_admin.ruolo != 'admin':
        messages.error(request, "Accesso negato.")
        return redirect('gestionale:dashboard_operatore')

    if request.method == 'POST':
        # Recupero dati dal form
        username = request.POST.get('username')
        email = request.POST.get('email')
        password = request.POST.get('password')
        nome = request.POST.get('nome')
        cognome = request.POST.get('cognome')
        ruolo = request.POST.get('ruolo')
        cellulare = request.POST.get('cellulare')

        try:
            # Creazione utente Django per il login
            user = User.objects.create_user(username=username, email=email, password=password)
            
            # Creazione profilo Operatore legato all'aeroporto dell'admin
            Operatore.objects.create(
                codice_operatore=f'OP-{username.upper()}',
                id_user=user,
                nome=nome,
                cognome=cognome,
                email=email,
                cellulare=cellulare,
                ruolo=ruolo,
                aeroporto=operatore_admin.aeroporto # Assegnazione automatica
            )
            messages.success(request, f"Operatore {nome} registrato con successo!")
            return redirect('gestionale:gestione_staff')
        except Exception as e:
            messages.error(request, f"Errore durante la registrazione: {e}")

    # Lista staff dell'aeroporto (escluso l'admin)
    # id_user per il filtro exclude
    staff = Operatore.objects.filter(
        aeroporto=operatore_admin.aeroporto
    ).exclude(id_user=request.user)
    
    return render(request, 'gestionale/gestione_staff.html', {
        'staff': staff,
        'operatore': operatore_admin
    })

@login_required
def profilo_operatore(request):
    operatore = operatore_corrente(request.user)

    if not operatore:
        messages.error(request, 'Area riservata agli operatori.')
        return redirect('gestionale:home')

    if request.method == 'POST':
        form = ProfiloOperatoreForm(request.POST, instance=operatore)

        if form.is_valid():
            profilo = form.save()
            request.user.email = profilo.email
            request.user.save(update_fields=['email'])

            messages.success(request, 'Profilo operatore aggiornato correttamente.')
            return redirect('gestionale:profilo_operatore')
    else:
        form = ProfiloOperatoreForm(instance=operatore)

    return render(request, 'gestionale/profilo_operatore.html', {
        'form': form,
        'operatore': operatore,
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
