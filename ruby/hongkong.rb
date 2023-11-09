#
# Calendrical Calculations Third Edition
# Nachum Dershowitz, Edward M. Reingold
# Cambridge University Press
# 2008
#

include Math
require_relative "gregorian"
require_relative "locale"
require_relative "time"
 
 
def hongkong_winter(g_year)
    standard_from_universal(
        solar_longitude_after(
            WINTER, 
            gregorian_new_year(g_year)),
        HONG_KONG)
end
 
def san_francisco_winter(g_year)
    standard_from_universal(
        solar_longitude_after(
            WINTER, 
            gregorian_new_year(g_year)),
        SAN_FRANCISCO)
end


w = hongkong_winter(2019)

date = gregorian_from_fixed(w)
time = w.to_clock

puts date
puts time


w = san_francisco_winter(2019)
date = gregorian_from_fixed(w)
time = w.to_clock

puts date
puts time

