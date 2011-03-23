#!/usr/bin/python
# coding: utf-8

import sys
import calendar
import datetime
import locale

d = datetime.datetime.today()

print '       %4d/ %2d' % (d.year, d.month)
print ' 日 月 火 水 木 金 土'

sdy = calendar.monthrange(d.year, d.month)[0]
edy = calendar.monthrange(d.year, d.month)[1]

l=[]
str=''

for i in range(sdy, edy+1):
    k = datetime.date(d.year, d.month, i)
    if k.weekday() != 6 and i == 1: # 月初日で日曜日以外
        for j in range(0, k.weekday() + 1):
            str += '   '
    
    if k.weekday() == 6 and i != 1: # 月初日以外で日曜日
        l.append(str)
        str = ''

    str += '%3d' % (i)

if len(str) != 0:
    l.append(str)

for item in l:
    print item

#    sys.stdout.write(i)
