local addonName, NS = ...


local Logo = {}
Logo.__index = Logo

function Logo:New(parent, left, top, hotids)
    local self = setmetatable({}, Logo)

    self.frame = NS.create_frame(parent, left, top, 40, 40, {0, 0, 0, 1})
    NS.create_frame(self.frame, 0, 0, 36, 4, {1, 0, 0, 1})
    NS.create_frame(self.frame, 0, -8, 36, 4, {0, 1, 0, 1})
    NS.create_frame(self.frame, 0, -16, 36, 4, {0, 0, 1, 1})
    NS.create_frame(self.frame, 0, -24, 36, 4, {1, 0, 1, 1})
    NS.create_frame(self.frame, 0, -32, 36, 4, {1, 1, 0, 1})

    return self
end

function Logo:Update()
end

NS.Logo = Logo