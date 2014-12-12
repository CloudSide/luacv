local luacv = require "luacv"
local image = luacv.load_image("files/244_111.gif.png", "GRAYSCALE")
image:save_image("files/test_face_" .. 1 .. ".png", {['PNG_COMPRESSION'] = 1})
image:release_image()