-- main

function _init()
    --init input lists
    p_i_last, p_inputs, p_i_data = {}, {}, {}
    -- map coords
    map_x, map_y = 0, 0
    init_player()
    init_agents()
    -- target vars
    is_target_active = true
    target_lt = 0
end

function _update()
    -- z to add agent
    if btnp(4) then
        a = agent:new()
        a.pos = vector(rnd(128), rnd(128))
        a.flip = false
        add(agent_list, a)
    end
    -- x to remove agent
    if btnp(5) then
        if (#agent_list > 0) deli(agent_list, #agent_list)
    end
    get_inputs()
    update_player()
    update_target(is_target_active)
    update_agents()
    --update map
    map_x += p_sx
    map_y += p_sy
end

function _draw()
    cls()
    --draw scrolling map
    for i = 0, 2 do
        for j = 0, 2 do
            map(
                0, 0,
                map_x % 128 + 128 * i - 128,
                map_y % 128 + 128 * j - 128
            )
        end
    end
    -- instructions
    rectfill(0, 114, 52, 128, 0)
    print("z to add", 1, 115, 1)
    print("x to subtract", 1, 122, 1)
    -- cpu
    rectfill(0, 7, 40, 13, 0)
    print("cpu:" .. tostr(ceil(stat(1) * 100)) .. "%", 1, 8, 1)
    --
    draw_player()
    draw_target(is_target_active)
    draw_agents()
    -- agent count
    rectfill(0, 0, 32, 6, 0)
    print("agents:" .. tostr(#agent_list), 1, 1, 7)
end

function change_target()
    target = { x = rnd(120) + p_sx, y = rnd(120) + p_sy }
end

function update_target(t)
    target_lt += 1
    if target_lt > 45 then
        change_target()
        target_lt = 0
    end
    if t then
        target.x += p_sx
        target.y += p_sy
    end
end

function draw_target(t)
    if (t) spr(3, target.x, target.y)
end