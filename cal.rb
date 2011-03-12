#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'date'
require 'optparse'

require 'hcal'                  # HolydayCalendar

$SPC = " "
ONEDAY_COLUMN_SIZE = 1 + 2                # 1 日分のカラムサイズ
$ONEDAY_SPC = ($SPC * ONEDAY_COLUMN_SIZE) # 1 日分の空白

class MyHolydayCalendar < HolydayCalendar
  def self.isLocalHolyday(year=@year, month=@month, day=@day)
    hdays = [[  1,  1,    0, 9999, nil,      '年末年始休暇' ],
             [  1,  2,    0, 9999, nil,      '年末年始休暇' ],
             [  1,  3,    0, 9999, nil,      '年末年始休暇' ],
             [ 12, 29,    0, 9999, nil,      '年末年始休暇' ],
             [ 12, 30,    0, 9999, nil,      '年末年始休暇' ],
             [ 12, 31,    0, 9999, nil,      '年末年始休暇' ],
            ]
    return super(hdays, year, month, day)
  end
end

class ConsoleColor
  @@red = "red"
  @@lightred = "lightred"
  @@blue = "blue"
  @@lightgray = "lightgray"
  @@reset = "reset"

  def set(name, reverse = false)
    colors = {
      @@red      =>["\033[0;31m", "\033[0;30;41m"],
      @@blue     =>["\033[0;34m", "\033[0;30;44m"],
      @@lightgray=>["\033[0;37m", "\033[0;30;47m"],
      @@lightred =>["\033[1;31m", "\033[1;30;41m"],}

    if colors[name] == nil then
      str = "\033[m"              # reset
    else
      str = colors[name][if reverse then 1 else 0 end]
   end

    return str
  end

  def wday2color(idx = -1)
    colornames = [@@red, @@lightgray, @@lightgray, @@lightgray, @@lightgray, @@lightgray, @@blue]
    if idx >= 0 && idx < colornames.size then
      color = colornames[idx]
    else
      color = @@reset
    end

    return color
  end

  def date2color(year, month, day)
    if MyHolydayCalendar.isHolyday(year, month, day) then
      color = @@red
    elsif MyHolydayCalendar.isLocalHolyday(year, month, day) then
      color = @@red
    else
      color = wday2color(Date.new(year, month, day).wday)
    end
    return color
  end

  def resetcolor()
    return wday2color
  end
end

def isDecimal(arg)
  return arg =~ /\d/
end

def puttitle(d, multi=false)
  str = ""
  wd = Date.new(d.year, d.month, d.day)
  if multi then
    for j in 0..2
      str << ($SPC * 6) if j != 0
      case j
        when 0 then wds = wd << 1 # 前月
        when 1 then wds = wd      # 当月
        when 2 then wds = wd >> 1 # 次月
      end
      str << sprintf("       %4d/ %2d", wds.year, wds.month)
    end
  else
    str << sprintf("       %4d/ %2d", wd.year, wd.month)
  end
  print str
  print "\n"
end

def putwday(multi=false)
  wdays = ["日", "月", "火", "水", "木", "金", "土"]
  cc = ConsoleColor.new()

  str = ""
  if multi then
    3.times do
      for i in 0..6
        print cc.set(cc.wday2color(i))
        print $SPC + wdays[i]
        print cc.set(cc.resetcolor)
      end
    end
  else
    for i in 0..6
      print cc.set(cc.wday2color(i))
      print $SPC + wdays[i]
      print cc.set(cc.resetcolor)
    end
  end

  print "\n"
end

def createday(d, highlight)
  cc = ConsoleColor.new()
  lastd = Date.new(d.year, d.month, -1)

  str = ""
  m1 = []
  for i in 1..lastd.day
    wkd = Date.new(d.year, d.month, i)
    wday = wkd.wday             # wday: 曜日 (整数 0-6)
    if i == 1 then
      str << ($ONEDAY_SPC * wday)
    elsif wday == 0 then        # 1 日以外の日曜日で改行する。
      m1.push(str)
      str = ""
    end

    str << $SPC
    if HolydayCalendar.isToday(wkd.year, wkd.month, i) && highlight then
      # 今日
      str << cc.set(cc.date2color(wkd.year, wkd.month, wkd.day), true)
    else
      str << cc.set(cc.date2color(wkd.year, wkd.month, wkd.day))
    end
    str << sprintf("%2d", i)
    str << cc.set(cc.resetcolor)
  end

  str << ($ONEDAY_SPC * (6 - lastd.wday))
  m1.push(str)
  return m1
end

def putday(d, highlight, multi=false)
  mds = []
  if multi then
    mds.push(createday(d << 1, highlight))
    mds.push(createday(d,      highlight))
    mds.push(createday(d >> 1, highlight))

    size = []
    mds.each do |m|
      size.push(m.size)
    end

    for i in 1..size.max
      str = ""

      mds.each do |m|
        if i <= m.size then
          str << m[i-1]
        else
          str << ($ONEDAY_SPC * 7)
        end
      end

      print str
      print "\n"
    end
  else
    mds.push(createday(d , highlight))
    mds.each do |m|
      m.each do |str|
        print str
        print "\n"
      end
    end
  end

  print "\n"
end

ohash = {:h=>true, :three=>false}
OptionParser.new{ |opt|
  opt.on('-m VAL') {|v| ohash[:m] = v}
  opt.on('-h')     {|v| ohash[:h] = !v} # Turns off highlighting of today.
  opt.on('-3')     {|v| ohash[:three] = v}
  opt.parse!(ARGV)
}

# TODO help を記述する。
# TODO カレンダーに出力した祝日の名前一覧を出力する。

y = 0
m = 0

# 引数より 1～12 を月、それ以外を年として取得する。
ARGV.each do |arg|
  if isDecimal(arg) then
    if HolydayCalendar.isMonth(arg.to_i) then
      m = arg.to_i
    else
      y = arg.to_i
    end
  end
end

# -m オプションの引数を月として取得する。
if ohash[:m] != nil && isDecimal(ohash[:m]) then
  if !HolydayCalendar.isMonth(ohash[:m].to_i)
    abort(m.to_s + " is neither a month number (1..12) nor a name")
  end
  m = ohash[:m].to_i
end

if y != 0 && m == 0 then
  for m in [2, 5, 8, 11]
    d = Date.new(y, m, 1)

    puttitle(d, true)
    putwday(true)
    putday(d, ohash[:h], true)
  end
else
  y = Time.now.year  if y == 0
  m = Time.now.month if m == 0

  d = Date.new(y, m, 1)

  puttitle(d, ohash[:three])
  putwday(ohash[:three])
  putday(d, ohash[:h], ohash[:three])
end
