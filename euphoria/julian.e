--
--
-- Calendrical Calculations Third Edition
-- Nachum Dershowitz, Edward M. Reingold
-- Cambridge University Press
-- 2008
--

include epoch.e
include gregorian.e
include std/math.e
include math.e


--
-- 3.1
--
global function is_julian_leap_year(integer j_year)
    integer r
    if j_year > 0 then
        r = 0
    else
        r = 3
    end if
    return mod(j_year, 4) = r
end function


--
-- 3.2
--
global constant epoch_julian = fixed_from_gregorian({0, December, 30})


--
-- 3.3
--
global function fixed_from_julian(sequence date)
    integer year = date[DATE_YEAR]
    integer month = date[DATE_MONTH]
    integer day = date[DATE_DAY]

    integer y
    if year < 0 then
        y = year + 1
    else
        y = year
    end if

    integer correction 
    if month <= 2 then
        correction = 0
    elsif is_julian_leap_year(year) then
        correction = -1
    else
        correction = -2
    end if

    return epoch_julian - 1 +
           365 * (y - 1) +
           floor((y - 1) / 4) +
           floor((367 * month - 362) / 12) +
           correction +
           day
end function


global function julian_to_fixed(sequence j_date)
    return fixed_from_julian(j_date)
end function


--
-- 3.4
--
global function julian_from_fixed(integer date)
    integer approx, year, month, day, prior_days, correction

    approx = floor((4 * (date - epoch_julian) + 1464) / 1461)

    if approx <= 0 then
        year = approx - 1
    else
        year = approx
    end if

    prior_days = date - fixed_from_julian({year, January, 1})

    if date < fixed_from_julian({year, March, 1}) then
        correction = 0
    elsif is_julian_leap_year(year) then
        correction = 1
    else
        correction = 2
    end if

    month = floor((12 * (prior_days + correction) + 373) / 367)

    day = date - fixed_from_julian({year, month, 1}) + 1

    return {year, month, day}
end function


global function fixed_to_julian(integer date)
    return julian_from_fixed(date)
end function


--
-- 3.15
--
-- Given a particular month and day in Julian, there can be one or two
-- occurrences of the same month-day in a Gregorian year.  This function
-- returns a sequence of fixed dates that has the given month-day in
-- the given Gregorian year.
--
global function julian_in_gregorian(
    integer j_month, integer j_day, integer g_year)

    sequence result = {}
    integer jan1, y0, y1, date1, date2

    jan1 = gregorian_new_year(g_year)
    y0 = date_year(julian_from_fixed(jan1))
    if y0 = -1 then
        y1 = 1
    else
        y1 = y0 + 1
    end if

    date1 = fixed_from_julian({y0, j_month, j_day})
    date2 = fixed_from_julian({y1, j_month, j_day})

    if is_in_range(date1, gregorian_year_range(g_year)) then
        result &= date1
    end if

    if is_in_range(date2, gregorian_year_range(g_year)) then
        result &= date2
    end if

    return result
end function


? fixed_from_julian({1582, October, 4})
? julian_from_fixed(fixed_from_julian({1582, October, 4}))
? julian_in_gregorian(February, 28, 41104)
