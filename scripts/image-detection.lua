local was_image

mp.register_event('file-loaded', function()
    local duration = mp.get_property_number('duration')
    if duration == nil or duration == 0 or duration == 1 then
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
