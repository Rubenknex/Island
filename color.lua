Color = {}
Color.__index = Color

function Color.fromRGB(r, g, b)
    local self = {}
    setmetatable(self, Color)

    self.r, self.g, self.b = r, g, b

    return self
end

function Color.fromHSL(h, s, l)
    local self = {}
    setmetatable(self, Color)

    self.r, self.g, self.b = Color.hslToRgb(h, s, l)
    print(tostring(self))

    return self
end

function Color.hslToRgb(h, s, l)
    h, s, l = (h/360)*6, s/100, l/100

    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end 

    return (r+m)*255,(g+m)*255,(b+m)*255,a
end

function Color:interpolate(other, x)
    return Color.fromRGB(utils.lerp(self.r, other.r, x), 
                         utils.lerp(self.g, other.g, x), 
                         utils.lerp(self.b, other.b, x))
end

function Color:toRGB()
    return self.r, self.g, self.b
end

function Color.__tostring(a)
    return "(" .. a.r .. ", " .. a.g .. ", " .. a.b .. ")"
end