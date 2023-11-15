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

    FUNCTION mod2(x NUMBER, a NUMBER, b NUMBER) RETURN NUMBER;  -- 1.24

    FUNCTION mod3(x NUMBER, b NUMBER) RETURN NUMBER;       -- 1.28

    FUNCTION list_of_fixed_from_moments(l dbms_sql.number_table) -- 1.37
    RETURN dbms_sql.number_table;

    FUNCTION positions_in_range(p NUMBER, c NUMBER, d NUMBER, a NUMBER, b NUMBER)  -- 1.40
    RETURN dbms_sql.number_table;

    FUNCTION radix(                                         -- 1.41
        a dbms_sql.number_table, 
        b dbms_sql.number_table, 
        d dbms_sql.number_table) 
    RETURN NUMBER;
END;
/
SHOW ERRORS
