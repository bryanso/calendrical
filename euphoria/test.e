include std/math.e
include epoch.e
include gregorian.e

-- integer shifted_epact
-- 
-- for i = 0 to 37 do
    -- shifted_epact = mod(14 + 11 * mod(i, 19), 30)
    -- printf(1, "%2d: %d\n", {i, shifted_epact})
-- end for


atom f2017 = gregorian_to_fixed({2017, October, 4})
atom a = f2017
for i = 1 to 12 do
    printf(1, "a: %.1f ", a)
    print(1, gregorian_from_fixed(floor(a)))
    printf(1, "  ")
    print(1, gregorian_from_fixed(round(a)))
    printf(1, "\n")
    a += 29.5
end for
