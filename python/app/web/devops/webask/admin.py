# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.contrib import admin

from .models import ServerHost,MysqlInfo
# Register your models here.
admin.site.register(ServerHost)
admin.site.register(MysqlInfo)
