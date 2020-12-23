local was_image

mp.register_event('file-loaded', function()
    local container_fps = mp.get_property_number('container-fps')
    if (container_fps == 1 or container_fps == nil and mp.get_property('video-format') == 'gif')
        and not mp.get_property('audio-codec') then
        mp.command('show-text "[${playlist-pos-1}/${playlist-count}] ${filename} ${width}x${height} ${!gamma==0:☀}" 3000')
        -- Or set osd-msg1 to show text permanently.

        if not was_image then
            -- mp.set_property('video-unscaled', 'yes')
            mp.command('enable-section image')
            was_image = true
        end
    elseif was_image then
        -- mp.set_property('video-unscaled', 'no')
        mp.set_property('video-zoom', 0)
        mp.set_property('panscan', 0)
        mp.command('disable-section image')
        was_image = false
    end
end)
