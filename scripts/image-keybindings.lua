mp.register_script_message('rm-file', function()
    os.remove(mp.get_property('path'))
    mp.command('playlist-remove current')
end)

mp.register_script_message('pan-image', function (axis, amount)
    local dim = mp.get_property_native('osd-dimensions')
    local width = dim.w - dim.ml - dim.mr
    local height = dim.h - dim.mt - dim.mb
    local dimension
    if mp.get_property_number('video-rotate') % 180 == 0 then
        dimension = axis == 'x' and width or height
    else
        dimension = axis == 'x' and height or width
    end
    local osd_dimension = axis == 'x' and dim.w or dim.h
    if dimension ~= osd_dimension then
        mp.commandv('add', 'video-align-' .. axis, amount * 2 * osd_dimension / (dimension - osd_dimension))
    end
end)
