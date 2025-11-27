-- agents

-- this implementation relies heavily on
-- @thacuber2a03's vector math library

-- prototype --

agent = {
    pos = vector(),
    origin = vector(),
    vel = vector(),
    accel = vector(),
    maxspd = .75,
    maxfrc = .05,
    size = 8,
    awareness = 12,
    color = 7,
    pos_record = {}
}

atgl = false

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

function init_agents()
    agent_list = {}
    -- add(agent_list, new_rnd_agent())
end

function update_agents()
    if (frame % 60 == 0) atgl = not atgl
    for a in all(agent_list) do
        if atgl then
            -- a.awareness *= 3
            a.size *= 2
        else
            -- a.awareness = 12
            a.size = 12
        end
        a:update()
    end
end

function draw_agents()
    for a in all(agent_list) do
        a:draw()
    end
end

-- create new random agent
function new_rnd_agent()
    local a = agent:new({
        pos = vector(16 + rnd(96), 16 + rnd(96)),
        maxspd = 1.5 + rnd(2.5),
        maxfrc = .05 + rnd(.05),
        tgt = target,
        color = round(7 + rnd(8))
    })
    return a
end

function spawn_agent(x, y, t, c)
    local a = agent:new({
        pos = vector(x, y),
        origin = vector(x, y),
        tgt = t,
        color = c
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
    -- add(self.pos_record, { x = self.pos.x, y = self.pos.y })
    -- if (count(self.pos_record) > 30) deli(self.pos_record, 1)
end

-- draw
function agent:draw()
    -- local c = self.color
    -- self.color = 0
    -- shape version
    -- body
    -- circfill(self.pos.x, self.pos.y, 1, self.color)
    -- circ(self.pos.x, self.pos.y, 2, self.color)
    -- "tail" or inverted velocity lines
    local length = 5
    -- for i = 0, 1 do
    --     line(
    --         self.pos.x,
    --         self.pos.y,
    --         self.pos.x - self.vel.x * length,
    --         self.pos.y - self.vel.y * length,
    --         self.color
    --     )
    --     line(
    --         self.pos.x - i,
    --         self.pos.y,
    --         self.pos.x - self.vel.x * length,
    --         self.pos.y - self.vel.y * length,
    --         self.color
    --     )
    --     line(
    --         self.pos.x + i,
    --         self.pos.y,
    --         self.pos.x - self.vel.x * length,
    --         self.pos.y - self.vel.y * length,
    --         self.color
    --     )
    --     line(
    --         self.pos.x,
    --         self.pos.y - i,
    --         self.pos.x - self.vel.x * length,
    --         self.pos.y - self.vel.y * length,
    --         self.color
    --     )
    --     line(
    --         self.pos.x,
    --         self.pos.y + i,
    --         self.pos.x - self.vel.x * length,
    --         self.pos.y - self.vel.y * length,
    --         self.color
    --     )
    -- end
    -- tongue
    -- circfill(
    --     self.pos.x + self.vel.x * length,
    --     self.pos.y + self.vel.y * length,
    --     1, self.color
    -- )
    -- length = 1
    for i = 0, 1 do
        local endx = self.pos.x + self.vel.x / length
        local endy = self.pos.y + self.vel.y / length
        line(self.origin.x - i * 2, self.origin.y, endx, endy, self.color)
        line(self.origin.x + i * 2, self.origin.y, endx, endy, self.color)
        line(self.origin.x, self.origin.y - i * 2, endx, endy, self.color)
        line(self.origin.x, self.origin.y + i * 2, endx, endy, self.color)
        local v = vector(endx, endy)
        -- local mag = v_mag(v)
        -- local hv = v_setmag(v, mag)
        line(self.origin.x, self.origin.y, v.x, v.y, self.color)
        -- line(hv.x, hv.y, endx, endy, 7)
    end
    -- circfill(self.pos.x, self.pos.y, 10, 0)
    -- pset(self.pos.x, self.pos.y, 11)
    -- circ(self.pos.x, self.pos.y, 2, 1)
    -- sprite version
    -- if (self.pos.x > self.tgt.x) then
    --     self.flip = true
    -- else
    --     self.flip = false
    -- end
    -- spr(2, self.pos.x, self.pos.y, 1, 1, self.flip)
    -- self.color = c
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
    -- if self.pos.x > 128 then
    --     self.pos.x = 0
    -- elseif self.pos.x < 0 then
    --     self.pos.x = 128
    -- end
    -- if self.pos.y > 128 then
    --     self.pos.y = 0
    -- elseif self.pos.y < 0 then
    --     self.pos.y = 128
    -- end
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