CREATE OR REPLACE PACKAGE calendar_pkg IS
--
-- Adapted from Calendrical Calculations: The Ultimate Edition
-- Edward M. Reingold and Nachum Dershowitz
--
-- bso Fri Nov 10 12:36:02 PST 2023
--


    SUNDAY      CONSTANT NUMBER := 0;   -- 1.53
    MONDAY      CONSTANT NUMBER := 1;   -- 1.54
    TUESDAY     CONSTANT NUMBER := 2;   -- 1.55
    WEDNESDAY   CONSTANT NUMBER := 3;   -- 1.56
    THURSDAY    CONSTANT NUMBER := 4;   -- 1.57
    FRIDAY      CONSTANT NUMBER := 5;   -- 1.58
    SATURDAY    CONSTANT NUMBER := 6;   -- 1.59

    JANUARY     CONSTANT NUMBER := 1;   -- 2.4
    FEBRUARY    CONSTANT NUMBER := 2;   -- 2.5
    MARCH       CONSTANT NUMBER := 3;   -- 2.6
    APRIL       CONSTANT NUMBER := 4;   -- 2.7
    MAY         CONSTANT NUMBER := 5;   -- 2.8
    JUNE        CONSTANT NUMBER := 6;   -- 2.9
    JULY        CONSTANT NUMBER := 7;   -- 2.10
    AUGUST      CONSTANT NUMBER := 8;   -- 2.11
    SEPTEMBER   CONSTANT NUMBER := 9;   -- 2.12
    OCTOBER     CONSTANT NUMBER := 10;  -- 2.13
    NOVEMBER    CONSTANT NUMBER := 11;  -- 2.14
    DECEMBER    CONSTANT NUMBER := 12;  -- 2.15

    EPOCH       CONSTANT NUMBER := 0;   -- 1.1
    JD_EPOCH    NUMBER;                 -- 1.3 Julian date epoch
    MJD_EPOCH   NUMBER;                 -- 1.6 Modified Julian Epoch
    UNIX_EPOCH  NUMBER;                 -- 1.9 Unix Epoch
    EGYPTIAN_EPOCH  NUMBER;             -- 1.46
    ARMENIAN_EPOCH NUMBER;              -- 1.50
    AKAN_DAY_NAME_EPOCH NUMBER;         -- 1.78
    GREGORIAN_EPOCH NUMBER;             -- 2.3

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

    FUNCTION radix2(                                        -- 1.42
        x NUMBER, 
        b dbms_sql.number_table, 
        d dbms_sql.number_table) 
    RETURN dbms_sql.number_table;

    FUNCTION time_from_clock(hms dbms_sql.number_table)     -- 1.43
    RETURN NUMBER;

    FUNCTION clock_from_moment(t NUMBER)                    -- 1.44 
    RETURN dbms_sql.number_table;

    FUNCTION angle_from_degrees(a NUMBER)                   -- 1.45
    RETURN dbms_sql.number_table;

    FUNCTION fixed_from_egyptian(year NUMBER, month NUMBER, day NUMBER)  -- 1.47
    RETURN NUMBER;

    FUNCTION egyptian_from_fixed(date NUMBER)              -- 1.49
    RETURN dbms_sql.number_table;

    FUNCTION fixed_from_armenian(year NUMBER, month NUMBER, day NUMBER)  -- 1.51
    RETURN NUMBER;

    FUNCTION armenian_from_fixed(date NUMBER)              -- 1.52
    RETURN dbms_sql.number_table;

    FUNCTION day_of_week_from_fixed(date NUMBER)           -- 1.60
    RETURN NUMBER;

    -- 1.62
    FUNCTION kday_on_or_before(k NUMBER, date NUMBER) 
    RETURN NUMBER;

    -- 1.65
    FUNCTION kday_on_or_after(k NUMBER, date NUMBER) 
    RETURN NUMBER;

    -- 1.66
    FUNCTION kday_nearest(k NUMBER, date NUMBER) 
    RETURN NUMBER;

    -- 1.67
    FUNCTION kday_before(k NUMBER, date NUMBER) 
    RETURN NUMBER;

    -- 1.68
    FUNCTION kday_after(k NUMBER, date NUMBER) 
    RETURN NUMBER;

    -- 1.76
    FUNCTION akan_day_name(n NUMBER) 
    RETURN dbms_sql.number_table;

    -- 1.77
    FUNCTION akan_name_difference(
        prefix1 NUMBER, stem1 NUMBER, prefix2 NUMBER, stem2 NUMBER) 
    RETURN NUMBER;

    -- 1.79
    FUNCTION akan_name_from_fixed(date NUMBER) 
    RETURN dbms_sql.number_table;

    -- 1.80
    FUNCTION akan_day_name_on_or_before(
        prefix NUMBER, stem NUMBER, date NUMBER) 
    RETURN NUMBER;

    -- 2.16
    FUNCTION gregorian_leap_year(year INTEGER) 
    RETURN BOOLEAN;

END;
/
SHOW ERRORS
