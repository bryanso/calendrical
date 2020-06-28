#
# Calendrical Calculations Third Edition
# Nachum Dershowitz, Edward M. Reingold
# Cambridge University Press
# 2008
#

include Math
require "date"


#
# Math utility
#

class Numeric
    def to_radian
        self * PI / 180
    end

    def to_degree
        self * 180 / PI
    end

    def sign
        if self < 0 then
            -1
        elsif self > 0 then
            1
        else
            0
        end
    end

    def to_clock
        clock_from_moment(self)
    end
end


#
# Ruby's trig routines take in radian unit but the book has degrees.
# It's convenient to define these new trig routines in degree unit.
#
def sin_degree(a)
    sin(a.to_radian)
end


def cos_degree(a)
    cos(a.to_radian)
end


def tan_degree(a)
    tan(a.to_radian)
end


#
# 13.6
#
def arctan_degree(y, x)
    a = atan(y / x).to_degree

    if x == 0 and y != 0 then
        r = y.sign * 90
    elsif x >= 0
        r = a
    else
        r = a + 180
    end

    r % 360
end


def arcsin_degree(x)
    asin(x).to_degree
end


def arccos_degree(x)
    acos(x).to_degree
end


#
# 1.22
#
# Adjusted mod function, is defined as
#
#    a amod y == y        if x mod y == 0
#                x mod y  otherwise
#
def amod(x, y)
    r = x % y
    r == 0? y : r
end


#
# 1.28
#
def min_search(k, f, limit = 1000000)
    #
    # Search forward until f(k) is true and return k as the first 
    # true argument
    #
    if limit <= 0 then
        raise 'min_search exceeds limit'
    end

    if f.call(k) then
        k
    else
        min_search(k + 1, f, limit - 1)
    end
end


#
# 1.29
#
def max_search(k, f, limit = 1000000)
    #
    # Search forward until f(k) is false and return (k-1) as the last 
    # true argument
    #
    if limit <= 0 then
        raise 'max_search exceeds limit'
    end

    if not f.call(k) then
        k - 1
    else
        max_search(k + 1, f, limit - 1)
    end
end


#
# 1.31
#
def generic_binary_search(u, v, f, g)
    x = (u + v) / 2.0

    if f.call(u, v) then
        #
        # f is a termination function, taking current lower bound,
        # upper bound as arguments; returning true or false
        #
        x
    elsif g.call(x) then
        generic_binary_search(u, x, f, g)
    else
        generic_binary_search(x, v, f, g)
    end
end


#
# 1.32
#
def angular_binary_search(function, y, a, b)
    f = lambda {|l, u| (u - l) < (10 ** -5)}
    g = lambda {|x| (function.call(x) - y) % 360 < 180}
    generic_binary_search(a, b, f, g)
end


class Position
    attr_accessor :latitude, 
                  :longitude, 
                  :elevation,   # In meter
                  :zone         # In fraction of a day

    def initialize(latitude, longitude, elevation = 0, zone = 0)
        @latitude = latitude
        @longitude = longitude
        @elevation = elevation
        @zone = zone
    end

    def to_s
        @latitude.to_s + ", " + @longitude.to_s + ", " + @elevation.to_s + ", " + @zone.to_s
    end
end


class Point
    attr_accessor :x, :y, :z

    def initialize(x, y, z = nil)
        @x = x
        @y = y
        @z = z
    end

    def to_s
        if z == nil then
            "(" + x.to_s + ", " + y.to_s + ")"
        else
            "(" + x.to_s + ", " + y.to_s + ", " + z.to_s + ")"
        end
    end
end


#
# 1.36
#
# Angles can be described in terms of a sequence of degrees, arc minutes 
# and arc seconds
#
class Angle
    attr_accessor :degree, 
                  :minute, 
                  :second

    def initialize(d = 0, m = 0, s = 0)
        @degree = d
        @minute = m
        @second = s
    end

    #
    # 1.37
    #
    # Given angle alpha as a real number degrees, convert it to an Angle 
    #
    def self.from_degree(alpha)
        d = alpha.floor
        m = (60 * (alpha % 1)).floor
        s = (alpha * 60 * 60) % 60

        new(d, m, s)
    end

    def to_degree
        @degree + @minute / 60.0 + @second / 3600.0
    end

    def to_radian
        self.to_degree * PI / 180
    end

    def to_s
        @degree.to_s + "° " + @minute.to_s + "' " + @second.to_s + '"'
    end
end


#
# Calendar Routines
#

EPOCH = 0

#
# 1.1
#
# R.D., Rata Die, Fixed date -- elapsed day since the onset of
# Monday, January 1, 1 (Gregorian)
#
def rd(t)
   t - EPOCH
end


#
# 1.3
#
# Julian day number
# Julian days counted backward and forward from
#
# JD 0 == Noon, Monday, January 1, 4713 B.C.E
#      == Noon, Monday, November 24, -4713 (Gregorian)
#
EPOCH_JD = -1721424.5


#
# 1.4
#
def moment_from_jd(jd)
    jd + EPOCH_JD
end


#
# 1.5
#
def jd_from_moment(t)
    t - EPOCH_JD
end


#
# 1.6
#
# Modified Julian day number for convenience so fixed day numbers
# of recent years are not negative
#
EPOCH_MJD = 678576


#
# 1.7
#
def fixed_from_mjd(mjd)
    mjd + EPOCH_MJD
end


#
# 1.8
#
def mjd_from_fixed(date)
    date - EPOCH_MJD
end 


#
# 1.9
#
def fixed_from_moment(t)
    t.floor
end 


#
# 1.10
#
def fixed_from_jd(jd)
    moment_from_jd(jd).floor
end


#
# 1.11
#
def jd_from_fixed(date)
    jd_from_moment(date)
end


#
# 1.16
#
# x % 1 returns the fractional part of x
#
def time_from_moment(t)
    t % 1
end


#
# Round to nearest second for a moment t
#
def round_to_second(t)
    ((t * 24 * 60 * 60) / (24 * 60 * 60)).round
end


#
# Day is a structure of { year, month, day }
# (The name Date is used by Ruby)
#

class Day
    attr_accessor :year, 
                  :month, 
                  :day

    def initialize(y, m, d)
        @year = y
        @month = m
        @day = d
    end

    def to_s
        @year.to_s + "/" + @month.to_s + "/" + @day.to_s
    end
end

#
# Clock is a structure of { hour, minute, second }
#

class Clock
    attr_accessor :hour, 
                  :minute, 
                  :second

    def initialize(h, m, s)
        @hour = h
        @minute = m
        @second = s
    end

    def to_s
        @hour.to_s + ":" + @minute.to_s + ":" + @second.to_s
    end
end


#
# 1.34
#
# Convert the clock time into a fraction of a day
#
#                         s
#                   m + ---
#       1                60
#     ---- * ( h + --------- )
#      24              60
#
def time_from_clock(clock)
    h = clock.hour
    m = clock.minute
    s = clock.second

    (h + (m + s / 60.0) / 60.0) / 24.0
end


#
# 1.35
#
# Convert the fractional part of rd moment t to clock components
#
def clock_from_moment(t)
    time = time_from_moment(t)
    h = (time * 24).floor
    m = ((time * 24 * 60) % 60).floor
    s = (time * 24 * 60 * 60) % 60

    Clock.new(h, m, s)
end


#
# 1.44 to 1.50
#
SUNDAY = 0
MONDAY = SUNDAY + 1
TUESDAY = SUNDAY + 2
WEDNESDAY = SUNDAY + 3
THURSDAY = SUNDAY + 4
FRIDAY = SUNDAY + 5
SATURDAY = SUNDAY + 6


#
# 1.51
#
def day_of_week_from_fixed(date)
    (date - SUNDAY) % 7
end


#
# 1.53
#
# Find the date that is a k-day (day of week is k) on or
# before a fixed RD date
#
def kday_on_or_before(k, date)
    date - day_of_week_from_fixed(date - k)
end


#
# 1.58
#
def kday_on_or_after(k, date)
    kday_on_or_before(k, date + 6)
end


#
# 1.59
#
def kday_nearest(k, date)
    kday_on_or_before(k, date + 3)
end


#
# 1.60
#
def kday_before(k, date)
    kday_on_or_before(k, date - 1)
end


#
# 1.61
#
def kday_after(k, date)
    kday_on_or_before(k, date + 7)
end

# puts rd(10)
# puts moment_from_jd(10)
# puts jd_from_moment(10)
# puts fixed_from_moment(10.123)
# puts jd_from_fixed(fixed_from_jd(0.5))
