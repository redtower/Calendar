#!/usr/bin/ruby
# -*- coding: utf-8 -*-

class HolydayCalendar
  def initialize(year=nil, month=nil, day=nil)
    @year=year
    @month=month
    @day=day
  end

  def isHolyday1(year, month, day)
    # ref. http://homepage1.nifty.com/~tetsu/ruby/cmd/cal.html
    #          月, 日,開始年,終了年,     区分,  名前
    hdays = [[  1,  1,  1948,  9999,      nil, '元日'         ],
             [  1, 15,  1948,  1999,      nil, '成人の日'     ],
             [  1,  0,  2000,  9999,    'HM2', '成人の日'     ],
             [  2, 11,  1967,  9999,      nil, '建国記念の日' ],
             [  3,  0,  1878,  1947, 'SPRING', '春季皇霊祭'   ],
             [  3,  0,  1948,  9999, 'SPRING', '春分の日'     ],
             [  4, 29,  1927,  1988,      nil, '天皇誕生日'   ], # 昭和天皇
             [  4, 29,  1989,  2006,      nil, 'みどりの日'   ],
             [  4, 29,  2007,  9999,      nil, '昭和の日'     ],
             [  5,  3,  1948,  9999,      nil, '憲法記念日'   ],
             [  5,  4,  2007,  9999,      nil, 'みどりの日'   ],
             [  5,  5,  1948,  9999,      nil, 'こどもの日'   ],
             [  7, 20,  1996,  2002,      nil, '海の日'       ],
             [  7, 20,  2003,  9999,    'HM3', '海の日'       ],
             [  8, 31,  1913,  1913,      nil, '天皇誕生日'   ], # 大正天皇
             [  9, 15,  1966,  2002,      nil, '敬老の日'     ],
             [  9,  0,  2003,  9999,    'HM3', '敬老の日'     ],
             [  9,  0,  1878,  1947, 'AUTUMN', '秋季皇霊祭'   ],
             [  9,  0,  1948,  9999, 'AUTUMN', '秋分の日'     ],
             [  9, 22,  1868,  1872,      nil, '天皇誕生日'   ], # 明治天皇
             [ 10, 10,  1966,  1999,      nil, '体育の日'     ],
             [ 10,  0,  2000,  9999,    'HM2', '体育の日'     ],
             [ 10, 31,  1914,  1926,      nil, '天皇誕生日'   ], # 大正天皇
             [ 11,  3,  1873,  1911,      nil, '天皇誕生日'   ], # 明治天皇
             [ 11,  3,  1948,  9999,      nil, '文化の日'     ],
             [ 11, 23,  1948,  9999,      nil, '勤労感謝の日' ],
             [ 12, 23,  1989,  9999,      nil, '天皇誕生日'   ], # 平成天皇
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

  def isHolyday(year=@year, month=@month, day=@day)
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
    v = if year < 2000 then 2213 else 2089 end
    return (31 * year + v)/128 - year/4 + year/100
  end

  def autumn(year)
    v = if year < 2000 then 2525 else 2395 end
    return (31 * year + v)/128 - year/4 + year/100
  end

  def isLocalHolyday1(hdays, year=@year, month=@month, day=@day)
    flg = false;

    hdays.each do |hday|
      hm = hday[0]
      next unless month == hm

      hsy = hday[2]
      hey = hday[3]
      next unless (year  >= hsy && year <= hey)

      hd = hday[1]

      if day == hd then
        flg = true
        break
      end
    end

    return flg
  end

  def isLocalHolyday(holydayslist=nil, year=@year, month=@month, day=@day)
    holydays = if holydayslist == nil then [[ nil, nil, nil, nil, nil, nil ],] else holydayslist end
    return isLocalHolyday1(holydays, year, month, day)
  end
end
