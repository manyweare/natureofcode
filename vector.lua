-- vector.p8 v2.3.1
-- by @thacuber2a03

function vector(x, y) return { x = x or 0, y = y or 0 } end

function v_polar(a, l) return vector(l * cos(a), l * sin(a)) end
function v_rnd() return v_polar(rnd(), 1) end
function v_copy(v) return vector(v.x, v.y) end
function v_unpack(v) return v.x, v.y end
function v_tostr(v) return "[" .. v.x .. ", " .. v.y .. "]" end

function v_add(a, b) return vector(a.x + b.x, a.y + b.y) end
function v_sub(a, b) return v_add(a, v_neg(b)) end
function v_scale(v, n) return vector(v.x * n, v.y * n) end
v_mul = v_scale
function v_div(v, n) return v_scale(v, 1 / n) end
function v_neg(v) return v_scale(v, -1) end

function v_dot(a, b) return a.x * b.x + a.y * b.y end
function v_magsq(v) return v_dot(v, v) end
function v_mag(v) return sqrt(v_magsq(v)) end
function v_distsq(a, b) return v_magsq(v_sub(b, a)) end
function v_dist(a, b) return sqrt(v_distsq(a, b)) end
function v_norm(v) return v_div(v, v_mag(v)) end
function v_perp(v) return vector(v.y, -v.x) end
function v_dir(a, b) return v_norm(v_sub(b, a)) end

-- added setmag and limit they're useful for locomotion
function v_setmag(v, n) return v_mul(v_norm(v), n) end
function v_limit(v, n)
    if (v_magsq(v) > n * n) v = v_setmag(v, n)
    return v
end

function v_proj(a, b)
    return v_scale(a, v_dot(a, b) / v_magsq(a))
end

function v_angle(v) return atan2(v.x, v.y) end
function v_rot(v, a) return v_polar(a, v_mag(v)) end
function v_rotby(v, a) return v_rot(v, v_angle(v) + a) end

function v_lerp(a, b, t) return v_add(a, v_mul(v_sub(b, a), t)) end
function v_flr(v) return vector(flr(v.x), flr(v.y)) end

v_right = vector(1, 0)
v_left = vector(-1, 0)
v_down = vector(0, 1)
v_up = vector(0, -1)

v_one = vector(1, 1)
v_center = vector(64, 64)