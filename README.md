This is an example configuration for using mpv as an image viewer.

## Why?

* mpv is feature rich and far more extensible than any image viewer. You can easily add original keybindings, set up conditional profiles and do pretty much anything with Lua scripts
* Zoomed images with a good scaling filter look better than in image viewers (or at least the ones I previously used)
* You can use quit-watch-later with directories of images
* You can browse directories with both videos and images in one application
* It supports Wayland unlike sxiv or feh
* Background transparency on X11 with Nvidia proprietary drivers and on Wayland

## How can I display thumbnails of images?

Use https://github.com/occivink/mpv-gallery-view

## Why not use occivink/mpv-image-viewer?

I wanted large images only to start from the top right corner and a "fill to width" keybinding.
