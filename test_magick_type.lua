local ffi = require'ffi'
local magick = require "magick"
local magick_type = require 'magick_type'



local mt = magick_type.new("楷体")

local text = ffi.cast("char *", "你好新浪云存储")

mt:set_font(50, {255,0,0,255}, 0)

--print(mt.font.font_color.r)
mt:draw_text(text, 45, -1)

local im = magick.constitute_image(mt.mt_image.im_w, mt.mt_image.im_h, "BGRA", "CharPixel", mt.mt_image.image_data)
im:write("test_yui.bmp")

mt:destroy()