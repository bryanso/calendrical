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

    --
    -- 1.34
    -- This ia generic binary search algorithm that can be adapted to perform
    -- any searches for answers to some increasing function.  
    --
    -- Supposed we want to find x where some function f(x) = y
    --
    -- q(l, u) is an accuracy test, e.g. u - l < 0.0001
    -- [a, b] is the initial guess interval
    -- p is a boolean test function that is false within the range [a, x) and
    -- turns true in the range [x, b]
    --
    -- E.g., To use it to find x that satisifies f(x) = y where f is an
    -- increasing function and x has accuracy to 4 decimal digits and
    -- x is known to be between [0, 1] can be:
    --
    -- min_binary_search(
    --    function (l, u) { (u - l) < 0.0001 },
    --    0,    
    --    1,
    --    function (x) { f(x) >= y }
    -- )   
    --   
    -- Due to the lack of lambda function support in PL/SQL this is 
    -- not yet implemented.
    --

    --
    -- 1.37
    --
    FUNCTION list_of_fixed_from_moments(l dbms_sql.number_table)
    RETURN dbms_sql.number_table IS
        t dbms_sql.number_table;
        i INTEGER;
        n INTEGER;
    BEGIN
        i := l.FIRST;
        WHILE i IS NOT NULL LOOP
            n := fixed_from_moment(l(i));
            t(i) := n;
            i := l.NEXT(i);
        END LOOP;
        RETURN t;
    END;

    --
    -- 1.40
    --
    -- To collect all occurrence of events, such as holidays, in an interval time,
    -- like a Gregorian year, we write a generic function to find the first occurrence on
    -- or after a given moment of the p-th moment in a c-day cycle, 0 <= p < c, and then
    -- recursively find the remaining occurrences:
    --
    -- positions-in-range(p, c, d, [a .. b)) ::=
    --     {}                                                 // if  date >= b
    --     {date} || positions-in-range(p, c, d, [a+c .. b))  // otherwise
    --
    -- where date = (p - d) mod [a .. a+c)                    // mod2
    --
    FUNCTION positions_in_range(p NUMBER, c NUMBER, d NUMBER, a NUMBER, b NUMBER) 
    RETURN dbms_sql.number_table IS
        date NUMBER;
        i NUMBER := 1;
        l NUMBER := a;
        result dbms_sql.number_table;
    BEGIN  
        LOOP
            date := mod2(p - d, l, l + c);
            EXIT WHEN date >= b;
            result(i) := date;
            i := i + 1;
            l := l + c;
        END LOOP;

        RETURN result;
    END;

    --
    -- 1.41
    -- Evaluate mixed-radix number 
    --
    -- a = { a0 a1 a2 ... an }
    --
    -- written in base
    --
    -- b = { b1 b2 ... bk } || { bk+1 bk+2 ... bn }   // starting from bk+1 it's decimal places
    --
    -- Notice length of b is one less than length of a.
    --
    FUNCTION radix(
        a dbms_sql.number_table, 
        b dbms_sql.number_table, 
        d dbms_sql.number_table) 
    RETURN NUMBER IS
        n INTEGER;
        result NUMBER;
        factor NUMBER;
    BEGIN
        n := a.count;
        IF n == 0 THEN
            RETURN 0;
        END IF;

        result := a(n);  -- Start backwards
        n = n - 1;

        -- Decimal places need division
        FOR k IN REVERSE 1 .. d.COUNT 
        LOOP
            result := a(n) + result / d(k)
            n := n - 1;
        END LOOP;

        factor := 1;
        -- Start multiplicative bases
        for k IN REVERSE 1 .. length(b)
        LOOP
            factor := factor * b(k);
            result := result + a(n) * factor;
            n := n - 1;
        END LOOP;

        -- Test cases
        -- ♠ radix({0 4 48 0}, {}, {24, 60, 60})
        -- 0.19999999999999998
        -- ♠ radix({4 1 12 44 2.88} {7} {24 60 60})
        -- 29.53058888888889

        RETURN result;
    END;


BEGIN
    JD_EPOCH := rd(-1721424.5);  -- 1.3 Julian date Epoch
    MJD_EPOCH := rd(678576);     -- 1.6 Modified Julian Epoch
    UNIX_EPOCH := rd(719163);    -- 1.9 Unix Epoch

END;
/
SHOW ERRORS
