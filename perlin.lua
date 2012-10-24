perlin = {}

local p = {}

function perlin.seed(seed)
    math.randomseed(seed)

    for i=0, 255 do p[i] = i end

    for i=255, 1, -1 do
        local j = math.random(0, i)
        p[i], p[j] = p[j], p[i]
    end

    for i=0, 255 do p[256 + i] = p[i] end
end

function perlin.fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

function perlin.lerp(x, a, b)
    return a + x * (b - a)
end

function perlin.grad(ha, x, y)
    local h = ha % 16
    local u, v = 0, 0

    if h < 8 then u = x else u = y end
    if h < 4 then v = y elseif h == 12 or h == 14 then v = x end

    if h % 2 == 0 then u = -u end
    if h % 4 == 0 then v = -v end

    return u + v
end

function perlin.noise(x, y)
    local X = math.floor(x % 256)
    local Y = math.floor(y % 256)

    local fracX = x - math.floor(x)
    local fracY = y - math.floor(y)

    local u = perlin.fade(fracX)
    local v = perlin.fade(fracY)

    local A  = p[X] + Y
    local AA = p[A]
    local AB = p[A + 1]

    local B  = p[X + 1] + Y
    local BA = p[B]
    local BB = p[B + 1]

    return perlin.lerp(v, perlin.lerp(u, perlin.grad(p[AA], fracX,     fracY    ), 
                                         perlin.grad(p[BA], fracX - 1, fracY    )), 
                          perlin.lerp(u, perlin.grad(p[AB], fracX,     fracY - 1), 
                                         perlin.grad(p[BB], fracX - 1, fracY - 1)))
end