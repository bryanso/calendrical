require_relative 'holidays'
require_relative 'chinese'


start_date = Day.new(2032, 12, 15)

(1..24).each {
    m = solar_term_on_or_after(gregorian_to_fixed(start_date))
    puts m.to_gregorian

    start_date.day += 15
    m = solar_term_on_or_after(gregorian_to_fixed(start_date))
    puts m.to_gregorian

    start_date.day = 1
    start_date.month += 1
    if start_date.month >= 13 then
        start_date.month = 1
        start_date.year += 1
    end
}
