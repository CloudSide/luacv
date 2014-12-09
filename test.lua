local luacv = require "luacv"

--test load image
--[
local image = luacv.load_image("files/test_0x11.png", "ANYCOLOR")
local faces = image:object_detect("haarcascade_frontalface_alt2.xml")
for i = 1, #faces, 1 do
	print(faces[i].x, faces[i].y, faces[i].width, faces[i].height)
end
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

--[[
local img = image:resize(100, 50, 'RESIZE_LIMIT')
img:save_image("files/test_resize.jpg")
--]]

--[[
local img = image:fill(1000, 50, 'FILL_DEFULT', 'GRAVITY_FACES')
--local img = image:fill(1000, 400)
print(img:get_size())
img:save_image("files/test_fill.jpg")
--]]

local src = luacv.load_image("files/test_1.jpg", "ANYCOLOR")
local img = image:overlay(src, 200, 200, 200, 200, 1)
img:save_image("files/test_overlay.jpg")

image:release_image()