require "color"

objectTypes={
    starfish={
        origin_x=8,
        origin_y=8,
        collidable=false,
    },
    shell={
        origin_x=8,
        origin_y=8,
        collidable=false,
    },
    stone={
        origin_x=8,
        origin_y=8,
        collidable=false,
    },
	grass={
		origin_x=8,
		origin_y=16,
		collidable=false,
	},
    palm={
        origin_x=16,
        origin_y=64,
        radius=8,
        canFlip=true,
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
    {type="water", limit=0.35, startColor=Color.fromHSL(218, 75, 35), endColor=Color.fromHSL(218, 75, 55)},
    {type="sand", limit=0.4, startColor=Color.fromHSL(59, 55, 67), endColor=Color.fromHSL(59, 55, 80)},
    {type="grass", limit=0.9, startColor=Color.fromHSL(103, 50, 32), endColor=Color.fromHSL(103, 50, 23)},
    {type="rock", limit=1.0, startColor=Color.fromHSL(0, 0, 40), endColor=Color.fromHSL(0, 0, 32)}
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