require_relative 'gregorian'
require_relative 'epoch'
require_relative 'time'

PALO_ALTO = Position.new(
    Angle.new(37.0, 28.0, 5.9484).to_degree,
    Angle.new(-122.0, 8.0, 38.1696).to_degree,
    28.0,
    -8.0 / 24
)           


def day_length(date, locale)
    a = sunrise(date, locale)
    b = sunset(date, locale)
    puts clock_from_moment(a)
    puts clock_from_moment(b)
    puts (b-a) * 24.0
    puts ""
end
    

d1 = gregorian_to_fixed(Day.new(2021, 12, 20))
day_length(d1, PALO_ALTO)

d1 = gregorian_to_fixed(Day.new(2021, 12, 21))
day_length(d1, PALO_ALTO)

d1 = gregorian_to_fixed(Day.new(2021, 12, 22))
day_length(d1, PALO_ALTO)

d1 = gregorian_to_fixed(Day.new(2021, 12, 23))
day_length(d1, PALO_ALTO)

d1 = gregorian_to_fixed(Day.new(2021, 12, 24))
day_length(d1, PALO_ALTO)
