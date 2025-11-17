-- agents

-- this implementation relies heavily on
-- @thacuber2a03's vector math library

-- prototype --

agent = {
    size = { w = 8, h = 8 },
    pos = vector(0, 0),
    vel = vector(0, 0),
    accel = vector(0, 0),
    maxspd = 1 + rnd(3),
    maxfrc = .05 + rnd(.1)
}

function init_agents()
    agent_list = {}
    target = _p
end

function update_agents()
    for a in all(agent_list) do
        a:update()
    end
end

function draw_agents()
    for a in all(agent_list) do
        a:draw()
    end
end

-- constructor
function agent:new(o)
    o = o or {}
    local a = {}
    -- copy in defaults first
    for k, v in pairs(self) do
        a[k] = v
    end
    -- write in extra parameters
    for k, v in pairs(o) do
        a[k] = v
    end
    -- metatable assignment
    setmetatable(a, self)
    self.__index = self
    return a
end

-- update
function agent:update()
    -- behaviors
    -- self:seek(_p)
    self:arrive(target, 16)
    self:separate(agent_list, 6)
    -- basic locomotion
    self.accel = v_limit(self.accel, self.maxfrc)
    self.vel = v_add(self.vel, self.accel)
    self.vel = v_limit(self.vel, self.maxspd)
    self.pos = v_add(self.pos, self.vel)
    -- constrain to screen
    -- self.pos.x = mid(0, self.pos.x, 120)
    -- self.pos.y = mid(0, self.pos.y, 120)
    -- player moves agent (scrolling map)
    self.pos = v_add(self.pos, vector(p_sx, p_sy))
end

-- draw
function agent:draw()
    if (self.pos.x > target.x) then
        self.flip = true
    else
        self.flip = false
    end
    spr(2, self.pos.x, self.pos.y, 1, 1, self.flip)
end

-- autonomous agents implementation --

function agent:seek(target)
    local desired = v_sub(target, self.pos)
    -- set the magnitude of the desired vector to max speed
    desired = v_setmag(desired, self.maxspd)
    -- this is the mmost important part:
    local steer = v_sub(desired, self.vel)
    -- limit the steer force
    steer = v_limit(steer, self.maxfrc)
    self:apply_force(steer)
end

function agent:arrive(target, radius)
    local desired = v_sub(target, self.pos)
    local distance = v_mag(desired)
    -- the radius where the arrive behavior will kick in
    if distance < radius then
        -- set magnitude according to closeness
        local magnitude = map_value(distance, 0, radius, 0, self.maxspd)
        desired = v_setmag(desired, magnitude)
    else
        desired = v_setmag(desired, self.maxspd)
    end
    local steer = v_sub(desired, self.vel)
    steer = v_limit(steer, self.maxfrc)
    self:apply_force(steer)
end

function agent:apply_force(force)
    self.accel = v_add(self.accel, force)
end

function agent:separate(list, radius)
    local sum = vector(0, 0)
    -- to keep track of how many units are too close
    local count = 0
    local distance = 0
    for other in all(list) do
        distance = approx_dist(self.pos, other.pos)
        if (self != other and distance < radius) then
            -- vector pointing away from neighboring unit
            local diff = v_sub(self.pos, other.pos)
            -- magnitude is inversely proportional to distance
            diff = v_setmag(diff, 1 / distance)
            sum = v_add(sum, diff)
            count += 1
        end
    end
    if count > 0 then
        -- sum becomes the desired vector
        sum = v_setmag(sum, self.maxspd)
        local steer = v_sub(sum, self.vel)
        steer = v_limit(steer, self.maxfrc)
        self:apply_force(steer)
    end
end