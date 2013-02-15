function class(base)
    local c = {}

    if type(base) == "table" then
        for key,value in pairs(base) do
            c[key] = value
        end
        c._base = base
    end

    c.__index = c

    local mt = {}
    mt.__call = function(class_table, ...)
        local self = {}
        setmetatable(self, c)

        if class_table.init then
            class_table.init(self, ...)
        else
            if base and base.init then
                base.init(self, ...)
            end
        end

        return self
    end

    c.is_a = function(self, klass)
        local m = getmetatable(self)

        while m do
            if m == klass then return true end
            m = m._base
        end

        return false
    end

    setmetatable(c, mt)
    return c
end