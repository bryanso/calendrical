require_relative 'time'

d = gregorian_to_fixed(Day.new(2020, 12, 17))
t1 = sunrise(d, SAN_FRANCISCO)
t2 = sunset(d, SAN_FRANCISCO)
puts t1.to_clock
puts t2.to_clock

d = gregorian_to_fixed(Day.new(2020, 12, 18))
t1 = sunrise(d, GREENWICH)
t2 = sunset(d, GREENWICH)
puts t1.to_clock
puts t2.to_clock

d = gregorian_to_fixed(Day.new(1945, 11, 12))
t1 = sunrise(d, URBANA)
t2 = sunset(d, URBANA)
puts t1.to_clock
puts t2.to_clock


