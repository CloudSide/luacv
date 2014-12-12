local cv = require("luacv")
local magick = require("magick")

--[
local mgck = magick.load_image("/Users/bruce/Desktop/4.gif")
mgck:set_first_iterator()
print(mgck:get_width(), mgck:get_height())
print(mgck:get_format())
--]]
mgck:set_format("png")
mgck:write("/Users/bruce/Desktop/4.png")

local cvimg = cv.load_image("/Users/bruce/Desktop/4.png" , 'UNCHANGED')
cvimg:set_image_roi(101, -10, 150, 100)
print(cvimg:get_size())
cvimg:save_image('/Users/bruce/Desktop/4.cv.png', {['PNG_COMPRESSION'] = 9})
cvimg:release_image()