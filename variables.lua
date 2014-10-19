require "color"
require "vec2"

objectTypes={
    starfish={
        origin=Vec2(8, 8),
        value_min=0.35,value_max=0.45,
        density=0.4,
        rotation=true,
    },
    shell={
        origin=Vec2(8, 8),
        value_min=0.35,value_max=0.45,
        density=0.4,
        rotation=true,
    },
    stone={
        origin=Vec2(8, 8),
        value_min=0.35,value_max=0.9,
        density=0.3,
        rotation=true,
    },
	grass={
		origin=Vec2(8, 16),
        value_min=0.45,value_max=0.9,
        density=1,
    },
    palm={
        origin=Vec2(16, 64),
        value_min=0.43,value_max=0.5,
        density=2,
        radius=8,
        collidable=true,
        can_flip=true,
        flat=false
    },
    palm_leaf={
        origin=Vec2(8, 8),
        value_min=0.43,value_max=0.5,
        density=1,
        rotation=true
    },
}

-- Map
tileSize = 16
tileDrawSize = 32

mapFrequency = 2.5
mapAmplitude = 8
mapPersistence = 0.45
mapOctaves = 4
mapSmoothingPasses = 3

tileTypes = {
    {type="water", limit=0.35, startColor=Color.fromHSL(218, 75, 35), endColor=Color.fromHSL(218, 60, 55)},
    {type="sand",  limit=0.45,  startColor=Color.fromHSL(56, 36, 80),  endColor=Color.fromHSL(56, 70, 88)},
    {type="grass", limit=0.9,  startColor=Color.fromHSL(103, 50, 32), endColor=Color.fromHSL(103, 50, 23)},
    {type="rock",  limit=1.0,  startColor=Color.fromHSL(0, 0, 40),    endColor=Color.fromHSL(0, 0, 32)}
}

-- World
gridSize = 256

-- Player
playerSpeed = 150
playerSprintSpeed = 250

-- Crab
crabSpeed = 50
crabMinRange = 20
crabMaxRange = 40
crabMinIdle = 0.5
crabMaxIdle = 3.0