CREATE OR REPLACE PACKAGE BODY calendar_pkg IS
--
-- Adapted from Calendrical Calculations by 
-- Edward M. Reingold and Nachum Dershowitz
--
-- bso Fri Nov 10 12:36:02 PST 2023
--

    --
    -- 1.17
    -- The book uses a different definition of mod function:
    -- x mod y ::= x - y * floor(x/y)
    --
    FUNCTION mod(x NUMBER, y NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN x - y * FLOOR(x / y);
    END;

    --
    -- 1.1 Initial Epoch and Rata Die (fixed date)
    --
    FUNCTION rd(t NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN t - EPOCH;
    END;

    --
    -- 1.4
    --
    FUNCTION moment_from_jd(jd NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN jd + JD_EPOCH;
    END;
    
    --
    -- 1.5
    --
    FUNCTION jd_from_moment(t NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN t - JD_EPOCH;
    END;

    --
    -- 1.7
    --
    FUNCTION fixed_from_mjd(mjd NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN mjd + MJD_EPOCH;
    END;

    --
    -- 1.8
    --
    FUNCTION mjd_from_fixed(date NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN date - MJD_EPOCH;
    END;

    --
    -- 1.10
    --
    FUNCTION moment_from_unix(seconds INTEGER) RETURN NUMBER IS
    BEGIN
        RETURN UNIX_EPOCH + seconds / 24.0 / 60.0 / 60.0;
    END;

    --
    -- 1.11
    --
    FUNCTION unix_from_moment(t NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN 24 * 60 * 60 * (t - UNIX_EPOCH);
    END;

    --
    -- 1.12
    --
    FUNCTION fixed_from_moment(t NUMBER) RETURN INTEGER IS
    BEGIN
        RETURN floor(t);
    END;

    --
    -- 1.13
    --
    FUNCTION fixed_from_jd(jd NUMBER) RETURN INTEGER IS
    BEGIN
        RETURN floor(moment_from_jd(jd));
    END;

    --
    -- 1.14
    --
    FUNCTION jd_from_fixed(date NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN jd_from_moment(date);
    END;

    --
    -- 1.18
    --
    FUNCTION time_from_moment(t NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN mod(t, 1);
    END;

    --
    -- 1.22
    --
    FUNCTION gcd(x NUMBER, y NUMBER) RETURN NUMBER IS
    BEGIN    
        IF y = 0 THEN
            RETURN x;
        ELSE
            RETURN gcd(y, mod(x, y));
        END IF;
    END;

    --
    -- 1.23
    --
    FUNCTION lcm(x NUMBER, y NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN x * y / gcd(x, y);
    END;

    --
    -- 1.24
    -- This is a modified mod typeset as x mod [a .. b) in the book.
    --
    -- x mod [a .. b) ::= 
    --     x                     if a == b;
    --     a + (x-a) mod (b-a)   otherwise
    --
    FUNCTION mod2(x NUMBER, a NUMBER, b NUMBER) RETURN NUMBER IS
    BEGIN
        IF a = b THEN
            RETURN x;
        ELSE
            RETURN a + mod(x - a, b - a);
        END IF;
    END;

    --
    -- 1.28
    -- This is a modified mod typeset as x mod [1 .. b] in the book.
    --
    -- x mod [1 .. b] ::=
    --     b                 if x mod b == 0
    --     x mod b           otherwise
    --
    FUNCTION mod3(x NUMBER, b NUMBER) RETURN NUMBER IS
        n NUMBER;
    BEGIN
        n := mod(x, b);
        IF n = 0 THEN 
            RETURN b;
        ELSE 
            RETURN n;
        END IF;
    END;

    --
    -- 1.30
    -- Conditional summation will sum f(i) starting from i = k
    -- as long as p(i) is true.
    --
    -- Due to the lack of lambda function support in PL/SQL this is 
    -- not yet implemented.
    --

    --
    -- 1.31
    -- Conditional multiplication analogous to 1.30 above.
    -- Multiply f(i) as long as p(i) is true.
    --
    -- Due to the lack of lambda function support in PL/SQL this is 
    -- not yet implemented.
    --

    --
    -- 1.32
    -- MIN search searches for the smallest d in the sequence d0, d0+1, ...
    -- such that the condition p holds true for d.  The caller must make
    -- sure this function will terminate for some d.  Return d.
    --
    -- Due to the lack of lambda function support in PL/SQL this is 
    -- not yet implemented.
    --

    --
    -- 1.33
    -- MAX search is the compliment of MIN search.  It returns d such
    -- that p(d0), p(d0+1), ... p(d) are true but the next one p(d+1) is
    -- false.  Return d.  If p(d0) is already false, return d0-1.
    -- The caller must make sure this function will terminate.
    --
    -- Due to the lack of lambda function support in PL/SQL this is 
    -- not yet implemented.
    --

BEGIN
    JD_EPOCH := rd(-1721424.5);  -- 1.3 Julian date Epoch
    MJD_EPOCH := rd(678576);     -- 1.6 Modified Julian Epoch
    UNIX_EPOCH := rd(719163);    -- 1.9 Unix Epoch

END;
/
SHOW ERRORS
