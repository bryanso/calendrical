#
#
# Calendrical Calculations Third Edition
# Nachum Dershowitz, Edward M. Reingold
# Cambridge University Press
# 2008
#

require_relative "julian"


#
# 2.31
#
def independence_day(g_year)
    fixed_from_gregorian(Day.new(g_year, JULY, 4))
end


#
# 2.35
#
def labor_day(g_year)
    first_kday(MONDAY, Day.new(g_year, SEPTEMBER, 1))
end


#
# 2.36
#
def memorial_day(g_year)
    last_kday(MONDAY, Day.new(g_year, MAY, 31))
end


#
# p. 27
#
def thanksgiving(g_year)
    nth_kday(4, THURSDAY, Day.new(g_year, NOVEMBER, 1))
end


#
# 2.37
#
# US Election Day is the Tuesday after the first Monday in November,
# which is the first Tuesday on or after November 2
#
def election_day(g_year)
    first_kday(TUESDAY, Day.new(g_year, NOVEMBER, 2))
end


#
# 2.38
#
def daylight_saving_start(g_year)
    nth_kday(2, SUNDAY, Day.new(g_year, MARCH, 1))
end


#
# 2.39
#
def daylight_saving_end(g_year)
    first_kday(SUNDAY, Day.new(g_year, NOVEMBER, 1))
end


#
# 2.40
#
def christmas(g_year)
    fixed_from_gregorian(Day.new(g_year, DECEMBER, 25))
end


def new_year(g_year)
    fixed_from_gregorian(Day.new(g_year, JANUARY, 1))
end


def new_year_eve(g_year)
    fixed_from_gregorian(Day.new(g_year - 1, DECEMBER, 31))
end


#
# 2.41
#
def advent(g_year)
    kday_nearest(SUNDAY, fixed_from_gregorian(Day.new(g_year, NOVEMBER, 30)))
end


#
# 2.42
#
def epiphany(g_year)
    first_kday(SUNDAY, Day.new(g_year, JANUARY, 2))
end


def assumption(g_year)
    fixed_from_gregorian(Day.new(g_year - 1, AUGUST, 15))
end



# for i = 2000 to 2030 do
#     ? gregorian_from_fixed(thanksgiving(i))
# end for


#
# 8.1 auxiliary
#
# Paschal Moon is the first full moon on or after Vernal Equinox
# with the simplifying assumption that the latter is always on March 21
#
def paschal_moon_orthodox(g_year)
    #
    # Moon phase number on April 5 (half a month after March 21)
    #
    shifted_epact = (14 + 11 * (g_year % 19)) % 30

    j_year = g_year > 0 ? g_year : g_year - 1

    #
    # Paschal moon (moon phase no. 14) happens to be simply April 19
    # minus moon phase no. on April 5
    #
    fixed_from_julian(Day.new(j_year, APRIL, 19)) - shifted_epact
end


#
# 8.1
#
# Still used by Orthodox churches except those in Finland
#
def orthodox_easter(g_year)
    kday_after(SUNDAY, paschal_moon_orthodox(g_year))
end


#
# 8.3 auxiliary
#
def paschal_moon(g_year)
    century = (g_year / 100).floor + 1

    shifted_epact = 
        (14 + 
         11 * (g_year % 19) -
         (3.0/4 * century).floor +
         (1.0/25 * (5 + 8 * century)).floor) % 30

    if shifted_epact == 0 or 
        (shifted_epact == 1 and 10 < (g_year % 19)) then
        adjusted_epact = shifted_epact + 1
    else
        adjusted_epact = shifted_epact
    end
    
    fixed_from_gregorian(Day.new(g_year, APRIL, 19)) - adjusted_epact
end


#
# 8.3 
#
def easter(g_year)
    kday_after(SUNDAY, paschal_moon(g_year))
end



y = 2018
# puts paschal_moon_orthodox(y)
# puts orthodox_easter(y)
# puts "Julian"
# puts julian_from_fixed(paschal_moon_orthodox(y))
# puts julian_from_fixed(orthodox_easter(y))
# puts "Gregorian"
# puts gregorian_from_fixed(paschal_moon_orthodox(y))
# puts gregorian_from_fixed(orthodox_easter(y))
# puts easter(y)
# puts fixed_to_gregorian(easter(y))

