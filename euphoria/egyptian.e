--
--
-- Calendrical Calculations Third Edition
-- Nachum Dershowitz, Edward M. Reingold
-- Cambridge University Press
-- 2008
--

include epoch.e


--
-- p. 24
--
global constant egyptian_month_names = {
    "Thoth",
    "Phaophi",
    "Athyr",
    "Choiak",
    "Tybi",
    "Mechir",
    "Phamenoth",
    "Pharmuthi",
    "Pachon",
    "Payni",
    "Epiphi",
    "Mesori",
    "unnamed"
}


--
-- 1.38
--
global constant epoch_egyptian = fixed_from_jd(1448638)

