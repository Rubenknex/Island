require "utils"

Color = class()

function Color:init(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a or 255
end

function Color.fromHSL(h, s, l)
    local r, g, b = Color.hslToRgb(h, s, l)

    return Color(r, g, b)
end

function Color.hslToRgb(h, s, l)
    h, s, l = (h / 360) * 6, s / 100, l / 100

    local c = (1 - math.abs(2 * l - 1)) * s
    local x = (1 - math.abs(h % 2 - 1)) * c

    local m, r, g, b = (l - .5 * c), 0, 0, 0 

    if     h < 1 then r, g, b = c, x, 0
    elseif h < 2 then r, g, b = x, c, 0
    elseif h < 3 then r, g, b = 0, c, x
    elseif h < 4 then r, g, b = 0, x, c
    elseif h < 5 then r, g, b = x, 0, c
    else              r, g, b = c, 0, x
    end 

    return (r + m) * 255, (g + m) * 255, (b + m) * 255
end

function Color.interpolate(a, b, x)
    return Color(utils.lerp(a.r, b.r, x), utils.lerp(a.g, b.g, x), utils.lerp(a.b, b.b, x))
end

function Color:toRGB()
    return self.r, self.g, self.b
end

function Color:toRGBA()
    return self.r, self.g, self.b, self.a
end

function Color.__tostring(a)
    return "Color(" .. a.r .. "," .. a.g .. "," .. a.b .. "," .. a.a ")"
end