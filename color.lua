require "utils"

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

    self.r, self.g, self.b = utils.hslToRgb(h, s, l)

    return self
end

function Color:interpolate(other, x)
    return Color.fromRGB(utils.lerp(self.r, other.r, x), 
                         utils.lerp(self.g, other.g, x), 
                         utils.lerp(self.b, other.b, x))
end

function Color:toRGB()
    return self.r, self.g, self.b
end