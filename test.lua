local luacv = require "luacv"

--test load image
--[
local image = luacv.load_image("files/test_0x1.jpg", "UNCHANGED") --test_0x1.jpg

--[[
local faces = image:object_detect("haarcascade_frontalface_alt2.xml")
for i = 1, #faces, 1 do
	print(faces[i].x, faces[i].y, faces[i].width, faces[i].height)
end
--]]

--test image roi
--[[
image:set_image_roi(100, 100, 100, 100)
image:save_image("files/test_3_set_image_roi.jpg")
--]]

--test draw line
--[[
image:line(10, 50, 90, 50, {255,255,255,1}, 10, 'CONNECTION_4')
image:save_image("files/test_3_line.jpg")
--]]

--test draw rectangle
--[[
image:rectangle(10, 50, 90, 90, {255,0,255,0}, -1, 'CONNECTION_4')
image:save_image("files/test_3_rectangle.png")
--]]

--test draw ellipse
--[[
image:ellipse(image.cv_image.width/2, image.cv_image.height/2, image.cv_image.width/2, image.cv_image.height/2, 360, 0, 360, {255,0,255,0}, -1, 'CV_AA')
image:save_image("files/test_3_ellipse.png")
--]]

--[[
local img = image:resize(100, 50, 'RESIZE_LIMIT')
img:save_image("files/test_resize.jpg")
--]]

--[[
local img = image:fill(200, 200, 'FILL_DEFULT', 'GRAVITY_SOUTH_WEST')
print(img:get_size())
img:save_image("files/test_fill.jpg")
--]]

--[[
local img = image:thumb(250, 250, 'GRAVITY_FACE')
print(img:get_size())
img:save_image("files/test_thumb.jpg")
--]]

--[[
local img = image:crop(109000,100,250, 250)
print(img:get_size())
img:save_image("files/test_crop.jpg")
--]]

--[[
local img = image:pad(80, 800, 'PAD_LIMIT', nil, {255,0,255,1})
print(img:get_size())
img:save_image("files/test_pad.jpg")
--]]

--[
local img = image:round_corner(-100, {0,0,0,255})
img:save_image("files/test_round_corner.jpg")
--]]

--[[
local img = image:round_corner(-1)
local aa = img:background_color({0,255,0,255})
aa:save_image("files/test_round_corner.png")
--]]

--[[
local src = luacv.load_image("files/test_1.jpg", "ANYCOLOR")
local img = image:overlay(src, 200, 200, 200, 200, 1)
img:save_image("files/test_overlay.jpg")
--]]

image:release_image()