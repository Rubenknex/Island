require "color"

-- Map
tileSize = 16
tileDrawSize = 32

mapFrequency = 3
mapAmplitude = 1
mapPersistence = 0.6
mapOctaves = 6
mapPadding = 15
mapSmoothingPasses = 5

waterLimit = 0.35
sandLimit = 0.4
grassLimit = 0.65
rockLimit = 1.0

-- These colors are in HSL format
tileColorTransitions = {
    {Color.fromHSL(218, 100, 35), Color.fromHSL(218, 100, 60)}, -- Water
    {Color.fromHSL(59, 55, 67),   Color.fromHSL(59, 55, 80)},   -- Sand
    {Color.fromHSL(103, 50, 32),  Color.fromHSL(103, 50, 23)},  -- Grass
    {Color.fromHSL(0, 0, 40),     Color.fromHSL(0, 0, 32)}      -- Rock
}

-- Player
playerSpeed = 150
playerSprintSpeed = 250

-- Crab
crabSpeed = 50
crabMinRange = 20
crabMaxRange = 40
crabMinIdle = 0.5
crabMaxIdle = 3.0