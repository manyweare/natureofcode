-- agents

-- this implementation relies heavily on
-- @thacuber2a03's vector math library

-- prototype --

agent = {
    pos = vector(),
    vel = vector(),
    accel = vector(),
    maxspd = 1,
    maxfrc = .1,
    size = 6,
    awareness = 10,
    pos_record = {}
}

function init_agents()
    agent_list = {}
    add(agent_list, new_rnd_agent())
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

-- create new random agent
function new_rnd_agent()
    a = agent:new({
        pos = vector(16 + rnd(96), 16 + rnd(96)),
        maxspd = 1 + rnd(2),
        maxfrc = .05 + rnd(.1),
        tgt = target
    })
    return a
end

-- update
function agent:update()
    -- behaviors
    -- limit list to the agent's awareness radius
    local nearby_agents = nearby(self, agent_list, self.awareness)
    if behaviors[curr_behavior] == "seek" then
        self:seek(target)
    elseif behaviors[curr_behavior] == "arrive" then
        self:arrive(target, target_influence)
    elseif behaviors[curr_behavior] == "flock" then
        self:flock(nearby_agents)
    end
    self:separate(nearby_agents)
    -- basic locomotion
    self:move()
    -- record position
    -- if self.pos_record != nil then
    --     add(self.pos_record, { x = self.pos.x, y = self.pos.y })
    --     if (count(self.pos_record) > 30) deli(self.pos_record, 1)
    -- end
end

-- draw
function agent:draw()
    -- shape version
    circfill(self.pos.x, self.pos.y, 1, 7)
    -- pset(self.pos.x, self.pos.y, 11)
    -- circ(self.pos.x, self.pos.y, 2, 1)

    -- sprite version
    -- if (self.pos.x > self.tgt.x) then
    --     self.flip = true
    -- else
    --     self.flip = false
    -- end
    -- spr(2, self.pos.x, self.pos.y, 1, 1, self.flip)
end

-- basic locomotion --

function agent:move()
    self.accel = v_limit(self.accel, self.maxfrc)
    self.vel = v_add(self.vel, self.accel)
    self.vel = v_limit(self.vel, self.maxspd)
    self.pos = v_add(self.pos, self.vel)
    -- clamp to screen
    -- self.pos.x = mid(self.size / 2, self.pos.x, 128 - self.size / 2)
    -- self.pos.y = mid(self.size / 2, self.pos.y, 128 - self.size / 2)
    -- wrap around screen
    if self.pos.x > 128 then
        self.pos.x = 0
    elseif self.pos.x < 0 then
        self.pos.x = 128
    end
    if self.pos.y > 128 then
        self.pos.y = 0
    elseif self.pos.y < 0 then
        self.pos.y = 128
    end
end

function agent:apply_force(force)
    self.accel = v_add(self.accel, force)
end

-- autonomous agents implementation --

function agent:seek(target)
    local desired = v_sub(target, self.pos)
    -- set the magnitude of the desired vector to max speed
    desired = v_setmag(desired, self.maxspd)
    -- this is the most important part:
    local steer = v_sub(desired, self.vel)
    -- steer = v_limit(steer, self.maxfrc)
    self:apply_force(steer)
    return steer
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
    -- steer = v_limit(steer, self.maxfrc)
    self:apply_force(steer)
end

function agent:separate(list)
    local steering = vector()
    -- -- limit list to the agent's awareness radius
    -- local nearby_agents = nearby(self, list, self.awareness)
    -- how many units are too close
    local count = 0
    local distance = 0
    for k, other in pairs(list) do
        distance = approx_dist(self.pos, other.pos)
        -- separate if the other unit is encroaching on agent
        if self != other and distance < self.size then
            -- vector pointing away from neighboring unit
            local diff = v_sub(self.pos, other.pos)
            -- magnitude is inversely proportional to distance
            diff = v_setmag(diff, 1 / distance)
            steering = v_add(steering, diff)
            count += 1
        end
    end
    if count > 0 then
        -- steering becomes the desired vector
        steering = v_setmag(steering, self.maxspd)
        steering = v_sub(steering, self.vel)
        -- steering = v_limit(steering, self.maxfrc)
        self:apply_force(steering)
    end
end

function agent:align(list)
    local steering = vector()
    -- limit list to the agent's awareness radius
    -- local nearby_agents = nearby(self, list, self.awareness)
    -- how many units are close
    local count = 0
    local distance = 0
    for k, other in pairs(list) do
        distance = approx_dist(self.pos, other.pos)
        -- if other is within radius add its velocity
        if self != other and distance < self.awareness then
            steering = v_add(steering, other.vel)
            count += 1
        end
    end
    if count > 0 then
        steering = v_setmag(steering, self.maxspd)
        steering = v_sub(steering, self.vel)
    end
    self:apply_force(steering)
end

function agent:cohere(list)
    local sum = vector()
    -- limit list to the agent's awareness radius
    -- local nearby_agents = nearby(self, list, self.awareness)
    local count = 0
    for k, other in pairs(list) do
        distance = approx_dist(self.pos, other.pos)
        if self != other and distance < self.awareness then
            sum = v_add(sum, other.pos)
            count += 1
        end
    end
    if count > 0 then
        sum = v_div(sum, count)
        self:seek(sum)
    end
    -- return vector()
end

function agent:flock(list)
    self:align(list)
    self:cohere(list)
end