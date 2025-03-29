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

local is_intial_callback
local function undo_lavfi_complex()
    if is_intial_callback then
        is_intial_callback = false
        return
    end
    mp.set_property('lavfi-complex', '')
    mp.set_property('vid', 1)
    mp.command('video-remove 2')
    mp.unobserve_property(undo_lavfi_complex)
end

mp.register_script_message('double-page-mode', function()
    if mp.get_property_native('lavfi-complex') ~= '' then
        undo_lavfi_complex()
        return
    end

    local previous = mp.get_property('playlist/' .. mp.get_property('playlist-pos') - 1 .. '/filename')

    if not previous then
        local error = 'double-page-mode only works if there is a previous playlist entry.'
        mp.msg.error(error)
        mp.osd_message(error)
        return
    end

    mp.commandv('video-add', previous, 'auto')
    local track_list = mp.get_property_native('track-list')

    local graph = '[vid1] [vid2] hstack [vo]'
    if track_list[1]['demux-w'] ~= track_list[2]['demux-w'] or track_list[1]['demux-h'] ~= track_list[2]['demux-h'] then
        graph = '[vid2] scale=' .. track_list[1]['demux-w'] .. ':' .. track_list[1]['demux-h'] .. ' [vid2-scaled]; [vid1] [vid2-scaled] hstack [vo]'
    end

    mp.set_property('lavfi-complex', graph)

    is_intial_callback = true
    mp.observe_property('playlist-pos', nil, undo_lavfi_complex)
end)
