from django import forms
from .models import AsignacionTarea, Anuncio, Nota, PublicacionNotas, Componente, Docente
from django.contrib.auth.models import User

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



class DocenteUserForm(forms.ModelForm):
    username = forms.CharField(max_length=150, required=True, label="Nombre de usuario")
    password = forms.CharField(widget=forms.PasswordInput(), required=True, label="Contraseña")
    first_name = forms.CharField(max_length=150, required=True, label="Nombre")
    last_name = forms.CharField(max_length=150, required=True, label="Apellido")
    email = forms.EmailField(required=True)

    class Meta:
        model = Docente
        fields = ['email', 'celular', 'imagen_perfil']  

    def save(self, commit=True):
        # Crear usuario
        user = User.objects.create_user(
            username=self.cleaned_data['username'],
            password=self.cleaned_data['password'],
            first_name=self.cleaned_data['first_name'],
            last_name=self.cleaned_data['last_name'],
            email=self.cleaned_data['email'],
        )

        # Concatenar nombre completo para el Docente
        nombre_completo = f"{user.first_name} {user.last_name}"

        # Crear el Docente
        docente = super().save(commit=False)
        docente.user = user
        docente.nombres_apellidos = nombre_completo
        if commit:
            docente.save()
        return docente

class DocenteUserEditForm(forms.ModelForm):
    username = forms.CharField(max_length=150, required=True, label="Nombre de usuario")
    first_name = forms.CharField(max_length=150, required=True, label="Nombre")
    last_name = forms.CharField(max_length=150, required=True, label="Apellido")
    email = forms.EmailField(required=True)

    class Meta:
        model = Docente
        fields = ['celular', 'imagen_perfil']

    def __init__(self, *args, **kwargs):
        # Recuperar instancia del Docente si se pasó
        docente = kwargs.get('instance', None)
        super().__init__(*args, **kwargs)
        if docente:
            self.fields['username'].initial = docente.user.username
            self.fields['first_name'].initial = docente.user.first_name
            self.fields['last_name'].initial = docente.user.last_name
            self.fields['email'].initial = docente.user.email

    def save(self, commit=True):
        docente = super().save(commit=False)
        user = docente.user
        user.username = self.cleaned_data['username']
        user.first_name = self.cleaned_data['first_name']
        user.last_name = self.cleaned_data['last_name']
        user.email = self.cleaned_data['email']
        docente.nombres_apellidos = f"{user.first_name} {user.last_name}"
        if commit:
            user.save()
            docente.save()
        return docente