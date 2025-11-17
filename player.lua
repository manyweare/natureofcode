--player
function init_player()
    --player aim direction
    _p = { x = 63, y = 63 }
    --direction
    p_dir, p_dx, p_dy, p_sx, p_sx = 0, 0, 0, 0, 0
    p_spd = 1.5
    p_spr = 1
    p_flip = false
end

function update_player()
    --get direction (joystick check)
    get_direction()
    --set direction for movement
    set_direction()
    --sprite flip
    if not p_flip then
        if (p_sx > 0) p_flip = true
    else
        if (p_sx < 0) p_flip = false
    end
end

function get_direction()
    p_dx = p_i_data[1] - p_i_data[2]
    p_dy = p_i_data[3] - p_i_data[4]
end

function set_direction()
    --get input and determine
    --direction
    p_sx, p_sy = p_dx, p_dy
    --set speed of each
    if abs(p_sx) == abs(p_sy) then
        p_sx *= p_spd * 0.7
        p_sy *= p_spd * 0.7
    else
        p_sx *= p_spd
        p_sy *= p_spd
    end
end

function draw_player()
    --draw player
    spr(p_spr, 62, 62, 1, 1, p_flip)
end