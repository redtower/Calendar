#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'date'
require 'optparse'

$SPC = " "
ONEDAY_COLUMN_SIZE = 1 + 2                # 1 日分のカラムサイズ
$ONEDAY_SPC = ($SPC * ONEDAY_COLUMN_SIZE) # 1 日分の空白

class ConsoleColor
  @@red = "red";
  @@blue = "blue";
  @@lightgray = "lightgray";
  @@reset = "reset";

  def set(name, reverse = false)
    names      =  [@@red,        @@blue,       @@lightgray]
    colors     = [["\033[0;31m", "\033[0;34m", "\033[0;37m"],    # ノーマル
                  ["\033[0;31m", "\033[0;34m", "\033[0;30;47m"]] # 反転

    idx = names.index(name)
    if idx == nil then
      str = "\033[m"              # reset
    else
      if reverse then
        str = colors[1][idx]
      else
        str = colors[0][idx]
      end
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

  def isHolyday1(year, month, day)
    # ref. http://homepage1.nifty.com/~tetsu/ruby/cmd/cal.html
    hdays = [[  1,  1,    0, 9999, nil,      '元旦'         ],
             [  1, 15,    0, 1999, nil,      '成人の日'     ],
             [  1,  0, 2000, 9999, 'HM2',    '成人の日'     ],
             [  2, 11,    0, 9999, nil,      '建国記念の日' ],
             [  3,  0,    0, 9999, 'SPRING', '春分の日'     ],
             [  4, 29,    0, 1988, nil,      '天皇誕生日'   ],
             [  4, 29, 1989, 2006, nil,      'みどりの日'   ],
             [  4, 29, 2007, 9999, nil,      '昭和の日'     ],
             [  5,  3,    0, 9999, nil,      '憲法記念日'   ],
             [  5,  4, 2007, 9999, nil,      'みどりの日'   ],
             [  5,  5,    0, 9999, nil,      'こどもの日'   ],
             [  7, 20, 1996, 2002, nil,      '海の日'       ],
             [  7, 20, 2003, 9999, 'HM3',    '海の日'       ],
             [  9, 15,    0, 2002, nil,      '敬老の日'     ],
             [  9,  0, 2003, 9999, 'HM3',    '敬老の日'     ],
             [  9,  0,    0, 9999, 'AUTUMN', '秋分の日'     ],
             [ 10, 10,    0, 1999, nil,      '体育の日'     ],
             [ 10,  0, 2000, 9999, 'HM2',    '体育の日'     ],
             [ 11,  3,    0, 9999, nil,      '文化の日'     ],
             [ 11, 23,    0, 9999, nil,      '勤労感謝の日' ],
             [ 12, 23, 1989, 9999, nil,      '天皇誕生日'   ],
            ]
    flg = false;

    hdays.each do |hday|
      hm = hday[0]
      next unless month == hm

      hsy = hday[2]
      hey = hday[3]
      next unless (year  >= hsy && year <= hey)

      if hday[1] != 0 then
        hd = hday[1]
      else
        case hday[4]
        when 'HM2'    then hd = nMonday(year, month, 2) # Happy Monday 第2週
        when 'HM3'    then hd = nMonday(year, month, 3) # Happy Monday 第3週
        when 'SPRING' then hd = spring(year)            # 春分の日
        when 'AUTUMN' then hd = autumn(year)            # 秋分の日
        end
      end

      if day == hd then
        flg = true
        break
      end
    end

    return flg
  end

  def isHolyday(year, month, day)
    flg = isHolyday1(year, month, day) # 祝日チェック

    # 国民の休日判定
    unless flg then
      d = Date.new(year, month, day)
      bd = d - 1
      ad = d + 1
      if d.year >= 1986 &&                        # 1986 年以後
         isHolyday1(bd.year, bd.month, bd.day) && # 前日が祝日
         isHolyday1(ad.year, ad.month, ad.day)    # 翌日が祝日
        flg = true
      end
    end

    # 振替休日判定（月曜日）
    unless flg then
      d = Date.new(year, month, day)
      bd = d - 1
      if d.wday == 1 &&                        # 月曜日
         d.year >= 1973 &&                     # 1973 年以後
         isHolyday1(bd.year, bd.month, bd.day) # 前日が祝日
      then
        flg = true
      end
    end

    # 振替休日判定（火曜日から金曜日）
    unless flg then
      d = Date.new(year, month, day)
      if d.wday >= 2 && d.wday <= 5 && # 火曜日から金曜日
         d.year >= 2005                # 2005 年以後
        # 日曜日から前日まで祝日が連続している場合
        flg = true
        for i in 1..d.wday
          bd = d - i
          unless isHolyday1(bd.year, bd.month, bd.day)
            flg = false
            break
          end
        end
      end
    end

    return flg
  end

  def nMonday(year, month, n)
    count = 0
    for i in 1..Date.new(year, month, -1).day
      d = Date.new(year, month, i)
      if d.wday == 1 then
        count += 1
        if count == n then
          day = d.day
          break
        end
      end
    end

    return day
  end

  def spring(year)
    # 計算式
    # (31y+2213)/128-y/4+y/100    (1851年-1999年通用)
    # (31y+2089)/128-y/4+y/100    (2000年-2150年通用)

    # ref. http://ja.wikipedia.org/wiki/春分の日
    case year % 4
    when 0
      day = 21 if year >= 1900 && year <= 1956
      day = 20 if year >= 1960 && year <= 2088
      day = 19 if year >= 2092 && year <= 2096
    when 1
      day = 21 if year >= 1901 && year <= 1989
      day = 20 if year >= 1993 && year <= 2097
    when 2
      day = 21 if year >= 1902 && year <= 2022
      day = 20 if year >= 2026 && year <= 2098
    when 3
      day = 22 if year >= 1903 && year <= 1923
      day = 21 if year >= 1927 && year <= 2055
      day = 20 if year >= 2059 && year <= 2099
    end

    return day
  end

  def autumn(year)
    # 計算式
    # (31y+2525)/128-y/4+y/100    (1851年-1999年通用)
    # (31y+2395)/128-y/4+y/100    (2000年-2150年通用)

    # ref. http://ja.wikipedia.org/wiki/秋分の日
    case year % 4
    when 0
      day = 23 if year >= 1900 && year <= 2008
      day = 22 if year >= 2012 && year <= 2096
    when 1
      day = 24 if year >= 1901 && year <= 1917
      day = 23 if year >= 1921 && year <= 2041
      day = 22 if year >= 2045 && year <= 2097
    when 2
      day = 24 if year >= 1902 && year <= 1946
      day = 23 if year >= 1950 && year <= 2074
      day = 22 if year >= 2078 && year <= 2098
    when 3
      day = 24 if year >= 1903 && year <= 1979
      day = 23 if year >= 1983 && year <= 2099
    end

     return day
  end

  def date2color(year, month, day)
    if isHolyday(year, month, day) then
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

def isToday(year, month, day)
  today = Date.new(Time.now.year, Time.now.month, Time.now.day)
  return today === Date.new(year, month, day)
end

def isDecimal(arg)
  return arg =~ /\d/
end

def isMonth(m)
  return m >= 1 && m <= 12
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
    for j in 0..2
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
    if isToday(wkd.year, wkd.month, i) && highlight then
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

      for j in 0..2
        if i <= mds[j].size then
          str << mds[j][i-1]
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

d = Date.new(Time.now.year, Time.now.month, Time.now.day)

y=d.year
m=d.month
ARGV.each do |arg|
  if isDecimal(arg) then
    if isMonth(arg.to_i) then
      m = arg.to_i
    else
      y = arg.to_i
    end
  end
end

if ohash[:m] != nil && isDecimal(ohash[:m]) then
  abort(m.to_s + " is neither a month number (1..12) nor a name") if !isMonth(ohash[:m].to_i)
  m = ohash[:m].to_i
end

d = Date.new(y, m, 1)
puttitle(d, ohash[:three])
putwday(ohash[:three])
putday(d, ohash[:h], ohash[:three])
