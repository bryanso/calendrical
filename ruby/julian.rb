#
#
# Calendrical Calculations Third Edition
# Nachum Dershowitz, Edward M. Reingold
# Cambridge University Press
# 2008
#

require_relative "gregorian"


#
# 3.1
#
def julian_leap_year?(j_year)
    r = j_year > 0 ? 0 : 3
    (j_year % 4) == r
end


#
# 3.2
#
EPOCH_JULIAN = fixed_from_gregorian(Day.new(0, DECEMBER, 30))


#
# 3.3
#
def fixed_from_julian(date)
    year = date.year
    month = date.month
    day = date.day

    if year < 0 then
        y = year + 1
    else
        y = year
    end

    if month <= 2 then
        correction = 0
    elsif julian_leap_year?(year) then
        correction = -1
    else
        correction = -2
    end

    EPOCH_JULIAN - 1 +
        365 * (y - 1) +
        ((y - 1) / 4).floor +
        ((367 * month - 362) / 12).floor +
        correction +
        day
end


def julian_to_fixed(j_date)
    fixed_from_julian(j_date)
end


def julian_puts(moment)
    day = fixed_to_julian(moment)
    time = clock_from_moment(moment)
    puts day.to_s + " " + time.to_s
end


#
# 3.4
#
def julian_from_fixed(date)
    date = date.floor

    approx = ((4 * (date - EPOCH_JULIAN) + 1464) / 1461).floor

    if approx <= 0 then
        year = approx - 1
    else
        year = approx
    end

    prior_days = date - fixed_from_julian(Day.new(year, JANUARY, 1))

    if date < fixed_from_julian(Day.new(year, MARCH, 1)) then
        correction = 0
    elsif julian_leap_year?(year) then
        correction = 1
    else
        correction = 2
    end

    month = ((12 * (prior_days + correction) + 373) / 367).floor

    day = date - fixed_from_julian(Day.new(year, month, 1)) + 1

    Day.new(year, month, day)
end


def fixed_to_julian(date)
    julian_from_fixed(date)
end


class Numeric
    def to_julian
        fixed_to_julian(self)
    end
end


#
# 3.15
#
# Given a particular month and day in Julian, there can be one or two
# occurrences of the same month-day in a Gregorian year.  This function
# returns a sequence of fixed dates that has the given month-day in
# the given Gregorian year.
#
def julian_in_gregorian(j_month, j_day, g_year)

    result = []
    jan1 = gregorian_new_year(g_year)
    y0 = julian_from_fixed(jan1).year
    if y0 == -1 then
        y1 = 1
    else
        y1 = y0 + 1
    end

    date1 = fixed_from_julian(Day.new(y0, j_month, j_day))
    date2 = fixed_from_julian(Day.new(y1, j_month, j_day))

    if gregorian_year_range(g_year).include?(date1) then
        result << date1
    end

    if gregorian_year_range(g_year).include?(date2) then
        result << date2
    end

    result
end


# puts fixed_from_julian(Day.new(1582, OCTOBER, 4))
# puts julian_from_fixed(fixed_from_julian(Day.new(1582, OCTOBER, 4)))
# puts julian_in_gregorian(FEBRUARY, 28, 41104)
