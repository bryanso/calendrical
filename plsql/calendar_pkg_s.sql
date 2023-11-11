CREATE OR REPLACE PACKAGE calendar_pkg IS
--
-- Adapted from Calendrical Calculations by 
-- Edward M. Reingold and Nachum Dershowitz
--
-- bso Fri Nov 10 12:36:02 PST 2023
--


    EPOCH       CONSTANT NUMBER := 0;   -- 1.1
    JD_EPOCH    NUMBER;                 -- 1.3 Julian date epoch
    MJD_EPOCH   NUMBER;                 -- 1.6 Modified Julian Epoch
    UNIX_EPOCH  NUMBER;                 -- 1.9 Unix Epoch

    FUNCTION mod(x NUMBER, y NUMBER) RETURN NUMBER;  -- 1.17 Modified mod function

    FUNCTION rd(t NUMBER) RETURN NUMBER;    -- 1.1 Initial Epoch and Rata Die (fixed date)

    FUNCTION moment_from_jd(jd NUMBER) RETURN NUMBER;      -- 1.4

    FUNCTION jd_from_moment(t NUMBER) RETURN NUMBER;       -- 1.5

    FUNCTION fixed_from_mjd(mjd NUMBER) RETURN NUMBER;     -- 1.7

    FUNCTION mjd_from_fixed(date NUMBER) RETURN NUMBER;    -- 1.8

    FUNCTION moment_from_unix(seconds INTEGER) RETURN NUMBER;  -- 1.10

    FUNCTION unix_from_moment(t NUMBER) RETURN NUMBER;     -- 1.11

    FUNCTION fixed_from_moment(t NUMBER) RETURN INTEGER;   -- 1.12

    FUNCTION fixed_from_jd(jd NUMBER) RETURN INTEGER;      -- 1.13

    FUNCTION jd_from_fixed(date NUMBER) RETURN NUMBER;     -- 1.14

    FUNCTION time_from_moment(t NUMBER) RETURN NUMBER;     -- 1.18

    FUNCTION gcd(x NUMBER, y NUMBER) RETURN NUMBER;        -- 1.22

    FUNCTION lcm(x NUMBER, y NUMBER) RETURN NUMBER;        -- 1.23

END;
/
SHOW ERRORS
