local options = {
    gesture_click = 'playlist-next force',
    gesture_up = 'no-osd set video-zoom 0',
    gesture_right = 'no-osd cycle-values video-unscaled yes no; no-osd set video-zoom 0',
    gesture_down = 'script-message playlist-view-open',
    gesture_left = 'playlist-prev',
}

require 'mp.options'.read_options(options)

mp.register_script_message('rm-file', function()
    os.remove(mp.get_property('path'))
    mp.command('playlist-remove current')
end)

mp.register_script_message('pan-image', function (axis, amount)
    local dims = mp.get_property_native('osd-dimensions')
    local dimension = axis == 'x' and dims.w - dims.ml - dims.mr or dims.h - dims.mt - dims.mb
    local osd_dimension = axis == 'x' and dims.w or dims.h
    if dimension > osd_dimension then
        mp.commandv('add', 'video-align-' .. axis, amount * 2 * osd_dimension / (dimension - osd_dimension))
    end
end)

local old_mouse_pos
mp.add_key_binding(nil, 'gesture', function (table)
    if table.event == 'down' then
        old_mouse_pos = mp.get_property_native('mouse-pos')
        return
    end

    local mouse_pos = mp.get_property_native('mouse-pos')
    if math.abs(mouse_pos.y - old_mouse_pos.y) > math.abs(mouse_pos.x - old_mouse_pos.x) then
        mp.command(options[mouse_pos.y > old_mouse_pos.y and 'gesture_down' or 'gesture_up'])
    elseif mouse_pos.x == old_mouse_pos.x then
        mp.command(options.gesture_click)
    else
        mp.command(options[mouse_pos.x > old_mouse_pos.x and 'gesture_right' or 'gesture_left'])
    end
end, { complex = true })

mp.add_key_binding(nil, 'align-to-cursor', function (table)
    if table.event == 'up' then
        mp.remove_key_binding('align-to-cursor-mouse-move')
        return
    end

    local dims = mp.get_property_native('osd-dimensions')
    mp.add_forced_key_binding('MOUSE_MOVE', 'align-to-cursor-mouse-move', function()
        local mouse_pos = mp.get_property_native('mouse-pos')
        if dims.w - dims.ml - dims.mr > dims.w  then
            mp.set_property('video-align-x', (mouse_pos.x * 2 - dims.w) / dims.w)
        end
        if dims.h - dims.mt - dims.mb > dims.h  then
            mp.set_property('video-align-y', (mouse_pos.y * 2 - dims.h) / dims.h)
        end
    end)
end, { complex = true })

mp.add_key_binding(nil, 'drag-to-pan', function (table)
    if table.event == 'up' then
        mp.remove_key_binding('drag-to-pan-mouse-move')
        return
    end

    local dims = mp.get_property_native('osd-dimensions')
    local old_mouse_pos = mp.get_property_native('mouse-pos')
    local old_video_align_x = mp.get_property_native('video-align-x')
    local old_video_align_y = mp.get_property_native('video-align-y')
    mp.add_forced_key_binding('MOUSE_MOVE', 'drag-to-pan-mouse-move', function()
        local mouse_pos = mp.get_property_native('mouse-pos')
        if dims.w - dims.ml - dims.mr > dims.w  then
            mp.set_property(
            'video-align-x',
            math.min(1, math.max(old_video_align_x + 2 * (mouse_pos.x - old_mouse_pos.x) / (dims.ml + dims.mr), -1))
            )
        end
        if dims.h - dims.mt - dims.mb > dims.h  then
            mp.set_property(
            'video-align-y',
            math.min(1, math.max(old_video_align_y + 2 * (mouse_pos.y - old_mouse_pos.y) / (dims.mt + dims.mb), -1))
            )
        end
    end)
end, { complex = true })
