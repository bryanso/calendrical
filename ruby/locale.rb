#
# Calendrical Calculations Third Edition
# Nachum Dershowitz, Edward M. Reingold
# Cambridge University Press
# 2008
#

include Math
require_relative "gregorian"


HONG_KONG = Position.new(
    22.3964,
    114.1095,
    0,
    8.0 / 24
)


SAN_FRANCISCO = Position.new(
    Angle.new(37.0, 46.0, 29.0).to_degree,
    Angle.new(-122.0, 25.0, 9.0).to_degree,
    28.0,
    -8.0 / 24
)


#
# 13.1
#
URBANA = Position.new(40.1, -88.2, 225.0, -6.0 / 24)


#
# 13.2
#
GREENWICH = Position.new(51.4777815, 0, 46.9, 0)


#
# 13.3
#
MECCA = Position.new(
    Angle.new(21.0, 25.0, 24.0).to_degree, 
    Angle.new(39.0, 49.0, 24.0).to_degree, 
    298.0, 
    3.0 / 24
)


#
# 13.4
#
JERUSALEM = Position.new(31.8, 35.2, 800.0, 2.0 / 24)


#
# 13.75
#
CFS_ALERT = Position.new(
    Angle.new(82.0, 30.0, 0).to_degree, 
    Angle.new(-62.0, 19.0, 0).to_degree, 
    0, 
    -5.0 / 24
)


