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


BEGIN
    JD_EPOCH := rd(-1721424.5);  -- 1.3 Julian date Epoch
    MJD_EPOCH := rd(678576);     -- 1.6 Modified Julian Epoch
    UNIX_EPOCH := rd(719163);    -- 1.9 Unix Epoch

END;
/
SHOW ERRORS
