# AeroBase

AeroBase è un progetto universitario di Basi di Dati sviluppato con Django e MySQL.
Il sistema simula una piattaforma aeroportuale per la ricerca e prenotazione dei voli da parte dei passeggeri e per la gestione operativa da parte dello staff aeroportuale.

## Obiettivo del progetto

AeroBase non è pensato soltanto come un sito di acquisto biglietti, ma come una piccola piattaforma gestionale aeroportuale.
I passeggeri possono registrarsi, cercare voli, acquistare biglietti (dichiarando eventuali bagagli) simulando un pagamento e visualizzare lo stato dei voli in arrivo e partenza tramite tabellone. Parallelamente, gli operatori aeroportuali possono gestire voli, gate, bagagli e personale in base al proprio ruolo.

L’idea progettuale è quella di un servizio utilizzabile da più aeroporti: ogni operatore è associato a uno specifico aeroporto e può operare solo sui dati collegati al proprio scalo.

## Tecnologie utilizzate

- Python
- Django
- MySQL
- HTML
- CSS
- JavaScript
- draw.io

## Funzionalità principali

### Area pubblica

- Home page
- Ricerca voli per aeroporto di partenza, destinazione e data
- Tabellone voli aggiornato dinamicamente
- Registrazione cliente
- Login e logout

### Area cliente

- Prenotazione volo
- Scelta della classe
- Scelta del posto disponibile
- Dichiarazione bagagli
- Pagamento simulato
- Consultazione delle prenotazioni
- Modifica dei dati personali e documentali
- Visualizzazione di eventuali informazioni relative ai voli

### Area operatore

- Dashboard operatore
- Gestione voli: modifica di orari, ritardi, stato operativo e assegnazione di gate compatibili con il tipo di volo
- Verifica e aggiornamento bagagli dei clienti al check-in
- Gestione staff da parte dell’admin aeroportuale

## Struttura del database

Il database è realizzato in MySQL. Le tabelle principali del progetto sono:

- `Aeroporto`
- `Aereo`
- `Gate`
- `Volo`
- `Volo_Nazionale`
- `Volo_Internazionale`
- `Compagnia_Aerea`
- `Operatore`
- `Bagaglio`
- `Passeggero`
- `Transazione`
- `Metodo_Pagamento`

Nel modello logico alcune relazioni sono implementate come tabelle, sia per consentirne il salvataggio sia perché contengono dati propri.
Le relazioni in questione sono:

- `Prenotazione` collega `Passeggero` e `Volo`, memorizzando anche posto, classe, data di acquisto e stato del pagamento;
- `Gestione_Volo` collega `Operatore` e `Volo`, registrando le modifiche operative effettuate sui voli.

Il progetto utilizza inoltre la tabella `auth_user`, generata da Django tramite `django.contrib.auth`, per la gestione dell’autenticazione e delle password hashate.

## Scelte progettuali principali

### Autenticazione

L’autenticazione non è stata sviluppata da zero, ma utilizza il sistema già fornito da Django tramite `django.contrib.auth`.
Le credenziali degli utenti sono salvate nella tabella `auth_user`, mentre le tabelle `Passeggero` e `Operatore` contengono solo i dati applicativi del progetto.

Il collegamento tra `auth_user` e le tabelle del dominio avviene tramite il campo `id_user`.

### Ruoli operatori

Gli operatori possono avere ruoli differenti:

- `admin`
- `operatore_voli`
- `operatore_bagagli`

Ogni ruolo può accedere solo alle funzionalità previste.

### Voli nazionali e internazionali

La tabella `Volo` contiene i dati comuni a tutti i voli, a cui sono legate due tabelle di specializzazione, chiamate: `Volo_Nazionale` e `Volo_Internazionale`. Questa scelta permette di separare:

- informazioni comuni a tutti i voli;
- informazioni specifiche dei voli nazionali;
- informazioni specifiche dei voli internazionali.

### Gate e compatibilità

Ogni gate appartiene a un aeroporto. I gate possono essere associati a un terminal, a un’area di imbarco e possono essere marcati come compatibili con voli internazionali.

Lato Django, quando un operatore modifica un volo, vengono mostrati solo i gate compatibili con il tipo di volo e con l’aeroporto dell’operatore.

### Bagagli

I bagagli vengono dichiarati dal passeggero durante la prenotazione. In fase iniziale il bagaglio può non avere ancora peso e operatore associato, questi dati vengono aggiunti successivamente dall’operatore bagagli durante il check-in.

### Vincoli

Il database utilizza:
- chiavi primarie;
- chiavi esterne;
- vincoli `UNIQUE`;
- vincoli `CHECK`;
- campi `ENUM`;
- politiche `ON DELETE CASCADE`;
- politiche `ON DELETE SET NULL`;
- indici per ottimizzare alcune query.

Le logiche più dinamiche, come scelta posto, gestione pagamento, aggiornamento stato voli e controllo ruoli, sono gestite lato Django.

## Installazione del progetto

### Clonare il repository

```bash
git clone https://github.com/martilumastro/aerobase.git
```

### Accedere alla cartella del progetto

```bash
cd aerobase
```

### Creare l'ambiente virtuale

```bash
python -m venv venv
```

### Attivare l'ambiente virtuale

Su Linux / WSL:

```bash
source venv/bin/activate
```

Su Windows PowerShell:

```powershell
venv\Scripts\Activate.ps1
```

### Installare le dipendenze

```bash
pip install -r requirements.txt
```

### Configurare il database

Configurare il database MySQL nel file `settings.py` oppure tramite variabili d’ambiente.

### Eseguire le migrazioni Django

```bash
python manage.py migrate
```

### Avviare il server

```bash
python manage.py runserver
```

Il sito sarà disponibile all’indirizzo:

```text
http://127.0.0.1:8000/
```

### Importazione del database

Il progetto include un dump MySQL del database.
Esempio di importazione:

```bash
mysql -u nome_utente -p nome_database < aerobase_dump.sql
```

### Esempi SQL per popolamento database
<!-- Aeroporto - Compagnia_Aerea - Aereo - Gate - Volo - Volo_Nazionale - Volo_Internazionale - Operatore -->

### Utenti di test

I passeggeri hanno la possibilità di registrarsi in autonomia al sito, operazione obbligatoria per procedere con la prenotazione di un volo.
Per quanto riguarda gli operatori questa operazione non è prevista, nuovo personale può essere aggiunto solo da un admin aeroportuale.

Credenziali demo per test:
- Admin aeroportuale:
- Operatore voli:
- Operatore bagagli:
- Cliente:


## Galleria
<!-- Immagini -->

## Struttura generale del progetto

```text
aerobase/
├── aerobase_project/
├── gestionale/
│   ├── static/
│   ├── templates/
│   ├── models.py
│   ├── views.py
│   ├── forms.py
│   └── urls.py
├── aerobase_dump.sql
├── manage.py
└── README.md
```

## Note
- Il pagamento presente nel progetto è simulato e non utilizza gateway reali.
- Il tabellone voli usa JavaScript per interrogare periodicamente un endpoint Django e aggiornare i dati visualizzati.
- Il progetto è stato realizzato per finalità universitarie nell’ambito del corso di Basi di Dati.
- Il diagramma E-R è stato realizzato con draw.io ed è incluso nel repository.
