local luacv = require "luacv"

local image = luacv.load_image("files/test_2.png", "UNCHANGED")
print(image:get_size())
--image:release_image()
image:set_image_roi(100, 100, 100, 100)
--[
print(image:get_size())

image:save_image("files/222.png", {

	['PNG_COMPRESSION'] = 0,
})
--]]
