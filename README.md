This is an example configuration for using mpv as an image viewer.

## Why?

* mpv is feature rich and far more extensible than any image viewer. You can easily add key bindings, set up conditional profiles and do pretty much anything with scripts
* Zoomed images look better than in image viewers with less advanced scaling
* You can use quit-watch-later with directories of images
* You can browse directories with both videos and images in one application
* Background transparency
* It supports Wayland unlike sxiv or feh

## Usage

`positioning.lua` and `--video-recenter` have been upstreamed into mpv 0.40 (use https://github.com/guidocella/mpv-image-config/tree/931e71082f88ecb9afdd7728afb1ea9bc197c288 for mpv 0.39), so you just need to copy what you want to use from `mpv.conf` and `input.conf` into your versions of these files.

`scripts/image-bindings.lua` is an optional script with extra script bindings I didn't consider worth upstreaming: a simple gesture, deletion of the current file and oneshot double page mode.

## How can I display thumbnails of images?

Use [mpv-gallery-view](https://github.com/occivink/mpv-gallery-view)
