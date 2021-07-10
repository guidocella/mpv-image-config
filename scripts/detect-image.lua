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

    local duration = mp.get_property_native('duration')
    return duration == nil or duration == 0 or duration == 0.1 or duration == 1
end

mp.register_event('file-loaded', function()
    if is_image() then
        mp.command('show-text "[${playlist-pos-1}/${playlist-count}] ${filename} ${width}x${height} ${!gamma==0:☀}" 3000')
        -- Or set osd-msg1 to show text permanently.

        if not was_image then
            if not options.upscale_small then
                mp.set_property('video-unscaled', 'yes')
            end
            mp.command('enable-section image')
            was_image = true
        end
    elseif was_image then
        mp.set_property('video-unscaled', 'no')
        mp.set_property('video-zoom', 0)
        mp.set_property('panscan', 0)
        mp.command('disable-section image')
        was_image = false
    end
end)

-- Align images bigger than the window to the top right corner,
-- and smaller ones to the center.
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
            mp.set_property('video-align-x', dwidth > dims.w and 1 or 0)
            mp.set_property('video-align-y', dheight > dims.h and -1 or 0)
            return
        end
    end

    mp.set_property('video-align-x', dims.w - dims.ml - dims.mr > dims.w and 1 or 0)
    mp.set_property('video-align-y', dims.h - dims.mt - dims.mb > dims.h and -1 or 0)
end)
