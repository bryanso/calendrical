--
--
-- Calendrical Calculations Third Edition
-- Nachum Dershowitz, Edward M. Reingold
-- Cambridge University Press
-- 2008
--

include epoch.e
include std/math.e


--
-- 2.3
--
global constant epoch_gregorian = 1


--
-- 2.4 - 2.15
--

global constant January = 1
global constant February = 2
global constant March = 3
global constant April = 4
global constant May = 5
global constant June = 6
global constant July = 7
global constant August = 8
global constant September = 9
global constant October = 10
global constant November = 11
global constant December = 12


--
-- 2.16
--
global function is_gregorian_leap_year(atom g_year)
    if mod(g_year, 4) = 0 and not
        find(mod(g_year, 400), {100, 200, 300}) then
	return 1
    else
        return 0
    end if
end function
  

--
-- 2.17
--
global function fixed_from_gregorian(sequence g_date)
    atom year = g_date[DATE_YEAR]
    atom month = g_date[DATE_MONTH]
    atom day = g_date[DATE_DAY]

    integer correction
    
    if month <= 2 then
        correction = 0
    elsif is_gregorian_leap_year(year) then
        correction = -1
    else
        correction = -2
    end if

    integer f = epoch_gregorian - 1 + 
           365 * (year - 1) + 
           floor((year - 1) / 4) -
           floor((year - 1) / 100) +
           floor((year - 1) / 400) +
           floor((367 * month - 362) / 12) +
           day +
           correction

?f
return f
end function

global function gregorian_to_fixed(sequence g_date)
    return fixed_from_gregorian(g_date)
end function


--
-- 2.18
--
global function gregorian_new_year(integer g_year)
    return fixed_from_gregorian({g_year, January, 1})
end function


--
-- 2.19
--
global function gregorian_year_end(integer g_year)
    return fixed_from_gregorian({g_year, December, 31})
end function


--
-- 2.20
--
global function gregorian_year_range(integer g_year)
    return {gregorian_new_year(g_year), gregorian_year_end(g_year)}
end function


--
-- 2.21
--
global function gregorian_year_from_fixed(integer date)
    integer d0, d1, d2, d3, n1, n4, n100, n400, year

    d0 = date - epoch_gregorian

    n400 = floor(d0 / 146097)               -- day 146097 is last day of 400-year cycle
    d1 = mod(d0, 146097)

    n100 = floor(d1 / 36524)                -- last day of 100-year cycle
    d2 = mod(d1, 36524)

    n4 = floor(d2 / 1461)                   -- last day of 4-year cycle
    d3 = mod(d2, 1461)

    n1 = floor(d3 / 365)

    year = 400 * n400 + 100 * n100 + 4 * n4 + n1
    
    if n100 = 4 or n1 = 4 then
        return year
    else
        return year + 1
    end if
end function


--
-- 2.23
--
global function gregorian_from_fixed(integer date)
    integer year, month, day, prior_days, correction

    year = gregorian_year_from_fixed(date)

    prior_days = date - gregorian_new_year(year)

    if date < fixed_from_gregorian({year, March, 1}) then
        correction = 0
    elsif is_gregorian_leap_year(year) then
        correction = 1
    else
        correction = 2
    end if

    month = floor((12 * (prior_days + correction) + 373) / 367)

    day = 1 + date - fixed_from_gregorian({year, month, 1})

    return {year, month, day}
end function


--
-- 2.32
--
-- Find the nth k-day (day of week) on or after a gregorian date
-- (n can be negative to find before)
--
global function nth_kday(integer n, integer k, sequence g_date)
    if n > 0 then
        return 7 * n + kday_before(k, fixed_from_gregorian(g_date))
    else
        return 7 * n + kday_after(k, fixed_from_gregorian(g_date))
    end if
end function


--
-- 2.33
-- 
global function first_kday(integer k, sequence g_date)
    return nth_kday(1, k, g_date)
end function


--
-- 2.34
--
global function last_kday(integer k, sequence g_date)
    return nth_kday(-1, k, g_date)
end function



function test(integer m)
    return floor((367 * m - 362) / 12)
end function


-- ? gregorian_from_fixed(577736)
-- ? fixed_from_gregorian({1582, October, 15})
