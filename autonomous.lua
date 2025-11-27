-- main

function _init()
    -- target vars
    is_debug_active = false
    target = agent:new({
        x = 64,
        y = 42
    })
    tpos = { 16, 16, 112, 16, 112, 70, 16, 70 }
    ti = 1
    -- t_pos = { 16, 72, 104 }
    target_lt = 0
    target_influence = 30
    -- debug vars
    cpu = 0
    cpu_max = 0
    cpu_avg = 0
    cpu_vals = {}
    cpu_clr = { 1, 1, 1, 9, 8 }
    behaviors = { "seek", "arrive", "flock" }
    curr_behavior = 2
    -- initialize agents
    init_agents()
    num = 6
    height = 128
    hratio = height / num
    hratio += (hratio / num + 1)
    wratio = 128 / num
    wratio += (wratio / num + 1)
    frame = 0
    tgl = false
    -- spawn around the screen
    for i = 0, num - 1 do
        local a = spawn_agent(i * wratio, 0, target, 1)
        add(agent_list, a)
        local a = spawn_agent(i * wratio, height, target, 1)
        add(agent_list, a)
        if i > 0 and i < num - 1 then
            local a = spawn_agent(0, i * hratio, target, 1)
            add(agent_list, a)
            local a = spawn_agent(128, i * hratio, target, 1)
            add(agent_list, a)
        end
    end
end

function _update()
    update_target()
    update_agents()
    update_input()
    if (is_debug_active) update_debug()
    -- update_spawn()
end

function _draw()
    cls()
    draw_agents()
    draw_target()
    draw_map()
    if is_debug_active then
        draw_debug(agent_list)
        draw_ui()
        draw_target()
    end
    -- draw_trail(agent_list)
end

function update_spawn()
    local max_spawn = 42
    if frame % 5 == 0 then
        -- local
        local a = spawn_agent(rnd(128), -10, target, round(7 + rnd(8)))
        add(agent_list, a)
        if (#agent_list > max_spawn) then deli(agent_list, 1) end
        local a = spawn_agent(rnd(128), 138, target, round(7 + rnd(8)))
        add(agent_list, a)
        if (#agent_list > max_spawn) then deli(agent_list, 1) end
        local a = spawn_agent(-10, rnd(128), target, round(7 + rnd(8)))
        add(agent_list, a)
        if (#agent_list > max_spawn) then deli(agent_list, 1) end
        local a = spawn_agent(138, rnd(128), target, round(7 + rnd(8)))
        add(agent_list, a)
        if (#agent_list > max_spawn) then deli(agent_list, 1) end
    end
    frame += 1
    if (frame == 129) frame = 0
end

function update_input()
    -- left/right to change behavior
    if (btnp(0)) curr_behavior = max(1, curr_behavior - 1)
    if (btnp(1)) curr_behavior = min(curr_behavior + 1, #behaviors)
    -- up to add agent
    if (btnp(2)) add(agent_list, new_rnd_agent())
    -- down to remove agent
    if btnp(3) then
        if (#agent_list > 0) deli(agent_list, #agent_list)
    end
    -- o/z to toggle target
    if btnp(4) then
        while #agent_list > 1 do
            deli(agent_list, 1)
        end
        is_debug_active = true
    end
    -- x to toggle cls
    if (btnp(5)) is_debug_active = not is_debug_active
end

function rnd_target_pos(min, max)
    return {
        x = mid(min, rnd(max), max),
        y = mid(min, rnd(max), max)
    }
end

function update_target()
    target_lt += 1
    -- local dx, dy = 0, 0
    if target_lt > 5 + rnd(10) then
        target.x = mid(32, 32 + rnd(64), 96)
        target.y = mid(height / 2 - 6, rnd(height / 2 + 6), height / 2 + 6)
        -- target.x += (1 - rnd(2))
        -- target.y += (1 - rnd(2))
        target_lt = 0
    end
end

function draw_target()
    -- circfill(target.x, target.y, 32, 0)
    -- circfill(64, 48, 24, 0)
    -- circ(target.x, target.y, target_influence, 1)
end

function draw_trail(t)
    for a in all(t) do
        for i, j in pairs(a.pos_record) do
            pset(j.x, j.y, 1)
        end
    end
end

function update_debug()
    cpu = round(stat(1) * 100)
    cpu_max = max(cpu, cpu_max)
    -- calculate averate of last cpu values
    if (#cpu_vals > 100) then
        deli(cpu_vals, 1)
    end
    add(cpu_vals, cpu)
    local cpu_sum = 0
    for i = 1, #cpu_vals do
        cpu_sum += cpu_vals[i]
    end
    cpu_avg = round(cpu_sum / #cpu_vals)
end

function draw_map()
    map(0, 0, 0, 0, 16, 16)
    local cx = 4
    local cy = 84
    local xo = 62
    local clrs = { 7, 12, 8 }
    -- print("friday", cx, cy, clrs[1])
    -- print("december 19", cx, cy + 7, clrs[1])
    -- print("6-8pm", cx, cy + 14, clrs[1])
    -- print("room c-130", cx + xo, cy, clrs[2])
    -- print("food+prizes!", cx + xo, cy + 7, clrs[2])
    print("friday  december 19  6-8pm", cx + 8, 104, clrs[1])
    print("450 grand concourse room c-130", cx, 111, clrs[1])
    print("capstone games + prizes", cx + 14, 120, clrs[1])
    -- if tgl then
    -- print("capstone games", cx + 32, 120, clrs[1])
    -- else
    -- print("+bonus games & prizes", cx + 17, 120, clrs[1])
    -- end
    if frame % 30 == 0 then
        tgl = not tgl
    end
    frame += 1
    -- print("capstone games", cx + xo, 112, clrs[3])
    -- print("+other classes", cx + xo, 119, clrs[3])
end

function draw_ui()
    -- fillp(0x8000)
    -- rectfill(0, 0, 128, 128, 3)
    -- fillp()
    -- agent count
    -- rectfill(0, 0, 36, 6, 0)
    print("agents:" .. tostr(#agent_list), 1, 1, 7)
    -- cpu
    -- rectfill(0, 6, 32, 13, 0)
    local i = min(round(map_value(stat(1), 0, 1, 1, #cpu_clr)), #cpu_clr)
    print("cpu:" .. tostr(cpu) .. "%", 1, 8, cpu_clr[i])
    print("avg:" .. tostr(cpu_avg) .. "%", 1, 14, 1)
    print("max:" .. tostr(cpu_max) .. "%", 1, 20, 1)
    -- behavior display
    -- rectfill(63, 0, 87, 6, 0)
    print(behaviors[curr_behavior], 64, 1, 8)
    -- instructions
    -- rectfill(0, 114, 128, 128, 0)
    print("⬆️⬇️:add/delete", 64, 115, 1)
    print("⬅️➡️:behavior", 64, 122, 1)
    print("🅾️:reset", 1, 115, 1)
    print("❎:toggle ui", 1, 122, 1)
end

function draw_debug(t)
    -- forces
    for k, a in pairs(t) do
        -- awareness radius
        circ(a.pos.x, a.pos.y, a.awareness, 1)
        -- velocity line
        line(
            a.pos.x,
            a.pos.y,
            a.pos.x + a.vel.x * 5,
            a.pos.y + a.vel.y * 5,
            2
        )
        -- accel line
        line(
            a.pos.x,
            a.pos.y,
            a.pos.x + a.accel.x * 25,
            a.pos.y + a.accel.y * 25,
            3
        )
    end
end