local was_image

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
            -- mp.set_property('video-unscaled', 'yes')
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
