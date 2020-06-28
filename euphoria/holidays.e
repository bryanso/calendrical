--
--
-- Calendrical Calculations Third Edition
-- Nachum Dershowitz, Edward M. Reingold
-- Cambridge University Press
-- 2008
--

include std/math.e
include math.e
include julian.e
include gregorian.e


--
-- 2.31
--
global function independence_day(integer g_year)
    return fixed_from_gregorian({g_year, July, 4})
end function


--
-- 2.35
--
global function labor_day(integer g_year)
    return first_kday(Monday, {g_year, September, 1})
end function


--
-- 2.36
--
global function memorial_day(integer g_year)
    return last_kday(Monday, {g_year, May, 31})
end function


--
-- p. 27
--
global function thanksgiving(integer g_year)
    return nth_kday(4, Thursday, {g_year, November, 1})
end function


--
-- 2.37
--
-- US Election Day is the Tuesday after the first Monday in November,
-- which is the first Tuesday on or after November 2
--
global function election_day(integer g_year)
    return first_kday(Tuesday, {g_year, November, 2})
end function


--
-- 2.38
--
global function daylight_saving_start(integer g_year)
    return nth_kday(2, Sunday, {g_year, March, 1})
end function


--
-- 2.39
--
global function daylight_saving_end(integer g_year)
    return first_kday(Sunday, {g_year, November, 1})
end function


--
-- 2.40
--
global function christmas(integer g_year)
    return fixed_from_gregorian({g_year, December, 25})
end function


global function new_year(integer g_year)
    return fixed_from_gregorian({g_year, January, 1})
end function


global function new_year_eve(integer g_year)
    return fixed_from_gregorian({g_year - 1, December, 31})
end function


--
-- 2.41
--
global function advent(integer g_year)
    return kday_nearest(Sunday, fixed_from_gregorian({g_year, November, 30}))
end function


--
-- 2.42
--
global function epiphany(integer g_year)
    return first_kday(Sunday, {g_year, January, 2})
end function


global function assumption(integer g_year)
    return fixed_from_gregorian({g_year - 1, August, 15})
end function



-- for i = 2000 to 2030 do
--     ? gregorian_from_fixed(thanksgiving(i))
-- end for


--
-- 8.1 auxiliary
--
-- Paschal Moon is the first full moon on or after Vernal Equinox
-- with the simplifying assumption that the latter is always on March 21
--
global function paschal_moon_orthodox(integer g_year)
    integer j_year, shifted_epact

    --
    -- Moon phase number on April 5 (half a month after March 21)
    --
    shifted_epact = mod(14 + 11 * mod(g_year, 19), 30)

    if g_year > 0 then
        j_year = g_year
    else
        j_year = g_year - 1
    end if

    --
    -- Paschal moon (moon phase no. 14) happens to be simply April 19
    -- minus moon phase no. on April 5
    --
    return fixed_from_julian({j_year, April, 19}) - shifted_epact
end function



--
-- 8.1
--
-- Still used by Orthodox churches except those in Finland
--
global function orthodox_easter(integer g_year)
    return kday_after(Sunday, paschal_moon_orthodox(g_year))
end function


constant y = 2018
? paschal_moon_orthodox(y)
? orthodox_easter(y)
printf(1, "Julian\n")
? julian_from_fixed(paschal_moon_orthodox(y))
? julian_from_fixed(orthodox_easter(y))
printf(1, "Gregorian\n")
? gregorian_from_fixed(paschal_moon_orthodox(y))
? gregorian_from_fixed(orthodox_easter(y))

