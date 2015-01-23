local ffi = require'ffi'
local magick = require "magick"
local magick_type = require 'magick_type'

local function printf(...)
	print(string.format(...))
end

local mt = magick_type.new("宋体-简")





--local text = ffi.cast("char *", "你好新浪云存储")
--
--mt:set_font(50, {255,0,0,255}, 0)
--
--mt:draw_text(text, -1, -1)
--
--local im = magick.constitute_image(mt.mt_image.im_w, mt.mt_image.im_h, "BGRA", "CharPixel", mt.mt_image.image_data)
--im:write("test_yui_2_bold.bmp")


local font_table = mt:unpack_font()

local key, val
for key,val in pairs(font_table) do
	print(key,"-")
	if type(val) == "table" then
		local key_style, val_index
		for key_style, val_index in pairs(val) do
			print("		", key_style,":",val_index)
		end
	end
	
end

mt:destroy()