require_relative 'holidays'
require_relative 'chinese'


start_date = Day.new(2032, 12, 15)

(1..24).each {
    new_moon = chinese_new_moon_before(gregorian_to_fixed(start_date))
    puts new_moon.to_gregorian
    start_date.month += 1
    if start_date.month >= 13 then
        start_date.month = 1
        start_date.year += 1
    end
}
