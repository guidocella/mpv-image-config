mp.register_script_message('rm-file', function()
    os.remove(mp.get_property('path'))
    mp.command('playlist-remove current')
end)

mp.register_script_message('pan-image', function (axis, amount)
    local width = mp.get_property_number('dwidth')
    if not width then return end
    local height = mp.get_property_number('dheight')
    local osd_width = mp.get_property_number('osd-width')
    local osd_height = mp.get_property_number('osd-height')
    if mp.get_property('video-unscaled') == 'no' then
        if width / osd_width < height / osd_height then
            local scaled_width = width * osd_height / height
            width = scaled_width +
                (osd_width - scaled_width) * mp.get_property_number('panscan')
            height = osd_height * width / scaled_width
        else
            local scaled_height = height * osd_width / width
            height = scaled_height +
                (osd_height - scaled_height) * mp.get_property_number('panscan')
            width = osd_width * height / scaled_height
        end
    end
    if mp.get_property_number('video-rotate') % 180 == 0 then
        dimension = axis == 'x' and width or height
    else
        dimension = axis == 'x' and height or width
    end
    dimension = dimension * 2 ^ mp.get_property_number('video-zoom')
    local osd_dimension = axis == 'x' and osd_width or osd_height
    local new_align = mp.get_property_number('video-align-' .. axis) +
        amount * 2 * osd_dimension / (dimension - osd_dimension)
    mp.set_property(
        'video-align-' .. axis,
        math.max(math.min(new_align, 1), -1)
    )
end)
