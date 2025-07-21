from django import forms
from .models import AsignacionTarea, Anuncio, Nota, PublicacionNotas, Componente

class LoginDocenteForm(forms.Form):
    email = forms.EmailField(
        label="Correo electrónico",
        widget=forms.EmailInput(attrs={
            'class': 'form-control rounded-pill',
            'placeholder': 'Correo electrónico',
        })
    )
    password = forms.CharField(
        label="Contraseña",
        widget=forms.PasswordInput(attrs={
            'class': 'form-control rounded-start-pill',
            'placeholder': 'Contraseña',
        })
    )


class LoginAdministradorForm(forms.Form):
    email = forms.EmailField(
        label="Correo electrónico",
        widget=forms.EmailInput(attrs={
            'class': 'form-control rounded-pill',
            'placeholder': 'Correo electrónico',
        })
    )
    password = forms.CharField(
        label="Contraseña",
        widget=forms.PasswordInput(attrs={
            'class': 'form-control rounded-start-pill',
            'placeholder': 'Contraseña',
        })
    )


class AsignacionTareaForm(forms.ModelForm):
    class Meta:
        model = AsignacionTarea
        fields = ['titulo', 'descripcion', 'fecha_entrega', 'intentos_maximos', 'publicada']
        widgets = {
            'fecha_entrega': forms.DateTimeInput(attrs={
                'type': 'datetime-local',
                'class': 'form-control',
                'readonly': 'true',  
                'onkeydown': 'return false'  
            }),
        }        


class CrearAnuncioForm(forms.ModelForm):
    class Meta:
        model = Anuncio
        fields = ['titulo', 'contenido', 'publicada']
        widgets = {
            'contenido': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 5,
            })
        }
        

class NotaForm(forms.ModelForm):
    class Meta:
        model = Nota
        fields = ['tareas', 'lecciones', 'grupales', 'individuales', 'inasistencias']
        widgets = {
            'tareas': forms.NumberInput(attrs={'step': '0.01', 'min': '0'}),
            'lecciones': forms.NumberInput(attrs={'step': '0.01', 'min': '0'}),
            'grupales': forms.NumberInput(attrs={'step': '0.01', 'min': '0'}),
            'individuales': forms.NumberInput(attrs={'step': '0.01', 'min': '0'}),
            'inasistencias': forms.NumberInput(attrs={'min': '0'}),
        }

class PublicacionNotasEditarForm(forms.ModelForm):
    class Meta:
        model = PublicacionNotas
        fields = ['habilitado', 'fecha_inicio', 'fecha_fin']
        widgets = {
            'fecha_inicio': forms.DateTimeInput(attrs={'type': 'datetime-local'}),
            'fecha_fin': forms.DateTimeInput(attrs={'type': 'datetime-local'}),
        }


class PublicacionNotasForm(forms.ModelForm):
    class Meta:
        model = PublicacionNotas
        fields = ['componente', 'habilitado', 'fecha_inicio', 'fecha_fin']
        widgets = {
            'fecha_inicio': forms.DateTimeInput(attrs={'type': 'datetime-local'}),
            'fecha_fin': forms.DateTimeInput(attrs={'type': 'datetime-local'}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        usados = PublicacionNotas.objects.values_list('componente_id', flat=True)
        self.fields['componente'].queryset = Componente.objects.exclude(id__in=usados)
