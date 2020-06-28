--
--
-- Calendrical Calculations Third Edition
-- Nachum Dershowitz, Edward M. Reingold
-- Cambridge University Press
-- 2008
--

include std/math.e


global constant epoch = 0

--
-- 1.1
--
-- R.D., Rata Die, Fixed date -- elapsed day since the onset of 
-- Monday, January 1, 1 (Gregorian)
-- 
global function rd(atom t) 
   return t - epoch
end function


--
-- 1.3
--
-- Julian day number 
-- Julian days counted backward and forward from
--
-- JD 0 == Noon, Monday, January 1, 4713 B.C.E
--      == Noon, Monday, November 24, -4713 (Gregorian)
--
global constant epoch_jd = -1721424.5


--
-- 1.4
--
global function moment_from_jd(atom jd)
    return jd + epoch_jd
end function


--
-- 1.5
--
global function jd_from_moment(atom t)
    return t - epoch_jd
end function


--
-- 1.6
--
-- Modified Julian day number for convenience so fixed day numbers
-- of recent years are not negative
--
global constant epoch_mjd = 678576


--
-- 1.7
--
global function fixed_from_mjd(atom mjd)
    return mjd + epoch_mjd
end function


--
-- 1.8
--
global function mjd_from_fixed(atom date)
    return date - epoch_mjd
end function


--
-- 1.9
--
global function fixed_from_moment(atom t)
    return floor(t)
end function


--
-- 1.10
--
global function fixed_from_jd(atom jd)
    return floor(moment_from_jd(jd))
end function


--
-- 1.11
--
global function jd_from_fixed(atom date)
    return jd_from_moment(date)
end function


--
-- 1.16
--
global function time_from_moment(atom t)
    return mod(t, 1)
end function


--
-- Round to nearest second for a moment t
--
global function round_to_second(atom t)
    return round(t * 24 * 60 * 60) / (24 * 60 * 60)
end function


--
-- Date is a sequence of { year, month, day }
--

global constant DATE_YEAR = 1
global constant DATE_MONTH = 2
global constant DATE_DAY = 3


global function date_year(sequence date)
    return date[DATE_YEAR]
end function

global function date_month(sequence date)
    return date[DATE_MONTH]
end function

global function date_day(sequence date)
    return date[DATE_DAY]
end function


--
-- Clock is a sequence of { hour, minute, second }
--

global constant CLOCK_HOUR = 1
global constant CLOCK_MINUTE = 2
global constant CLOCK_SECOND = 3


--
-- 1.34
--
-- Convert the clock time into a fraction of a day
--
--                         s
--                   m + ---
--       1                60
--     ---- * ( h + --------- )
--      24              60
--
global function time_from_clock(sequence clock)
    atom h = clock[CLOCK_HOUR]
    atom m = clock[CLOCK_MINUTE]
    atom s = clock[CLOCK_SECOND]

    return (h + (m + s / 60) / 60) / 24
end function


--
-- 1.35
--
-- Convert the fractional part of rd moment t to clock components
--
global function clock_from_moment(atom t)
    atom h, m, s, time

    time = time_from_moment(t)
    h = floor(time * 24)
    m = floor(mod(time * 24 * 60, 60))
    s = mod(time * 24 * 60 * 60, 60)

    return {h, m, s}
end function


--
-- 1.36
--
-- Angles can be described in terms of a sequence of degrees, arc minutes 
-- and arc seconds
--
global constant ANGLE_DEGREE = 1
global constant ANGLE_MINUTE = 2
global constant ANGLE_SECOND = 3

--
-- 1.37
--
-- Given angle alpha as a real number degrees, convert it to a sequence
--
global function angle_from_degrees(atom alpha)
    atom d, m, s
    
    d = floor(alpha)
    m = floor(60 * mod(alpha, 1))
    s = mod(alpha * 60 * 60, 60)

    return {d, m, s}
end function


--
-- 1.44 to 1.50
--
global constant Sunday = 0
global constant Monday = Sunday + 1
global constant Tuesday = Sunday + 2
global constant Wednesday = Sunday + 3
global constant Thursday = Sunday + 4
global constant Friday = Sunday + 5
global constant Saturday = Sunday + 6


--
-- 1.51
--
global function day_of_week_from_fixed(atom date)
    return mod(date - Sunday, 7)
end function


--
-- 1.53
--
-- Find the date that is a k-day (day of week is k) on or
-- before a fixed RD date
--
global function kday_on_or_before(integer k, atom date)
    return date - day_of_week_from_fixed(date - k)
end function


--
-- 1.58
--
global function kday_on_or_after(integer k, atom date)
    return kday_on_or_before(k, date + 6)
end function


--
-- 1.59
--
global function kday_nearest(integer k, atom date)
    return kday_on_or_before(k, date + 3)
end function


--
-- 1.60
--
global function kday_before(integer k, atom date)
    return kday_on_or_before(k, date - 1)
end function


--
-- 1.61
--
global function kday_after(integer k, atom date)
    return kday_on_or_before(k, date + 7)
end function




-- ? rd(10)
-- ? moment_from_jd(10)
-- ? jd_from_moment(10)
-- ? fixed_from_moment(10.123)
-- ? jd_from_fixed(fixed_from_jd(0.5))
