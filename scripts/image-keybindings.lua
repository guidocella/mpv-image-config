mp.register_script_message('rm-file', function()
    os.remove(mp.get_property('path'))
    mp.command('playlist-remove current')
end)

mp.register_script_message('pan-image', function (axis, amount)
    local dim = mp.get_property_native('osd-dimensions')
    local dimension = axis == 'x' and dim.w - dim.ml - dim.mr or dim.h - dim.mt - dim.mb
    local osd_dimension = axis == 'x' and dim.w or dim.h
    if dimension ~= osd_dimension then
        mp.commandv('add', 'video-align-' .. axis, amount * 2 * osd_dimension / (dimension - osd_dimension))
    end
end)
