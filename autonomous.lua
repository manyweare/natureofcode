-- main

function _init()
    -- target vars
    is_debug_active = true
    target = rnd_target_pos(16, 112)
    target_lt = 0
    target_influence = 30
    cpu = 0
    cpu_max = 0
    cpu_avg = 0
    cpu_vals = {}
    cpu_clr = { 1, 1, 1, 9, 8 }
    behaviors = { "seek", "arrive", "flock" }
    curr_behavior = 2
    -- initialize agents
    init_agents()
end

function _update()
    update_target()
    update_agents()
    update_input()
end

function _draw()
    cls()
    if is_debug_active then
        -- fillp(0x8000)
        -- rectfill(0, 0, 128, 128, 1)
        -- fillp()
        -- agent count
        -- rectfill(0, 0, 36, 6, 0)
        print("agents:" .. tostr(#agent_list), 1, 1, 7)
        -- cpu
        -- rectfill(0, 6, 32, 13, 0)
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
        -- vel and force lines
        draw_debug(agent_list)
        draw_target()
    end
    draw_agents()
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
    if target_lt > 45 then
        target = rnd_target_pos(12, 116)
        target_lt = 0
    end
end

function draw_target()
    circ(target.x, target.y, 1, 8)
    -- circ(target.x, target.y, target_influence, 1)
end

function draw_debug(t)
    -- forces
    for k, a in pairs(t) do
        -- -- position trail
        -- for i, j in pairs(a.pos_record) do
        --     pset(j.x, j.y, 1)
        -- end
        -- awareness radius
        -- circ(a.pos.x, a.pos.y, a.awareness, 1)
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