local luacv = require "luacv"
local image = luacv.load_image("2M.PNG", "UNCHANGED")
print(image:get_size())
image:set_image_roi(100, 100, 100, 100)
print(image:get_size())
image:save_image("222.png", {
	['PNG_COMPRESSION'] = 0,
})
