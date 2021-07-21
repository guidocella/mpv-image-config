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
