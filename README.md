This is an example configuration for using mpv as an image viewer.

mpv 0.34 is needed for the `track-list/N/image` sub-property.

## Why?

* mpv is feature rich and far more extensible than any image viewer. You can easily add original key bindings, set up conditional profiles and do pretty much anything with Lua scripts
* Zoomed images with a good scaling filter look better than in image viewers (or at least the ones I previously used), and you can even improve image quality further with GLSL shaders like https://github.com/bloc97/Anime4K
* You can use quit-watch-later with directories of images
* You can browse directories with both videos and images in one application
* It supports Wayland unlike sxiv or feh
* Background transparency on X11 with Nvidia proprietary drivers and on Wayland

## Usage

Copy what you want to use from `mpv.conf` and `input.conf` into your versions of these files, and copy or symlink into `~~/scripts` `scripts/align-images.lua` for automatically aligning the OSD to the top-right corner of images bigger than the OSD and centering images smaller than the OSD, and `scripts/image-bindings.lua` for the script messages used by `input.conf`.

## How can I display thumbnails of images?

Use https://github.com/occivink/mpv-gallery-view
