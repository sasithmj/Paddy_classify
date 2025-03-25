from django.urls import path
from . import views

urlpatterns = [
    path('predict/', views.classify_paddy_disease, name='classify_paddy_disease'),
]