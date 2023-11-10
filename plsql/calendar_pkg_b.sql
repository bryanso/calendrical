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


BEGIN
    JD_EPOCH := rd(-1721424.5);  -- 1.3 Julian date Epoch
    MJD_EPOCH := rd(678576);     -- 1.6 Modified Julian Epoch
    UNIX_EPOCH := rd(719163);    -- 1.9 Unix Epoch

END;
/
SHOW ERRORS
