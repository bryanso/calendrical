#
#
# Calendrical Calculations Third Edition
# Nachum Dershowitz, Edward M. Reingold
# Cambridge University Press
# 2008
#

require_relative "epoch"


#
# 2.3
#
EPOCH_GREGORIAN = 1


#
# 2.4 - 2.15
#

JANUARY = 1
FEBRUARY = 2
MARCH = 3
APRIL = 4
MAY = 5
JUNE = 6
JULY = 7
AUGUST = 8
SEPTEMBER = 9
OCTOBER = 10
NOVEMBER = 11
DECEMBER = 12


#
# 2.16
#
def gregorian_leap_year?(g_year)
    (g_year % 4) == 0 and not [100, 200, 300].include?(g_year % 400) 
end
  

#
# 2.17
#
def fixed_from_gregorian(g_date)
    year = g_date.year
    month = g_date.month
    day = g_date.day

    if month <= 2 then
        correction = 0
    elsif gregorian_leap_year?(year) then
        correction = -1
    else
        correction = -2
    end

    EPOCH_GREGORIAN - 1 + 
        365 * (year - 1) + 
        ((year - 1) / 4).floor -
        ((year - 1) / 100).floor +
        ((year - 1) / 400).floor +
        ((367 * month - 362) / 12).floor +
        day +
        correction
end

def gregorian_to_fixed(g_date)
    fixed_from_gregorian(g_date)
end


#
# 2.18
#
def gregorian_new_year(g_year)
    fixed_from_gregorian(Day.new(g_year, JANUARY, 1))
end


#
# 2.19
#
def gregorian_year_end(g_year)
    fixed_from_gregorian(Day.new(g_year, DECEMBER, 31))
end


#
# 2.20
#
def gregorian_year_range(g_year)
    gregorian_new_year(g_year) .. gregorian_year_end(g_year)
end


#
# 2.21
#
def gregorian_year_from_fixed(date)
    date = date.floor
    d0 = date - EPOCH_GREGORIAN

    n400 = (d0 / 146097).floor               # day 146097 is last day of 400-year cycle
    d1 = d0 % 146097

    n100 = (d1 / 36524).floor                # last day of 100-year cycle
    d2 = d1 % 36524

    n4 = (d2 / 1461).floor                   # last day of 4-year cycle
    d3 = d2 % 1461

    n1 = (d3 / 365).floor

    year = 400 * n400 + 100 * n100 + 4 * n4 + n1
    
    n100 == 4 or n1 == 4 ? year : year + 1
end


#
# 2.23
#
def gregorian_from_fixed(date)
    date = date.floor
    year = gregorian_year_from_fixed(date)

    prior_days = date - gregorian_new_year(year)

    if date < fixed_from_gregorian(Day.new(year, MARCH, 1)) then
        correction = 0
    elsif gregorian_leap_year?(year) then
        correction = 1
    else
        correction = 2
    end

    month = ((12 * (prior_days + correction) + 373) / 367).floor

    day = 1 + date - fixed_from_gregorian(Day.new(year, month, 1))

    Day.new(year, month, day)
end


def fixed_to_gregorian(date)
    gregorian_from_fixed(date)
end


class Numeric
    def to_gregorian
        gregorian_from_fixed(self)
    end
end


def gregorian_puts(moment)
    day = fixed_to_gregorian(moment)
    time = clock_from_moment(moment)
    puts day.to_s + " " + time.to_s
end


#
# 2.24
#
def gregorian_date_difference(g_date1, g_date2)
    fixed_from_gregorian(g_date2) - fixed_from_gregorian(g_date1)
end


#
# 2.25
#
def day_number(g_date)
    gregorian_date_difference(
        gregorian_year_end(g_date.year - 1),
        g_date)
end


#
# 2.26
#
def days_remaining(g_date)
    gregorian_date_difference(
        g_date,
        gregorian_year_end(g_date.year))
end


#
# 2.32
#
# Find the nth k-day (day of week) on or after a gregorian date
# (n can be negative to find before)
#
def nth_kday(n, k, g_date)
    if n > 0 then
        7 * n + kday_before(k, fixed_from_gregorian(g_date))
    else
        7 * n + kday_after(k, fixed_from_gregorian(g_date))
    end
end


#
# 2.33
# 
def first_kday(k, g_date)
    nth_kday(1, k, g_date)
end


#
# 2.34
#
def last_kday(k, g_date)
    nth_kday(-1, k, g_date)
end


# puts gregorian_from_fixed(577736)
# puts fixed_from_gregorian(Day.new(1582, OCTOBER, 15))


def today
    d = Date.today
    Day.new(d.year, d.month, d.day)
    gregorian_to_fixed(d)
end


