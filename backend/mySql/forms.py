from django import forms

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
