# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models

# Create your models here.

class ServerHost(models.Model):
    address=models.CharField('IP',max_length=16)
    user=models.CharField('用户',max_length=25)
    password=models.CharField('密码',max_length=50)
    tags=models.CharField('标签',max_length=100)
    location=models.CharField('地址',max_length=100)
    iskeys=models.BooleanField('密钥登录')
    ispub=models.BooleanField('公网主机')
    sshfilename=models.CharField('密钥文件路径',max_length=100)

    def __unicode__(self):
        return self.address

class MysqlInfo(models.Model):
    user=models.CharField('用户',max_length=25)
    address=models.ForeignKey('ServerHost')
    password=models.CharField(max_length=50)
    tags=models.CharField('标签',max_length=100)

    def __unicode__(self):
        return self.tags
