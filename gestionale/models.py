from django.db import models
from django.contrib.auth.models import User

class Compagnia_Aerea(models.Model):
    codice_vettore = models.CharField(max_length=3, primary_key=True)
    nome_compagnia = models.CharField(max_length=50)
    nazione = models.CharField(max_length=50)

    class Meta:
        db_table = 'Compagnia_Aerea'

class Aereo(models.Model):
    id_aereo = models.AutoField(primary_key=True)
    modello = models.CharField(max_length=50)
    capacita_passeggeri = models.IntegerField()
    codice_vettore = models.ForeignKey(Compagnia_Aerea, on_delete=models.CASCADE, db_column='codice_vettore')

    class Meta:
        db_table = 'Aereo'

class Gate(models.Model):
    codice_gate = models.CharField(max_length=10, primary_key=True)
    terminal = models.CharField(max_length=10)

    class Meta:
        db_table = 'Gate'

class Aeroporto(models.Model):
    codice_iata = models.CharField(max_length=3, primary_key=True)
    nome_aeroporto = models.CharField(max_length=100)
    citta = models.CharField(max_length=80)
    nazione = models.CharField(max_length=80)
    codice_icao = models.CharField(max_length=4, unique=True, null=True, blank=True)

    class Meta:
        db_table = 'Aeroporto'

    def __str__(self):
        return f'{self.citta} - {self.nome_aeroporto} ({self.codice_iata})'

class Volo(models.Model):
    STATO_CHOICES = [
        ('in_orario', 'In Orario'),
        ('in_ritardo', 'In Ritardo'),
        ('imbarco', 'Imbarco'),
        ('partito', 'Partito'),
        ('cancellato', 'Cancellato'),
    ]

    id_volo = models.AutoField(primary_key=True)
    numero_volo = models.CharField(max_length=10, unique=True)
    orario_partenza = models.DateTimeField()
    orario_arrivo = models.DateTimeField()
    

    partenza = models.ForeignKey(
        Aeroporto,
        on_delete=models.PROTECT,
        db_column='partenza',
        related_name='voli_in_partenza'
    )

    destinazione = models.ForeignKey(
        Aeroporto,
        on_delete=models.PROTECT,
        db_column='destinazione',
        related_name='voli_in_arrivo'
    )

    id_aereo = models.ForeignKey(Aereo, on_delete=models.CASCADE, db_column='id_aereo')
    codice_gate = models.ForeignKey(Gate, on_delete=models.SET_NULL, null=True, blank=True, db_column='codice_gate')
    stato = models.CharField(max_length=20, choices=STATO_CHOICES, default='in_orario')
    prezzo = models.DecimalField(max_digits=8, decimal_places=2)
    ritardo_minuti = models.IntegerField(default=0)

    class Meta:
        db_table = 'Volo'


class Operatore(models.Model):
    RUOLO_CHOICES = [
        ('admin', 'Admin'),
        ('operatore_voli', 'Operatore Voli'),
        ('operatore_bagagli', 'Operatore Bagagli'),
    ]
    codice_operatore = models.CharField(max_length=20, primary_key=True)
    nome = models.CharField(max_length=50)
    cognome = models.CharField(max_length=50)
    email = models.EmailField(max_length=50, unique=True)
    cellulare = models.CharField(max_length=20, unique=True)
    ruolo = models.CharField(max_length=20, choices=RUOLO_CHOICES)
    aeroporto = models.ForeignKey(
    Aeroporto,
    on_delete=models.PROTECT,
    null=True,
    blank=True,
    db_column='codice_aeroporto',
    related_name='operatori'
    )
    id_user = models.OneToOneField(User, on_delete=models.SET_NULL, null=True, blank=True, db_column='id_user')

    class Meta:
        db_table = 'Operatore'

class Passeggero(models.Model):
    username = models.CharField(max_length=20, primary_key=True)
    nome = models.CharField(max_length=50)
    cognome = models.CharField(max_length=50)
    email = models.EmailField(max_length=50, unique=True)
    numero_passaporto = models.CharField(max_length=20, unique=True, null=True, blank=True)
    cellulare = models.CharField(max_length=20, unique=True, null=True, blank=True)
    nazionalita = models.CharField(max_length=50)
    id_user = models.OneToOneField(User, on_delete=models.SET_NULL, null=True, blank=True, db_column='id_user')

    class Meta:
        db_table = 'Passeggero'

class Prenotazione(models.Model):
    id_prenotazione = models.AutoField(primary_key=True)
    CLASSE_CHOICES = [
        ('economy', 'Economy'),
        ('business', 'Business'),
        ('first', 'First'),
    ]
    username_passeggero = models.ForeignKey(Passeggero, on_delete=models.CASCADE, db_column='username_passeggero')
    id_volo = models.ForeignKey(Volo, on_delete=models.CASCADE, db_column='id_volo')
    data_acquisto = models.DateTimeField(auto_now_add=True)
    posto = models.CharField(max_length=5)
    classe = models.CharField(max_length=10, choices=CLASSE_CHOICES)

    class Meta:
        db_table = 'Prenotazione'
        unique_together = (('username_passeggero', 'id_volo'),)

class Gestione_Volo(models.Model):
    OPERAZIONE_CHOICES = [
        ('modifica_stato', 'Modifica Stato'),
        ('modifica_gate', 'Modifica Gate'),
        ('modifica_aereo', 'Modifica Aereo'),
    ]
    codice_operatore = models.ForeignKey(Operatore, on_delete=models.CASCADE, db_column='codice_operatore')
    id_volo = models.ForeignKey(Volo, on_delete=models.CASCADE, db_column='id_volo')
    timestamp_modifica = models.DateTimeField(auto_now_add=True)
    tipo_operazione = models.CharField(max_length=20, choices=OPERAZIONE_CHOICES)

    class Meta:
        db_table = 'Gestione_Volo'
        unique_together = (('codice_operatore', 'id_volo'),)

class Bagaglio(models.Model):
    TIPO_CHOICES = [
        ('cabina', 'Cabina'),
        ('stiva', 'Stiva'),
        ('speciale', 'Speciale'),
    ]

    STATO_CHOICES = [
        ('imbarcato', 'Imbarcato'),
        ('consegnato', 'Consegnato'),
        ('smarrito', 'Smarrito'),
        ('ritrovato', 'Ritrovato'),
    ]
    
    id_bagaglio = models.AutoField(primary_key=True)
    peso_kg = models.DecimalField(max_digits=5, decimal_places=2)
    tipo = models.CharField(max_length=10, choices=TIPO_CHOICES)
    
    stato = models.CharField(
        max_length=20, 
        choices=STATO_CHOICES, 
        default='imbarcato'
    )
    
    passeggero = models.ForeignKey('Passeggero', on_delete=models.CASCADE, db_column='username_passeggero')
    volo = models.ForeignKey('Volo', on_delete=models.CASCADE, db_column='id_volo')
    operatore = models.ForeignKey('Operatore', on_delete=models.CASCADE, db_column='codice_operatore')

    class Meta:
        db_table = 'Bagaglio'
