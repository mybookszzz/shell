# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render

from django.http import HttpResponse
from .models import ServerHost
# Create your views here.

def home(request):
    innerip=ServerHost.objects.values_list("address").filter(ispub=False)
    pubip=ServerHost.objects.values_list("address").filter(ispub=True)
    return render(request,'home.html',{'innerIP':innerip,'pubIP':pubip})
