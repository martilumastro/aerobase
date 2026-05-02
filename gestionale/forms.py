from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from django.db import transaction

from .models import Bagaglio, Passeggero, Prenotazione, Volo


class RegistrazionePasseggeroForm(UserCreationForm):
    """Form per registrazione nuovo passeggero:
    Estende UserCreationForm per gestire sia l'autenticazione (User)
    che i dati anagrafici specifici (Passeggero)."""
    nome = forms.CharField(max_length=50)
    cognome = forms.CharField(max_length=50)
    email = forms.EmailField(max_length=50)
    numero_passaporto = forms.CharField(max_length=20, required=False)
    cellulare = forms.CharField(max_length=20, required=False)
    nazionalita = forms.CharField(max_length=50)

    class Meta:
        model = User
        # Campi per la creazione dell'account
        fields = ('username', 'email', 'password1', 'password2')

    def clean_username(self):
        # Validazione per lo username.
        username = self.cleaned_data['username']

        if len(username) > 20:
            raise forms.ValidationError('Lo username deve avere al massimo 20 caratteri.')
        
        # Verifica che lo username non sia già presente in Passeggero
        if Passeggero.objects.filter(username=username).exists():
            raise forms.ValidationError('Esiste gia un passeggero con questo username.')

        return username

    def clean_email(self):
        #Validazione personalizzata per l'email."
        email = self.cleaned_data['email']

        # Verifica unicità dell'email in Passeggero
        if Passeggero.objects.filter(email=email).exists():
            raise forms.ValidationError('Esiste gia un passeggero con questa email.')

        return email

    @transaction.atomic
    def save(self, commit=True):
        # Sovrascrittura metodo save per creare contemporaneamente oggetto User e Passeggero in modo atomico.
        # Salva l'utente (User) nel database di autenticazione
        user = super().save(commit=False)
        user.email = self.cleaned_data['email']

        if commit:
            user.save()

            # Creazione record nella tabella Passeggero
            Passeggero.objects.create(
                username=user.username,
                nome=self.cleaned_data['nome'],
                cognome=self.cleaned_data['cognome'],
                email=self.cleaned_data['email'],
                numero_passaporto=self.cleaned_data.get('numero_passaporto') or None,
                cellulare=self.cleaned_data.get('cellulare') or None,
                nazionalita=self.cleaned_data['nazionalita'],
                id_user=user,
            )

        return user


class RicercaVoliForm(forms.Form):
    partenza = forms.CharField(
        max_length=80,
        required=False,
        label='Partenza',
        widget=forms.TextInput(attrs={
            'placeholder': 'Roma, Fiumicino, FCO...'
        })
    )

    destinazione = forms.CharField(
        max_length=80,
        required=False,
        label='Destinazione',
        widget=forms.TextInput(attrs={
            'placeholder': 'Milano, Malpensa, MXP...'
        })
    )

    data_partenza = forms.DateField(
        required=False,
        label='Data',
        widget=forms.DateInput(attrs={'type': 'date'})
    )


class PrenotazioneForm(forms.ModelForm):
    #Form creazione/modifica di una prenotazione.
    class Meta:
        model = Prenotazione
        fields = ('posto', 'classe')


class GestioneVoloForm(forms.ModelForm):
    class Meta:
        model = Volo
        fields = (
            'orario_partenza',
            'orario_arrivo',
            'id_aereo',
            'codice_gate',
            'ritardo_minuti',
            'stato',
        )
        widgets = {
            'orario_partenza': forms.DateTimeInput(attrs={'type': 'datetime-local', 'class': 'input-field'}),
            'orario_arrivo': forms.DateTimeInput(attrs={'type': 'datetime-local', 'class': 'input-field'}),
        }

    def __init__(self, *args, **kwargs):
        # Recuperiamo l'operatore passato dalla view
        self.operatore = kwargs.pop('operatore', None)
        super().__init__(*args, **kwargs)
        
        volo = self.instance
        
        # ID Aereo sola lettura
        self.fields['id_aereo'].disabled = True
        
        if self.operatore and self.operatore.aeroporto:
            mio_aeroporto = self.operatore.aeroporto
            
            # CASO A: Il volo PARTE dal mio aeroporto
            if volo.partenza == mio_aeroporto:
                # Può modificare: Orario Partenza e Gate
                # Bloccol'arrivo e lo stato (se vuoi sia automatico)
                self.fields['orario_arrivo'].disabled = True
                self.fields['ritardo_minuti'].disabled = True
                # self.fields['stato'].disabled = True # Scommenta se lo stato è automatico
                
            # CASO B: Il volo ARRIVA nel mio aeroporto
            elif volo.destinazione == mio_aeroporto:

                self.fields['orario_partenza'].disabled = True
                self.fields['orario_arrivo'].disabled = True
                self.fields['ritardo_minuti'].disabled = True
                self.fields['stato'].disabled = True
    # METODO CLEAN
    def clean(self):
        cleaned_data = super().clean()
        gate = cleaned_data.get('codice_gate')
        
        # Prendere l'orario effettivo (partenza o arrivo)
        orario_riferimento = cleaned_data.get('orario_partenza') or self.instance.orario_partenza
        
        if gate and orario_riferimento:
            # Controlla se il gate è occupato a quell'ora
            conflitto = Volo.objects.filter(
                codice_gate=gate,
                orario_partenza=orario_riferimento
            ).exclude(pk=self.instance.pk).exists()

            if conflitto:
                self.add_error('codice_gate', f"ATTENZIONE: Il Gate {gate} è già occupato per l'orario selezionato!")
        
        return cleaned_data

class BagaglioForm(forms.ModelForm):
    class Meta:
        model = Bagaglio
        fields = (
            'prenotazione_passeggero',
            'prenotazione_volo',
            'peso_kg',
            'tipo',
        )
