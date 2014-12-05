local luacv = require "luacv"

--test load image
--[
local image = luacv.load_image("files/test_3.png", "ANYCOLOR")
--]]

--test image roi
--[[
image:set_image_roi(100, 100, 100, 100)
image:save_image("files/test_3_set_image_roi.png", {['PNG_COMPRESSION'] = 0})
--]]

--test draw line
--[[
image:line(10, 50, 90, 50, {255,255,255,0}, 10, 'CONNECTION_4')
image:save_image("files/test_3_line.png")
--]]

--test draw rectangle
--[[
image:rectangle(10, 50, 90, 90, {255,0,255,0}, -1, 'CONNECTION_4')
image:save_image("files/test_3_rectangle.png")
--]]

--test draw ellipse
--[[
image:ellipse(100, 200, 90, 90, 360, 0, 360, {255,0,255,0}, -1, 'CV_AA')
image:save_image("files/test_3_ellipse.png")
--]]

image:crop_for_scale()

image:release_image()