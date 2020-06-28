include std/math.e

--
--
-- Calendrical Calculations Third Edition
-- Nachum Dershowitz, Edward M. Reingold
-- Cambridge University Press
-- 2008
--


--
-- 1.15
--
-- Redefining the mod function to make sure it conforms to Dershowitz-Reingold's
-- definition so it works correctly with floating point numbers
--
-- global function mod(atom x, atom y)
--    return x - y * floor(x / y)
-- end function
--
-- Euphoria's definition is the same
--
-- mod(5/3, 4/4) == 1/6
--


--
-- 1.21
--
global function lcm(atom x, atom y)
    return x * y / gcd(x, y)
end function


--
-- 1.22
--
-- Adjusted mod function, is defined as
--
--    a amod y == y        if x mod y == 0
--                x mod y  otherwise
--
global function amod(atom x, atom y)
    atom r = mod(x, y)
    if r = 0 then
        return y
    else
        return r
    end if
end function


global function is_in_range(atom a, sequence s)
    return s[1] <= a and a <= s[2]
end function
