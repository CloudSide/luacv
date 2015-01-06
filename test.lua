local luacv = require "luacv"
local magick = require "magick"


--local mgk = magick.load_image("files/yanshi_2.jpg")
local mgk = magick.load_image("files/5M.jpeg") --face-detection.png
local format = mgk:get_format():lower()  
if format == 'gif' then 
	mgk:set_first_iterator() 
	mgk:set_format('jpeg')
end

local w = mgk:get_width()
local h = mgk:get_height()
local image = luacv.create_image(w, h, 8, 4)                                                                                       
mgk:export_image_pixels(0, 0, w, h, 'BGRA', 'CharPixel', image:get_image_data()) 



--test load image
--[[
local image = luacv.load_image("files/yanshi.jpg", "UNCHANGED") --test_0x1.jpg

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
image:resize(100, 50)
image:save_image("files/test_resize.jpg")
--]]

--[[
image:fill(image.cv_image.width*0.99999, 640, 'FILL_DEFAULT', 'GRAVITY_FACES')
image:save_image("files/test_fill.jpg")
--]]

--[[
image:thumb(50, 50, 'GRAVITY_FACES')
image:save_image("files/test_thumb.jpg")
--]]

--[[
image:crop(1000, 400, 500, 100, nil)
image:save_image("files/test_crop.jpg")
--]]

--[[
image:pad(1000, 400, 'PAD_LIMIT', nil, {255,0,255,1})
image:save_image("files/test_pad2.jpg")
--]]

--[[
image:round_corner(400, {0,0,0,255})
image:save_image("files/test_round_corner.jpg")
--]]

--[[
local img = image:round_corner(-1)
local aa = img:background_color({0,255,0,255})
aa:save_image("files/test_round_corner.png")
--]]

--[
local src = luacv.load_image("files/alpha.png", 'UNCHANGED')
image:overlay(src, 100, -100, 300, 300, 0.6)
image:save_image("files/test_overlay.png")
--]]

image:release_image()