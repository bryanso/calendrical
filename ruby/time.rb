#
# Calendrical Calculations Third Edition
# Nachum Dershowitz, Edward M. Reingold
# Cambridge University Press
# 2008
#

include Math
require_relative "constants"
require_relative "gregorian"
require_relative "locale"


BOGUS = (2**(0.size * 8 -2) -1)


# 13.5
#
# If a spherical Earth is assumed, the direction (measured in degrees, east of due
# north) of location 'focus', along a great circle, when one stands at location 'locale', 
# can be determined by spherical trigonometry 
#
def direction(locale, focus) 
    p0 = locale.latitude
    p1 = focus.latitude

    s0 = locale.longitude
    s1 = focus.longitude

    y = sin_degree(s1 - s0)
    x = cos_degree(p0) * tan_degree(p1) - sin_degree(p0) * cos_degree(s0 - s1)

    if (x == 0 and y == 0) or (focus.latitude == 90) then
        0
    elsif focus.latitude == -90 then
        180
    else
        arctan_degree(y, x)
    end
end


#
# 13.7
#
def zone_from_longitude(p)
    p / 360
end


#
# 13.8
#
def universal_from_local(t, locale)
    t - zone_from_longitude(locale.longitude)
end


#
# 13.9
#
def local_from_universal(t, locale)
    t + zone_from_longitude(locale.longitude)
end


#
# 13.10
#
def standard_from_universal(t, locale)
    t + locale.zone
end


#
# 13.11
#
def universal_from_standard(t, locale)
    t - locale.zone
end


#
# 13.12
#
def standard_from_local(t, locale)
    standard_from_universal(
        universal_from_local(t, locale), 
        locale)
end


#
# 13.13
#
def local_from_standard(t, locale)
    local_from_universal(
        universal_from_standard(t, locale),
        locale)
end


#
# 13.14
#
def ephemeris_correction(t)
    year = gregorian_year_from_fixed(t.floor)

    c = gregorian_date_difference(
        Day.new(1900, JANUARY, 1),
        Day.new(year, JULY, 1)) / 36525.0

    x = 0.5 + gregorian_date_difference(
        Day.new(1810, JANUARY, 1),
        Day.new(year, JANUARY, 1))

    if 1988 <= year and year <= 2019 then
        (year - 1933) / 86400.0

    elsif 1900 <= year and year <= 1987 then
            -0.00002 + 0.000297 * c + 0.025184 * c ** 2 -
            0.181133 * c ** 3 + 0.553040 * c ** 4 -
            0.861938 * c ** 5 + 0.677066 * c ** 6 -
            0.212591 * c ** 7

    elsif 1800 <= year and year <= 1899 then
        -0.000009 + 0.003844 * c + 0.083563 * c ** 2 +
            0.865736 * c ** 3 + 4.867575 * c ** 4 + 15.845535 * c ** 5 +
            31.332267 * c ** 6 + 38.291999 * c ** 7 + 28.316289 * c ** 8 +
            11.636204 * c ** 9 + 2.043794 * c ** 10

    elsif 1700 <= year and year <= 1799 then
        (8.118780842 -
         0.005092142 * (year - 1700) +
         0.003336121 * (year - 1700) ** 2 -
         0.0000266484 * (year - 1700) ** 3) / 86400.0

    elsif 1620 <= year and year <= 1699 then
        (196.58333 -
         4.0675 * (year - 1600) +
         0.0219167 * (year - 1600) ** 2) / 86400.0
    else
        (x ** 2 / 41048480.0 - 15) / 86400.0
    end
end


#
# 13.15
#
def dynamical_from_universal(t)
    t + ephemeris_correction(t)
end

def universal_to_dynamical(t)
    dynamical_from_universal(t)
end


#
# 13.16
#
def universal_from_dynamical(t)
    t - ephemeris_correction(t)
end

def dynamical_to_universal(t)
    universal_from_dynamical(t)
end


#
# 13.18
#
J2000 = 0.5 + gregorian_new_year(2000)


#
# 13.17
#
def julian_centuries(t)
    (dynamical_from_universal(t) - J2000) / 36525
end


#
# 13.19
#
def equation_of_time(t)
    c = julian_centuries(t)

    l = (280.46645 +        ## Degrees need to become radian
        36000.76983 * c +        ## for Ruby trig functions
        0.0003032 * c ** 2)

    anomaly = (357.52910 +       ## ditto
        35999.05030 * c -
        0.0001559 * c ** 2 -
        0.00000048 * c ** 3)

    eccentricity = 0.016708617 -
        0.000042037 * c -
        0.0000001236 * c ** 2

    epsilon = obliquity(t)

    y = tan_degree(epsilon / 2) ** 2

    equation = 1 / (2 * PI) *
        (y * sin_degree(2 * l) -
            2 * eccentricity * sin_degree(anomaly) +
            4 * eccentricity * y * sin_degree(anomaly) * cos_degree(2 * l) -
            0.5 * y ** 2 * sin_degree(4 * l) -
            1.25 * eccentricity ** 2 * sin_degree(2 * anomaly))

    equation.sign * [equation.abs, 0.5].min    ## 0.5 == 12 hours
end


#
# 13.20
#
def apparent_from_local(t, locale)
   t + equation_of_time(universal_from_local(t, locale))
end


#
# 13.21
#
def local_from_apparent(t, locale)
    t - equation_of_time(universal_from_local(t, locale))
end


#
# 13.22
#
def midnight(date, locale)
    standard_from_local(
        local_from_apparent(date, locale),
        locale)
end


#
# 13.23
#
def midday(date, locale)
    standard_from_local(
        local_from_apparent(date + 0.5, locale),
        locale)
end


#
# 13.24
#
def sidereal_from_moment(t)
    c = (t - J2000) / 36525.0

    (280.46061837 + 
        36525 * 360.98564736629 * c +
        0.000387933 * c ** 2 -
        1.0 / 38710000 * c ** 3) % 360
end


#
# 13.25
#
def obliquity(t)
    c = julian_centuries(t)

    Angle.new(23.0, 26.0, 21.448).to_degree +    ## Inclination of Earth's rotational axis
          (Angle.new(0, 0, -46.8150).to_degree * c -
           Angle.new(0, 0, 0.000590).to_degree * c ** 2 +
           Angle.new(0, 0, 0.001813).to_degree * c **3)
end


#
# 13.26
#
# longitude gamma
# latitude beta
#
def declination(t, beta, gamma)
    epsilon = obliquity(t)
    arcsin_degree(
        sin_degree(beta) * cos_degree(epsilon) +
        cos_degree(beta) * sin_degree(epsilon) * sin_degree(gamma))
end


#
# 13.27
#
# longitude gamma
# latitude beta
#
def right_ascension(t, beta, gamma)
    epsilon = obliquity(t)
    arctan_degree(
        sin_degree(gamma) * cos_degree(epsilon) - 
            tan_degree(beta) * sin_degree(epsilon),
        cos_degree(gamma))
end


#
# 13.28
#
MEAN_TROPICAL_YEAR = 365.242189


#
# 13.29
#
MEAN_SIDEREAL_YEAR = 365.25636


#
# Table 13.1 Arguments for solar_longitude
#
SOLAR_LONGITUDE_TABLE = [
    Point.new(403406, 270.54861, 0.9287892),
    Point.new(195207, 340.19128, 35999.1376958),
    Point.new(119433, 63.91854, 35999.4089666),
    Point.new(112392, 331.26220, 35998.7287385),
    Point.new(3891, 317.843, 71998.20261),
    Point.new(2819, 86.631, 71998.4403),
    Point.new(1721, 240.052, 36000.35726),
    Point.new(660, 310.26, 71997.4812),
    Point.new(350, 247.23, 32964.4678),
    Point.new(334, 260.87, -19.4410),
    Point.new(314, 297.82, 445267.1117),
    Point.new(268, 343.14, 45036.8840),
    Point.new(242, 166.79, 3.1008),
    Point.new(234, 81.53, 22518.4434),
    Point.new(158, 3.50, -19.9739),
    Point.new(132, 132.75, 65928.9345),
    Point.new(129, 182.95, 9038.0293),
    Point.new(114, 162.03, 3034.7684),
    Point.new(99, 29.8, 33718.148),
    Point.new(93, 266.4, 3034.448),
    Point.new(86, 249.2, -2280.773),
    Point.new(78, 157.6, 29929.992),
    Point.new(72, 257.8, 31556.493),
    Point.new(68, 185.1, 149.588),
    Point.new(64, 69.9, 9037.750),
    Point.new(46, 8, 107997.405),
    Point.new(38, 197.1, -4444.176),
    Point.new(37, 250.4, 151.771),
    Point.new(32, 65.3, 67555.316),
    Point.new(29, 162.7, 31556.080),
    Point.new(28, 341.5, -4561.540),
    Point.new(27, 291.6, 107996.706),
    Point.new(27, 98.5, 1221.655),
    Point.new(25, 146.7, 62894.167),
    Point.new(24, 110, 31437.369),
    Point.new(21, 5.2, 14578.298),
    Point.new(21, 342.6, -31931.757),
    Point.new(20, 230.9, 34777.243),
    Point.new(18, 256.1, 1221.999),
    Point.new(17, 45.3, 62894.511),
    Point.new(14, 242.9, -4442.039),
    Point.new(13, 115.2, 107997.909),
    Point.new(13, 151.8, 119.066),
    Point.new(13, 285.3, 16859.071),
    Point.new(12, 53.3, -4.578),
    Point.new(10, 126.6, 26895.292),
    Point.new(10, 205.7, -39.127),
    Point.new(10, 85.9, 12297.536),
    Point.new(10, 146.1, 90073.778)
]
 

#
# 13.31
#
def nutation(t)
    c = julian_centuries(t)
    a = 124.90 - 1934.134 * c + 0.002063 * c ** 2
    b = 201.11 + 72001.5377 * c + 0.00057 * c ** 2

    -0.004778 * sin_degree(a) - 0.0003667 * sin_degree(b)
end


#
# 13.32
#
def aberration(t)
   c = julian_centuries(t)
   
   0.0000974 * cos_degree(177.63 + 35999.01848 * c) - 0.005575
end


#
# 13.30
#
def solar_longitude(t)
    l = solar_longitude_aux(t)
    (l + aberration(t) + nutation(t)) % 360
end


def solar_longitude_aux(t)
    c = julian_centuries(t)
    s = SOLAR_LONGITUDE_TABLE.sum { |p| 
        p.x * sin_degree(p.y + p.z * c)
    }
    282.7771834 +
        36000.76953744 * c + 
        0.000005729577951308232 * s
end


#
# 13.33
#
def solar_longitude_after(l, t)
    rate = MEAN_TROPICAL_YEAR / 360.0
    tau = t + rate * ((l - solar_longitude(t)) % 360)
    a = [t, tau - 5].max
    b = tau + 5
    f = lambda {|x| solar_longitude(x)}

    angular_binary_search(f, l, a, b)
end


#
# 13.34 to 13.37
#
SPRING = 0
SUMMER = 90
AUTUMN = 180
WINTER = 270


#
# 13.38
#
def urbana_winter(g_year)
    standard_from_universal(
        solar_longitude_after(
            WINTER, 
            gregorian_new_year(g_year)),
        URBANA)
end


#
# 13.41
#
def estimate_prior_solar_longitude(l, t)
    rate = MEAN_TROPICAL_YEAR / 360.0
    tau = t - rate * ((solar_longitude(t) - l) % 360)
    delta = ((solar_longitude(tau) - l + 180) % 360) - 180

    [t, tau - rate * delta].min
end


#
# 13.43
#
MEAN_SYNODIC_MONTH = 29.530588853


#
# 13.44
#
# nth new moon after the new moon of January 11, 1 Gregorian
#
TABLE_13_3 = [
    [-0.40720, 0, 0, 1, 0],
    [ 0.17241, 1, 1, 0, 0],
    [ 0.01608, 0, 0, 2, 0],
    [ 0.01039, 0, 0, 0, 2],
    [ 0.00739, 1, -1, 1, 0],
    [-0.00514, 1, 1, 1, 0],
    [ 0.00208, 2, 2, 0, 0],
    [-0.00111, 0, 0, 1, -2],
    [-0.00057, 0, 0, 1, 2],
    [ 0.00056, 1, 1, 2, 0],
    [-0.00042, 0, 0, 3, 0],
    [ 0.00042, 1, 1, 0, 2],
    [ 0.00038, 1, 1, 0, -2],
    [-0.00024, 1, -1, 2, 0],
    [-0.00007, 0, 2, 1, 0],
    [ 0.00004, 0, 0, 2, -2],
    [ 0.00004, 0, 3, 0, 0],
    [ 0.00003, 0, 1, 1, -2],
    [ 0.00003, 0, 0, 2, 2],
    [-0.00003, 0, 1, 1, 2],
    [ 0.00003, 0, -1, 1, 2],
    [-0.00002, 0, -1, 1, -2],
    [-0.00002, 0, 1, 3, 0],
    [ 0.00002, 0, 0, 4, 0]
]


TABLE_13_4 = [
    [251.88, 0.016321, 0.000165],
    [251.83, 26.641886, 0.000164],
    [349.42, 36.412478, 0.000126],
    [84.66, 18.206239, 0.000110],
    [141.74, 53.303771, 0.000062],
    [207.14, 2.453732, 0.000060],
    [154.84, 7.306860, 0.000056],
    [34.52, 27.261239, 0.000047],
    [207.19, 0.121824, 0.000042],
    [291.34, 1.844379, 0.000040],
    [161.72, 24.198154, 0.000037],
    [239.56, 25.513099, 0.000035],
    [331.55, 3.592518, 0.000023]
]


TABLE_13_5 = [
    [ 6288774, 0, 0, 1, 0],
    [ 1274027, 2, 0, -1, 0],
    [ 658314, 2, 0, 0, 0],
    [ 213618, 0, 0, 2, 0],
    [-185116, 0, 1, 0, 0],
    [-114332, 0, 0, 0, 2],
    [ 58793, 2, 0, -2, 0],
    [ 57006, 2, -1, -1, 0],
    [ 53322, 2, 0, 1, 0],
    [ 45758, 2, -1, 0, 0],
    [-40923, 0, 1, -1, 0],
    [-34720, 1, 0, 0, 0],
    [-30383, 0, 1, 1, 0],
    [ 15327, 2, 0, 0, -2],
    [-12528, 0, 0, 1, 2],
    [ 10980, 0, 0, 1, -2],
    [ 10675, 4, 0, -1, 0],
    [ 10034, 0, 0, 3, 0],
    [ 8548, 4, 0, -2, 0],
    [-7888, 2, 1, -1, 0],
    [-6766, 2, 1, 0, 0],
    [-5163, 1, 0, -1, 0],
    [ 4987, 1, 1, 0, 0],
    [ 4036, 2, -1, 1, 0],
    [ 3994, 2, 0, 2, 0],
    [ 3861, 4, 0, 0, 0],
    [ 3665, 2, 0, -3, 0],
    [-2689, 0, 1, -2, 0],
    [-2602, 2, 0, -1, 2],
    [ 2390, 2, -1, -2, 0],
    [-2348, 1, 0, 1, 0],
    [ 2236, 2, -2, 0, 0],
    [-2120, 0, 1, 2, 0],
    [-2069, 0, 2, 0, 0],
    [ 2048, 2, -2, -1, 0],
    [-1773, 2, 0, 1, -2],
    [-1595, 2, 0, 0, 2],
    [ 1215, 4, -1, -1, 0],
    [-1110, 0, 0, 2, 2],
    [-892, 3, 0, -1, 0],
    [-810, 2, 1, 1, 0],
    [ 759, 4, -1, -2, 0],
    [-713, 0, 2, -1, 0],
    [-700, 2, 2, -1, 0],
    [ 691, 2, 1, -2, 0],
    [ 596, 2, -1, 0, -2],
    [ 549, 4, 0, 1, 0],
    [ 537, 0, 0, 4, 0],
    [ 520, 4, -1, 0, 0],
    [-487, 1, 0, -2, 0],
    [-399, 2, 1, 0, -2],
    [ 351, 1, 1, 1, 0],
    [-340, 3, 0, -2, 0],
    [ 330, 4, 0, -3, 0],
    [ 327, 2, -1, 2, 0],
    [-323, 0, 2, 1, 0],
    [ 299, 1, 1, -1, 0],
    [ 294, 2, 0, 3, 0]
]


TABLE_13_6 = [
    [ 5128122, 0, 0, 0, 1],
    [ 280602, 0, 0, 1, 1],
    [ 277693, 0, 0, 1, -1],
    [ 173237, 2, 0, 0, -1],
    [ 55413, 2, 0, -1, 1],
    [ 46271, 2, 0, -1, -1],
    [ 32573, 2, 0, 0, 1],
    [ 17198, 0, 0, 2, 1],
    [ 9266, 2, 0, 1, -1],
    [ 8822, 0, 0, 2, -1],
    [ 8216, 2, -1, 0, -1],
    [ 4324, 2, 0, -2, -1],
    [ 4200, 2, 0, 1, 1],
    [-3359, 2, 1, 0, -1],
    [ 2463, 2, -1, -1, 1],
    [ 2211, 2, -1, 0, 1],
    [ 2065, 2, -1, -1, -1],
    [-1870, 0, 1, -1, -1],
    [ 1828, 4, 0, -1, -1],
    [-1794, 0, 1, 0, 1],
    [-1749, 0, 0, 0, 3],
    [-1565, 0, 1, -1, 1],
    [-1491, 1, 0, 0, 1],
    [-1475, 0, 1, 1, 1],
    [-1410, 0, 1, 1, -1],
    [-1344, 0, 1, 0, -1],
    [-1335, 1, 0, 0, -1],
    [ 1107, 0, 0, 3, 1],
    [ 1021, 4, 0, 0, -1],
    [ 833, 4, 0, -1, 1],
    [ 777, 0, 0, 1, -3],
    [ 671, 4, 0, -2, 1],
    [ 607, 2, 0, 0, -3],
    [ 596, 2, 0, 2, -1],
    [ 491, 2, -1, 1, -1],
    [-451, 2, 0, -2, 1],
    [ 439, 0, 0, 3, -1],
    [ 422, 2, 0, 2, 1],
    [ 421, 2, 0, -3, -1],
    [-366, 2, 1, -1, 1],
    [-351, 2, 1, 0, 1],
    [ 331, 4, 0, 0, 1],
    [ 315, 2, -1, 1, 1],
    [ 302, 2, -2, 0, -1],
    [-283, 0, 0, 1, 3],
    [-229, 2, 1, 1, -1],
    [ 223, 1, 1, 0, -1],
    [ 223, 1, 1, 0, 1],
    [-220, 0, 1, -2, -1],
    [-220, 2, 1, -1, -1],
    [-185, 1, 0, 1, 1],
    [ 181, 2, -1, -2, -1],
    [-177, 0, 1, 2, 1],
    [ 176, 4, 0, -2, -1],
    [ 166, 4, -1, -1, -1],
    [-164, 1, 0, 1, -1],
    [ 132, 4, 0, 1, -1],
    [-119, 1, 0, -2, -1],
    [ 115, 4, -1, 0, -1],
    [ 107, 2, -2, 0, 1]
]


TABLE_13_7 = [
    [-20905355, 0, 0, 1, 0],
    [-3699111, 2, 0, -1, 0],
    [-2955968, 2, 0, 0, 0],
    [-569925, 0, 0, 2, 0],
    [ 48888, 0, 1, 0, 0],
    [-3149, 0, 0, 0, 2],
    [ 246158, 2, 0, -2, 0],
    [-152138, 2, -1, -1, 0],
    [-170733, 2, 0, 1, 0],
    [-204586, 2, -1 ,0, 0],
    [-129620, 0, 1, -1, 0],
    [ 108743, 1, 0, 0, 0],
    [ 104755, 0, 1, 1, 0],
    [ 10321, 2, 0, 0, -2],
    [ 0, 0, 0, 1, 2],
    [ 79661, 0, 0, 1, -2],
    [-34782, 4, 0, -1, 0],
    [-23210, 0, 0, 3, 0],
    [-21636, 4, 0, -2, 0],
    [ 24208, 2, 1, -1, 0],
    [ 30824, 2, 1, 0, 0],
    [-8379, 1, 0, -1, 0],
    [-16675, 1, 1, 0, 0],
    [-12831, 2, -1, 1, 0],
    [-10445, 2, 0, 2, 0],
    [-11650, 4, 0, 0, 0],
    [ 14403, 2, 0, -3, 0],
    [-7003, 0, 1, -2, 0],
    [ 0, 2, 0, -1, 2],
    [ 10056, 2, -1, -2, 0],
    [ 6322, 1, 0, 1, 0],
    [-9884, 2, -2, 0, 0],
    [ 5751, 0, 1, 2, 0],
    [ 0, 0, 2, 0, 0],
    [-4950, 2, -2, -1, 0],
    [ 4130, 2, 0, 1, -2],
    [ 0, 2, 0, 0, 2],
    [-3958, 4, -1, -1, 0],
    [ 0, 0, 0, 2, 2],
    [ 3258, 3, 0, -1, 0],
    [ 2616, 2, 1, 1, 0],
    [-1897, 4, -1, -2, 0],
    [-2117, 0, 2, -1, 0],
    [ 2354, 2, 2, -1, 0],
    [ 0, 2, 1, -2, 0],
    [ 0, 2, -1, 0, -2],
    [-1423, 4, 0, 1, 0],
    [-1117, 0, 0, 4, 0],
    [-1571, 4, -1, 0, 0],
    [-1739, 1, 0, -2, 0],
    [ 0, 2, 1, 0, -2],
    [-4421, 0, 0, 2, -2],
    [ 0, 1, 1, 1, 0],
    [ 0, 3, 0, -2, 0],
    [ 0, 4, 0, -3, 0],
    [ 0, 2, -1, 2, 0],
    [ 1165, 0, 2, 1, 0],
    [ 0, 1, 1, -1, 0],
    [ 0, 2, 0, 3, 0],
    [ 8752, 2, 0, -1, -2]
]


def nth_new_moon(n)
    n0 = 24724
    k = n - n0
    c = k / 1236.85

    approx = J2000 +
       (5.09765 +
        MEAN_SYNODIC_MONTH * 1236.85 * c +
        0.0001337 * c ** 2 -
        0.000000150 * c ** 3 +
        0.00000000073 * c ** 4)

    e = 1 - 
        0.002516 * c -
        0.0000074 * c ** 2

    solar_anomaly = 2.5534 +
        1236.85 * 29.10535669 * c -
        0.0000218 * c ** 2 -
        0.00000011 * c ** 3

    lunar_anomaly = 201.5643 +
        385.81693528 * 1236.85 * c +
        0.0107438 * c ** 2 +
        0.00001239 * c ** 3 -
        0.000000058 * c ** 4

    moon_argument = 160.7108 +
        390.67050274 * 1236.85 * c -
        0.0016341 * c ** 2 -
        0.00000227 * c ** 3 +
        0.000000011 * c ** 4

    omega = 124.7746 +
        (-1.56375580 * 1236.85) * c +
        0.0020691 * c ** 2 +
        0.00000215 * c ** 3

    correction = -0.00017 * sin_degree(omega) +
        TABLE_13_3.sum { |p|
            p[0] * e ** p[1] * sin_degree(
                p[2] * solar_anomaly +
                p[3] * lunar_anomaly +
                p[4] * moon_argument)
        }

    extra = 0.000325 * sin_degree(
        299.77 + 
        132.8475848 * c -
        0.009173 * c ** 2)

    additional = TABLE_13_4.sum { |p|
        p[2] * sin_degree(p[0] + p[1] * k)
    }

    universal_from_dynamical(approx + correction + extra + additional)
end


#
# 13.45
#
def new_moon_before(t)
    t0 = nth_new_moon(0)
    phi = lunar_phase(t)
    n = ((t - t0) / MEAN_SYNODIC_MONTH - phi / 360.0).round

    k = max_search(
        n - 1,
        lambda { |i| nth_new_moon(i) < t }
    )

    nth_new_moon(k)
end


#
# 13.46
#
def new_moon_at_or_after(t)
    t0 = nth_new_moon(0)
    phi = lunar_phase(t)
    n = ((t - t0) / MEAN_SYNODIC_MONTH - phi / 360.0).round

    k = min_search(
        n,
        lambda { |i| nth_new_moon(i) >= t }
    )

    nth_new_moon(k)
end


#
# 13.47
#
def lunar_longitude(t)
    c = julian_centuries(t)
    l_prime = mean_lunar_longitude(c)
    d = lunar_elongation(c)
    m = solar_anomaly(c)
    m_prime = lunar_anomaly(c)
    f = moon_node(c)
    e = 1 - 0.002516 * c - 0.0000074 * c ** 2

    correction = 1.0 / 1000000 * TABLE_13_5.sum { |p|
        p[0] * 
        (e ** p[2].abs) *
        sin_degree(p[1] * d + p[2] * m + p[3] * m_prime + p[4] * f)
    }

    venus = 3958.0 / 1000000 * 
        sin_degree(119.75 + 131.849 * c)

    jupiter = 318.0 / 1000000 *
        sin_degree(53.09 + 479264.29 * c)

    flat_earth = 1962.0 / 1000000 *
        sin_degree(l_prime - f)

    (l_prime + correction + venus + jupiter + flat_earth + nutation(t)) % 360
end


#
# 13.48
#
def mean_lunar_longitude(c)
    218.3164477 + 
        481267.88123421 * c -
        0.0015786 * c ** 2 +
        1.0 / 538841 * c ** 3 -
        1.0 / 65194000 * c ** 4
end


#
# 13.49
#
def lunar_elongation(c)
    297.8501921 +
        445267.1114034 * c -
        0.0018819 * c ** 2 +
        1.0 / 545868 * c ** 3 -
        1.0 / 113065000 * c ** 4
end


# 
# 13.50
#
def solar_anomaly(c)
    357.5291092 +
        35999.0502909 * c -
        0.0001536 * c ** 2 +
        1.0 / 24490000 * c ** 3
end


#
# 13.51
#
def lunar_anomaly(c)
    134.9633964 +
        477198.8675055 * c +
        0.0087414 * c ** 2 +
        1.0 / 69699 * c ** 3 -
        1.0 / 14712000 * c ** 4
end


#
# 13.52
#
def moon_node(c)
    93.2720950 +
        483202.0175233 * c -
        0.0036539 * c ** 2 -
        1.0 / 3526000 * c ** 3 +
        1.0 / 863310000 * c ** 4
end


#
# 13.53
#
# Defined as the difference in longitudes of the sun and moon at
# any moment t
#
def lunar_phase(t)
    phi = (lunar_longitude(t) - solar_longitude(t)) % 360

    t0 = nth_new_moon(0)

    n = ((t - t0) / MEAN_SYNODIC_MONTH).round

    phi_prime = 360 * (((t - nth_new_moon(n)) / MEAN_SYNODIC_MONTH) % 1)

    (phi - phi_prime).abs > 180 ? phi_prime : phi
end


#
# 13.54
#
def lunar_phase_at_or_before(phi, t) 
    tau = t - MEAN_SYNODIC_MONTH / 360.0 *
        ((lunar_phase(t) - phi) % 360)

    a = tau - 2
    b = [t, tau + 2].min

    angular_binary_search(
        lambda { |i| lunar_phase(i) },
        phi, 
        a, 
        b)
end        


#
# 13.55
#
def lunar_phase_at_or_after(phi, t) 
    tau = t + MEAN_SYNODIC_MONTH / 360.0 *
        ((phi - lunar_phase(t)) % 360)

    a = [t, tau - 2].max
    b = tau + 2

    angular_binary_search(
        lambda { |i| lunar_phase(i) },
        phi, 
        a, 
        b)
end        


#
# 13.56 - 13.59
#
MOON_NEW = 0
MOON_FULL = 180
MOON_FIRST_QUARTER = 90
MOON_LAST_QUARTER = 270


#
# 13.60
#
def lunar_latitude(t)
    c = julian_centuries(t)
    l_prime = mean_lunar_longitude(c)
    d = lunar_elongation(c)
    m = solar_anomaly(c)
    m_prime = lunar_anomaly(c)
    f = moon_node(c)

    e = 1 - 0.002516 * c -
        0.0000074 * c ** 2

    beta = 1.0 / 1000000 * 
        TABLE_13_6.sum { |p|
            p[0] * e ** p[2].abs *
            sin_degree(
                p[1] * d +
                p[2] * m +
                p[3] * m_prime +
                p[4] * f)
        }

    venus = 175.0 / 1000000 *
       (sin_degree(119.75 + 131.849 * c + f) +
        sin_degree(119.75 + 131.849 * c - f))
   
    flat_earth = -2235.0 / 1000000 * sin_degree(l_prime) +
        127.0 / 1000000 * sin_degree(l_prime - m_prime) -
        115.0 / 1000000 * sin_degree(l_prime + m_prime)

    extra = 382.0 / 1000000 * 
        sin_degree(313.45 + 481266.484 * c)

    beta + venus + flat_earth + extra
end


#
# 13.61
#
def lunar_altitude(t, locale)
    phi = locale.latitude
    psi = locale.longitude
    lam = lunar_longitude(t)
    beta = lunar_latitude(t)
    alpha = right_ascension(t, beta, lam)
    delta = declination(t, beta, lam)
    theta0= sidereal_from_moment(t)
    h = (theta0 + psi - alpha) % 360
    altitude = arcsin_degree(
        sin_degree(phi) * sin_degree(delta) +
        cos_degree(phi) * cos_degree(delta) * cos_degree(h))

    (altitude + 180) % 360 - 180
end


#
# 13.62
#
def lunar_distance(t)
    c = julian_centuries(t)
    d = lunar_elongation(c)
    m = solar_anomaly(c)
    m_prime = lunar_anomaly(c)
    f = moon_node(c)
    e = 1 - 0.002516 * c -
        0.0000074 * c ** 2

    correction = TABLE_13_7.sum { |p|
        p[0] * e ** p[2].abs *
        cos_degree(
            p[1] * d +
            p[2] * m +
            p[3] * m_prime +
            p[4] * f)
    }
        
    385000560 + correction
end


#
# 13.63
#
def lunar_parallax(t, locale)
    geo = lunar_altitude(t, locale)
    delta = lunar_distance(t)
    alt = 6378140.0 / delta
    arg = alt * cos_degree(geo)

    arcsin_degree(arg)
end


#
# 13.64
#
def topocentric_lunar_altitude(t, locale)
    lunar_altitude(t, locale)- lunar_parallax(t, locale)
end


#
# 13.65
#
def approx_moment_of_depression(t, locale, alpha, early)
    try = sine_offset(t, locale, alpha)
    date = fixed_from_moment(t)

    if alpha >= 0 then
        alt = early ? date : date + 1
    else
        alt = date + 0.5
    end

    if try.abs > 1 then
        value = sine_offset(alt, locale, alpha)
    else
        value = try
    end

    if value.abs <= 1 then
        local_from_apparent(
            date + 12 / 24.0 +
                (early ? -1 : 1) * 
                (((12 / 24.0 + arcsin_degree(value) / 360) % 1) - 6 / 24.0),
            locale)
    else
        BOGUS
    end
end


#
# 13.66
#
def sine_offset(t, locale, alpha) 
    phi = locale.latitude
    t_prime = universal_from_local(t, locale)
    delta = declination(t_prime, 0, solar_longitude(t_prime))

    tan_degree(phi) * tan_degree(delta) +
        sin_degree(alpha) / (cos_degree(delta) * cos_degree(phi))
end


THIRTY_SECONDS = time_from_clock(Clock.new(0, 0, 30))
#
# 13.67
#
def moment_of_depression(approx, locale, alpha, early)
    t = approx_moment_of_depression(approx, locale, alpha, early)

    if t == BOGUS then
        BOGUS
    elsif (approx - t).abs < THIRTY_SECONDS then
        t
    else
        moment_of_depression(t, locale, alpha, early)
    end
end


#
# 13.68 & 13.70
#
MORNING = true
EVENING = false


#
# 13.69
#
def dawn(date, locale, alpha)
    result = moment_of_depression(
        date + 6.0 / 24, locale, alpha, MORNING)

    if result == BOGUS then
        BOGUS
    else
        standard_from_local(result, locale)
    end
end


#
# 13.71
#
def dusk(date, locale, alpha)
    result = moment_of_depression(
        date + 18.0 / 24, locale, alpha, EVENING)

    if result == BOGUS then
        BOGUS
    else
        standard_from_local(result, locale)
    end
end


#
# 13.72
#
def sunrise(date, locale)
    h = [0, locale.elevation].max
    r = EARTH_RADIUS
    dip = arccos_degree(r / (r + h))
    alpha = Angle.new(0, 50.0, 0).to_degree + dip +
        Angle.new(0, 0, 19.0).to_degree * sqrt(h)

    dawn(date, locale, alpha)
end


#
# 13.73
#
def sunset(date, locale) 
    h = [0, locale.elevation].max
    r = EARTH_RADIUS
    dip = arccos_degree(r / (r + h))
    alpha = Angle.new(0, 50.0, 0).to_degree + dip +
        Angle.new(0, 0, 19.0).to_degree * sqrt(h)

    dusk(date, locale, alpha)
end


#
# 13.74
#
def urbana_sunset(g_date)
    time_from_moment(
        sunset(
            fixed_from_gregorian(g_date),
            URBANA))
end


#
# 13.76
#
def jewish_sabbath_ends(date, locale)
    dusk(date, locale, Angle.new(7.0, 5.0, 0))
end


#
# 13.77
#
def jewish_dusk(date, locale)
    dusk(date, locale, Angle.new(4.0, 40.0, 0))
end


#
# Table 13.8
#
# Significance of various solar depression angles.
#
TABLE_13_8 = [
    [ Angle.new(20.0, 0, 0).to_degree, "Alternative Jewish dawn (Rabbenu Tam)" ],
    [ Angle.new(18.0, 0, 0).to_degree, "Astronomical and Islamic dawn" ],
    [ Angle.new(16.0, 0, 0).to_degree, "Jewish dawn (Maimonides)" ],
    [ Angle.new(15.0, 0, 0).to_degree, "Alternative Islamic dawn" ],
    [ Angle.new(12.0, 0, 0).to_degree, "Nautical twilight begins" ],
    [ Angle.new(6.0, 0, 0).to_degree, "Civil twilight begins" ],
    [ Angle.new(0, 50.0, 0).to_degree, "Sunrise" ],
    [ Angle.new(0, 50.0, 0).to_degree, "Sunset" ],
    [ Angle.new(4.0, 40.0, 0).to_degree, "Jewish dusk (Vilna Gaon)" ],
    [ Angle.new(6.0, 0, 0).to_degree, "Civil twilight ends" ],
    [ Angle.new(7.0, 5.0, 0).to_degree, "Jewish sabbath ends (Cohn)" ],
    [ Angle.new(8.0, 30.0, 0).to_degree, "Alternative Jewish sabbath ends (Tykocinski)" ],
    [ Angle.new(12.0, 0, 0).to_degree, "Nautical twilight ends" ],
    [ Angle.new(15.0, 0, 0).to_degree, "Alternative Islamic dusk" ],
    [ Angle.new(18.0, 0, 0).to_degree, "Astronomical and Islamic dusk" ],
    [ Angle.new(20.0, 0, 0).to_degree, "Alternative Jewish dusk (Rabbenu Tam)" ]
]


#
# 13.78
#
# This returns the duration of an "hour" (daytime divided by 12)
# in fractions of a day
#
def daytime_temporal_hour(date, locale)
    rise = sunrise(date, locale)
    set = sunset(date, locale)

    (rise == BOGUS or set == BOGUS) ? 
        BOGUS :
        (set - rise) / 12.0
end


#
# 13.79
#
# This returns the duration of an "hour" (night time divided by 12)
# in fractions of a day
#
def nighttime_temporal_hour(date, locale)
    rise = sunrise(date + 1, locale)
    set = sunset(date, locale)

    (rise == BOGUS or set == BOGUS) ? 
        BOGUS :
        (rise - set) / 12.0
end


#
# 13.80
#
def standard_from_sundial(t, locale)
    date = fixed_from_moment(t)
    hour = 24 * (t % 1)

    if 6 <= hour and hour <= 18 then
        h = daytime_temporal_hour(date, locale)
    elsif hour < 6 then
        h = nighttime_temporal_hour(date - 1, locale)
    else 
        h = nighttime_temporal_hour(date, locale)
    end

    if h == BOGUS then
        BOGUS
    elsif 6 <= hour and hour <= 18 then
        sunrise(date, locale) + (hour - 6) * h
    elsif hour < 6 then
        sunset(date - 1, locale) + (hour + 6) * h
    else
        sunset(date, locale) + (hour - 18) * h
    end
end


#
# 13.81
#
def jewish_morning_end(date, locale)
    standard_from_sundial(date + 10.0 / 24, locale)
end


#
# 13.82
#
def asr(date, locale)
    noon = universal_from_standard(
        midday(date, locale),
        locale
    )
    phi = locale.latitude
    delta = declination(noon, 0, solar_longitude(noon))
    altitude = delta - phi - 90
    h = arctan_degree(
        tan_degree(altitude),
        2 * tan_degree(altitude) + 1
    )

    dusk(date, locale, -h)
end


#
# Convert moment from locale1 to locale2
#
def timezone_conversion(t, locale1, locale2)
    universal = universal_from_standard(t, locale1)
    standard_from_universal(universal, locale2)
end


puts "Today's moon phase: "
puts lunar_phase(today).round(2)

d = Day.new(1945, 11, 12)
f = gregorian_to_fixed(d)

puts "Urbana sunset: "
u = urbana_sunset(d)
puts u.to_clock
# 
# puts time_from_moment(sunset(f, CFS_ALERT)).to_clock
