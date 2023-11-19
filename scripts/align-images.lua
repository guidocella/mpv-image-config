local options = {
    align_x = 1,
}

require 'mp.options'.read_options(options, nil, function () end)

-- Align the OSD to the top right corner of images bigger than the OSD.
mp.register_event('video-reconfig', function ()
    -- Don't realign videos so they are centered after increasing panscan.
    if not mp.get_property_native('current-tracks/video/image') then
        return
    end

    local dims = mp.get_property_native('osd-dimensions')

    if dims.ml + dims.mr < 0 then
        mp.set_property('video-align-x', options.align_x)
    end
    if dims.mt + dims.mb < 0 then
        mp.set_property('video-align-y', -1)
    end
end)

-- Center the image when it's smaller than the window.
mp.observe_property('osd-dimensions', 'native', function (_, dims)
    if dims.ml + dims.mr > 0 then
        mp.set_property('video-align-x', 0)
    end
    if dims.mt + dims.mb > 0 then
        mp.set_property('video-align-y', 0)
    end
end)
