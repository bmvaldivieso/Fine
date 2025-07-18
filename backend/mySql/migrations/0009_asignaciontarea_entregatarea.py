# Generated by Django 4.2.16 on 2025-07-14 16:39

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('mySql', '0008_alter_nota_unique_together_nota_bimestre_and_more'),
    ]

    operations = [
        migrations.CreateModel(
            name='AsignacionTarea',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('titulo', models.CharField(max_length=255)),
                ('descripcion', models.TextField()),
                ('fecha_entrega', models.DateTimeField()),
                ('intentos_maximos', models.PositiveIntegerField(default=1)),
                ('publicada', models.BooleanField(default=False)),
                ('componente', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='mySql.componente')),
                ('docente', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='mySql.docente')),
            ],
        ),
        migrations.CreateModel(
            name='EntregaTarea',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('intento_numero', models.PositiveIntegerField()),
                ('fecha_entrega', models.DateTimeField(auto_now_add=True)),
                ('entregado', models.BooleanField(default=False)),
                ('calificacion', models.FloatField(blank=True, null=True)),
                ('observaciones', models.TextField(blank=True)),
                ('asignacion', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='mySql.asignaciontarea')),
                ('estudiante', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='mySql.estudiante')),
            ],
        ),
    ]
