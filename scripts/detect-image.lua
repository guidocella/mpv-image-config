local options = {
    upscale_small = true,
}
local was_image

require 'mp.options'.read_options(options, nil, function () end)

local function is_image()
    for _, track in pairs(mp.get_property_native('track-list')) do
        if track.type == 'audio' then
            return false
        end
    end

    -- container-fps is nil and thus estimated-frame-count is 0 for certain
    -- videos like wmv and even certain h264 mkv, and also when lavfi-complex
    -- is used, so check the duration too.
    -- duration can be unavailable while loading very large images.
    local duration = mp.get_property_native('duration', 0)
    -- 1-frame gifs have nil container-fps and 0.1 duration.
    -- Some large jpgs have duration 1 instead of 0.
    return mp.get_property_native('container-fps', 1) == 1 and (duration == 0 or duration == 0.1 or duration == 1)
end

local function is_video()
    -- vid is nil with lavfi-complex.
    for _, track in pairs(mp.get_property_native('track-list')) do
        if track.type == 'video' and track.selected then
            return not track.albumart
        end
    end

    return false
end

mp.register_event('file-loaded', function()
    if is_image() then
        mp.command('show-text "[${playlist-pos-1}/${playlist-count}] ${filename} ${width}x${height} ${!gamma==0:☀}" 3000')
        -- Or set osd-msg1 to show text permanently.

        if not was_image then
            if not options.upscale_small then
                mp.set_property('video-unscaled', 'yes')
            end
            mp.set_property('linear-downscaling', 'no') -- makes some manga brighter
            mp.set_property('deband', 'no') -- rarely useful with images
            mp.command('enable-section image')
            was_image = true
        end
    elseif is_video() then
        mp.command('show-text "[${playlist-pos-1}/${playlist-count}] ${media-title} ${width}x${height} ${?percent-pos==0:${duration}}${!percent-pos==0:${time-pos} / ${duration} (${percent-pos}%)} ${!gamma==0:☀}" 10000')

        if was_image then
            mp.set_property('video-unscaled', 'no')
            mp.set_property('video-zoom', 0)
            mp.set_property('panscan', 0)
            mp.set_property('linear-downscaling', 'yes')
            mp.set_property('deband', 'yes')
            mp.command('disable-section image')
            was_image = false
        end
    end
end)

-- Align images bigger than the window to the top right corner.
local dont_center
mp.observe_property('dwidth', 'native', function (_, dwidth)
    local dims = mp.get_property_native('osd-dimensions')
    if not dwidth or not is_image() then return end

    local dheight = mp.get_property_native('dheight')

    -- osd-width and osd-height, and even display-width and display-height, can be unavailable when the first image loads.
    if dims.w == 0 then
        dims.w = mp.get_property_native('display-width', 1920)
        dims.h = mp.get_property_native('display-height', 1080)
    end

    if options.upscale_small then
        local old_unscaled = mp.get_property_bool('video-unscaled')
        local unscaled = (dwidth > dims.w or dheight > dims.h) and mp.get_property_native('panscan') == 0
        mp.set_property_bool('video-unscaled', unscaled)
        -- dims = mp.get_property_native('osd-dimensions')  this isn't recalculated immediately, so just align the image based on dwidth and dheight
        if not old_unscaled and unscaled then
            if dwidth > dims.w then
                mp.set_property('video-align-x', 1)
            end
            if dheight > dims.h then
                mp.set_property('video-align-y', -1)
            end
            dont_center = true
            return
        end
    end

    if dims.w - dims.ml - dims.mr > dims.w then
        mp.set_property('video-align-x', 1)
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
