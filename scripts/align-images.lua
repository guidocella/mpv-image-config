local options = {
    first_unscaled = false,
    align_x = 1,
}
local is_first = true

require 'mp.options'.read_options(options, nil, function () end)

-- Align images bigger than the window to the top right corner.
local dont_center
mp.observe_property('video-out-params', 'native', function (_, params)
    if not mp.get_property_native('current-tracks/video/image') then
        return
    end

    local dims = mp.get_property_native('osd-dimensions')
    -- osd-width and osd-height, and even display-width and display-height, can be unavailable when the first image loads.
    if dims.w == 0 then
        dims.w = mp.get_property_native('display-width', 1920)
        dims.h = mp.get_property_native('display-height', 1080)
    end

    if is_first then
        is_first = false
        if not options.first_unscaled then return end

        if not mp.get_property_bool('video-unscaled') and (params.dw > dims.w or params.dh > dims.h) and mp.get_property_native('image-display-duration') == math.huge then
            mp.set_property('video-unscaled', 'yes')

            -- dims = mp.get_property_native('osd-dimensions')
            -- this isn't recalculated immediately, so just align the image based on dwidth and dheight
            if params.dw > dims.w then
                mp.set_property('video-align-x', options.align_x)
            end
            if params.dh > dims.h then
                mp.set_property('video-align-y', -1)
            end
            dont_center = true
            return
        end
    end

    if dims.w - dims.ml - dims.mr > dims.w then
        mp.set_property('video-align-x', options.align_x)
    end
    if dims.h - dims.mt - dims.mb > dims.h then
        mp.set_property('video-align-y', -1)
    end
end)

-- Center the image when it's smaller than the window.
mp.observe_property('osd-dimensions', 'native', function (_, dims)
    if dont_center then
        dont_center = false
        return
    end

    if dims.w - dims.ml - dims.mr < dims.w then
        mp.set_property('video-align-x', 0)
    end
    if dims.h - dims.mt - dims.mb < dims.h then
        mp.set_property('video-align-y', 0)
    end
end)
