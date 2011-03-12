# -*- coding: utf-8 -*-
require 'test/unit'

require 'date'
require 'hcal'

class TC_HolydayCalendar < Test::Unit::TestCase
  def test_isMonth_1
    assert(HolydayCalendar.isMonth(1))
    assert(HolydayCalendar.isMonth(12))
  end

  def test_isMonth_2
    assert_equal(false, HolydayCalendar.isMonth(-1))
    assert_equal(false, HolydayCalendar.isMonth(0))
    assert_equal(false, HolydayCalendar.isMonth(13))
    assert_equal(false, HolydayCalendar.isMonth('a'))
  end

  def test_isToday_1
    assert(HolydayCalendar.isToday(Time.now.year, Time.now.month, Time.now.day))
  end

  def test_isToday_2
    now = Time.now
    y = 0
    m = now.month
    d = now.day
    assert_equal(false, HolydayCalendar.isToday(y, m, d))

    y = now.year
    m = if now.month != 1 then now.month - 1 else now.month + 1 end
    d = now.day
    assert_equal(false, HolydayCalendar.isToday(y, m, d))

    y = now.year
    m = now.month
    d = if now.day != 1 then now.day - 1 else now.day + 1 end
    assert_equal(false, HolydayCalendar.isToday(y, m, d))
  end

  def test_isToday_3
    HolydayCalendar.new(Time.now.year, Time.now.month, Time.now.day)
    assert(HolydayCalendar.isToday())
  end

  def test_isToday_4
    HolydayCalendar.new(0, Time.now.month, Time.now.day)
    assert_equal(false, HolydayCalendar.isToday())
  end

  def test_spring
    assert_equal(21, HolydayCalendar.spring(1900))
    assert_equal(21, HolydayCalendar.spring(1956))
    assert_equal(20, HolydayCalendar.spring(1960))
    assert_equal(20, HolydayCalendar.spring(2088))
    assert_equal(19, HolydayCalendar.spring(2092))
    assert_equal(19, HolydayCalendar.spring(2096))

    assert_equal(21, HolydayCalendar.spring(1901))
    assert_equal(21, HolydayCalendar.spring(1989))
    assert_equal(20, HolydayCalendar.spring(1993))
    assert_equal(20, HolydayCalendar.spring(2097))

    assert_equal(21, HolydayCalendar.spring(1902))
    assert_equal(21, HolydayCalendar.spring(2022))
    assert_equal(20, HolydayCalendar.spring(2026))
    assert_equal(20, HolydayCalendar.spring(2098))

    assert_equal(22, HolydayCalendar.spring(1903))
    assert_equal(22, HolydayCalendar.spring(1923))
    assert_equal(21, HolydayCalendar.spring(1927))
    assert_equal(21, HolydayCalendar.spring(2055))
    assert_equal(20, HolydayCalendar.spring(2059))
    assert_equal(20, HolydayCalendar.spring(2099))

    assert_equal( 0, HolydayCalendar.spring('a'))
  end

  def test_autumn
    assert_equal(23, HolydayCalendar.autumn(1900))
    assert_equal(23, HolydayCalendar.autumn(2008))
    assert_equal(22, HolydayCalendar.autumn(2012))
    assert_equal(22, HolydayCalendar.autumn(2096))

    assert_equal(24, HolydayCalendar.autumn(1901))
    assert_equal(24, HolydayCalendar.autumn(1917))
    assert_equal(23, HolydayCalendar.autumn(1921))
    assert_equal(23, HolydayCalendar.autumn(2041))
    assert_equal(22, HolydayCalendar.autumn(2045))
    assert_equal(22, HolydayCalendar.autumn(2097))

    assert_equal(24, HolydayCalendar.autumn(1902))
    assert_equal(24, HolydayCalendar.autumn(1946))
    assert_equal(23, HolydayCalendar.autumn(1950))
    assert_equal(23, HolydayCalendar.autumn(2074))
    assert_equal(22, HolydayCalendar.autumn(2078))
    assert_equal(22, HolydayCalendar.autumn(2098))

    assert_equal(24, HolydayCalendar.autumn(1903))
    assert_equal(24, HolydayCalendar.autumn(1979))
    assert_equal(23, HolydayCalendar.autumn(1983))
    assert_equal(23, HolydayCalendar.autumn(2099))

    assert_equal( 0, HolydayCalendar.autumn('a'))
  end

  def test_nMonday
    assert_equal( 7, HolydayCalendar.nMonday(  1, 2011,   3))
    assert_equal(14, HolydayCalendar.nMonday(  2, 2011,   3))
    assert_equal(21, HolydayCalendar.nMonday(  3, 2011,   3))
    assert_equal(28, HolydayCalendar.nMonday(  4, 2011,   3))

    assert_equal( 0, HolydayCalendar.nMonday(  5, 2011,   3))

    assert_equal( 0, HolydayCalendar.nMonday(  1, 2011,  13))
    assert_equal( 0, HolydayCalendar.nMonday(  1, 2011,   0))
    assert_equal( 0, HolydayCalendar.nMonday(  1, 2011,  -1))

    assert_equal( 0, HolydayCalendar.nMonday( -1, 2011,   3))

    assert_equal( 0, HolydayCalendar.nMonday(  1,  'a',   3))
    assert_equal( 0, HolydayCalendar.nMonday(  1, 2011, 'a'))
    assert_equal( 0, HolydayCalendar.nMonday('a', 2011,   3))

    HolydayCalendar.new(2011, 3)
    assert_equal( 7, HolydayCalendar.nMonday())
    assert_equal(14, HolydayCalendar.nMonday(2))
  end

  def test_isNationalHolyday
    # 国民の祝日のチェック。国民の休日、振替休日は含まない。
    assert(HolydayCalendar.isNationalHolyday(2011, 1, 1)) # 元日
    assert(HolydayCalendar.isNationalHolyday(2011, 1,10)) # 成人の日
    assert(HolydayCalendar.isNationalHolyday(2011, 2,11)) # 建国記念の日
    assert(HolydayCalendar.isNationalHolyday(2011, 3,21)) # 春分の日
    assert(HolydayCalendar.isNationalHolyday(2011, 4,29)) # 昭和の日
    assert(HolydayCalendar.isNationalHolyday(2011, 5, 3)) # 憲法記念日
    assert(HolydayCalendar.isNationalHolyday(2011, 5, 4)) # みどりの日
    assert(HolydayCalendar.isNationalHolyday(2011, 5, 5)) # こどもの日
    assert(HolydayCalendar.isNationalHolyday(2011, 7,18)) # 海の日  （第3月曜日）
    assert(HolydayCalendar.isNationalHolyday(2011, 9,19)) # 敬老の日（第3月曜日）
    assert(HolydayCalendar.isNationalHolyday(2011, 9,23)) # 秋分の日
    assert(HolydayCalendar.isNationalHolyday(2010,10,11)) # 体育の日（第2月曜日）
    assert(HolydayCalendar.isNationalHolyday(2011,11, 3)) # 文化の日
    assert(HolydayCalendar.isNationalHolyday(2011,11,23)) # 勤労感謝の日
    assert(HolydayCalendar.isNationalHolyday(2011,12,23)) # 天皇誕生日
  end

  def test_isNationalHolyday_NotNatinalHolyday
    # 国民の祝日でない日
    assert_equal(false, HolydayCalendar.isNationalHolyday(2011, 1, 2)) # 日曜日
    assert_equal(false, HolydayCalendar.isNationalHolyday(2011, 1, 3)) # 平日
    assert_equal(false, HolydayCalendar.isNationalHolyday(2011, 1,15)) # 旧成人の日
    assert_equal(false, HolydayCalendar.isNationalHolyday(2012, 2,12)) # 振替休日
    assert_equal(false, HolydayCalendar.isNationalHolyday(1988, 5, 4)) # 国民の休日
    assert_equal(false, HolydayCalendar.isNationalHolyday(2011, 7,20)) # 旧海の日
    assert_equal(false, HolydayCalendar.isNationalHolyday(2011, 9,15)) # 旧敬老の日
    assert_equal(false, HolydayCalendar.isNationalHolyday(2010,10,10)) # 旧体育の日
  end

  def test_isNationalHolyday_Range_0101
    # 元日
  end

  def test_isNationalHolyday_Range_0102
    # 成人の日（1949～1999：1/15、2000～：1月第2月曜日）
    assert_equal(false, HolydayCalendar.isNationalHolyday(1948, 1,15))
    assert(HolydayCalendar.isNationalHolyday(1949, 1,15))
    assert(HolydayCalendar.isNationalHolyday(1999, 1,15))
    assert(HolydayCalendar.isNationalHolyday(2000, 1,10))
    assert_equal(false, HolydayCalendar.isNationalHolyday(2000, 1,15))
  end

  def test_isNationalHolyday_Range_0201
    # 建国記念の日（1967～：2/11）
    assert_equal(false, HolydayCalendar.isNationalHolyday(1966, 2,11))
    assert(HolydayCalendar.isNationalHolyday(1967, 2,11))
  end

  def test_isNationalHolyday_Range_0301
    # 春分の日
  end

  def test_isNationalHolyday_Range_0401
    # 天皇誕生日（1927～1988：4/29）
    # みどりの日（1989～2006：4/29）
    # 昭和の日  （2007～    ：4/29）
    assert_equal(false, HolydayCalendar.isNationalHolyday(1926, 4,29))
    assert(HolydayCalendar.isNationalHolyday(1927, 4,29))
    assert(HolydayCalendar.isNationalHolyday(1989, 4,29))
    assert(HolydayCalendar.isNationalHolyday(2007, 4,29))
  end

  def test_isNationalHolyday_Range_0501
    # 憲法記念日（1948～：5/3）
    assert_equal(false, HolydayCalendar.isNationalHolyday(1947, 5, 3))
    assert(HolydayCalendar.isNationalHolyday(1948, 5, 3))
  end

  def test_isNationalHolyday_Range_0502
    # みどりの日（2007～：5/4）
    assert_equal(false, HolydayCalendar.isNationalHolyday(2006, 5, 4))
    assert(HolydayCalendar.isNationalHolyday(2007, 5, 4))
  end

  def test_isNationalHolyday_Range_0503
    # こどもの日（1948～：5/5）
    assert_equal(false, HolydayCalendar.isNationalHolyday(1947, 5, 5))
    assert(HolydayCalendar.isNationalHolyday(1948, 5, 5))
  end

  def test_isNationalHolyday_Range_0701
    # 海の日（1996～2002：7/20、2003～：7月第3月曜日）
    assert_equal(false, HolydayCalendar.isNationalHolyday(1995, 7,20))
    assert(HolydayCalendar.isNationalHolyday(1996, 7,20))
    assert(HolydayCalendar.isNationalHolyday(2002, 7,20))
    assert(HolydayCalendar.isNationalHolyday(2003, 7,21))
    assert_equal(false, HolydayCalendar.isNationalHolyday(2003, 7,20))
  end

  def test_isNationalHolyday_Range_0901
    # 敬老の日（1966～2002：9/15、2003～：9月第3月曜日）
    assert_equal(false, HolydayCalendar.isNationalHolyday(1965, 9,15))
    assert(HolydayCalendar.isNationalHolyday(1966, 9,15))
    assert(HolydayCalendar.isNationalHolyday(2002, 9,15))
    assert(HolydayCalendar.isNationalHolyday(2003, 9,15))
    assert(HolydayCalendar.isNationalHolyday(2004, 9,20))
    assert_equal(false, HolydayCalendar.isNationalHolyday(2004, 9,15))
  end

  def test_isNationalHolyday_Range_0902
    # 秋分の日
  end

  def test_isNationalHolyday_Range_1001
    # 体育の日（1966～1999：10/10、2000～：10月第2月曜日）
    assert_equal(false, HolydayCalendar.isNationalHolyday(1965,10,10))
    assert(HolydayCalendar.isNationalHolyday(1966,10,10))
    assert(HolydayCalendar.isNationalHolyday(1999,10,10))
    assert(HolydayCalendar.isNationalHolyday(2000,10, 9))
    assert_equal(false, HolydayCalendar.isNationalHolyday(2000,10,10))
  end

  def test_isNationalHolyday_Range_1101
    # 文化の日（1948～：11/3）
    assert_equal(false, HolydayCalendar.isNationalHolyday(1947,11, 3))
    assert(HolydayCalendar.isNationalHolyday(1948,11, 3))
  end

  def test_isNationalHolyday_Range_1102
    # 勤労感謝の日（1948～：11/23）
    assert_equal(false, HolydayCalendar.isNationalHolyday(1947,11,23))
    assert(HolydayCalendar.isNationalHolyday(1948,11,23))
  end

  def test_isNationalHolyday_Range_1201
    # 天皇誕生日（1989～：12/23）
    assert_equal(false, HolydayCalendar.isNationalHolyday(1988,12,23))
    assert(HolydayCalendar.isNationalHolyday(1989,12,23))
  end

  def test_isNationalHolyday_Other
    assert_equal(false, HolydayCalendar.isNationalHolyday())

    HolydayCalendar.new(2011,1,1)
    assert(HolydayCalendar.isNationalHolyday())

    assert_equal(false, HolydayCalendar.isNationalHolyday( 'a', 12, 23))
    assert_equal(false, HolydayCalendar.isNationalHolyday(2011,'a', 23))
    assert_equal(false, HolydayCalendar.isNationalHolyday(2011, 12,'a'))
  end

  def test_isBetweenTwoNationalHolyday
    # 国民の休日（1988～2006：5/4、ただし1992,1998は振替休日、1997,2003は日曜日のため除外）
    is = [1988,1989,1990,1991,1993,1994,1995,1996,1999,2000,2001,2002,2004,2005,2006]
    is.each do |y|
      assert(HolydayCalendar.isBetweenTwoNationalHolyday(y, 5, 4))
    end
    assert_equal(false, HolydayCalendar.isBetweenTwoNationalHolyday(1992, 5, 4))
    assert_equal(false, HolydayCalendar.isBetweenTwoNationalHolyday(1997, 5, 4))
    assert_equal(false, HolydayCalendar.isBetweenTwoNationalHolyday(1998, 5, 4))
    assert_equal(false, HolydayCalendar.isBetweenTwoNationalHolyday(2003, 5, 4))

    HolydayCalendar.new(1988,5,4)
    assert(HolydayCalendar.isBetweenTwoNationalHolyday())

    assert_equal(false, HolydayCalendar.isBetweenTwoNationalHolyday( 'a', 12, 23))
    assert_equal(false, HolydayCalendar.isBetweenTwoNationalHolyday(2011,'a', 23))
    assert_equal(false, HolydayCalendar.isBetweenTwoNationalHolyday(2011, 12,'a'))
  end

  def test_isSubstituteHolyday_Monday
    # 振替休日(月曜日)
    # 1月2日
    is = [1978, 1984, 1989, 1995, 2006, 2012, 2017, 2023, 2034, 2040, 2045]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_Monday(y, 1, 2))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday(2011, 1, 2))

    # 1月16日
    is = [1978, 1984, 1989, 1995]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_Monday(y, 1,16))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday(2006, 1,16))

    # 2月12日
    is = [1979, 1990, 1996, 2001, 2007, 2018, 2024, 2029, 2035, 2046]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_Monday(y, 2,12))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday(2011, 2,12))

    # 3月21日
    is = [1988, 2005, 2016, 2033, 2044]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_Monday(y, 3,21))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday(2011, 3,21))

    # 3月22日
    is = [1982, 1999, 2010, 2027]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_Monday(y, 3,22))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday(2011, 3,22))

    # 4月30日
    is = [1973, 1979, 1984, 1990, 2001, 2007, 2012, 2018, 2029, 2035, 2040, 2046]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_Monday(y, 4,30))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday(2011, 4,30))

    # 5月4日
    is = [1981, 1987, 1992, 1998]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_Monday(y, 5, 4))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday(2009, 5, 4))

    # 5月6日
    is = [1974, 1985, 1991, 1996, 2002, 2013, 2019, 2024, 2030, 2041, 2047]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_Monday(y, 5, 6))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday(2011, 5, 6))

    # 7月21日
    is = [1997]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_Monday(y, 7,21))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday(2003, 7,21))

    # 9月16日
    is = [1974, 1985, 1991, 1996, 2002]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_Monday(y, 9,16))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday(2013, 9,16))

    # 9月23日
    is = [2024]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_Monday(y, 9,23))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday(2013, 9,23))

    # 9月24日
    is = [1973, 1984, 1990, 2001, 2007, 2018, 2029, 2035, 2046]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_Monday(y, 9,24))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday(2012, 9,24))

    # 10月11日
    is = [1976, 1982, 1993, 1999]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_Monday(y,10,11))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday(2004,10,11))

    # 11月4日
    is = [1974, 1985, 1991, 1996, 2002, 2013, 2019, 2024, 2030, 2041, 2047]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_Monday(y,11, 4))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday(2011,11, 3))

    # 11月24日
    is = [1975, 1980, 1986, 1997, 2003, 2008, 2014, 2025, 2031, 2036, 2042]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_Monday(y,11,24))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday(2011,11,24))

    # 12月24日
    is = [1990, 2001, 2007, 2012, 2018, 2029, 2035, 2040, 2046]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_Monday(y,12,24))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday(2011,11,24))

    assert_equal(false,HolydayCalendar.isSubstituteHolyday_Monday())
    HolydayCalendar.new(2012,12,24)
    assert(HolydayCalendar.isSubstituteHolyday_Monday())

    assert_equal(false, HolydayCalendar.isSubstituteHolyday_Monday( 'a', 12, 24))
    assert_equal(false, HolydayCalendar.isSubstituteHolyday_Monday(2012,'a', 24))
    assert_equal(false, HolydayCalendar.isSubstituteHolyday_Monday(2012, 12,'a'))
  end

  def test_isSubstituteHolyday_ExceptMonday
    # 振替休日(月曜日以外)
    # 5月6日
    is = [2014, 2025, 2031, 2036, 2042]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_ExceptMonday(y, 5, 6))
    end
    is = [2009, 2015, 2020, 2026, 2037, 2043,2048]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday_ExceptMonday(y, 5, 6))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday_ExceptMonday(2011, 5, 6))

    assert_equal(false,HolydayCalendar.isSubstituteHolyday_ExceptMonday())
    HolydayCalendar.new(2009, 5, 6)
    assert(HolydayCalendar.isSubstituteHolyday_ExceptMonday())

    assert_equal(false, HolydayCalendar.isSubstituteHolyday_ExceptMonday( 'a',  5,  6))
    assert_equal(false, HolydayCalendar.isSubstituteHolyday_ExceptMonday(2009,'a',  6))
    assert_equal(false, HolydayCalendar.isSubstituteHolyday_ExceptMonday(2009,  5,'a'))
  end

  def test_isSubstituteHolyday
    # 振替休日(月曜日)
    # 1月2日
    is = [1978, 1984, 1989, 1995, 2006, 2012, 2017, 2023, 2034, 2040, 2045]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y, 1, 2))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2011, 1, 2))

    # 1月16日
    is = [1978, 1984, 1989, 1995]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y, 1,16))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2006, 1,16))

    # 2月12日
    is = [1979, 1990, 1996, 2001, 2007, 2018, 2024, 2029, 2035, 2046]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y, 2,12))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2011, 2,12))

    # 3月21日
    is = [1988, 2005, 2016, 2033, 2044]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y, 3,21))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2011, 3,21))

    # 3月22日
    is = [1982, 1999, 2010, 2027]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y, 3,22))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2011, 3,22))

    # 4月30日
    is = [1973, 1979, 1984, 1990, 2001, 2007, 2012, 2018, 2029, 2035, 2040, 2046]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y, 4,30))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2011, 4,30))

    # 5月4日
    is = [1981, 1987, 1992, 1998]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y, 5, 4))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2009, 5, 4))

    # 5月6日
    is = [1974, 1985, 1991, 1996, 2002, 2013, 2019, 2024, 2030, 2041, 2047]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y, 5, 6))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2011, 5, 6))

    # 7月21日
    is = [1997]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y, 7,21))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2003, 7,21))

    # 9月16日
    is = [1974, 1985, 1991, 1996, 2002]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y, 9,16))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2013, 9,16))

    # 9月23日
    is = [2024]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y, 9,23))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2013, 9,23))

    # 9月24日
    is = [1973, 1984, 1990, 2001, 2007, 2018, 2029, 2035, 2046]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y, 9,24))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2012, 9,24))

    # 10月11日
    is = [1976, 1982, 1993, 1999]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y,10,11))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2004,10,11))

    # 11月4日
    is = [1974, 1985, 1991, 1996, 2002, 2013, 2019, 2024, 2030, 2041, 2047]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y,11, 4))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2011,11, 3))

    # 11月24日
    is = [1975, 1980, 1986, 1997, 2003, 2008, 2014, 2025, 2031, 2036, 2042]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y,11,24))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2011,11,24))

    # 12月24日
    is = [1990, 2001, 2007, 2012, 2018, 2029, 2035, 2040, 2046]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y,12,24))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2011,11,24))

    # 振替休日(月曜日以外)
    # 5月6日
    is = [2014, 2025, 2031, 2036, 2042]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(2014, 5, 6))
    end
    is = [2009, 2015, 2020, 2026, 2037, 2043, 2048]
    is.each do |y|
      assert(HolydayCalendar.isSubstituteHolyday(y, 5, 6))
    end
    assert_equal(false,HolydayCalendar.isSubstituteHolyday(2011, 5, 6))

    assert_equal(false,HolydayCalendar.isSubstituteHolyday())
    HolydayCalendar.new(2012,12,24)
    assert(HolydayCalendar.isSubstituteHolyday())

    assert_equal(false, HolydayCalendar.isSubstituteHolyday( 'a', 12, 24))
    assert_equal(false, HolydayCalendar.isSubstituteHolyday(2012,'a', 24))
    assert_equal(false, HolydayCalendar.isSubstituteHolyday(2012, 12,'a'))
  end

  def test_isHolyday
    assert(HolydayCalendar.isHolyday(2011, 1, 1)) # 元日
    assert(HolydayCalendar.isHolyday(2011, 1,10)) # 成人の日
    assert(HolydayCalendar.isHolyday(2011, 2,11)) # 建国記念の日
    assert(HolydayCalendar.isHolyday(2011, 3,21)) # 春分の日
    assert(HolydayCalendar.isHolyday(2011, 4,29)) # 昭和の日
    assert(HolydayCalendar.isHolyday(2011, 5, 3)) # 憲法記念日
    assert(HolydayCalendar.isHolyday(2011, 5, 4)) # みどりの日
    assert(HolydayCalendar.isHolyday(2011, 5, 5)) # こどもの日
    assert(HolydayCalendar.isHolyday(2011, 7,18)) # 海の日  （第3月曜日）
    assert(HolydayCalendar.isHolyday(2011, 9,19)) # 敬老の日（第3月曜日）
    assert(HolydayCalendar.isHolyday(2011, 9,23)) # 秋分の日
    assert(HolydayCalendar.isHolyday(2010,10,11)) # 体育の日（第2月曜日）
    assert(HolydayCalendar.isHolyday(2011,11, 3)) # 文化の日
    assert(HolydayCalendar.isHolyday(2011,11,23)) # 勤労感謝の日
    assert(HolydayCalendar.isHolyday(2011,12,23)) # 天皇誕生日

    assert_equal(false, HolydayCalendar.isHolyday(2011, 1, 2)) # 日曜日
    assert_equal(false, HolydayCalendar.isHolyday(2011, 1, 3)) # 平日
    assert_equal(false, HolydayCalendar.isHolyday(2011, 1,15)) # 旧成人の日
    assert_equal(false, HolydayCalendar.isHolyday(2011, 7,20)) # 旧海の日
    assert_equal(false, HolydayCalendar.isHolyday(2011, 9,15)) # 旧敬老の日
    assert_equal(false, HolydayCalendar.isHolyday(2010,10,10)) # 旧体育の日

    assert(HolydayCalendar.isHolyday(2006, 5, 4)) # 国民の休日
    assert(HolydayCalendar.isHolyday(1995, 1,16)) # 振替休日(月曜日)
    assert(HolydayCalendar.isHolyday(2007, 2,12)) # 振替休日(月曜日)
    assert(HolydayCalendar.isHolyday(2009, 5, 6)) # 振替休日(月曜日以外)
  end
end
