-- tools

function round(n)
    return (n % 1 < 0.5) and flr(n) or ceil(n)
end

-- map a value from one range to another
-- similar to p5.js map
function map_value(n, min1, max1, min2, max2)
    return (((n - min1) * (max2 - min2)) / (max1 - min1)) + min2
end

function rpd(d, rd)
    local _dir = rnd(1)
    local _rad = d + flr(rnd(rd))
    local x = 64 + cos(_dir) * _rad
    local y = 64 + sin(_dir) * _rad
    return unpack({ x, y })
end

-- from bbs (TODO: find op and credit)
-- way faster than vector dist
function approx_dist(a, b)
    local dx, dy = abs(b.x - a.x), abs(b.y - a.y)
    local maskx, masky = dx >> 31, dy >> 31
    local a0, b0 = (dx + maskx) ^^ maskx, (dy + masky) ^^ masky
    if a0 > b0 then
        return a0 * 0.9609 + b0 * 0.3984
    end
    return b0 * 0.9609 + a0 * 0.3984
end

function nearby(a, t, r)
    local n = {}
    for k, v in pairs(t) do
        if (approx_dist(a.pos, v.pos) < r) add(n, v)
    end
    return n
end

--from bbs (TODO: find op and credit)
--to circumvent #table error
function is_empty(t)
    for _, _ in pairs(t) do
        return false
    end
    return true
end

--rect rect AABB
function rect_rect_collision(r1, r2)
    return r1.pos.x < r2.pos.x + r2.size.w
            and r1.pos.x + r1.size.w > r2.pos.x
            and r1.pos.y < r2.pos.y + r2.size.h
            and r1.pos.y + r1.size.h > r2.pos.y
end

--get direction with cords
function get_dir(x1, y1, x2, y2)
    return atan2(x2 - x1, y2 - y1)
end

--get direction with objects that have x, y pos
function get_dir_pos(a, b)
    return atan2(b.x - a.x, b.y - a.y)
end

function get_dist_n(a, b, n)
    local x = abs(a.x - b.x)
    local y = abs(a.y - b.y)
    if x + y < n * 1.5 then
        local _d = sqrt(x * x + y * y)
        return _d < n and _d or n
    else
        return n
    end
end

function col(a, b, r)
    local x = abs(a.x - b.x)
    if x > r then return false end
    local y = abs(a.y - b.y)
    if y > r then return false end
    return (x * x + y * y) < r * r
end