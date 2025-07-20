from django import forms
from .models import AsignacionTarea, Anuncio

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
        

