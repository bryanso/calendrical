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


END;
/
SHOW ERRORS
