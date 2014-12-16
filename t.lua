local cv = require("luacv")
local magick = require("magick")

local mgck = magick.load_image("files/tttt_1.gif")
print("原图: " .. mgck:get_format())
--[[
local mgck = magick.load_image("files/244__.gif")
mgck:set_first_iterator()
print(mgck:get_width(), mgck:get_height())
print(mgck:get_format())
--]]
mgck:set_first_iterator()
mgck:set_format("png")
mgck:write("files/tttt_2.png")
mgck:destroy()

local cvimg = cv.load_image("files/tttt_2.png" , 'UNCHANGED')
cvimg:set_image_roi(1, 1, 15, 10)
print(cvimg:get_size())
cvimg:save_image('files/tttt_3.png', {['PNG_COMPRESSION'] = 9})
cvimg:release_image()


--mgck:set_format("png")
--mgck:write("files/244_11111.gif")