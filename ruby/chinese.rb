require_relative "time"


CHINESE_SKY_STEMS = [
    "甲",
    "乙",
    "丙",
    "丁",
    "戊",
    "己",
    "庚",
    "辛",
    "壬",
    "癸"
]


CHINESE_EARTH_BRANCHES = [
    "子",
    "丑",
    "寅",
    "卯",
    "辰",
    "巳",
    "午",
    "未",
    "申",
    "酉",
    "戌",
    "亥"
]


CHINESE_SOLAR_TERMS = [
    "立春",
    "雨水",
    "驚蟄",
    "春分",
    "清明",
    "谷雨",
    "立夏",
    "小滿",
    "芒種",
    "夏至",
    "小暑",
    "大暑",
    "立秋",
    "處暑",
    "白露",
    "秋分",
    "寒露",
    "霜降",
    "立冬",
    "小雪",
    "大雪",
    "冬至",
    "小寒",
    "大寒"
]


CHINESE_MONTH_NAMES = [
    "正",
    "二",
    "三",
    "四",
    "五",
    "六",
    "七",
    "八",
    "九",
    "十",
    "十一",
    "十二"
]


CHINESE_DAY_NAMES = [
    "初一",
    "初二",
    "初三",
    "初四",
    "初五",
    "初六",
    "初七",
    "初八",
    "初九",
    "初十",
    "十一",
    "十二",
    "十三",
    "十四",
    "十五",
    "十六",
    "十七",
    "十八",
    "十九",
    "二十",
    "廿一",
    "廿二",
    "廿三",
    "廿四",
    "廿五",
    "廿六",
    "廿七",
    "廿八",
    "廿九",
    "三十",
]


def chinese_month_name(m)
    CHINESE_MONTH_NAMES[m - 1] + "月"
end


def chinese_day_name(d)
    CHINESE_DAY_NAMES[d - 1]
end


def minor_solar_term_name(i)
    #
    # Array in Ruby starts at zero but solar terms counted from 1
    #
    i = i - 1 
    CHINESE_SOLAR_TERMS[i * 2]
end


def major_solar_term_name(i)
    #
    # Array in Ruby starts at zero but solar terms counted from 1
    #
    i = i - 1 
    CHINESE_SOLAR_TERMS[i * 2 + 1]
end


#
# 17.1
#
# Last major solar term on or before a date
#
# Strangely despite the name "current" if this function was passed the
# exact moment of a solar term it will return the last one.  But if we
# passed even m + 0.001 then it will return the current solar term.
#
def current_major_solar_term(date)
    s = solar_longitude(
        universal_from_standard(date, chinese_location(date)))

    amod((2 + (s / 30.0).floor), 12)
end


def last_major_solar_term(date)
    current_major_solar_term(date)
end


#
# 17.2
#
def chinese_location(t)
    year = gregorian_year_from_fixed(t)

    Position.new(
        Angle.new(39, 55, 0).to_degree,
        Angle.new(116, 25, 0).to_degree,
        43.5,
        year < 1929 ? (1397.0 / 180 / 24) : (8.0 / 24)
    )
end


#
# 17.3
#
def chinese_solar_longitude_on_or_after(lam, date)
    t = solar_longitude_after(
        lam,
        universal_from_standard(date, chinese_location(date)))

    standard_from_universal(t, chinese_location(t))
end


#
# 17.4
#
def major_solar_term_on_or_after(date)
    s = solar_longitude(midnight_in_china(date))

    l = (30 * (s / 30.0).ceil) % 360

    chinese_solar_longitude_on_or_after(l, date)
end


#
# 17.5
#
# Last minor solar term on or before a date
#
# Strangely despite the name "current" if this function was passed the
# exact moment of a solar term it will return the last one.  But if we
# passed even m + 0.001 then it will return the current solar term.
#
def current_minor_solar_term(date)
    s = solar_longitude(
        universal_from_standard(date, chinese_location(date)))

    amod((3 + ((s - 15) / 30.0).floor), 12)
end


def last_minor_solar_term(date)
    current_minor_solar_term(date)
end


#
# 17.6
#
def minor_solar_term_on_or_after(date)
    s = solar_longitude(midnight_in_china(date))

    l = (30 * ((s - 15) / 30.0).ceil + 15) % 360

    chinese_solar_longitude_on_or_after(l, date)
end


#
# Kludgy combinaction of major and minor
#
def solar_term_date_on_or_after(date)
    s1 = major_solar_term_on_or_after(date)
    s2 = minor_solar_term_on_or_after(date)
    [s1, s2].min
end


def solar_term_on_or_after(date)
    d = solar_term_date_on_or_after(date)
    s = solar_longitude(d)
    amod(4 + (s / 15.0).floor, 24)
end


#
# 17.7
#
def midnight_in_china(date)
    universal_from_standard(date, chinese_location(date))
end


#
# 17.8
#
def chinese_winter_solstice_on_or_before(date)
    approx = estimate_prior_solar_longitude(
        WINTER,
        midnight_in_china(date + 1)
    ) 
    min_search(
        approx.floor - 1,
        lambda { |i| WINTER < solar_longitude(midnight_in_china(i + 1)) }
    )
end


#
# 17.9
#
def chinese_new_moon_on_or_after(date)
    t = new_moon_at_or_after(midnight_in_china(date))

    standard_from_universal(t, chinese_location(t)).floor
end


#
# 17.10
#
def chinese_new_moon_before(date)
    t = new_moon_before(midnight_in_china(date))

    standard_from_universal(t, chinese_location(t)).floor
end


#
# 17.11
#
# This (Boolean) function works only if the date passed is the
# first day of a month (Chinese calendar)
#
def chinese_no_major_solar_term(date)
    next_new_moon = chinese_new_moon_on_or_after(date + 1)
    last_major_solar_term(date) == last_major_solar_term(next_new_moon)
end


#
# 17.12
#
def chinese_prior_leap_month(m_prime, m)
    (m >= m_prime) and
    (chinese_no_major_solar_term(m) or
     chinese_prior_leap_month(m_prime, chinese_new_moon_before(m)))
end


#
# 17.13
#
def chinese_new_year_in_sui(date)   ## The sui containing this date
    s1 = chinese_winter_solstice_on_or_before(date)
    s2 = chinese_winter_solstice_on_or_before(s1 + 370)
    m12 = chinese_new_moon_on_or_after(s1 + 1)
    m13 = chinese_new_moon_on_or_after(m12 + 1)
    next_m11 = chinese_new_moon_before(s2 + 1)
 
    if ((next_m11 - m12) / MEAN_SYNODIC_MONTH).round == 12 and
        (chinese_no_major_solar_term(m12) or
         chinese_no_major_solar_term(m13)) then
        #
        # Very rare condition 閏十二月
        #
        chinese_new_moon_on_or_after(m13 + 1)
    else
        m13
    end
end


#
# 17.14
#
def chinese_new_year_on_or_before(date)
    new_year = chinese_new_year_in_sui(date)
    if date >= new_year then
        new_year
    else
        chinese_new_year_in_sui(date - 180)
    end
end


CHINESE_EPOCH = fixed_from_gregorian(Day.new(-2636, FEBRUARY, 15))

class Chinese_Day
    attr_accessor :cycle,
                  :year, 
                  :month, 
                  :leap, 
                  :day

    def initialize(c, y, m, l, d)
        @cycle = c
        @year = y
        @leap = l
        @month = m
        @day = d
    end

    def to_s
        @cycle.to_s + "/" + @year.to_s + "/" + @month.to_s + 
            (@leap ? "'" : "") + "/" + @day.to_s
    end
end


def chinese_from_fixed(date)
    s1 = chinese_winter_solstice_on_or_before(date)
    s2 = chinese_winter_solstice_on_or_before(s1 + 370)

    m12 = chinese_new_moon_on_or_after(s1 + 1)
    next_m11 = chinese_new_moon_before(s2 + 1)
    m = chinese_new_moon_before(date + 1)

    leap_year = (((next_m11 - m12) / MEAN_SYNODIC_MONTH).round) == 12

    month = ((m - m12) / MEAN_SYNODIC_MONTH).round - 
        ((leap_year and chinese_prior_leap_month(m12, m)) ? 1 : 0)

    month = amod(month, 12)

    leap_month = (
        leap_year and
        chinese_no_major_solar_term(m) and
        not chinese_prior_leap_month(m12, chinese_new_moon_before(m)))

    elapsed_years = (1.5 - month / 12.0 + (date - CHINESE_EPOCH) / MEAN_TROPICAL_YEAR).floor

    cycle = ((elapsed_years - 1) / 60.0).floor + 1

    year = amod(elapsed_years, 60)

    day = date - m + 1

    Chinese_Day.new(cycle, year, month, leap_month, day)
end


def fixed_to_chinese(date)
    chinese_from_fixed(date)
end


class Numeric
    def to_chinese
        chinese_from_fixed(self)
    end
end


#
# 17.17
#
def fixed_from_chinese(date)
    mid_year = (
        CHINESE_EPOCH +
        ((date.cycle - 1) * 60 + date.year - 1 + 0.5) * MEAN_TROPICAL_YEAR
    ).floor
    
    new_year = chinese_new_year_on_or_before(mid_year)

    p = chinese_new_moon_on_or_after(
        new_year + (date.month - 1) * 29)

    d = chinese_from_fixed(p)

    prior_new_moon = 
        (date.month == d.month and date.leap == d.leap) ? 
            p :
            chinese_new_moon_on_or_after(p + 1)

    prior_new_moon + date.day - 1
end


def chinese_year_to_stem(year)
    CHINESE_SKY_STEMS[(year - 1) % 10]
end


def chinese_year_to_branch(year)
    CHINESE_EARTH_BRANCHES[(year - 1) % 12]
end

def chinese_year_to_stem_branch(year)
    chinese_year_to_stem(year) + chinese_year_to_branch(year)
end   
