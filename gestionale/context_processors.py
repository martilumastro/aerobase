from .models import Operatore, Passeggero


def profili_utente(request):
    if not request.user.is_authenticated:
        return {
            'operatore_corrente_template': None,
            'passeggero_corrente_template': None,
        }

    return {
        'operatore_corrente_template': Operatore.objects.filter(id_user=request.user).first(),
        'passeggero_corrente_template': Passeggero.objects.filter(id_user=request.user).first(),
    }
