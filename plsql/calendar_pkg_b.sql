CREATE OR REPLACE PACKAGE BODY calendar_pkg IS
--
-- Adapted from Calendrical Calculations: The Ultimate Edition
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
        IF n = 0 THEN
            RETURN 0;
        END IF;

        result := a(n);  -- Start backwards
        n := n - 1;

        -- Decimal places need division
        FOR k IN REVERSE 1 .. d.COUNT 
        LOOP
            result := a(n) + result / d(k);
            n := n - 1;
        END LOOP;

        factor := 1;
        -- Start multiplicative bases
        FOR k IN REVERSE 1 .. b.COUNT
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

        --
        -- PL/SQL number_table can be initialized this way:
        --
        -- DECLARE
        --     a dbms_sql.number_table;
        --     b dbms_sql.number_table;
        --     d dbms_sql.number_table;
        -- BEGIN
        --     a := dbms_sql.number_table(4, 1, 12, 44, 2.88);
        --     b := dbms_sql.number_table(7);
        --     d := dbms_sql.number_table(24, 60, 60);
        --     dbms_output.put_line(calendar_pkg.radix(a, b, d));
        -- END;
        --

        RETURN result;
    END;

    --
    -- 1.42 (Reverse of 1.41)
    --
    FUNCTION radix2(
        x NUMBER, 
        b dbms_sql.number_table, 
        d dbms_sql.number_table) 
    RETURN dbms_sql.number_table IS
        a dbms_sql.number_table;
        factor NUMBER := 1;
        t NUMBER;
    BEGIN
        FOR k IN 1 .. d.COUNT
        LOOP
            factor := factor * d(k);
            IF k = d.COUNT THEN
                t := mod(x * factor, d(k));
            ELSE
                t := mod(floor(x * factor), d(k));
            END IF;
            a(k + b.COUNT + 1) := t;
        END LOOP;

        factor := 1;
        FOR k IN REVERSE 1 .. b.COUNT 
        LOOP
            t := mod(floor(x / factor), b(k));
            a(k + 1) := t;
            factor := factor * b(k);
        END LOOP;

        -- a0
        a(1) := floor(x / factor);

        RETURN a;
    END;

    --
    -- 1.43
    --
    -- Definition in the book is incorrect.  The following should be the
    -- corrected version.  But it's more readable to use the 3rd ed. formula.
    --
    -- function time_from_clock(hms) {
    --    radix({0} & hms, {}, {24, 60, 60}) 
    -- }
    --
    -- Formula from 3rd edition
    --
    FUNCTION time_from_clock(hms dbms_sql.number_table)
    RETURN NUMBER IS
        h NUMBER := hms(1);
        m NUMBER := hms(2);
        s NUMBER := hms(3);
    BEGIN
        RETURN (h + (m + s / 60) / 60) / 24;
    END;

    --
    -- 1.44
    --
    -- Formula from 3rd edition
    --
    -- function clock_from_moment(t) {
    --     variable h, m, s
    --     variable time = time_from_moment(t)
    --     h = floor(time * 24)
    --     m = floor(mod(time * 24 * 60, 60))
    --     s = mod(time * 24 * 60 * 60, 60)
    --     {h m s}
    -- }
    --
    FUNCTION clock_from_moment(t NUMBER) 
    RETURN dbms_sql.number_table IS
        time NUMBER;
        result dbms_sql.number_table;
    BEGIN
        time := time_from_moment(t);
        result(1) := floor(time * 24);
        result(2) := floor(mod(time * 24 * 60, 60));
        result(3) := mod(time * 24 * 60 * 60, 60);
        RETURN result;
    END;

    --
    -- 1.45
    -- 
    FUNCTION angle_from_degrees(a NUMBER) 
    RETURN dbms_sql.number_table IS
        dms dbms_sql.number_table;
    BEGIN 
        dms := radix2(
            abs(a), 
            dbms_sql.number_table(), 
            dbms_sql.number_table(60, 60));
        IF a < 0 THEN
            dms(1) := -dms(1);
            dms(2) := -dms(2);
            dms(3) := -dms(3);
        END IF;
        RETURN dms;
    END;

    --
    -- The Egyptian Months
    --
    --  1. Thoth                  30 days
    --  2. Phaophi                30 days
    --  3. Athyr                  30 days
    --  4. Choiak                 30 days
    --  5. Tybi                   30 days
    --  6. Mechir                 30 days
    --  7. Phamenoth              30 days
    --  8. Pharmuthi              30 days
    --  9. Pachon                 30 days
    -- 10. Payni                  30 days
    -- 11. Epiphi                 30 days
    -- 12. Mesori                 30 days
    -- 13. (unnamed epagomenae)    5 days
    --

    --
    -- 1.47
    --
    FUNCTION fixed_from_egyptian(ymd dbms_sql.number_table) 
    RETURN NUMBER IS
    BEGIN
        RETURN EGYPTIAN_EPOCH + 
            365 * (ymd(1) - 1) +
            30 * (ymd(2) - 1) + 
            ymd(3) - 1;
    END;

    --
    -- 1.49
    --
    FUNCTION egyptian_from_fixed(date NUMBER) 
    RETURN dbms_sql.number_table IS
        days NUMBER;
        year NUMBER;
        month NUMBER;
        day NUMBER;
    BEGIN
        days := date - EGYPTIAN_EPOCH;
        year := floor(days / 365) + 1;
        month := floor(mod(days, 365) / 30) + 1;
        day := days - 365 * (year - 1) - 30 * (month - 1) + 1;
        RETURN dbms_sql.number_table(year, month, day);
    END;

    --
    -- The Armenian Months
    --
    --  1. Nawasardi              30 days
    --  2. Hori                   30 days
    --  3. Sahmi                  30 days
    --  4. Tre                    30 days
    --  5. K'aloch                30 days
    --  6. Arach                  30 days
    --  7. Mehekani               30 days
    --  8. Areg                   30 days
    --  9. Ahekani                30 days
    -- 10. Mareri                 30 days
    -- 11. Margach                30 days
    -- 12. Hrotich                30 days
    -- 13. aweleach                5 days
    --

    --
    -- 1.51
    --
    FUNCTION fixed_from_armenian(ymd dbms_sql.number_table) 
    RETURN NUMBER IS
    BEGIN
        RETURN ARMENIAN_EPOCH + 
            fixed_from_egyptian(ymd) -
            EGYPTIAN_EPOCH;
    END;

    --
    -- 1.52
    --
    FUNCTION armenian_from_fixed(date NUMBER) 
    RETURN dbms_sql.number_table IS
    BEGIN
        RETURN egyptian_from_fixed(date + EGYPTIAN_EPOCH - ARMENIAN_EPOCH);
    END;

    -- 1.60
    FUNCTION day_of_week_from_fixed(date NUMBER) 
    RETURN NUMBER IS
    BEGIN
        RETURN mod(date - rd(0) - SUNDAY, 7);
    END;

    -- 1.62
    FUNCTION kday_on_or_before(k NUMBER, date NUMBER) 
    RETURN NUMBER IS
    BEGIN
        RETURN date - day_of_week_from_fixed(date - k);
    END;

    -- 1.65
    FUNCTION kday_on_or_after(k NUMBER, date NUMBER) 
    RETURN NUMBER IS
    BEGIN
        RETURN kday_on_or_before(k, date + 6);
    END;

    -- 1.66
    FUNCTION kday_nearest(k NUMBER, date NUMBER) 
    RETURN NUMBER IS
    BEGIN
        RETURN kday_on_or_before(k, date + 3);
    END;

    -- 1.67
    FUNCTION kday_before(k NUMBER, date NUMBER) 
    RETURN NUMBER IS
    BEGIN
        RETURN kday_on_or_before(k, date - 1);
    END;

    -- 1.68
    FUNCTION kday_after(k NUMBER, date NUMBER) 
    RETURN NUMBER IS
    BEGIN
        RETURN kday_on_or_before(k, date + 7);
    END;

    --
    -- Section 1.13 Simultaneous Cycles
    --
    -- Some calendars employ two cycles running simultaneously.
    -- Each day is labeled by a pair of number <a, b>, beginning
    -- with <0, 0>, followed by <1, 1>, <2, 2>, and so on.
    -- Supposed the first component repeats after c days and the
    -- second after d days, with c < d < 2c, then after day
    -- <c-1, c-1> comes days <0, c>, <1, c+1>, and so on until
    -- <d-c-1, d-1>, which is followed by <d-c, 0>.  If day 0 of
    -- the calendar is labeled <0, 0> then day n is <mod(n, c),
    -- mod(n, d)>.  The Chinese use such pairs to identify years
    -- (see Section 19.4), which cycles of length c = 10 and
    -- d = 12 but, because the first component ranges from 1 to
    -- 10, inclusive, and the second from 1 to 12, we would use
    -- the adjusted remainder function: <mod3(n, 10), mod3(n, 12)
    --
    -- More generally, for arbitrary positive integers c and d,
    -- if the label of day 0 is <e, f> then day n is labeled
    --
    -- <mod(n+ , c), mod(n+f, d)>
    --
    -- Inverting this representation is harder.
    --
    -- Let 
    --     l = lcm(c, d)
    --     g = gcd(c, d)
    --     u = c / g
    --     v = d / g
    --  
    -- Find k so that
    --     mod(k * u, v) = 1
    --
    -- n = mod(a - e + c * k * (b - a + e - f) / g, l)
    --

    --
    -- The prefixes of the Akan calendar are
    --
    -- 1 Nwona (care, wellness, surpass, innocence)
    -- 2 Nkyi (passing, no restrictions)
    -- 3 Kuru (sacred, complete)
    -- 4 Kwa (ordinary, empty, freedom)
    -- 5 Mono (fresh, new)
    -- 6 Fo (generous, calm, love to another)
    --
    -- The stems are
    --
    -- 1 Wukuo (cleansing, advocate, mean-spirited)
    -- 2 Yaw (pain, suffering, bravery)
    -- 3 Fie (depart from, come forth, travel)
    -- 4 Memene (digest, satiety, creation, ancient)
    -- 5 Kwasi (freedom, purify, smoke)
    -- 6 Dwo (peaceful, cool, calm)
    -- 7 Bene (well-cooked)
    -- 

    -- 1.76
    FUNCTION akan_day_name(n NUMBER) 
    RETURN dbms_sql.number_table IS
        l dbms_sql.number_table;
    BEGIN
        l(1) := mod3(n, 6);
        l(2) := mod3(n, 7);
        RETURN l;
    END;

    -- 1.77
    FUNCTION akan_name_difference(
        name1 dbms_sql.number_table,
        name2 dbms_sql.number_table)
    RETURN NUMBER IS
        p NUMBER := name2(1) - name1(1);
        s NUMBER := name2(2) - name1(2);
    BEGIN
        RETURN mod3(p + 36 * (s - p), 42);
    END;

    -- 1.79
    FUNCTION akan_name_from_fixed(date NUMBER) 
    RETURN dbms_sql.number_table IS
    BEGIN
        RETURN akan_day_name(date - AKAN_DAY_NAME_EPOCH);
    END;

    -- 1.80
    FUNCTION akan_day_name_on_or_before(
        name dbms_sql.number_table, date NUMBER) 
    RETURN NUMBER IS
        z dbms_sql.number_table := akan_name_from_fixed(0);
    BEGIN
        RETURN mod2(
            akan_name_difference(z, name),
            date,
            date - 42);
    END;

    -- 2.16
    FUNCTION gregorian_leap_year(year INTEGER) 
    RETURN BOOLEAN IS
    BEGIN
        RETURN mod(year, 4) = 0 AND 
            mod(year, 400) NOT IN (100, 200, 300);
    END;

BEGIN
    JD_EPOCH := rd(-1721424.5);  -- 1.3 Julian date Epoch
    MJD_EPOCH := rd(678576);     -- 1.6 Modified Julian Epoch
    UNIX_EPOCH := rd(719163);    -- 1.9 Unix Epoch
    EGYPTIAN_EPOCH := fixed_from_jd(1448638);    -- 1.46
    ARMENIAN_EPOCH := rd(201443);                -- 1.50
    AKAN_DAY_NAME_EPOCH := rd(37);               -- 1.78
    GREGORIAN_EPOCH := rd(1);                    -- 2.3

END;
/
SHOW ERRORS
