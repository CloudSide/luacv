local luacv = require "luacv"

local image = luacv.load_image("files/test_3.png", "ANYCOLOR")

image:set_image_roi(100, 100, 100, 100)
image:save_image("files/test_3_set_image_roi.png", {['PNG_COMPRESSION'] = 0})


image:line(10, 50, 90, 50, {255,255,255,0}, 10, 'CONNECTION_4')
image:save_image("files/test_3_line.png")

image:release_image()