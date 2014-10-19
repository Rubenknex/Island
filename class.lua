function class(base)
    -- Create the new class and set the __index to the class
    -- definition to look up methods
    local cls = {}
    cls.__index = cls

    -- This part doesn't allow the child class to have new methods.
    -- Copy the properties of the base class over to the new class
    --[[if type(base) == "table" then
        for key, value in pairs(base) do
            --cls[key] = value
        end
    end]]

    local mt = {}
    mt.__index = base
    mt.__call = function(class_table, ...)
        local instance = setmetatable({}, cls)

        if class_table.init then
            class_table.init(instance, ...)
        else
            if base and base.init then
                base.init(instance, ...)
            end
        end

        return instance
    end

    setmetatable(cls, mt)

    return cls
end