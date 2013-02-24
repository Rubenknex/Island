noise = {}

local p = {}

local grad3 = {
    {1, 1, 0}, {-1, 1, 0}, {1, -1, 0}, {-1, -1, 0},
    {1, 0, 1}, {-1, 0, 1}, {1, 0, -1}, {-1, 0, -1},
    {0, 1, 1}, {0, -1, 1}, {0, 1, -1}, {0, -1, -1},
}

local function smootherstep(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

local function lerp(x, a, b)
    return a + x * (b - a)
end

local function grad(ha, x, y)
    local h = ha % 16
    local u, v = 0, 0

    if h < 8 then u = x else u = y end
    if h < 4 then v = y elseif h == 12 or h == 14 then v = x end

    if h % 2 == 0 then u = -u end
    if h % 4 == 0 then v = -v end

    return u + v
end

local function dot(g, x, y)
    return g[1] * x + g[2] * y
end

function noise.seed(seed)
    math.randomseed(seed)

    for i=0, 255 do p[i] = i end

    for i=255, 1, -1 do
        local j = math.random(0, i)
        p[i], p[j] = p[j], p[i]
    end

    for i=0, 255 do p[256 + i] = p[i] end
end

function noise.perlin(x, y)
    local X = math.floor(x % 256)
    local Y = math.floor(y % 256)

    local fracX = x - math.floor(x)
    local fracY = y - math.floor(y)

    local u = smootherstep(fracX)
    local v = smootherstep(fracY)

    local A  = p[X] + Y
    local AA = p[A]
    local AB = p[A + 1]

    local B  = p[X + 1] + Y
    local BA = p[B]
    local BB = p[B + 1]

    return lerp(v, lerp(u, grad(p[AA], fracX,     fracY    ), 
                           grad(p[BA], fracX - 1, fracY    )), 
                   lerp(u, grad(p[AB], fracX,     fracY - 1), 
                           grad(p[BB], fracX - 1, fracY - 1)))
end

function noise.simplex(x, y)
    local F2 = 0.5 * (math.sqrt(3) - 1)
    local s = (x + y) * F2
    local i = math.floor(x + s)
    local j = math.floor(y + s)

    local G2 = (3 - math.sqrt(3)) / 6
    local t = (i + j) * G2
    local X0 = i - t
    local Y0 = j - t
    local x0 = x - X0
    local y0 = y - Y0

    local i1, j1 = 0, 0
    if x0 > y0 then i1 = 1 else j1 = 1 end

    local x1 = x0 - i1 + G2
    local y1 = y0 - j1 + G2
    local x2 = x0 - 1 + 2 * G2
    local y2 = y0 - 1 + 2 * G2

    local ii = i % 256
    local jj = j % 256
    local gi0 = p[ii + p[jj]] % 12
    local gi1 = p[ii + p[jj + j1] + i1] % 12
    local gi2 = p[ii + p[jj + 1] + 1] % 12

    local n0, n1, n2 = 0, 0, 0

    local t0 = 0.5 - x0 * x0 - y0 * y0
    if t0 > 0 then
        t0 = t0 * t0
        n0 = t0 * t0 * dot(grad3[gi0 + 1], x0, y0)
    end

    local t1 = 0.5 - x1 * x1 - y1 * y1
    if t1 > 0 then
        t1 = t1 * t1
        n1 = t1 * t1 * dot(grad3[gi1 + 1], x1, y1)
    end

    local t2 = 0.5 - x2 * x2 - y2 * y2
    if t2 > 0 then
        t2 = t2 * t2
        n2 = t2 * t2 * dot(grad3[gi2 + 1], x2, y2)
    end

    return (70 * (n0 + n1 + n2) + 1) / 2 
end